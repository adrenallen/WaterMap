tool
class_name WaterMap
extends Node2D

# Max capacity of a cell
export (int) var cell_capacity := 8

# Color of the liquid to spawn
export (Color) var liquid_color := Color(64.0/255.0, 82.0/255.0, 155.0/255.0)

# Enables spawn full liquid cell at mouse click position
export (bool) var click_spawn_liquid := false

# What tiles should be treated as full water tiles on spawn?
export (Array, int) var liquid_spawn_tile_indices := []

# Should tiles in parent tilemap be removed on init if they are
# matched to a given water_tile_indices value?
export (bool) var should_remove_liquid_spawn_tiles_from_parent := false

# Threshold number that when surpassed will emit a signal
# indicating this cell has over or under the threshold.
export (int) var liquid_cell_capacity_signal_threshold := 6

# Indicates a cell capacity has gone over the threshold
signal liquid_cell_capacity_over_threshold(cell_position)

# Indicates a cell capacity has gone under the threshold
signal liquid_cell_capacity_under_threshold(cell_position)

# Dimensions of a cell
var _cell_size : Vector2

# tracks the active shape of cells
var _cells_rect := Rect2(0,0,0,0)

# Cell data
var _cells := {}

# The tilemap node for referencing for liquid simulation
var _tilemap : TileMap

var _actions := [] # actions to calculate on tick

const BLOCKING_CELL = -1 # TODO - remove this and replace with "is_blocking" method that checks tilemap

# Called when the node enters the scene tree for the first time.
func _ready():
	if not _is_parent_tilemap():
		push_error("Parent must be a TileMap")
		
	_tilemap = get_parent() as TileMap
	
	# Initializing based on tilemap data
	_cell_size = _tilemap.get_cell_size()
	_cells_rect = _tilemap.get_used_rect()
	
	_initialize_liquid_spawn_tile_conversions()


func _process(delta):
	for i in 1: # TODO - why do we do this?
		tick()
		
	if click_spawn_liquid && Input.is_mouse_button_pressed(BUTTON_LEFT):
		var pos = _tilemap.world_to_map(get_global_mouse_position())
		_grow_bounds_for_point(pos.x, pos.y)
		pos.x = round(pos.x) #stupid
		pos.y = round(pos.y)
		_set_cell(pos.x, pos.y, cell_capacity)
	
# looks at parent tilemap and handles spawning liquid tiles
# based on the liquid spawn tile indices
# and removing the spawn tiles if configured to do so
func _initialize_liquid_spawn_tile_conversions() -> void:
	if len(liquid_spawn_tile_indices) < 1:
		return #nothing to do!
	# TODO - is this slower than just looping the whole tilemap instead?
	for wt_idx in liquid_spawn_tile_indices:
		var tiles := _tilemap.get_used_cells_by_id(wt_idx)
		for tile in tiles:
			_set_cell(tile.x, tile.y, cell_capacity)
			if should_remove_liquid_spawn_tiles_from_parent:
				_tilemap.set_cellv(tile, -1)
	
func _grow_bounds_for_point(x: int, y: int) -> void:
	var grow = {
		"top": 0,
		"left": 0,
		"right": 0,
		"bottom": 0
	}
	if not _cells_rect.has_point(Vector2(x,y)):
		if _cells_rect.end.x < x:
			grow.right = abs(_cells_rect.end.x - x)
		elif _cells_rect.position.x > x:
			grow.left = abs(_cells_rect.position.x - x)
			
		if _cells_rect.end.y < y:
			grow.bottom = abs(_cells_rect.end.y - y)
		elif _cells_rect.position.y > y:
			grow.top = abs(_cells_rect.position.y - y)
			
		_cells_rect = _cells_rect.grow_individual(grow.left, grow.top, grow.right, grow.bottom)
	
func _set_cell(x: int, y: int, value: int) -> void:
	_cells[_get_cell_key(x,y)] = value

func _get_cell(x: int, y: int) -> int:
	return _cells.get(_get_cell_key(x,y), 0)

func _get_cell_key(x: int, y: int) -> String:
	return str(x) + "-" + str(y)
	
func _is_parent_tilemap() -> bool:
	return (get_parent() is TileMap)
	
