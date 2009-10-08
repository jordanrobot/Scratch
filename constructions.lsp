;	Constructions v0.4.296
;	-A scratchpad layer utility for Autocad
;
;	Tested on Autocad 2008-2010
;	May require Autocad Express Tools
;	I haven't gotten around to checking compatibility.
;
;	2009 Matthew D. Jordan :  http://scenic-shop.com
;	This file is provided "as is" by the author.
;   The authorship and url must remain with the copied function. 
;
;	command: cst - switches between layers, creates if temporary layer doesn't exist
;	command: dst - deletes temporary layer
;
;
;
;	function: cst_load - error checking at load and document switching
;	function: cst_backup_color - saves default crosshair colors to blackboard namespace
;	function: cst_crosshair_on - turns crosshair color on
;	function: cst_crosshair_off - turns crosshair color off
;	function: cst_crosshair_grace - reactor based - crosshair color rescue if autocad exits
;	function: cst_reset_color - resets the crosshair color to user defaults called by cst_crosshair_grace


;###################
;###   On Load   ###
;###################


(vl-load-com)
(setvar "cmdecho" 0)
;only load this object once
(if (= pref_pointer nil)
	(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))
	)


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

;set default original layer, just in case
(setq cst_origlay "0")


(cst_load nil nil)	


;####################
;###   Commands   ###
;####################


;--- The big CST command: decision logic ---

(defun c:cst()
	(setvar "cmdecho" 0)
	;if the cst_lay layer exists...
	(if (tblsearch "LAYER" cst_lay)
		(if (= (getvar "clayer") cst_lay)
			(setvar "clayer" cst_origlay)
			(setvar "clayer" cst_lay)
			)
		(command "_.layer" "make" cst_lay "color" cst_laycol "" "ON" "" "Ltype" "" "" "Plot" "No" "" "LWeight" cst_laylwt "" "")
		)
	(princ)
	)


;--- decision logic.  Deletes the cst layer if it exists ---

(defun c:dst()
	(setvar "cmdecho" 0)
	;abort if the constructions layer is not present
	(if (not (tblsearch "LAYER" cst_lay)) (quit))
	
	(setvar "clayer" cst_origlay)
	(command "_laydel" "n" cst_lay "" "yes")
	
	(princ)
	)


;###########################
;###   Layer Functions   ###
;###########################


;--- reactor runs cst_load when switching between documents ---

(vlr-docmanager-reactor	nil '((:vlr-documentBecameCurrent . cst_load)))

(defun cst_load  ( reactor args )
	;does (vl-bb-ref 'cst_model_color) exist?
	(if (not (= (vl-bb-ref 'cst_model_color) nil))
		;yes - is it the same as cst_crosshair?
		(progn
			(if (= vl-bb-ref 'cst_model_color (vl-bb-ref 'cst_crosshair))
				;it is the same as cst_crosshair! - then we will reset it	
				(cst_reset_color)
				;it isn't magenta - then leave it be.
				)
			)
		;no backup color!? - then backup the user's crosshairs color
		(cst_backup_color)
		)
	(cst_toggle_color)
	)


;--- reactor watches for the clayer variable ---

(vlr-SysVar-Reactor
	nil '((:vlr-SysVarChanged . cst_sysvar_filter)))
(vlr-SysVar-Reactor
	nil '((:vlr-SysVarWillChange . cst_set_origlay)))


;--- if sysvar is "CLAYER" send to toggle_color ---
(defun cst_sysvar_filter (reactor args)
	(if (member (strcase (car args)) '("CLAYER"))
		(cst_toggle_color)
		)
	(if (member (strcase (car args)) '("CLAYER"))
		(cst_toggle_color)
		)

	)

;--- backs up the original layer before changing to cst_lay ---
(defun cst_set_origlay (reactor args)
	(if (member (strcase (car args)) '("CLAYER"))
		(if (not (= (getvar "clayer") cst_lay))
			(setq cst_origlay (getvar "clayer"))			
			)
		)
	)


;###########################
;###   Color Functions   ###
;###########################


;--- If cst_lay is current, change crosshair color ---
(defun cst_toggle_color ()
	(if (= (getvar "clayer") cst_lay)
		(cst_crosshair_on)
		(cst_crosshair_off)
		)
	)


;--- back up user's crosshair colors to the blackboard namespace ---
(defun cst_backup_color ( / model_color layout_color )

;write test
; if actual color is magenta? - ignore
; if actual color is same as backup? - ignore
; if actual color is not magenta or backup, then the user must have changed it, save a new one.

	;save old crosshair colors
	(setq model_color (vlax-variant-value (vlax-make-variant (vla-get-ModelCrosshairColor pref_pointer) vlax-vblong)))
	(setq layout_color (vlax-variant-value (vlax-make-variant (vla-get-LayoutCrosshairColor pref_pointer) vlax-vblong)))

	;save results to blackboard namespace
	(vl-bb-set 'cst_model_color model_color)
	(vl-bb-set 'cst_layout_color layout_color)
	)

;--- reset default crosshair colors (emergency use only)
(defun cst_reset_color ()
	(vl-bb-set 'cst_model_color "16777215")
	(vl-bb-set 'cst_layout_color "0")
	)


;--- crosshair color on ---
(defun cst_crosshair_on()
	;make cst_crosshair color current
	(vla-put-layoutcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_crosshair) vlax-vblong))
	(vla-put-modelcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_crosshair) vlax-vblong))
	)

;--- crosshair color off ---
(defun cst_crosshair_off()
	;make original crosshair colors current
	(vla-put-layoutcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_layout_color) vlax-vblong))
	(vla-put-modelcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_model_color) vlax-vblong))
	)


;###################
;###   Exiting   ###
;###################

(defun *error* (msg)
	(setvar "cmdecho" 0)
	(if (eq cst_origlay (or cst_lay nil))
		(setvar "clayer" cst_origlay)
		)
	(cst_crosshair_off)
	(princ msg)
	(princ)
	)


; --- reactor watches for exits, closes & ends - sets crosshair back to default ---

(vlr-command-reactor nil '((:vlr-commandWillStart . cst_crosshair_grace)))


(defun cst_crosshair_grace ( reactor args ) 
   (if (member (car args) '(: "CLOSE" "QUIT" "END"))
		(if (not (eq (vl-bb-ref 'cst_model_color) nil))
			(cst_crosshair_off)
			)
    	)
	)