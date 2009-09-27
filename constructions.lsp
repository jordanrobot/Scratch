;	Constructions v0.1.11
;	-An AutoCAD layer multitasker
;
;	Copyright (c) 2009 Matthew D. Jordan
;	MIT license (see bottom of file for boring license text).
;
;
;	This script creates ojbects in a pre-specified layer, then
; 	jumps back to the original layer after the object is created.
;
;	You can change the "jump-to" layer in the first line of code.
;
;	Built-in Layer Jump! commands
;		x2 = draw xlines in "jump-to" layer
;		ra2 = draw rays in "jump-to" layer
;
;	Its simple to edit/create your own "layer-jump" command wrappers
;	at the bottom of the file
;
;TODO: add in a clear layer-jump layer function (perhaps with layerisolate and select all?)
; maybe makes use of a pause after object selection that asks if user wants to proceed.
;
;Todo: add in a popd & pushd functionality that works with constructions layer.



;define the "jump-to" layer, default is "constructions"
(setq jump_to_layer "constructions")

;error handing - cleans up if things go awry
(defun *error* (msg)
	(setvar "cmdecho" 0)
	(command "_.layer" "set" jump_from_layer "")
	(setvar "clayer" jump_from_layer)
	(setvar "cmdecho" current_echo)
	(princ msg)
	(princ)
)

;the layer jump logic
(defun layer_jump(command_to_run)
	;get current echo state and current layer -> save for later
	(setq current_echo (getvar "cmdecho"))
	(setq jump_from_layer (getvar "clayer"))

	;turn off echo
	(setvar "cmdecho" 0)

	;Create/change the layer and turn off command echo
	(command "_.layer" "new" jump_to_layer "")
	(command "_.layer" "set" jump_to_layer "")		
	(setvar "cmdecho" 1)

	;run specified command, continue until stopped
	(command command_to_run)
		(while (= 1 (logand (getvar "CMDACTIVE") 1)) (command PAUSE))

	;put layer and echo state back the way they were
	(setvar "cmdecho" 0)
	(command "_.layer" "set" jump_from_layer "")
	(setvar "clayer" jump_from_layer)
	(setvar "cmdecho" current_echo)
)

;The XLINE wrapper
(defun c:x2()
(layer_jump "xline")
(princ)
)

;The RAY wrapper
(defun c:ra2()
(layer_jump "ray")
(princ)
)

;Create your own wrappers!