func _get_configuration_warning() -> String:
	if not _is_parent_tilemap():
		return 'Parent must be a TileMap'
	return ''
	
func _is_cell_blocking(x: int, y: int) -> bool:
	var tile_idx = _tilemap.get_cell(x,y)
	if liquid_spawn_tile_indices.has(tile_idx) or tile_idx == -1:
		return false
	return true


func tick():
	for y in range(_cells_rect.position.y, _cells_rect.end.y):
		for x in range(_cells_rect.position.x, _cells_rect.end.x):
			var cell = _get_cell(x,y)
			if cell > 0:
				
				# REMOVE THIS TO REMOVE EVAPORATION
				if cell == 1 and randi() % 50 == 0:
					# Evaporate
					_actions.append([x, y, -1])
					continue
				# END
				
				var ncell_down = _get_cell(x, y + 1)
				if ncell_down >= 0 and ncell_down < cell_capacity and not _is_cell_blocking(x, y + 1):
					_actions.append([x, y, -1])
					_actions.append([x, y + 1, 1])
					cell -= 1 # TODO - remove this?
					continue
				
				var ncell_left = _get_cell(x - 1, y)
				var ncell_right = _get_cell(x + 1, y)
				
				if ncell_left == -1 and ncell_right == -1:
					continue
#				if ncell_left >= cell and ncell_right >= cell:
#					continue
				
				var could_evaporate = false
				#if ncell_left == BLOCKING_CELL:
				if _is_cell_blocking(x - 1, y):
					if cell - ncell_right == 1:
						could_evaporate = true
				#elif ncell_right == BLOCKING_CELL:
				elif _is_cell_blocking(x + 1, y):
					if cell - ncell_left == 1:
						could_evaporate = true
				else:
					if cell - ncell_left == 1 or cell - ncell_right == 1:
						could_evaporate = true
				if could_evaporate and randi() % 30 == 0:
					_actions.append([x, y, BLOCKING_CELL])
					continue
				
				var dx = null
				if ncell_left < 0:
					dx = 1
				elif ncell_right < 0:
					dx = -1
				elif ncell_left == ncell_right:
					if randi() % 2 == 0:
						dx = 1
					else:
						dx = -1
				elif ncell_left > ncell_right:
					dx = 1
				else:
					dx = -1
				
				var ncell = _get_cell(x + dx, y)
				#if ncell >= cell or ncell == BLOCKING_CELL:
				if ncell >= cell or _is_cell_blocking(x + dx, y):
					continue
				
				_actions.append([x, y, -1])
				_actions.append([x + dx, y, 1])
				cell -= 1
				if cell <= 0:
					continue

	# Apply actions
	for a in _actions:
		
		var x = a[0]
		var y = a[1]
		var d = a[2]
		
		var cell = _get_cell(x, y)
		var new_cell = cell + d
		
		_set_cell(x, y, new_cell)
		
		# Check if we need to emit signal for threshold change
		if (new_cell >= liquid_cell_capacity_signal_threshold 
			&& cell < liquid_cell_capacity_signal_threshold):
			emit_signal("liquid_cell_capacity_over_threshold", Vector2(x,y))
		elif (new_cell < liquid_cell_capacity_signal_threshold 
			&& cell >= liquid_cell_capacity_signal_threshold):
			emit_signal("liquid_cell_capacity_under_threshold", Vector2(x,y))
	
	_actions.clear()
	
	# Trigger a redraw
	update()


func _draw():
	for y in range(_cells_rect.position.y, _cells_rect.end.y):
		for x in range(_cells_rect.position.x, _cells_rect.end.x):
			var cell = _get_cell(x,y)
			
			if cell > 0:
				var f = float(cell) / cell_capacity
				# var col = Color(64.0/255.0, 82.0/255.0, 155.0/255.0)
				var col := liquid_color
				if f > 1.0:
					#col.r += f - 1.0
					var col_add = (f - 1.0)/2
					col.r += col_add
					col.g += col_add
					col.b += col_add
				f = clamp(f, 0.0, 1.0)
				if _get_cell(x, y - 1) > 0:
					f = 1.0
				var r = Rect2(x * _cell_size.x, (y + 1.0 - f) * _cell_size.y, _cell_size.x, _cell_size.y * f)
				draw_rect(r, col)
			

