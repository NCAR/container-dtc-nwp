################################################################################
####  Python Script Documentation Block
#                      
# Script name:       	plot_CompRef.py
# Script description:  	Generates plots from WRF post processed grib2 output
#			over the CONUS
#
# Authors:  Ben Blake		Org: NOAA/NWS/NCEP/EMC		Date: 2020-05-07
#           David Wright 	Org: University of Michigan
#
# Notes: Modified for use in DTC NWP containers
#
# Instructions:		Make sure all the necessary modules can be imported.
#                       Five command line arguments are needed:
#                       1. Cycle date/time in YYYYMMDDHH format
#                       2. Forecast hour
#                       3. GRIB_FILE: Input GRIB file to be plotted
#                       4. CARTOPY_DIR: Base directory of cartopy shapefiles
#                          -Shapefiles cannot be directly downloaded to NOAA
#                            machines from the internet, so shapefiles need to
#                            be downloaded if geopolitical boundaries are
#                            desired on the maps.
#                          -File structure should be:
#                            CARTOPY_DIR/shapefiles/natural_earth/cultural/*.shp
#                       5. Domain (e.g., d01)
#           		To create plots for forecast hour 24 from 5/7 00Z cycle:
#                        python plot_allvars.py 2020050700 24 /path/to/expt_dirs
#                        /experiment/name /path/to/base/cartopy/maps d01 
#
################################################################################

#-------------Import modules --------------------------#
import pygrib
import cartopy.crs as ccrs
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
import cartopy.feature as cfeature
import matplotlib
matplotlib.use('Agg')
import io
import matplotlib.pyplot as plt
import dateutil.relativedelta, dateutil.parser
from PIL import Image
from matplotlib.gridspec import GridSpec
import numpy as np
import time,os,sys,multiprocessing
import multiprocessing.pool
from scipy import ndimage
from netCDF4 import Dataset
import pyproj
import argparse
import yaml
import cartopy

# Set MPLCONFIGDIR to be under /home dir (need comuser write permission)
os.environ[ 'MPLCONFIGDIR' ] = 'home/pythonprd/.config/matplotlib'

#--------------Define some functions ------------------#

def ndate(cdate,hours):
   if not isinstance(cdate, str):
     if isinstance(cdate, int):
       cdate=str(cdate)
     else:
       sys.exit('NDATE: Error - input cdate must be string or integer.  Exit!')
   if not isinstance(hours, int):
     if isinstance(hours, str):
       hours=int(hours)
     else:
       sys.exit('NDATE: Error - input delta hour must be a string or integer.  Exit!')

   indate=cdate.strip()
   hh=indate[8:10]
   yyyy=indate[0:4]
   mm=indate[4:6]
   dd=indate[6:8]
   #set date/time field
   parseme=(yyyy+' '+mm+' '+dd+' '+hh)
   datetime_cdate=dateutil.parser.parse(parseme)
   valid=datetime_cdate+dateutil.relativedelta.relativedelta(hours=+hours)
   vyyyy=str(valid.year)
   vm=str(valid.month).zfill(2)
   vd=str(valid.day).zfill(2)
   vh=str(valid.hour).zfill(2)
   return vyyyy+vm+vd+vh


def clear_plotables(ax,keep_ax_lst,fig):
  #### - step to clear off old plottables but leave the map info - ####
  if len(keep_ax_lst) == 0 :
    print("clear_plotables WARNING keep_ax_lst has length 0. Clearing ALL plottables including map info!")
  cur_ax_children = ax.get_children()[:]
  if len(cur_ax_children) > 0:
    for a in cur_ax_children:
      if a not in keep_ax_lst:
       # if the artist isn't part of the initial set up, remove it
        a.remove()


def compress_and_save(filename):
  #### - compress and save the image - ####
  ram = io.BytesIO()
  plt.savefig(ram, format='png', bbox_inches='tight', dpi=150)
  ram.seek(0)
  im = Image.open(ram)
  im2 = im.convert('RGB').convert('P', palette=Image.ADAPTIVE)
  im2.save(filename, format='PNG')


