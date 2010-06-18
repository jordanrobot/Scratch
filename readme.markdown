Scratch v1.2.3
==============
A scratchpad layer utility for Autocad

2009-2010 Matthew D. Jordan : http://scenic-shop.com

Released under the MIT License

Tested on Autocad 2008-2010

Commands
--------
* `` : (backticks) switches between layers, creates the layer if it doesn't already exist. Uses a SysVarWillChange reactor (watching the clayer variable) to backup the original layer before switching to the temporary layer. This ensures that cst will work even when changing layers via the layer dropdown box or from the layer dialogue window

* e` : erase construction layers prompt, now with options!
	* delete all
	* delete selected
	* preview objects to delete

* x` : move selected objects to the constructions layer

* c` : copy selected objects to the constructions layer

Croshair Color Changer
----------------------

The scratchColor.lsp file is no more, the functionality has been integrated into this file.  The crosshair will automagically change color if the constructions layer is current.

This crosshair color switching utility works by using two reactors - a SysVarChanged and a documentBecameCurrent; this ensures that the crosshair color will be correct when switching between documents and changing the current layer by any method.


User Variables
--------------

You can change the name & properties of the construction layer by changing the variables in the "Temporary Layer Properties" section.

* layer name: `scratchLayer`

* layer color: `scratchLayerColor`

* lineweight: `scratchLayerWeight`

* linetype: `scratchLayerLineT`

* layer plot attribute: `scratchLayerPlot`

* crosshair color: `scratchCrosshairColor` (This value must be an OLE color code.)

