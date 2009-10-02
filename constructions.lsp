;	Constructions v0.3.131
;	-A temporary layer multitasker for Autocad
;
;	Copyright (c) 2009 Matthew D. Jordan :  http://scenic-shop.com
;	This file is provided "as is" by the author.
;    The authorship and url must remain with the copied function. 

; define the "jump-to" layer
(setq cst_lay "constructions")

; set the crosshair color
(setq cst_crosshair 16711935)
(setq model_crosshair_color 16777215)
(setq layout_crosshair_color 1)

;load misc stuff
(vl-load-com)
(setvar "cmdecho" 1)

;if color is magenta, turn it white!

;set initial crosshair color settings
;(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))
;save old crosshair colors
;(setq old_model_color (vla-get-ModelCrosshairColor pref_pointer))
;(setq old_layout_color (vla-get-LayoutCrosshairColor pref_pointer))
;(vlax-release-object pref_pointer)


;creates & switches layers - wrapper logic
(defun c:cst()
	(if 
		;if the layer constructions exists...
		(tblsearch "LAYER" "constructions")
		; then if constructions is the current layer... jump out, else jump in
		(if (= cst_lay (getvar "clayer"))
			(cst_jumpout)
			(cst_jumpin)
			)
		;back to the first if, (no constructions layer?, then create it!)
		(cst_make)
		)
	(princ)
	)


;cleans the constructions layer of all objects
(defun c:dst()
	(if (tblsearch "LAYER" "constructions") (cst_clean) ())
	(princ)
	)


;the cst utilites: delete constructions layer, copy, move...
(defun c:fst( / cst_option temp_set)

	;abort if the constructions layer is not present
	(if (not (tblsearch "LAYER" cst_lay)) (quit))
	
	(cst_jumpout)
	
	(initget "d c c` m m` x t" )
	(setq cst_option (getkword "\nEnter Option: Delete/Copy/Move/[eXit]:"))
	
	(if (= cst_option "d") (cst_delete))
	;copy to original layer
	(if (= cst_option "c") (progn (setq temp_set (ssget)) (command "_copy" "")))
	;head for copy menu (to cst_lay/origlay)
	(if (= cst_option "m") (progn (setq temp_set (ssget)) (command ".chprop" "_p" "" "_la" cst_lay "")))
	(if (= cst_option "m`") (progn (setq temp_set (ssget)) (command ".chprop" "_p" "" "_la" cst_origlay "")))
	(if (= cst_option "x") (quit))
	(if (= cst_option nil) (cst_delete))
)


;progn (setq temp_set (ssget))

;;(defun cst_getallcst (/ temp)
;;	(setq temp (ssget '((8 . (cst_lay)))))

;;	(ssget "_X" 
;;	  '((0 . "RAY")(8 . "TEMP"))
;;	)

;;(ssget "_X" '((8 . ))



;;	(command "_copy" temp )
		;;if selection is blank, do not allow, otherwise continue
;;		(if (not (eq DimObject nil))
;;		)
;;	)

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
	(command "_.layer" "make" cst_lay "color" "Magenta" "" "ON" "" "Ltype" "" "" "Plot" "No" "" "LWeight" "0.1" "" "")
	;turn crosshair color on
	(cst_crosshair_on)
	)


(defun cst_delete()
	(cst_jumpout)
	(command "_laydel" "n" cst_lay "" "yes")
	)


(defun cst_clean( / tempSet)
	(cst_jumpout)
	(if (setq temp_set(ssget "X" (list (cons 8 cst_lay))))
		(command "_erase" temp_set "")
		)
	)


;crosshair color on
(defun cst_crosshair_on()
	(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))
	;set mouse color (layout) to cst_crosshair
	(vla-put-layoutcrosshaircolor pref_pointer (vlax-make-variant cst_crosshair vlax-vblong))
	;set mouse color (modelspace) to cst_crosshair
	(vla-put-modelcrosshaircolor pref_pointer (vlax-make-variant cst_crosshair vlax-vblong))
	;clean up stuff
	(vlax-release-object pref_pointer)
	(princ)
	)


;crosshair color off
(defun cst_crosshair_off()
	(setq pref_pointer (vla-get-display (vla-get-Preferences (vlax-get-acad-object))))
	;set mouse color (layout) to cst_crosshair
	(vla-put-layoutcrosshaircolor pref_pointer (vlax-make-variant layout_crosshair_color vlax-vblong))
	;set mouse color (modelspace) to cst_crosshair
	(vla-put-modelcrosshaircolor pref_pointer (vlax-make-variant model_crosshair_color vlax-vblong))
	;clean up stuff
	(vlax-release-object pref_pointer)
	(princ)
	)

;error handing - cleans up if things go awry
(defun *error* (msg)
	(setvar "cmdecho" 1)
	(cst_crosshair_off)
	(setvar "clayer" cst_origlay)
	(princ msg)
	(princ)
	)