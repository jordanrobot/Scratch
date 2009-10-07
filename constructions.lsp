;	Constructions v0.4.172
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
;	function: cst_load - provides the 1st level of logic for determining state of utility
;	function: cst_jumpin - jumps into the temporary layer
;	function: cst_jumpin - jumps into the provious layer
;	function: cst_backup_color - saves default crosshair colors to blackboard namespace
;	function: cst_crosshair_on - turns crosshair color on
;	function: cst_crosshair_off - turns crosshair color off
;	function: cst_crosshair_grace - reactor based - crosshair color rescue if autocad exits
;	function: cst_reset_color - resets the crosshair color to user defaults called by cst_crosshair_grace
;
;	variable: cst_lay - the temporary constructions layer
;	variable: cst_laycol - cst_lay's color
;	variable: cst_laylwt - cst_lay's lineweight
;	variable: cst_crosshair - the crosshair color when in temporary layer


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


;####################
;###   Commands   ###
;####################


;The big CST command: decision logic.
(defun c:cst()
	(setvar "cmdecho" 0)
	;if the cst_lay layer exists...
	(if (tblsearch "LAYER" cst_lay)
		; & if it is the current layer... jump out, else jump in
		(if (= cst_lay (getvar "clayer"))
			(cst_jumpout)
			(cst_jumpin)
			)
		;(back to the first if)  else, there is no cst_lay layer - save clayer & then create cst_lay layer
		(progn
			(setq cst_origlay (getvar "clayer"))
			(command "_.layer" "make" cst_lay "color" cst_laycol "" "ON" "" "Ltype" "" "" "Plot" "No" "" "LWeight" cst_laylwt "" "")
			(cst_crosshair_on)
			)
		)
	(princ)
	)


;The big DST command: decision logic.  Deletes the cst layer if it exists.
(defun c:dst()
	(setvar "cmdecho" 0)
	;abort if the constructions layer is not present
	(if (not (tblsearch "LAYER" cst_lay)) (quit))
	(cst_jumpout)
	(command "_laydel" "n" cst_lay "" "yes")
	(princ)
	)


;#####################
;###   Functions   ###
;#####################


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

	;does cst_lay exist?
	(if (tblsearch "LAYER" cst_lay)
		;yes - is it current?
	(progn

		(if (= cst_lay (getvar "clayer"))
			;yes - then we should change the crosshair color
			(cst_crosshair_on)
			;no - then we should make sure the crosshair color is user default
			(cst_crosshair_off)
			)
		)
		;cst_lay does not exist?  we should make sure the crosshair color is user default
		(cst_crosshair_off)
		)
	)
	

(defun cst_jumpin()
	;get current layer -> save for later
	(setq cst_origlay (getvar "clayer"))
	;change to the layer
	(setvar "clayer" cst_lay)
	(cst_crosshair_on)
	)


(defun cst_jumpout()
	;change current layer back to original
	(setvar "clayer" cst_origlay)
	(cst_crosshair_off)
	)


; if needed- this backs up the users' colors to the blackboard namespace, which means it will be
; accessable from any open drawings within an Autocad session.
(defun cst_backup_color ( / model_color layout_color )
	;save old crosshair colors
	(setq model_color (vlax-variant-value (vlax-make-variant (vla-get-ModelCrosshairColor pref_pointer) vlax-vblong)))
	(setq layout_color (vlax-variant-value (vlax-make-variant (vla-get-LayoutCrosshairColor pref_pointer) vlax-vblong)))

	;save results to blackboard namespace
	(vl-bb-set 'cst_model_color model_color)
	(vl-bb-set 'cst_layout_color layout_color)
	)


(defun cst_reset_color ()
	;reset default crosshair colors (could clobber user's crosshair
	;luckily it's not needed unless there is an acad crash)
	(vl-bb-set 'cst_model_color "16777215")
	(vl-bb-set 'cst_layout_color "0")
	(cst_crosshair_off)
	)


;crosshair color on
(defun cst_crosshair_on()
	;make cst_crosshair color current
	(vla-put-layoutcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_crosshair) vlax-vblong))
	(vla-put-modelcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_crosshair) vlax-vblong))
	)

;crosshair color off
(defun cst_crosshair_off()
	;make original crosshair colors current
	(vla-put-layoutcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_layout_color) vlax-vblong))
	(vla-put-modelcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_model_color) vlax-vblong))
	)


;error handing - cleans up if things go awry
(defun *error* (msg)
	(setvar "cmdecho" 0)
	(if (eq cst_origlay (or cst_lay nil))
		(setvar "clayer" cst_origlay)
		)
	(cst_crosshair_off)
	(princ msg)
	(princ)
	)


;##########################
;###   On Load part 2   ###
;##########################


(cst_load nil nil)	


;###########################
;###   Document Switch   ###
;###########################
;
;create a reactor to run cst_load when switching between documents.


(vlr-docmanager-reactor
	nil '((:vlr-documentBecameCurrent . cst_load)))

;############################
;###   If Autocad Exits   ###
;############################
;
;set crosshair back to original color, else all is lost!!!! (or at least the user's crosshair color)

(vlr-command-reactor
	nil '((:vlr-commandWillStart . cst_crosshair_grace)))

(defun cst_crosshair_grace ( reactor args ) 
    (if (member (car args) '(: "CLOSE" "QUIT" "END"))
		(if (not (eq (vl-bb-ref 'cst_model_color) nil))
			(cst_crosshair_off)
			)
    	)
	)