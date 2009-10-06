;	Constructions v0.4.112
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
;	function: cst_jumpin - jumps into the temporary layer
;	function: cst_jumpin - jumps into the provious layer
;	function: cst_backupcol - saves default crosshair colors to blackboard namespace
;	function: cst_crosshair_on - turns crosshair color on
;	function: cst_crosshair_off - turns crosshair color off
;	function: cst_crosshair_grace - reactor based - crosshair color rescue if autocad exits
;	function: cst_resetcol - resets the crosshair color to user defaults called by cst_crosshair_grace
;
;	variable: cst_lay - the temporary constructions layer
;	variable: cst_laycol - cst_lay's color
;	variable: cst_laylwt - cst_lay's lineweight
;	variable: cst_crosshair - the crosshair color when in temporary layer
;
;	command: cst - switches between layers, creates if temporary layer doesn't exist
;	command: dst - deletes temporary layer 


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


;The big CST command: decision logic.
(defun c:cst()
	(setvar "cmdecho" 0)
	;if user crosshair colors are not already backed up: then back them up!
	(if (eq (vl-bb-ref 'cst_model_color) nil)
		(cst_backupcol)
		)
	;if the layer constructions exists...
	(if (tblsearch "LAYER" cst_lay)
		; & if constructions is the current layer... jump out, else jump in
		(if (= cst_lay (getvar "clayer"))
			(cst_jumpout)
			(cst_jumpin)
			)
		;(back to the first if), no constructions layer - save clayer & then create cst_lay
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
	;if user crosshair colors are not backed up: then back them up!
	(if (not (eq (vl-bb-ref 'cst_model_color) nil))
		(cst_crosshair_off)
		)
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


;#######################################
;###   If Autocad Exits   ###
;#######################################
;
;before exit set crosshair back to original color, else all is lost!!!! (or at least the user's crosshair color)

(vlr-command-reactor
	nil '((:vlr-commandWillStart . cst_crosshair_grace)))

(defun cst_crosshair_grace (calling-reactor startcommandInfo / thecommandstart)

	(setq thecommandstart (nth 0 startcommandInfo))
	(cond 
		((= thecommandstart "EXIT") (cst_resetcol))
		((= thecommandstart "_EXIT") (cst_resetcol))		
		((= thecommandstart "exit") (cst_resetcol))
		((= thecommandstart "_exit") (cst_resetcol))		
		((= thecommandstart "CLOSE") (cst_resetcol))
		((= thecommandstart "_CLOSE") (cst_resetcol))
		((= thecommandstart "close") (cst_resetcol))
		((= thecommandstart "_close") (cst_resetcol))
		((= thecommandstart "_quit") (cst_resetcol))
		((= thecommandstart "quit") (cst_resetcol))
		((= thecommandstart "QUIT") (cst_resetcol))
		((= thecommandstart "_QUIT") (cst_resetcol))
			)
	(princ)
	)

;#####################
;###    On Load    ###
;#####################

;make this for when switching documents & on load?
;if current crosshair is magenta: then reset the old colors
(if (= (vlax-variant-value (vlax-make-variant (vla-get-ModelCrosshairColor pref_pointer) vlax-vblong)) 16711935)
	(cst_crosshair_off)
	)
