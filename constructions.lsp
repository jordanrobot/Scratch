;	Constructions v0.6
;
;	-A scratchpad layer utility for Autocad
;
;	Tested on Autocad 2008-2010
;	May require Autocad Express Tools
;	I haven't gotten around to checking compatibility.
;
;	2009 Matthew D. Jordan :  http://scenic-shop.com
;	This file is provided "as is" by the author.
;
;	command: CST - switches between layers, creates the layer
;	if it doesn't already exist.  Uses a SysVarWillChange reactor
;	(watching the clayer variable) to backup the original layer 
;	before switching to the temporary layer.  This ensures that
;	cst will work even when changing layers via the layer
;	dropdown box or from the layer dialogue window
;
;	command: EST - deletes the temporary layer
;
;	command: 1` - jumps to previous layer
;
;	automatic crosshair color functionality can be enabled by
;	loading the companion file - "constructionsColor.lsp"


;###################
;###   On Load   ###
;###################

(vl-load-com)
(setvar "cmdecho" 0)

(setq debug 1)
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

;####################
;###   Commands   ###
;####################

(defun c:cst()
	(setvar "cmdecho" 0)
	;if the cstLayer layer exists...
	(if (tblsearch "LAYER" cstLayer)
		(if (= (getvar "clayer") cstLayer)
			(setvar "clayer" PreviousLayer)
			(setvar "clayer" cstLayer)
			)
		(command "_.layer" "make" cstLayer "color" cstLayerCol "" "ON" "" "Ltype" "" "" "Plot" "No" "" "LWeight" cstLayerLwt "" "")
		)
	(princ)
	)


(defun c:est()
	(setvar "cmdecho" 0)
	;abort if the constructions layer is not present
	(if (not (tblsearch "LAYER" cstLayer)) (quit))
	(setvar "clayer" PreviousLayer)

	(command "_laydel" "n" cstLayer "" "yes")
	
	(princ)
	)

;-putting this here until I pull Previous Layer out of this file.
(defun c:1`()
	(setvar "clayer" PreviousLayer )
	(princ)
	)


;###################
;###   Reactor   ###
;###################


;--- reactor watches for the clayer variable ---
(vlr-SysVar-Reactor
	nil '((:vlr-SysVarWillChange . cst_set_origlay))
	)

;--- backs up the original layer before changing to cstLayer ---
(defun cst_set_origlay (reactor args)
	(if (member (strcase (car args)) '("CLAYER"))
		(if (not (= (getvar "clayer") cstLayer))
			(setq PreviousLayer (getvar "clayer"))			
			)
		)
	)


;###################
;###   Exiting   ###
;###################

(defun *error* (msg)
	(setvar "cmdecho" 0)
	(setvar "clayer" PreviousLayer)
	(princ msg)
	(princ)
	)