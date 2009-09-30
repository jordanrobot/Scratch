;	Constructions v0.3.58
;	-A temporary layer multitasker for Autocad
;
;	Copyright (c) 2009 Matthew D. Jordan :  http://scenic-shop.com
;	This file is provided "as is" by the author.
;    The authorship and url must remain with the copied function. 

; define the "jump-to" layer
(setq cst_lay "constructions")	
; set the crosshair color
(setq cst_crosshair 16711935)
(setq model_crosshair_color 16777215)
(setq layout_crosshair_color 1)

;load misc stuff
(vl-load-com)
(setvar "cmdecho" 0)


;set initial crosshair color settings
;(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))
;save old crosshair colors
;(setq old_model_color (vla-get-ModelCrosshairColor pref_pointer))
;(setq old_layout_color (vla-get-LayoutCrosshairColor pref_pointer))
;(vlax-release-object pref_pointer)


;logic wrapper for cst_lay creation & switching
(defun c:cst()
	(if 
		;if the layer constructions exists...
		(tblsearch "LAYER" "constructions")
		; then if constructions is the current layer... jump out, else jump in
		(if (= cst_lay (getvar "clayer"))
			(cst_jumpout)
			(cst_jumpin)
			)
		;back to the first if, (no constructions layer, then create it!)
		(cst_make)
		)
	(princ)
	)

;logic wrapper for cst_lay clean
(defun c:dst()
	(if (tblsearch "LAYER" "constructions") (cst_clean) ())
	(princ)
	)

(defun c:fst()

	;if no cst_lay, 
	(cst_menu)
	(princ)
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
	(cst_clean)
	(command "_laydel" "n" cst_lay "" "yes")
;	(command "-purge" "layer" cst_lay "yes" "")
	)

(defun cst_getall()
	(sssetfirst nil (ssget "X" (list (cons 8 cst_lay))))
	)


(defun cst_clean( / mySet)
	(cst_jumpout)
	(if (setq mySet(ssget "X" (list (cons 8 cst_lay))))
		(command "_erase" mySet "")
		)
	)

;(defun cst_isolate()
;)

;(defun cst_off()
;turn off
;if in, jump out
;)

(defun cst_menu()
	(cst_delete)
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
	(princ)
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
	(princ)
	)

;error handing - cleans up if things go awry
(defun *error* (msg)
	(setvar "cmdecho" 1)
	(cst_crosshair_off)
	(setvar "clayer" cst_origlay)
	(princ msg)
	(princ)
	)