def rotate_wind(true_lat,lov_lon,earth_lons,uin,vin,proj,inverse=False):
  #  Rotate winds from LCC relative to earth relative (or vice-versa if inverse==true)
  #   This routine is vectorized and *should* work on any size 2D vg and ug arrays.
  #   Program will quit if dimensions are too large.
  #
  # Input args:
  #  true_lat = True latitidue for LCC projection (single value in degrees)
  #  lov_lon  = The LOV value from grib (e.g. - -95.0) (single value in degrees)
  #              Grib doc says: "Lov = orientation of the grid; i.e. the east longitude value of
  #                              the meridian which is parallel to the Y-axis (or columns of the grid)
  #                              along which latitude increases as the Y-coordinate increases (the
  #                              orientation longitude may or may not appear on a particular grid).
  #
  #  earth_lons = Earth relative longitudes (can be an array, in degrees)
  #  uin, vin     = Input winds to rotate
  #
  # Returns:
  #  uout, vout = Output, rotated winds
  #-----------------------------------------------------------------------------------------------------

  # Get size and length of input u winds, if not 2d, raise an error
  q=np.shape(uin)
  ndims=len(q)
  if ndims > 2:
    # Raise error and quit!
    raise SystemExit("Input winds for rotation have greater than 2 dimensions!")
  if lov_lon > 0.: lov_lon=lov_lon-360.
  dtr=np.pi/180.0             # Degrees to radians

  if not isinstance(inverse, bool):
    raise TypeError("**kwarg inverse must be of type bool.")

  # Compute rotation constant which is also
  # known as the Lambert cone constant.  In the case
  # of a polar stereographic projection, this is one.
  # See the following pdf for excellent documentation
  # http://www.dtcenter.org/met/users/docs/write_ups/velocity.pdf
  if proj.lower()=='lcc':
    rotcon_p=np.sin(true_lat*dtr)
  elif proj.lower() in ['stere','spstere', 'npstere']:
    rotcon_p=1.0
  else:
    raise SystemExit("Unsupported map projection: "+proj.lower()+" for wind rotation.")

  angles = rotcon_p*(earth_lons-lov_lon)*dtr
  sinx2 = np.sin(angles)
  cosx2 = np.cos(angles)

  # Steps below are elementwise products, not matrix mutliplies
  if inverse==False:
    # Return the earth relative winds
    uout = cosx2*uin+sinx2*vin
    vout =-sinx2*uin+cosx2*vin
  elif inverse==True:
    # Return the grid relative winds
    uout = cosx2*uin-sinx2*vin
    vout = sinx2*uin+cosx2*vin

  return uout,vout


#-------------Start of script -------------------------#

# Load environment variables within yaml file
#inf = open('env.yaml', 'r')
#envf= yaml.load(inf, Loader=yaml.SafeLoader)
#inf.close()

# Define required positional arguments
parser = argparse.ArgumentParser()
parser.add_argument("Cycle date/time in YYYYMMDDHH format")
parser.add_argument("Forecast hour in HH format")
parser.add_argument("Path to experiment base directory")
parser.add_argument("Path to base directory of cartopy shapefiles")
parser.add_argument("Domain in d** format")
args = parser.parse_args()
              
# Read date/time, forecast hour, and directory paths from command line
ymdh = str(sys.argv[1])
ymd = ymdh[0:8]
year = int(ymdh[0:4])
month = int(ymdh[4:6])
day = int(ymdh[6:8])
hour = int(ymdh[8:10])
cyc = str(hour).zfill(2)
print(year, month, day, hour)

fhr = int(sys.argv[2])
fhour = str(fhr).zfill(2)
print('fhour '+fhour)
itime = ymdh
vtime = ndate(itime,int(fhr))

GRIB_FILE = str(sys.argv[3])
CARTOPY_DIR = str(sys.argv[4])
domain = str(sys.argv[5])

# Specify plotting domains
domains=[domain]

# Open the input file, if it exists
if os.path.exists(GRIB_FILE):
    data1 = pygrib.open(GRIB_FILE)
else:
    sys.exit('Error - input file does not exist ('+GRIB_FILE+').  Exit!')

# Get the lats and lons
grids = [data1]
lats = []
lons = []
lats_shift = []
lons_shift = []

for data in grids:
    # Unshifted grid for contours and wind barbs
    lat, lon = data[1].latlons()
    lats.append(lat)
    lons.append(lon)

    # Shift grid for pcolormesh
    lat1 = data[1]['latitudeOfFirstGridPointInDegrees']
    lon1 = data[1]['longitudeOfFirstGridPointInDegrees']
    try:
        nx = data[1]['Nx']
        ny = data[1]['Ny']
    except:
        nx = data[1]['Ni']
        ny = data[1]['Nj']
    dx = data[1]['DxInMetres']
    dy = data[1]['DyInMetres']
    pj = pyproj.Proj(data[1].projparams)
    llcrnrx, llcrnry = pj(lon1,lat1)
    llcrnrx = llcrnrx - (dx/2.)
    llcrnry = llcrnry - (dy/2.)
    x = llcrnrx + dx*np.arange(nx)
    y = llcrnry + dy*np.arange(ny)
    x,y = np.meshgrid(x,y)
    lon, lat = pj(x, y, inverse=True)
    lats_shift.append(lat)
    lons_shift.append(lon)

# Unshifted lat/lon arrays grabbed directly using latlons() method
lat = lats[0]
lon = lons[0]

# Shifted lat/lon arrays for pcolormesh
lat_shift = lats_shift[0]
lon_shift = lons_shift[0]

Lat0 = data1[1]['LaDInDegrees']
Lon0 = data1[1]['LoVInDegrees']
print(Lat0)
print(Lon0)

###################################################
# Read in all variables and calculate differences #
###################################################
t1a = time.perf_counter()

