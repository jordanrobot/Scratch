;	Constructions Color v0.5.189
;	-A scratchpad layer utility for Autocad
;	
;	Optional crosshair color switcher


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

(if (not (vl-bb-ref 'cstOldModelColor))
	(cst_backup_color)
	)


;####################
;###   Reactors   ###
;####################


;--- reactor watches for the clayer variable ---
(vlr-SysVar-Reactor
	nil '((:vlr-SysVarChanged . cst_clayer_filter)))

;--- if sysvar is "CLAYER" send to toggle_color ---
(defun cst_clayer_filter (reactor args)
	(if (member (strcase (car args)) '("CLAYER"))
		(cst_toggle_color nil nil)
		)
	)

;--- reactor runs cst_load when switching between documents ---
(vlr-docmanager-reactor	nil '((:vlr-documentBecameCurrent . cst_toggle_color)))

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


;--- back up user's crosshair colors to the blackboard namespace ---
(defun cst_backup_color ( / model_color layout_color )

	;save old crosshair colors
	(setq model_color (vlax-variant-value (vlax-make-variant (vla-get-ModelCrosshairColor cstColorPointer) vlax-vblong)))
	(setq layout_color (vlax-variant-value (vlax-make-variant (vla-get-LayoutCrosshairColor cstColorPointer) vlax-vblong)))

	;save results to blackboard namespace
	(vl-bb-set 'cstOldModelColor model_color)
	(vl-bb-set 'cstOldLayoutColor layout_color)
	)


;--- reset default crosshair colors (emergency use only)
(defun cst_reset_color ()
	(vl-bb-set 'cstOldModelColor "16777215")
	(vl-bb-set 'cstOldLayoutColor "0")
	)


;--- crosshair color on ---
(defun cst_crosshair_on()
	;make cst_crosshair color current
	(vla-put-layoutcrosshaircolor cstColorPointer (vlax-make-variant (vl-bb-ref 'cstCrosshairColor) vlax-vblong))
	(vla-put-modelcrosshaircolor cstColorPointer (vlax-make-variant (vl-bb-ref 'cstCrosshairColor) vlax-vblong))
	)


;--- crosshair color off ---
(defun cst_crosshair_off()

	(if (= (vl-bb-ref 'cstOldModelColor) (vl-bb-ref 'cstCrosshairColor))
		;it is the same as cst_crosshair! - then we will reset it	
		(cst_reset_color)
		;it isn't magenta - then leave it be.
		)

	;make original crosshair colors current
	(vla-put-layoutcrosshaircolor cstColorPointer (vlax-make-variant (vl-bb-ref 'cstOldLayoutColor) vlax-vblong))
	(vla-put-modelcrosshaircolor cstColorPointer (vlax-make-variant (vl-bb-ref 'cstOldModelColor) vlax-vblong))
	)


;###################
;###   Exiting   ###
;###################

(defun *error* (msg)
	(setvar "cmdecho" 1)
	(cst_crosshair_off)
	(princ msg)
	(princ)
	)


; --- reactor watches for exits, closes & ends - sets crosshair back to default ---
(vlr-command-reactor nil '((:vlr-commandWillStart . cst_crosshair_grace)))

(defun cst_crosshair_grace ( reactor args ) 
   (if (member (car args) '(: "CLOSE" "QUIT" "END" "EXIT"))
		(if (cstOldModelColor)
			(cst_crosshair_off)
			)
    	)
	)