;	Constructions Color v0.6
;
;	-A scratchpad layer utility for Autocad
;	-Optional crosshair color switcher
;
;	Tested on Autocad 2008-2010
;	May require Autocad Express Tools
;	I haven't gotten around to checking compatibility.
;
;	2009 Matthew D. Jordan :  http://scenic-shop.com
;	This file is provided "as is" by the author.
;
;	This crosshair color switching utility works by using
;	two reactors - a SysVarChanged and a documentBecameCurrent.
;	The color on/off is determined by the current layer.


;###################
;###   On Load   ###
;###################

(setvar "cmdecho" 0)
(vl-load-com)
;only load this object once
(if (= cstColorPointer nil)
	(setq cstColorPointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))
	)

; cst's crosshair color -> default is magenta (OLE color code)
(vl-bb-set 'cstCrosshairColor "16711935")

;(setq debug 1)

;####################
;###   Reactors   ###
;####################


;--- reactor watches for the clayer variable ---
(if (= cst_sysVarReactor nil)
	(progn
		(vlr-SysVar-Reactor	nil '((:vlr-SysVarChanged . cst_clayer_filter)))
		(setq cst_sysVarReactor 1)
		)
	)

;--- if sysvar is "CLAYER" send to toggle_color ---
(defun cst_clayer_filter (reactor args)

	(if (member (strcase (car args)) '("CLAYER"))
		(cst_toggle_color nil nil)
		)
	)

;--- reactor runs cst_load when switching between documents ---
(if (= cst_docManagerReactor nil)
	(progn
		(vlr-docmanager-reactor	nil '((:vlr-documentBecameCurrent . cst_toggle_color)))
		(setq cst_docManagerReactor 1)
		)
	)

;--- If cst_lay is current, change crosshair color ---
(defun cst_toggle_color (reactor args)

	(if (= (getvar "clayer") cstLayer)
		(cst_crosshair_on)
		(cst_crosshair_off)
		)
	)



;#####################
;###   Functions   ###
;#####################

;--- verify fidelity of backups & look for updated crosshair colors
(defun cst_backup_check ()

(cond
	;backup = cstCrosshairColor -> reset colors
	;(in case of acad crash while colors are changed, this will reset to default next time lisp is loaded)
	(	(or
			(= (vl-bb-ref 'cstOldLayoutColor) (atoi (vl-bb-ref 'cstCrosshairColor)))
			(= (vl-bb-ref 'cstOldModelColor) (atoi (vl-bb-ref 'cstCrosshairColor)))
		)
		(cst_reset_color)
		)

	;if (current != backup) & (current != cstCrosshairColor) -> backup
	;this will update the backup colors if user changes the crosshair colors via the options dialogue
	(	(and
			(or
				(/= (vlax-variant-value (vlax-make-variant (vla-get-LayoutCrosshairColor cstColorPointer) vlax-vblong)) (vl-bb-ref 'cstOldLayoutColor))
				(/= (vlax-variant-value (vlax-make-variant (vla-get-ModelCrosshairColor cstColorPointer) vlax-vblong)) (vl-bb-ref 'cstOldModelColor))
			)
			(/= (vlax-variant-value (vlax-make-variant (vla-get-ModelCrosshairColor cstColorPointer) vlax-vblong)) (atoi (vl-bb-ref 'cstCrosshairColor)))
			(/= (vlax-variant-value (vlax-make-variant (vla-get-LayoutCrosshairColor cstColorPointer) vlax-vblong)) (atoi (vl-bb-ref 'cstCrosshairColor)))
			)
		(cst_backup_color)
		)
	)	
	)

;--- back up user's crosshair colors to the blackboard namespace ---
(defun cst_backup_color ( / cstCurrentModelColor cstCurrentLayoutColor )

	;save old crosshair colors
	(setq cstCurrentModelColor (vlax-variant-value (vlax-make-variant (vla-get-ModelCrosshairColor cstColorPointer) vlax-vblong)))
	(setq cstCurrentLayoutColor (vlax-variant-value (vlax-make-variant (vla-get-LayoutCrosshairColor cstColorPointer) vlax-vblong)))

	;save results to blackboard namespace
	(vl-bb-set 'cstOldModelColor cstCurrentModelColor)
	(vl-bb-set 'cstOldLayoutColor cstCurrentLayoutColor)
	)


;--- reset default crosshair colors (emergency use only)
(defun cst_reset_color ()

	(vl-bb-set 'cstOldModelColor "16777215")
	(vl-bb-set 'cstOldLayoutColor "0")
	)


;--- crosshair color on ---
(defun cst_crosshair_on()

	(cst_backup_check)

	;make cst_crosshair color current
	(vla-put-layoutcrosshaircolor cstColorPointer (vlax-make-variant (vl-bb-ref 'cstCrosshairColor) vlax-vblong))
	(vla-put-modelcrosshaircolor cstColorPointer (vlax-make-variant (vl-bb-ref 'cstCrosshairColor) vlax-vblong))
	)


;--- crosshair color off ---
(defun cst_crosshair_off()

	(cst_backup_check)

	;make original crosshair colors current
	(vla-put-layoutcrosshaircolor cstColorPointer (vlax-make-variant (vl-bb-ref 'cstOldLayoutColor) vlax-vblong))
	(vla-put-modelcrosshaircolor cstColorPointer (vlax-make-variant (vl-bb-ref 'cstOldModelColor) vlax-vblong))
	)



;#######################
;###   run on load   ###
;#######################


;if no backup -> back it up, yo!

(if (not (and (vl-bb-ref 'cstOldLayoutColor) (vl-bb-ref 'cstOldModelColor)))
	(cst_backup_color)
	)

(cst_toggle_color nil nil)

;###################
;###   Exiting   ###
;###################

(defun *error* (msg)
	(setvar "cmdecho" 1)
	(cst_crosshair_off)
	(princ msg)
	)


; --- reactor watches for exits, closes & ends - sets crosshair back to default ---
(vlr-command-reactor nil '((:vlr-commandWillStart . cst_crosshair_grace)))

(defun cst_crosshair_grace ( reactor args ) 
   (if (member (car args) '(: "CLOSE" "QUIT" "END" "EXIT"))
		(cst_crosshair_off)
    	)
	)