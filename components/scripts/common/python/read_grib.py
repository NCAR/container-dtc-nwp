#-------------Import modules --------------------------#
import pygrib

keysinfile = []
varsinfile = []

# Open the grib2 file using pygrib
# This object (gribfile) here is an iterator, a special Python object
gribfile = pygrib.open('/home/postprd/wrfprs_d01.03')

# Use the iterator to print information about each grib message object
for i in gribfile:
  # Print the grib record
  #print(i)

  # Loop over each metadata item associated with each grib record
  # Grib record = i, metadata item = k
  for k in i.keys():
    if not k in keysinfile:
        keysinfile.append(k)
    if k=='name':
        #print("KEY = "+k)
        if getattr(i,k) in varsinfile:
            continue
        else:
            varsinfile.append(getattr(i,k))
        #print(getattr(i,k))    if k=='latLonValues':
        
print(varsinfile)
