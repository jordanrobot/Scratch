Scratch v0.8.2
==============
A scratchpad layer utility for Autocad

2009-2010 Matthew D. Jordan : http://scenic-shop.com

Released under the MIT License

Tested on Autocad 2008-2010

Commands
--------
* `CST`: switches between layers, creates the layer if it doesn't already exist. Uses a `SysVarWillChange` reactor (watching the `clayer` variable) to backup the original layer before switching to the temporary layer. This ensures that cst will work even when changing layers via the layer dropdown box or from the layer dialogue window

* `CST`\`: move selected objects to the temp layer

* `EST`: deletes all objects in the temporary layer with a confirmation

* `EST`\`: deletes all objects in the temporary layer without a confirmation

* `1`\`: jumps to previous layer


Croshair Color Changer
----------------------

By loading the scratchColor.lsp file, the crosshair will automatically change color if the constructions layer is current.

This crosshair color switching utility works by using two reactors - a SysVarChanged and a documentBecameCurrent; this ensures that the crosshair color will be correct when switching between documents and changing the current layer by any method.


User Variables
--------------

You can change the name & properties of the construction layer by changing the variables in the "Temporary Layer Properties" section.

* layer name: `cstLayer`

* layer color: `cstLayerCol`

* lineweight: `cstLayerLwt`

If you are using the crosshair color functionality, you can change the color by editing the `'cstCrosshairColor` variable (in the scratchColor.lsp file).  This value must be an OLE color code.