# Composite reflectivity
refc = data1.select(name='Maximum/Composite radar reflectivity')[0].values

t2a = time.perf_counter()
t3a = round(t2a-t1a, 3)
print(("%.3f seconds to read all messages") % t3a)


########################################
#    START PLOTTING FOR EACH DOMAIN    #
########################################

def main():

  # Number of processes must coincide with the number of domains to plot
  pool = multiprocessing.Pool(len(domains))
  pool.map(plot_all,domains)

def plot_all(dom):

  t1dom = time.perf_counter()
  print(('Working on '+dom))

  # Map corners for each domain
  llcrnrlon = np.min(lon)
  llcrnrlat = np.min(lat)
  urcrnrlon = np.max(lon)
  urcrnrlat = np.max(lat)
  lat_0 = Lat0
  lon_0 = Lon0
  extent=[llcrnrlon,urcrnrlon,llcrnrlat,urcrnrlat]

  # create figure and axes instances
  fig = plt.figure(figsize=(10,10))

  # Define where Cartopy Maps are located    
  cartopy.config['data_dir'] = CARTOPY_DIR
  os.environ["CARTOPY_USER_BACKGROUNDS"]=CARTOPY_DIR+'/raster_files'

  back_res='50m'
  back_img='off'

  # set up the map background with cartopy
  myproj=ccrs.LambertConformal(central_longitude=lon_0, central_latitude=lat_0, false_easting=0.0,
                          false_northing=0.0, secant_latitudes=None, standard_parallels=None,
                          globe=None)
  ax = plt.axes(projection=myproj)
  ax.set_extent(extent)

  fline_wd = 0.5  # line width
  falpha = 0.3    # transparency

  # natural_earth
#  land=cfeature.NaturalEarthFeature('physical','land',back_res,
#                    edgecolor='face',facecolor=cfeature.COLORS['land'],
#                    alpha=falpha)
  lakes=cfeature.NaturalEarthFeature('physical','lakes',back_res,
                    edgecolor='blue',facecolor='none',
                    linewidth=fline_wd,alpha=falpha)
  coastline=cfeature.NaturalEarthFeature('physical','coastline',
                    back_res,edgecolor='blue',facecolor='none',
                    linewidth=fline_wd,alpha=falpha)
  states=cfeature.NaturalEarthFeature('cultural','admin_1_states_provinces',
                    back_res,edgecolor='black',facecolor='none',
                    linewidth=fline_wd,linestyle=':',alpha=falpha)
  borders=cfeature.NaturalEarthFeature('cultural','admin_0_countries',
                    back_res,edgecolor='red',facecolor='none',
                    linewidth=fline_wd,alpha=falpha)


  # high-resolution background images
  if back_img=='on':
    ax.background_img(name='NE', resolution='high')

#  ax.add_feature(land)
  ax.add_feature(lakes)
  ax.add_feature(states)
  ax.add_feature(borders)
  ax.add_feature(coastline)

  # All lat lons are earth relative, so setup the associated projection correct for that data
  transform = ccrs.PlateCarree()
 
  # Map/figure has been set up here, save axes instances for use again later
  keep_ax_lst = ax.get_children()[:]

#################################
  # Plot composite reflectivity
#################################
  if (fhr > 0):         # Do not make composite reflectivity plot for forecast hour 0
    t1 = time.perf_counter()
    print(('Working on composite reflectivity for '+dom))

    units = 'dBZ'
    clevs = np.linspace(5,70,14)
    clevsdif = [20,1000]
    colorlist = ['turquoise','dodgerblue','mediumblue','lime','limegreen','green','#EEEE00','#EEC900','darkorange','red','firebrick','darkred','fuchsia']
    cm = matplotlib.colors.ListedColormap(colorlist)
    norm = matplotlib.colors.BoundaryNorm(clevs, cm.N)

    cs_1 = plt.pcolormesh(lon_shift,lat_shift,refc,transform=transform,cmap=cm,norm=norm)
    cs_1.cmap.set_under('white',alpha=0.)
    cs_1.cmap.set_over('black')
    cbar1 = plt.colorbar(cs_1,orientation='horizontal',pad=0.05,shrink=0.6,ticks=clevs,extend='max')
    cbar1.set_label(units,fontsize=8)
    cbar1.ax.tick_params(labelsize=8)
    ax.text(.5,1.03,'WRF Composite Reflectivity ('+units+') \n initialized: '+itime+' valid: '+vtime + ' (f'+fhour+')',horizontalalignment='center',fontsize=8,transform=ax.transAxes,bbox=dict(facecolor='white',alpha=0.85,boxstyle='square,pad=0.2'))

    compress_and_save('refc_'+dom+'_f'+fhour+'.png')
    t2 = time.perf_counter()
    t3 = round(t2-t1, 3)
    print(('%.3f seconds to plot composite reflectivity for: '+dom) % t3)

  plt.clf()

######################################################

main()

