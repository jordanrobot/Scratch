;	Scratch v0.8.0
;
;	-A scratchpad layer utility for Autocad
;
;	Tested on Autocad 2008-2010
;	May require Autocad Express Tools
;	I haven't gotten around to checking compatibility.
;
;	2009-2010 Matthew D. Jordan :  http://scenic-shop.com
;	This file is provided "as is" by the author.
;
;	command: CST - switches between layers, creates the layer
;	if it doesn't already exist.  Uses a SysVarWillChange reactor
;	(watching the clayer variable) to backup the original layer 
;	before switching to the temporary layer.  This ensures that
;	cst will work even when changing layers via the layer
;	dropdown box or from the layer dialogue window
;
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

;empty the cstLayer
(defun est( / tmp)
	(setvar "cmdecho" 0)
	;abort if the constructions layer is not present
	(if (not (tblsearch "LAYER" cstLayer)) (quit))
	(cst_jumpout)
;	(command "_laydel" "n" cstLayer "" "yes")
	(setq tmp (ssget "X" (list (cons 8 cstLayer))))
	(command ".erase" tmp "")

	(setvar "cmdecho" 1)
	(princ)
	)

;a command wrapper for the est function
(defun c:est`()
	(est)
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