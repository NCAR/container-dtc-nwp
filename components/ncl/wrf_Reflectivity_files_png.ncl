
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin
;
; Make a list of all files we are interested in
; DATADir = "/wrfprd/"
  DATADir = "./"
  FILES = systemfunc (" ls -1 " + DATADir + "wrfout_d01* ")
  numFILES = dimsizes(FILES)
  print("numFILES = " + numFILES)
  print(FILES)
  print (" ")

; We generate plots, but what kind do we prefer?
;  type = "x11"
; type = "pdf"
; type = "ps"
 type = "png"
; type = "ncgm"
  wks = gsn_open_wks(type,"plt_dbz1")
  gsn_define_colormap(wks,"WhViBlGrYeOrReWh")       ; Overwrite the standard color map

; Set some basic resources
  res = True
  res@MainTitle                   = "REAL-TIME WRF"
  res@Footer = False

  pltres = True
  mpres = True


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  a = addfiles(FILES+".nc","r")

  times = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)         ; number of times in the file


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  do it = 1,ntimes-1               ; TIME LOOP
 
     print("Working on time: " + times(it) )
     res@TimeLabel = times(it)   ; Set Valid time to use on plots


; First get the variables we will need        
; Both dbz and mdbz will be calculated using constant intercept parameters
; (as in early Reisner-2), with values of 8x10^6, 2x10^7, and 4x10^6 m^-4,
; for rain, snow, and graupel, respectively.

    ;mdbz = wrf_user_getvar(a,"mdbz",it) 
    ;dbz = wrf_user_getvar(a,"dbz",it) 
     refl = wrf_user_getvar(a,"REFL_10CM",it)

     opts = res                         
     opts@cnFillOn = True  
     opts@ContourParameters = (/ 5., 75., 5./)
     contour = wrf_contour(a[it],wks,refl(1,:,:),opts)     ; plot only lowest level
     plot = wrf_map_overlays(a[it],wks,(/contour/),pltres,mpres)
 
    ;contour = wrf_contour(a,wks,mdbz,opts)
    ;plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
 

   end do        ; END OF TIME LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end
