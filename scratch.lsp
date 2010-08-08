;####################
;###   Scratch!   ###
;####################
; version 1.2.4
;
;	-A scratchpad layer utility for Autocad
;
;	2009-2010 Matthew D. Jordan :  http://scenic-shop.com
;	Tested on Autocad 2008-2010
; Released under the MIT License - full text at bottom of file.



;#################
;###   Usage   ###
;#################
; Note: the ` symbol is a backtick (next to the 1 key)
;
;	command: `` - toggle between scratchpad layer and the current layer
;	command: e` - erase scratchpad (menu)
;			option: a - erase everything in scratchpad layer
;			option: p - preview all objects in scratchpad layer
;			option: s - erase only selected objects in scratchpad layer
;
;	command: m` - move selected objects to the scratchpad layer
;	command: 1` - jumps to previous layer



;###################
;###   On Load   ###
;###################


(vl-load-com)

(setq old_cmdecho (getvar "cmdecho"))
(setvar "cmdecho" 0)

;only load this object once
(if (= scratchColorPointer nil)
	(setq scratchColorPointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))
	) ;if



;############################
;###   Layer Properties   ###
;############################


;layer name
(setq scratchLayer "constructions")
;layer color
(setq scratchLayerColor "magenta")
;lineweight
(setq scratchLayerWeight "0.1")
;linetype
(setq scratchLayerLineT "Continuous")
;layer plot attribute - YES/NO
(setq scratchLayerPlot "NO")


