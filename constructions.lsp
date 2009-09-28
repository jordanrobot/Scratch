;	Constructions v0.3.0
;	-A layer multitasker for Autocad
;
;	Copyright (c) 2009 Matthew D. Jordan
;	GPLv3 license


; define the "jump-to" layer
(setq jump_to_layer "constructions")	
; set the crosshair color
(setq cst_crosshair_color 11111111)


;load misc stuff
(vl-load-com)
(setq init_flag 0)
(setvar "cmdecho" 0)

;set initial crosshair color settings
(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))
;save old crosshair colors
(setq old_model_color (vla-get-ModelCrosshairColor pref_pointer)))
(setq old_layout_color (vla-get-LayoutCrosshairColor pref_pointer)))
(vlax-release-object pref_pointer)


;logic wrapper for jump_to_layer creation & switching
(defun c:cst()
	(if 
		(= init_flag 0)
		(cst_make)
		(if (= jump_to_layer (getvar "clayer")) (jump_out) (jump_in))
		)
	(princ)
	)

;logic wrapper for jump_to_layer destruction
(defun c:dst()
	(if (= init_flag 0) () (cst_delete))
	(princ)
	)

(defun jump_in()
	;get current layer -> save for later
	(setq original_layer (getvar "clayer"))
	;change to the layer
	(setvar "clayer" jump_to_layer)
	;turn crosshair color on
	(cst_crosshair_on)
	)

(defun jump_out()
	;change current layer back to original
	(setvar "clayer" original_layer)
	;turn off crosshair color
	(cst_crosshair_off)
	)

(defun cst_make()
	;Get current layer -> save for later
	(setq original_layer (getvar "clayer"))
	;Create the jump_to_layer
	(command "_.layer" "make" jump_to_layer "color" "Magenta" "" "ON" "" "Ltype" "" "" "Plot" "No" "" "LWeight" "0.1" "" "")
	;init_flag is used for decisions
	(setq init_flag 1)
	;turn crosshair color on
	(cst_crosshair_on)
	)

(defun cst_delete()
	(jump_out)
	;delete jump_to_layer
	(command "_laydel" "_n" jump_to_layer "" "yes")
	;init_flag is used for decisions
	(setq init_flag 0)
	)

;crosshair color on
(defun cst_crosshair_on()
	(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))
	;set mouse color (layout) to cst_crosshair_color
	(vla-put-layoutcrosshaircolor pref_pointer (vlax-make-variant cst_crosshair_color vlax-vblong))
	;set mouse color (modelspace) to cst_crosshair_color
	(vla-put-modelcrosshaircolor pref_pointer (vlax-make-variant cst_crosshair_color vlax-vblong))
	;clean up stuff
	(vlax-release-object pref_pointer)
	(princ)
)

;crosshair color on
(defun cst_crosshair_off()
	(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))
	;set mouse color (layout) to cst_crosshair_color
	(vla-put-layoutcrosshaircolor pref_pointer (vlax-make-variant old_layout_color vlax-vblong))
	;set mouse color (modelspace) to cst_crosshair_color
	(vla-put-modelcrosshaircolor pref_pointer (vlax-make-variant old_model_color vlax-vblong))
	;clean up stuff
	(vlax-release-object pref_pointer)
	(princ)
	)

;error handing - cleans up if things go awry
(defun *error* (msg)
	(setvar "cmdecho" 1)
	(cst_crosshair_off)
	(setvar "clayer" original_layer)
	(princ msg)
	(princ)
	)