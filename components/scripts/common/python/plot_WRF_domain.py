import numpy as np

import matplotlib
import matplotlib.pyplot as plt
import cartopy
import cartopy.crs as ccrs
import cartopy.feature as cfeature

import WRFDomainLib


WPSFile = 'DemoData/namelist.wps.ps'

wpsproj, latlonproj, corner_lat_full, corner_lon_full, length_x, length_y, ndomains = WRFDomainLib.calc_wps_domain_info(WPSFile)

cmap = matplotlib.cm.terrain

fig1 = plt.figure(figsize=(6,4))
ax1 = plt.subplot(1, 1, 1, projection=wpsproj)

# d01
corner_x1, corner_y1 = WRFDomainLib.reproject_corners(corner_lon_full[0,:], corner_lat_full[0,:], wpsproj, latlonproj)
ax1.set_xlim([corner_x1[0]-length_x[0]/15, corner_x1[3]+length_x[0]/15])
ax1.set_ylim([corner_y1[0]-length_y[0]/15, corner_y1[3]+length_y[0]/15])

# d01 box
ax1.add_patch(matplotlib.patches.Rectangle((corner_x1[0], corner_y1[0]),  length_x[0], length_y[0], 
                                    fill=None, lw=2, edgecolor='black', zorder=2))
ax1.text(corner_x1[0]+length_x[0]*0.05, corner_y1[0]+length_y[0]*0.9, 'd01',
         fontweight='bold', size=10, color='black', zorder=2)

if ndomains==2:
    # d02 box
    corner_x2, corner_y2 = WRFDomainLib.reproject_corners(corner_lon_full[1,:], corner_lat_full[1,:], wpsproj, latlonproj)
    ax1.add_patch(matplotlib.patches.Rectangle((corner_x2[0], corner_y2[0]),  length_x[1], length_y[1], 
                                        fill=None, lw=2, edgecolor='black', zorder=2))
    ax1.text(corner_x2[0]+length_x[1]*0.05, corner_y2[0]+length_y[1]*1.1, 'd02',
             fontweight='bold', size=10, color='black', zorder=2)

if ndomains==3:
    # d03 box
    corner_x3, corner_y3 = WRFDomainLib.reproject_corners(corner_lon_full[2,:], corner_lat_full[2,:], wpsproj, latlonproj)
    ax1.add_patch(matplotlib.patches.Rectangle((corner_x3[0], corner_y3[0]),  length_x[2], length_y[2],
                                        fill=None, lw=2, edgecolor='red', zorder=2))
    ax1.text(corner_x3[0]+length_x[2]*0.05, corner_y3[0]+length_y[2]*0.9, 'd03', va='top', ha='left',
             fontweight='bold', size=15, color='red', zorder=2)


# map settings
#ax1.coastlines('50m', linewidth=0.8)
#ax1.add_feature(cartopy.feature.OCEAN, edgecolor='k', facecolor='lightblue')
#ax1.add_feature(cartopy.feature.LAKES, edgecolor='k', facecolor='lightblue')
#ax1.add_feature(cartopy.feature.LAND, edgecolor='k', facecolor='limegreen')

states = cartopy.feature.NaturalEarthFeature(category='cultural', scale='50m', facecolor='none',
                             name='admin_1_states_provinces_shp')
borders = cartopy.feature.NaturalEarthFeature(category='cultural', scale='50m', facecolor='none',
                             name='admin_0_countries')
lakes= cartopy.feature.NaturalEarthFeature('physical','lakes', scale='50m', facecolor='none',
                             edgecolor='k')
ax1.add_feature(states, linewidth=0.5,edgecolor='k')
ax1.add_feature(borders, linewidth=0.5,edgecolor='k')
ax1.add_feature(lakes, linewidth=0.5,edgecolor='k')

ax1.stock_img()


#gl = ax1.gridlines(crs=ccrs.PlateCarree(), draw_labels=True, linestyle='--', alpha=1)
#gl.top_labels = False
#gl.bottom_labels = False
#gl.left_labels = True
#gl.right_labels = True
#gl.xlocator = matplotlib.ticker.FixedLocator(np.arange(-180,-49,10))
#gl.ylocator = matplotlib.ticker.FixedLocator(np.arange(0,81,10))
#gl.xlabel_style = {'size': 6}
#gl.ylabel_style = {'size': 6}

ax1.set_title('WRF domain setup', size=14)
#plt.show()
fig1.savefig('WRF_test_domain.png')
