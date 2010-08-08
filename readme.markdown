Scratch v1.2.4
==============
A scratchpad layer utility for Autocad

2009-2010 Matthew D. Jordan : http://scenic-shop.com

Released under the MIT License

Tested on Autocad 2008-2010

Commands
--------
* `` : (backticks) switches between the current layer and the scratchpad layer.  It will create the scratchpad layer if it doesn't already exist. Uses a SysVarWillChange reactor (watching the clayer variable) to backup the original layer before switching to the scratchpad layer. This ensures that the color functions will work even when changing layers via the layer dropdown box or from the layer dialogue window

* e` : erase scratchpad, with options!
	option: a - erase everything in scratchpad layer
	option: p - preview all objects in scratchpad layer
	option: s - erase only selected objects in scratchpad layer

* m` : move selected objects to the constructions layer

* c` : copy selected objects to the constructions layer

Croshair Color Changer
----------------------

The scratchColor.lsp file is no more, the functionality has been integrated into the main scratch.lsp file.  The crosshair will automagically change color if the constructions layer is current.

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

