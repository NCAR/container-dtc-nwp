# This script takes a WPS namelist and plots the domain
# Current limitations/areas to improve: 
#   - Mercator and Polar Stereographic a work in progress: Not supported!!
#   - Only supports up to three domains
#   - Would be nice to use f90nml for reading namelist
# This script is heavily based off code from:
# https://github.com/lucas-uw/WRF-tools/tree/master/WRF_input_tools

import cartopy
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import io
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import os

import DefineDomain

# Set MPLCONFIGDIR to be under /home dir (need comuser write permission)
os.environ[ 'MPLCONFIGDIR' ] = '/home/pythonprd/.config/matplotlib'

# Location and name of namelist.wps
WPSFile = '/home/scripts/case/namelist.wps'

wpsproj, latlonproj, corner_lat_full, corner_lon_full, length_x, length_y, ndomains = DefineDomain.calc_wps_domain_info(WPSFile)

fig1 = plt.figure(figsize=(6,4))
ax1 = plt.subplot(1, 1, 1, projection=wpsproj)

# d01
corner_x1, corner_y1 = DefineDomain.reproject_corners(corner_lon_full[0,:], corner_lat_full[0,:], wpsproj, latlonproj)
ax1.set_xlim([corner_x1[0]-length_x[0]/15, corner_x1[3]+length_x[0]/15])
ax1.set_ylim([corner_y1[0]-length_y[0]/15, corner_y1[3]+length_y[0]/15])

# d01 box
ax1.add_patch(matplotlib.patches.Rectangle((corner_x1[0], corner_y1[0]),  length_x[0], length_y[0], 
                                    fill=None, lw=2, edgecolor='black', zorder=2))
ax1.text(corner_x1[0]+length_x[0]*0.05, corner_y1[0]+length_y[0]*0.9, 'd01',
         fontweight='bold', size=10, color='black', zorder=2)

if ndomains==2:
    # d02 box
    corner_x2, corner_y2 = DefineDomain.reproject_corners(corner_lon_full[1,:], corner_lat_full[1,:], wpsproj, latlonproj)
    ax1.add_patch(matplotlib.patches.Rectangle((corner_x2[0], corner_y2[0]),  length_x[1], length_y[1], 
                                        fill=None, lw=2, edgecolor='black', zorder=2))
    ax1.text(corner_x2[0]+length_x[1]*0.05, corner_y2[0]+length_y[1]*1.1, 'd02',
             fontweight='bold', size=10, color='black', zorder=2)

if ndomains==3:
    # d03 box
    corner_x3, corner_y3 = DefineDomain.reproject_corners(corner_lon_full[2,:], corner_lat_full[2,:], wpsproj, latlonproj)
    ax1.add_patch(matplotlib.patches.Rectangle((corner_x3[0], corner_y3[0]),  length_x[2], length_y[2],
                                        fill=None, lw=2, edgecolor='red', zorder=2))
    ax1.text(corner_x3[0]+length_x[2]*0.05, corner_y3[0]+length_y[2]*0.9, 'd03', va='top', ha='left',
             fontweight='bold', size=15, color='red', zorder=2)


# Define where Cartopy Maps are located
CARTOPY_DIR = "/home/data"
cartopy.config['data_dir'] = CARTOPY_DIR
os.environ["CARTOPY_USER_BACKGROUNDS"] = CARTOPY_DIR

# map settings
states = cartopy.feature.NaturalEarthFeature(category='cultural', scale='50m', facecolor='none',
                             name='admin_1_states_provinces')
borders = cartopy.feature.NaturalEarthFeature(category='cultural', scale='50m', facecolor='none',
                             name='admin_0_countries')
lakes = cartopy.feature.NaturalEarthFeature('physical', 'lakes', scale='50m', facecolor='none')
coastlines = cartopy.feature.NaturalEarthFeature('physical', 'coastline', scale='50m', facecolor='none')

ax1.add_feature(states, linewidth=0.5,edgecolor='k')
ax1.add_feature(borders, linewidth=0.5,edgecolor='k')
ax1.add_feature(lakes, linewidth=0.5,edgecolor='k')
ax1.add_feature(coastlines, linewidth=0.5,edgecolor='k')

ax1.stock_img()

gl = ax1.gridlines(crs=ccrs.PlateCarree(), draw_labels=True, linestyle='--', x_inline=False, y_inline=False, alpha=1)
gl.top_labels = False
gl.bottom_labels = True
gl.left_labels = True
gl.right_labels = True
gl.xlocator = matplotlib.ticker.FixedLocator(np.arange(-180,180,10))
gl.ylocator = matplotlib.ticker.FixedLocator(np.arange(-90,90,10))
gl.xlabel_style = {'size': 6,'rotation': 45}
gl.ylabel_style = {'size': 6}

ax1.set_title('WRF domain setup', size=14)
fig1.savefig("WRF_domain.png")

