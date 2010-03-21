;	Scratch v0.8.2
;
;	-A scratchpad layer utility for Autocad
;
;	Tested on Autocad 2008-2010
;
;	2009-2010 Matthew D. Jordan :  http://scenic-shop.com
;
; Released under the MIT License - full text at bottom of file.
;
;	command: CST - switches between layers, creates the layer
;	if it doesn't already exist.  Uses a SysVarWillChange reactor
;	(watching the clayer variable) to backup the original layer 
;	before switching to the temporary layer.  This ensures that
;	cst will work even when changing layers via the layer
;	dropdown box or from the layer dialogue window
;
; command: CST` - move selected objects to the temp layer
;	command: EST - deletes all objects in the temporary layer with a confirmation
;	command: EST` - deletes all objects in the temporary layer without a confirmation
;
;	command: 1` - jumps to previous layer
;
;	automatic crosshair color functionality can be enabled by
;	loading the companion file - "scratchColor.lsp"



;###################
;###   On Load   ###
;###################


(vl-load-com)
(setvar "cmdecho" 0)



;#######################################
;###   Temoporary Layer Properties   ###
;#######################################


;layer name
(setq cstLayer "constructions")
;layer color
(setq cstLayerCol "magenta")
;lineweight
(setq cstLayerLwt "0.1")

;set default original layer, just in case
(if (= PreviousLayer nil)
	(setq PreviousLayer "0")
	)

(setvar "cmdecho" 1)



;####################
;###   Commands   ###
;####################


(defun c:cst()
	(setvar "cmdecho" 0)
	;if the cstLayer layer exists...
	(if (tblsearch "LAYER" cstLayer)
		(if (= (getvar "clayer") cstLayer)
			(cst_jumpout)
			(cst_jumpin)
			)
		
		(command "_.layer" "make" cstLayer "color" cstLayerCol "" "ON" "" "Ltype" "" "" "Plot" "No" "" "LWeight" cstLayerLwt "" "")
		)
	(setvar "cmdecho" 1)
	(princ)
	)

;move selected objects to the cstLayer
(defun c:cst`( / eset)
  (setq eset (ssget))
  (command ".chprop" "_p" "" "_la" "constructions" "")
)

;empty the cstLayer
(defun est( / tmp)
	;abort if the constructions layer is not present
	(if (not (tblsearch "LAYER" cstLayer)) (quit))
	(cst_jumpout)
;	(command "_laydel" "n" cstLayer "" "yes")
	(setq tmp (ssget "X" (list (cons 8 cstLayer))))
	(command ".erase" tmp "")
	(princ)
	)

;a command wrapper for the est function
(defun c:est`()
  (setvar "cmdecho" 0)
  (est)
  (setvar "cmdecho" 1)
)

;preview before emptying the cstLayer
(defun c:est ( / temp_view )
	(setvar "cmdecho" 0)
	(command "undo" "begin")
	(setq temperror *error*)
	(setq *error* est`trap)

	(setq temp_view "est-autogen-159839sha29jfisnk")

	(command "-view" "save" temp_view "y")
	(command "-view" "settings" "layer" temp_view "save" "" "")
	(command "-layer" "off" "*" "y" "")
	(command "-layer" "thaw" cstLayer "on" cstLayer "")
	(command "Zoom" "extents" "zoom" "s" "0.95x")


	(initget "Yes No")
	(setq answer (getkword "\nEmpty constructions layer: [Yes/No] <No>:"))
	(if (= answer "Yes" )
		(progn
			(est)
			(command "-view" "restore" temp_view)
			(command "-view" "delete" temp_view)
		)
		(progn
			(command "-view" "restore" temp_view)
			(command "-view" "delete" temp_view)
      )
	)
	(setq *error* temperror)
  (command "regen")
  (command "undo" "end")
	(setvar "cmdecho" 1)
	(princ)
)

(defun est`trap (errmsg)
	(command "-view" "restore" temp_view)
	(command "-view" "delete" temp_view)
	(setq *error* temperr)
	(command "undo" "end")
	(setvar "cmdecho" 1)
   (princ)
)

;-bonus - switches you to previous layer.
(defun c:1`()
	(setvar "cmdecho" 0)
	(cst_jumpout)
	(setvar "cmdecho" 1)
	(princ)
	)


(defun cst_jumpout( / err )
	(setq err (vl-catch-all-apply 'setvar (list "clayer" PreviousLayer)))
	(if (vl-catch-all-error-p err)
		(progn
			(command "-layer" "thaw" PreviousLayer "" "")
			(setvar "clayer" PreviousLayer)
			)
 		)
	)


(defun cst_jumpin( / err )
	(setq err (vl-catch-all-apply 'setvar (list "clayer" cstLayer)))
	(if (vl-catch-all-error-p err)
		(progn
			(command "-layer" "thaw" cstLayer "" "")
			(setvar "clayer" cstLayer)
			)
		)
		(command "-layer" "on" cstLayer "")
	)



;###################
;###   Reactor   ###
;###################


;--- reactor watches for the clayer variable ---
(if (= cst_clayerReactor nil)
	(progn
		(vlr-SysVar-Reactor nil '((:vlr-SysVarWillChange . cst_R_watchclayer)))
		(setq cst_clayerReactor 1)
		)
	)

;--- backs up the original layer before changing to cstLayer ---
(defun cst_R_watchclayer (reactor args)
	(if (member (strcase (car args)) '("CLAYER"))
		(if (not (= (getvar "clayer") cstLayer))
			(setq PreviousLayer (getvar "clayer"))		
			)
		)
	)
  
  
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