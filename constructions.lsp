;	Constructions v0.4.94
;	-A scratchpad layer utility for Autocad
;
;	Tested on Autocad 2008-2010
;	May require Autocad Express Tools
;
;	Copyright (c) 2009 Matthew D. Jordan :  http://scenic-shop.com
;	This file is provided "as is" by the author.
;    The authorship and url must remain with the copied function. 


;###############################
;###   Load required stuff   ###
;###############################


;load misc stuff
(vl-load-com)
(setvar "cmdecho" 0)
(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))


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


;####################
;###   Commands   ###
;####################


;The big CST command: decision logic.  Calls other functions based on state of various things.
(defun c:cst()
	(if 
		;if the layer constructions exists...
		(tblsearch "LAYER" cst_lay)
		; & if constructions is the current layer... jump out, else jump in
		(if (= cst_lay (getvar "clayer"))
			(cst_jumpout)
			(cst_jumpin)
			)
		;(back to the first if), no constructions layer?, then create it!
		(cst_make)
		)
	(princ)
	)


;The bid DST command: decision logic.  Deletes the cst layer if it exists.
(defun c:dst()
	;abort if the constructions layer is not present
	(if (not (tblsearch "LAYER" cst_lay)) (quit))
	(cst_jumpout)
	(cst_delete)
	)


;#####################
;###   Functions   ###
;#####################


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
	(command "_.layer" "make" cst_lay "color" cst_laycol "" "ON" "" "Ltype" "" "" "Plot" "No" "" "LWeight" cst_laylwt "" "")
	;turn crosshair color on
	(cst_crosshair_on)
	)


(defun cst_delete()
	(cst_jumpout)
	(command "_laydel" "n" cst_lay "" "yes")
	)


; if needed- this backs up the users' colors to the blackboard namespace, which means it will be
; accessable from any open drawings within an Autocad session.
(defun cst_backupcol ( / model_color layout_color )

	;set initial crosshair color settings
	(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))

	;save old crosshair colors
	; rather clunky, I know.  But it was a bit buggy when chained together, and its fairly early in the morning. ;)
	(setq model_color (vla-get-ModelCrosshairColor pref_pointer))
	(setq model_color (vlax-make-variant model_color vlax-vblong))
	(setq model_color (vlax-variant-value model_color))

	(setq layout_color (vla-get-LayoutCrosshairColor pref_pointer))
	(setq layout_color (vlax-make-variant layout_color vlax-vblong))
	(setq layout_color (vlax-variant-value layout_color))

	;save results to blackboard namespace
	(vl-bb-set 'cst_model_color model_color)
	(vl-bb-set 'cst_layout_color layout_color)
	)


; this resets cursor color if anything goes wrong at application exit
(defun cst_resetcol ()
	(vl-bb-set 'cst_model_color "16777215")
	(vl-bb-set 'cst_layout_color "0")
	(cst_crosshair_off)
	)


;crosshair color on
(defun cst_crosshair_on()
	;set mouse color (layout) to cst_crosshair
	(vla-put-layoutcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_crosshair) vlax-vblong))
	;set mouse color (modelspace) to cst_crosshair
	(vla-put-modelcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_crosshair) vlax-vblong))
	)


;crosshair color off
(defun cst_crosshair_off()
	;set mouse color (layout) to original color
	(vla-put-layoutcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_layout_color) vlax-vblong))
	;set mouse color (modelspace) to original color
	(vla-put-modelcrosshaircolor pref_pointer (vlax-make-variant (vl-bb-ref 'cst_model_color) vlax-vblong))
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


;#####################
;###    On Load    ###
;#####################


; This bit checks out the cursor colors at lisp load and tries to correct anything that goes wrong.

;if user crosshair colors are not backed up: then back them up!
(if (eq (vl-bb-ref 'cst_model_color) nil)
	(cst_backupcol)
	)


;if old crosshair colors are magenta: then reset them
(if (eq (vl-bb-ref 'cst_model_color) 16711935)
	(cst_resetcol)
	)


;if current crosshair is magenta: then reset the old colors
(if (= (vlax-variant-value (vlax-make-variant (vla-get-ModelCrosshairColor pref_pointer) vlax-vblong)) 16711935)
	(cst_crosshair_off)
	)
