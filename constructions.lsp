;	Constructions v0.4.0
;	-A temporary layer multitasker for Autocad
;
;	Copyright (c) 2009 Matthew D. Jordan :  http://scenic-shop.com
;	This file is provided "as is" by the author.
;    The authorship and url must remain with the copied function. 


; define the "jump-to" layer
(setq cst_lay "constructions")


; set the crosshair color
(setq cst_crosshair 16711935) ; magenta
(setq model_crosshair_color 16777215)
(setq layout_crosshair_color 0)


;load misc stuff
(vl-load-com)
(setvar "cmdecho" 0)


;todo => better dynamic color switcher!

;;;old color code: gets the current colors, and saves them for later.  Now this is buggy when 
;;; the cursor is magenta, and you switch to another drawing.  The variables seem to be local
;;; to each drawing.  I'm sure there's a way around this without forcing a black/white cursor
;;; on the user.


;set initial crosshair color settings
;(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))
;save old crosshair colors
;(setq old_model_color (vla-get-ModelCrosshairColor pref_pointer))
;(setq old_layout_color (vla-get-LayoutCrosshairColor pref_pointer))
;(vlax-release-object pref_pointer)


;creates & switches layers - wrapper logic
(defun c:cst()
	(setvar "cmdecho" 0)
	(if 
		;if the layer constructions exists...
		(tblsearch "LAYER" cst_lay)
		; then if constructions is the current layer... jump out, else jump in
		(if (= cst_lay (getvar "clayer"))
			(cst_jumpout)
			(cst_jumpin)
			)
		;back to the first if, (no constructions layer?, then create it!)
		(cst_make)
		)
	(princ)
	)


;delete the cst_layer
(defun c:dst()
	(setvar "cmdecho" 0)
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
	(command "_.layer" "make" cst_lay "color" "Magenta" "" "ON" "" "Ltype" "" "" "Plot" "No" "" "LWeight" "0.1" "" "")
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
	(vla-put-layoutcrosshaircolor pref_pointer (vlax-make-variant cst_crosshair vlax-vblong))
	;set mouse color (modelspace) to cst_crosshair
	(vla-put-modelcrosshaircolor pref_pointer (vlax-make-variant cst_crosshair vlax-vblong))
	;clean up stuff
	(vlax-release-object pref_pointer)
	)


;crosshair color off
(defun cst_crosshair_off()
	(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))
	;set mouse color (layout) to cst_crosshair
	(vla-put-layoutcrosshaircolor pref_pointer (vlax-make-variant layout_crosshair_color vlax-vblong))
	;set mouse color (modelspace) to cst_crosshair
	(vla-put-modelcrosshaircolor pref_pointer (vlax-make-variant model_crosshair_color vlax-vblong))
	;clean up stuff
	(vlax-release-object pref_pointer)
	)

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