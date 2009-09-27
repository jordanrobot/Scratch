;	Constructions v0.2.32
;	-A layer multitasker for Autocad
;
;	Copyright (c) 2009 Matthew D. Jordan
;	GPLv3 license


;define the "jump-to" layer
(setq jump_to_layer "constructions")	
(setq cst_crosshair_color 111111)


;load required stuff
(vl-load-com)

;error handing - cleans up if things go awry
(defun *error* (msg)
	(setvar "cmdecho" 0)
;	(setvar "clayer" original_layer)
	(princ msg)
	(princ)
)

(defun jump_in()
	;get current echo state and current layer -> save for later
	(setq original_layer (getvar "clayer"))
	;Create/change the layer
	(command "_.layer" "make" jump_to_layer "color" "Magenta" "" "ON" "" "Ltype" "" "" "Plot" "No" "" "LWeight" "0.1" "" "")
	(princ)
	)

(defun jump_out()
	;this "if" ensures that you don't get stuck in the jump_to_layer
	(if (= original_layer jump_to_layer) (setq original_layer "0"))
	(setvar "clayer" original_layer)
	(princ)
	)

(defun c:cst()
	(if (= (getvar "clayer") jump_to_layer) (jump_out) (jump_in))
	(princ)
	)

; destroy jump_to_layer
(defun c:dst ()
	;the if ensures that you don't accidentally try to nuke the current layer.
	(if (= (getvar "clayer") jump_to_layer) (setvar "clayer" original_layer))
	(command "_laydel" "_n" jump_to_layer "" "yes")
	(princ)
	)

;change crosshairs to different color
(defun c:crosshair_color()
	(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))

	;save old crosshair colors
	(setq old_model_color (vla-get-ModelCrosshairColor pref_pointer))
	(setq old_layout_color (vla-get-LayoutCrosshairColor pref_pointer))

	;set mouse color (layout) to...
	(vla-put-layoutcrosshaircolor pref_pointer
		(vlax-make-variant cst_crosshair_color vlax-vblong)
	)

	;set mouse color (modelspace) to...
	(vla-put-modelcrosshaircolor pref_pointer
		(vlax-make-variant cst_crosshair_color vlax-vblong)
	)

	;clean up
	(vlax-release-object pref_pointer)
	(princ)
	)