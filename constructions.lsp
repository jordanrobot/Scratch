;	Constructions v0.4.45
;	-A scratchpad layer utility for Autocad
;
;	Tested on Autocad 2008-2010
;	Should be compatible with v2007
;
;	Copyright (c) 2009 Matthew D. Jordan :  http://scenic-shop.com
;	This file is provided "as is" by the author.
;    The authorship and url must remain with the copied function. 


;#######################################
;###   Temoporary Layer Properties   ###
;#######################################

;layer name
(setq cst_lay "constructions")
;layer color
(setq cst_laycol "magenta")
;lineweight
(setq cst_laylwt "0.1")
; cst's crosshair color -> default is magenta (OLE color code)
(vl-bb-set 'cst_crosshair "16711935")


;###############################
;###   Load required stuff   ###
;###############################

;load misc stuff
(vl-load-com)
(setvar "cmdecho" 0)


; if needed- this backs up the users' colors to the blackboard namespace, which means it will be
; accessable from any open drawings within an Autocad session.

(defun cst_backupcol ( / model_color layout_color pref_pointer )
	
	;set initial crosshair color settings
	(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))

	;save old crosshair colors
	(setq model_color (vla-get-ModelCrosshairColor pref_pointer))
	(setq model_color (vlax-make-variant model_color vlax-vblong))
	(setq model_color (vlax-variant-value model_color))

	(setq layout_color (vla-get-LayoutCrosshairColor pref_pointer))
	(setq layout_color (vlax-make-variant layout_color vlax-vblong))
	(setq layout_color (vlax-variant-value layout_color))

	(vl-bb-set 'cst_model_color model_color)
	(vl-bb-set 'cst_layout_color layout_color)

	(vlax-release-object pref_pointer)
)

(defun cst_resetcol ()
	
	)

;if user crosshair colors are not backed up: then back them up!
(if (eq (vl-bb-ref 'cst_model_color) nil)
	(if (eq (vl-bb-ref 'cst_model_color) 16711935)
		(cst_backupcol)
		(cst_resetcol)
		)
	)


; thar be dragons below!  don't know why, but there are
;(if (tblsearch "LAYER" cst_lay)
;if cst_lay is current, then set crosshair to magenta, if not, set to default
;	(if (= (getvar "clayer") cst_lay)
;		(cst_crosshair_on)
;		)
;	(cst_crosshair_off)
;	)


;The big CST command: decision logic.  Calls other functions based on state of various things.
(defun c:cst()
	(if 
		;if the layer constructions exists...
		(tblsearch "LAYER" cst_lay)
		; & if constructions is the current layer... jump out, else jump in
		(if (= cst_lay (getvar "clayer"))
			(cst_jumpout)
			(cst_jumpin)
			)
		;(back to the first if), no constructions layer?, then create it!
		(cst_make)
		)
	(princ)
	)


;The bid DST command: decision logic.  Deletes the cst layer if it exists.
(defun c:dst()
	;abort if the constructions layer is not present
	(if (not (tblsearch "LAYER" cst_lay)) (quit))
	(cst_jumpout)
	(cst_delete)
	)


(defun cst_jumpin()
	;get current layer -> save for later
	(setq cst_origlay (getvar "clayer"))
	;change to the layer
	(setvar "clayer" cst_lay)
	;turn crosshair color on
	(cst_crosshair_on)
	)


(defun cst_jumpout()
	;change current layer back to original
	(setvar "clayer" cst_origlay)
	;turn off crosshair color
	(cst_crosshair_off)
	)


(defun cst_make()
	;Get current layer -> save for later
	(if (tblsearch "LAYER" "constructions") () (setq cst_origlay (getvar "clayer")))
	;Create the cst_lay
	(command "_.layer" "make" cst_lay "color" cst_laycol "" "ON" "" "Ltype" "" "" "Plot" "No" "" "LWeight" cst_laylwt "" "")
	;turn crosshair color on
	(cst_crosshair_on)
	)


(defun cst_delete()
	(cst_jumpout)
	(command "_laydel" "n" cst_lay "" "yes")
	)


;crosshair color on
(defun cst_crosshair_on()
	(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))
	;set mouse color (layout) to cst_crosshair
	(vla-put-layoutcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_crosshair) vlax-vblong))
	;set mouse color (modelspace) to cst_crosshair
	(vla-put-modelcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_crosshair) vlax-vblong))
	;clean up stuff
	(vlax-release-object pref_pointer)
	)

;crosshair color off
(defun cst_crosshair_off()
	(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))
	;set mouse color (layout) to original color
	(vla-put-layoutcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_layout_color) vlax-vblong))
	;set mouse color (modelspace) to original color
	(vla-put-modelcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_model_color) vlax-vblong))
	;clean up stuff
	(vlax-release-object pref_pointer)
	)

	
;	(if (vlax-make-variant (vla-get-ModelCrosshairColor pref_pointer) vlax-vblong) (vlax-make-variant 16777215 vlax-vblong)
		
;		)
	

;error handing - cleans up if things go awry
(defun *error* (msg)
	(setvar "cmdecho" 1)
	(if (eq cst_origlay (or cst_lay nil))
		(setvar "clayer" cst_origlay)
		)
	(cst_crosshair_off)
	(princ msg)
	(princ)
	)