; set alternate crosshair color -> default is magenta (OLE color code "16711935")
(vl-bb-set 'scratchCrosshairColor "16711935")

;set default original layer, just in case
(if (= PreviousLayer nil)
	(setq PreviousLayer "0")
	) ;if

(setvar "cmdecho" old_cmdecho)



;###############################
;###   Non-Color Functions   ###
;###############################


;empty the scratchLayer
(defun scratchCleanup ( temp / eset)
	;abort if the constructions layer is not present
	(if (not (tblsearch "LAYER" scratchLayer)) (quit))

	(scratch_jumpout)

	(cond
		((= temp "a") (setq eset (ssget "X" (list (cons 8 scratchLayer)))) )
		((= temp "s") (setq eset (ssget (list (cons 8 scratchLayer)))) )
	)

	(command ".erase" eset "")

	(princ)
) ;defun


;preview before emptying the scratchLayer
(defun scratchCleanup_preview ( / *error* temp_view answer )

		(defun *error* (msg)
			(command "-view" "restore" temp_view)
			(command "-view" "delete" temp_view)
			(command "undo" "end")
			(setvar "cmdecho" old_cmdecho)
			(princ)
		)
	 
		(command "undo" "begin")
	
		(setq temp_view "scratchCleanup-autogen-159839sha29jfisnk")	
		(command "-view" "save" temp_view)
		(command "-view" "settings" "layer" temp_view "save" "" "")
		(command "-layer" "off" "*" "y" "")
		(command "-layer" "thaw" scratchLayer "on" scratchLayer "")
		(command "Zoom" "extents" "zoom" "s" "0.95x")
	
		(initget "All Selected eXit")
		(or
			(setq answer (getkword "\nEnter an erase option [All/Selected/eXit]<All>: "))
			(setq answer "All")
		) ;or
		
		(cond
			((= answer "All" )	(scratchCleanup "a"))
			((= answer "eXit"))
			((= answer "Selected") (scratchCleanup "s"))
		) ;cond
		
		(command "-view" "restore" temp_view)
		(command "-view" "delete" temp_view)

		(command "undo" "end")
	(princ)
) ;defun


(defun scratch_jumpout( / err )
	(setq err (vl-catch-all-apply 'setvar (list "clayer" PreviousLayer)))
	(if (vl-catch-all-error-p err)
		(progn
			(command "-layer" "thaw" PreviousLayer "" "")
			(setvar "clayer" PreviousLayer)
		) ;prog
 	) ;if
) ;defun


(defun scratch_jumpin( / err )
	(setq err (vl-catch-all-apply 'setvar (list "clayer" scratchLayer)))
	(if (vl-catch-all-error-p err)
		(progn
			(command "-layer" "thaw" scratchLayer "" "")
			(setvar "clayer" scratchLayer)
			) ;progn
	) ;if
	(command "-layer" "on" scratchLayer "")
) ;defun



;####################
;###   Commands   ###
;####################


(defun c:``()
	(setvar "cmdecho" 0)
	;if the scratchLayer layer exists...
	(if (tblsearch "LAYER" scratchLayer)
		(if (= (getvar "clayer") scratchLayer)
			(scratch_jumpout)
			(scratch_jumpin)
		)	;if	
	(command "_.layer" "make" scratchLayer "color" scratchLayerColor "" "ON" "" "Ltype" scratchLayerLineT "" "Plot" scratchLayerPlot "" "LWeight" scratchLayerWeight "" "")
	) ;if
	(setvar "cmdecho" old_cmdecho)
	(princ)
) ;defun


;Delete objects on the scratchLayer
(defun c:e`( / answer *error* )
	(defun *error* (msg)
		(command "undo" "end")
		(setvar "cmdecho" "old_cmdecho")
	)

	(setvar "cmdecho" 0)
	(command "undo" "begin")
	(if	(tblsearch "LAYER" scratchLayer)
		(progn
 			(initget "All Selected Preview eXit")
			(or	(setq answer (getkword "\nEnter an erase option [All/Selected/Preview/eXit] <All> : "))
				(setq answer "All")
			) ;or
			(cond
				((= answer "All") (scratchCleanup "a"))
				((= answer "Selected") (scratchCleanup "s"))
				((= answer "Preview") (scratchCleanup_preview))
				((= answer "eXit"))
			) ;cond
		) ;progn
		(prompt "\nNothing to delete!")
	) ;if
	(setvar "cmdecho" old_cmdecho)
	(command "undo" "end")
	(princ)
) ;defun


;-bonus - switches you to previous layer.
(defun c:1`()
	(scratch_jumpout)
	(princ)
) ;defun


;move selected objects to the scratchLayer
(defun c:m`( / eset )
	(while (not eset)(setq eset (ssget)))
	(if (not (tblsearch "LAYER" scratchLayer)) 
				(command "_.layer" "make" scratchLayer "color" scratchLayerColor "" "ON" "" "Ltype" scratchLayerLineT "" "Plot" scratchLayerPlot "" "LWeight" scratchLayerWeight "" "")
	) ;if
	(command ".chprop" "_p" "" "_la" "constructions" "")
	(princ)
) ;defun



;####################
;###   Reactors   ###
;####################


;--- reactor watches for the clayer variable ---
(if (= scratch_clayerReactor nil)
	(progn
		(vlr-SysVar-Reactor nil '((:vlr-SysVarWillChange . scratch_R_watchclayer)))
		(setq scratch_clayerReactor 1)
	) ;progn
) ;if

;--- backs up the original layer before changing to scratchLayer ---
(defun scratch_R_watchclayer (reactor args)
	(if (member (strcase (car args)) '("CLAYER"))
		(if (not (= (getvar "clayer") scratchLayer))
			(setq PreviousLayer (getvar "clayer"))		
		) ;if
	) ;if
) ;defun

;--- reactor watches for the clayer variable ---
(if (= scratch_sysVarReactor nil)
	(progn
		(vlr-SysVar-Reactor	nil '((:vlr-SysVarChanged . scratch_clayer_filter)))
		(setq scratch_sysVarReactor 1)
	) ;progn
) ;if

;--- if sysvar is "CLAYER" send to toggle_color ---
(defun scratch_clayer_filter (reactor args)
	(if (member (strcase (car args)) '("CLAYER"))
		(scratch_toggle_color nil nil)
	) ;if
) ;progn

;--- reactor runs scratch_load when switching between documents ---
(if (= scratch_docManagerReactor nil)
	(progn
		(vlr-docmanager-reactor	nil '((:vlr-documentBecameCurrent . scratch_toggle_color)))
		(setq scratch_docManagerReactor 1)
	) ;progn
) ;if

;--- If scratch_lay is current, change crosshair color ---
(defun scratch_toggle_color (reactor args)
	(if (= (getvar "clayer") scratchLayer)
		(scratch_crosshair_on)
		(scratch_crosshair_off)
	) ;if
) ;defun



;#####################
;###     Color     ###
;###   Functions   ###
;#####################


; verify fidelity of backups & look for updated crosshair colors
(defun scratch_backup_check ()
	(cond
		;backup = scratchCrosshairColor -> reset colors
		;(in case of acad crash while colors are changed, this will reset to default next time lisp is loaded)
		(	(or
				(= (vl-bb-ref 'scratchOldLayoutColor) (atoi (vl-bb-ref 'scratchCrosshairColor)))
				(= (vl-bb-ref 'scratchOldModelColor) (atoi (vl-bb-ref 'scratchCrosshairColor)))
			) ;or
			(scratch_reset_color)
		) ;case 1
	
		;if (current != backup) & (current != scratchCrosshairColor) -> backup
		;this will update the backup colors if user changes the crosshair colors via the options dialogue
		(	(and
				(or
					(/= (vlax-variant-value (vlax-make-variant (vla-get-LayoutCrosshairColor scratchColorPointer) vlax-vblong)) (vl-bb-ref 'scratchOldLayoutColor))
					(/= (vlax-variant-value (vlax-make-variant (vla-get-ModelCrosshairColor scratchColorPointer) vlax-vblong)) (vl-bb-ref 'scratchOldModelColor))
				) ;or
				(/= (vlax-variant-value (vlax-make-variant (vla-get-ModelCrosshairColor scratchColorPointer) vlax-vblong)) (atoi (vl-bb-ref 'scratchCrosshairColor)))
				(/= (vlax-variant-value (vlax-make-variant (vla-get-LayoutCrosshairColor scratchColorPointer) vlax-vblong)) (atoi (vl-bb-ref 'scratchCrosshairColor)))
			) ;and
			(scratch_backup_color)
		);case 2
	) ;cond	
) ;defun


;--- back up user's crosshair colors to the blackboard namespace ---
(defun scratch_backup_color ( / scratchCurrentModelColor scratchCurrentLayoutColor )

	;save old crosshair colors
	(setq scratchCurrentModelColor (vlax-variant-value (vlax-make-variant (vla-get-ModelCrosshairColor scratchColorPointer) vlax-vblong)))
	(setq scratchCurrentLayoutColor (vlax-variant-value (vlax-make-variant (vla-get-LayoutCrosshairColor scratchColorPointer) vlax-vblong)))

	;save results to blackboard namespace
	(vl-bb-set 'scratchOldModelColor scratchCurrentModelColor)
	(vl-bb-set 'scratchOldLayoutColor scratchCurrentLayoutColor)
) ;defun


;--- reset default crosshair colors (emergency use only)
(defun scratch_reset_color ()
	(vl-bb-set 'scratchOldModelColor "16777215")
	(vl-bb-set 'scratchOldLayoutColor "0")
) ;defun


;--- crosshair color on ---
(defun scratch_crosshair_on()

	(scratch_backup_check)

	;make scratch_crosshair color current
	(vla-put-layoutcrosshaircolor scratchColorPointer (vlax-make-variant (vl-bb-ref 'scratchCrosshairColor) vlax-vblong))
	(vla-put-modelcrosshaircolor scratchColorPointer (vlax-make-variant (vl-bb-ref 'scratchCrosshairColor) vlax-vblong))
) ;defun


;--- crosshair color off ---
(defun scratch_crosshair_off()

	(scratch_backup_check)

	;make original crosshair colors current
	(vla-put-layoutcrosshaircolor scratchColorPointer (vlax-make-variant (vl-bb-ref 'scratchOldLayoutColor) vlax-vblong))
	(vla-put-modelcrosshaircolor scratchColorPointer (vlax-make-variant (vl-bb-ref 'scratchOldModelColor) vlax-vblong))
) ;defun



;#######################
;###      Color      ###
;###   Run on Load   ###
;#######################


;if no backup -> back it up, yo!
(if (not (and (vl-bb-ref 'scratchOldLayoutColor) (vl-bb-ref 'scratchOldModelColor)))
	(scratch_backup_color)
) ;if

(scratch_toggle_color nil nil)
(setvar "cmdecho" old_cmdecho)



;###################
;###    Color    ###
;###   Exiting   ###
;###################


; --- reactor watches for exits, closes & ends - sets crosshair back to default ---
(vlr-command-reactor nil '((:vlr-commandWillStart . scratch_crosshair_grace)))

(defun scratch_crosshair_grace ( reactor args ) 
  (if (member (car args) '(: "CLOSE" "QUIT" "END" "EXIT"))
		(scratch_crosshair_off)
  ) ;if
) ;defun
	
	
; Copyright (c) 2009-2010 Matthew D. Jordan
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
; THE SOFTWARE.