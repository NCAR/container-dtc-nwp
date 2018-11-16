
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin
;
; Make a list of all files we are interested in
  DATADir = "/wrfprd/"
  PLTDir = "/nclprd/"
  domains = (/"d01"/)
  ndoms   = dimsizes(domains)

do id = 0,ndoms-1

  FILES = systemfunc (" ls -1 " + DATADir + "wrfout_"+domains(id)+"*" )
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
  wks = gsn_open_wks(type,PLTDir + "plt_Surface_multi_"+domains(id)+"_")

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

  slp = wrf_user_getvar(a,"slp",-1)    ; slp
    wrf_smooth_2d( slp, 3 )            ; smooth slp
  tc = wrf_user_getvar(a,"tc",-1)      ; 3D tc 
  u  = wrf_user_getvar(a,"ua",-1)      ; 3D U at mass points
  v  = wrf_user_getvar(a,"va",-1)      ; 3D V at mass points
  td2 =  wrf_user_getvar(a,"td2",-1)   ; Td2 in C
  tc2 = wrf_user_getvar(a,"T2",-1)     ; T2 in Kelvin
     tc2 = tc2-273.16                  ; T2 in C
  u10 = wrf_user_getvar(a,"U10",-1)    ; u at 10 m, mass point
  v10 = wrf_user_getvar(a,"V10",-1)    ; v at 10 m, mass point

  tf2 = 1.8*tc2+32.                    ; Turn temperature into Fahrenheit
    tf2@description = "Surface Temperature"
    tf2@units = "F"
  u10 = u10*1.94386                    ; Turn wind into knots
  v10 = v10*1.94386
    u10@units = "kts"
    v10@units = "kts"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  do it = 0,ntimes-1,1             ; TIME LOOP

    print("Working on time: " + times(it) )
    res@TimeLabel = times(it)   ; Set Valid time to use on plots

    ; Plotting options for T                
      opts = res                         
      opts@cnFillOn = True  
      opts@ContourParameters = (/ 75.,100., 2./)
      opts@gsnSpreadColorEnd = -3  ; End third from the last color in color map
      contour_tc = wrf_contour(a[it],wks,tf2(it,:,:),opts)
      delete(opts)


    ; Plotting options for SLP                     
      opts = res         
      opts@cnLineColor = "Blue"
      opts@cnHighLabelsOn = True
      opts@cnLowLabelsOn = True
      opts@ContourParameters = (/ 900., 1100., 4. /)
      opts@cnLineLabelBackgroundColor = -1
      opts@gsnContourLineThicknessesScale = 2.0
      contour_psl = wrf_contour(a[it],wks,slp(it,:,:),opts)
      delete(opts)

    ; Plotting options for Wind Vectors                 
      opts = res         
      opts@FieldTitle = "Wind"       ; overwrite Field Title
      opts@NumVectors = 30           ; density of wind barbs
      vector = wrf_vector(a[it],wks,u10(it,:,:),v10(it,:,:),opts)
      delete(opts)
  

    ; MAKE PLOTS                                       
      plot = wrf_map_overlays(a[it],wks,(/contour_tc,contour_psl,vector/),pltres,mpres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  end do        ; END OF TIME LOOP

delete(slp)
delete(tc)
delete(u)
delete(v)
delete(td2)
delete(tc2)
delete(u10)
delete(v10)
delete(tf2)

end do ; end of domain loop

end
