![WaterMap](addons/water-map/title.png)
# Add water physics to any TileMap in Godot.

## Installation

You can install the plugin using this repository by following the [instructions found here](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html)

This addon is pending approval to the official Godot Asset Library at this time.
<!-- Alternatively you can find this plugin on the official Godot Asset Library and install directly from Godot! -->

Once the plugin is installed in your project, simply add a `WaterMap` node as a child to any TileMap!
![WaterMap added to scene](readme-images/water-map-install-1.png)

## Demos
### Demo1
You can find Demo 1 under `demos/WaterMapDemo1.tscn`. This shows a few of the basic features such as click add liquid tiles and TileMap index translation to liquid tiles.

## Configuration

### Node Parameters
`Cell Capacity` - Maximum number of liquid units a given cell can contain

`Liquid Color` - Base color for the liquid

`Click Spawn Liquid` - Enable mouse left click to spawn liquid cell

`Liquid Spawn Tile Indices` - Add tile indices here from the TileMap's TileSet that you'd like to have converted into full capacity liquid cells at scene ready.

`Should Remove Liquid Spawn Tiles` - Remove tiles from the TileMap that are given as liquid spawn tiles. This is useful if you want a water tile on your tilemap to just turn into actual liquid at scene ready.

`Liquid Cell Capacity Signal Threshold` - The cell liquid capacity that should trigger signals. If the capacity becomes equal to or greater than this then the WaterMap will emit a `liquid_cell_capacity_over_threshold` with the cell's coordinates. If the capacity becomes less than the threshold it will emit a `liquid_cell_capacity_under_threshold` with the cell's coordinates.

### Node Signals
`liquid_cell_capacity_over_threshold` (cell coordinates) - Emitted when a cell's liquid capacity becomes equal to or greater than the configured threshold value.

`liquid_cell_capacity_under_threshold` (cell coordinates) - Emitted when a cell's liquid capacity becomes less than the configured threshold value.


## Reporting Issues
Please use Github's issue tracker!