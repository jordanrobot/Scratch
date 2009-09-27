;	Constructions v0.2.12
;	-A layer multitasker for Autocad
;
;	Copyright (c) 2009 Matthew D. Jordan
;	GPLv3 license


;define the "jump-to" layer
(setq jump_to_layer "constructions")	


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

;TODO?: Destroy constructions
; (maybe this stuff isn't such a good idea, prolly just cruft)
; idea was to give a reminder before deleting something you'd forgotten about
	;toggle layerisolate mode to Off
	;isolate the constructions layer
	;save zoom state
	;zoom to extents
	;ask user for easy confirmation (N to stop or similar)
	;if yes -> select all objects, erase
	;if no -> don't
	;zoom back to saved state
	;unisolate the constructions layer
	;toggle layerisolate mode to Fade