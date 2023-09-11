extends TileMap
@export_group("Map options")
## Map width.
@export var map_w : int = 80
## Map height.
@export var map_h: int = 80

@export_group("Room options")
## Minimum size of the rooms.
@export var min_room_size : int = 8
## Maximun amount of generated rooms.
@export var room_amount : int = 10
## Minimum leaf splitting factor.
@export var min_room_factor : float = 0.4

## Tiles. NOTE: Change when working with real tileset
const GROUND = Vector2i(1, 0)
const ROOF = Vector2i(0, 1)
const WALL = Vector2i(1, 1)

var tree = {} ## A dictionary with the entire tree.
var leaves = [] ## An array that has every id of every pair of leaves.
var leaf_id = 0 ## Current leaf id.
var rooms = [] ## An array containing all rooms in the map.

## NOTE: change.
func _ready():
	## Working with seeds is not necessary for now.
	randomize()
	generate()

## Makes all steps to generating the map in order.
func generate():
	clear()
	fill_roof()
	start_tree()
	create_leaf(0)
	create_rooms()
	join_rooms()
	clear_deadends()
	add_walls()
	
## Fills the entire map with roof tiles.
func fill_roof():
	for x in range(0, map_w):
		for y in range(0, map_h):
			set_cell(0, Vector2(x, y), 1, ROOF)
	
## Starts/restarts the tree dictionary.
func start_tree():
	rooms = []
	tree = {}
	leaves = []
	leaf_id = 0
	
	tree[leaf_id] = {"x": 1, "y": 1, "w": map_w-2, "h": map_h-2} ## Padding of 1 to each direction.
	leaf_id += 1
	
## Creates two leafs as children of parent leaf id.
func create_leaf(parent_id):
	var x = tree[parent_id].x
	var y = tree[parent_id].y
	var w = tree[parent_id].w
	var h = tree[parent_id].h
	
	## Sets the parents center. Weird placement for it, but it's fine i guess.
	tree[parent_id].center = { x = floor(x + w/2.0), y = floor(y + h/2.0)}
	var can_split = false
	
	## Randomizes the axis in wich the leaf is gonna be split.
	## 0 is horizontal and 1 is vertical.
	var split_type = randi_range(0, 1)
	
	## If the room is too small for an axis, try the other.
	if(min_room_factor * w < min_room_size):
		split_type = 0
	elif(min_room_factor * h < min_room_size):
		split_type = 1
	
	var leaf1 = {}
	var leaf2 = {}
	
	if(split_type == 1):
		var room_size = min_room_factor * w ## Used for random sized split
		if(room_size >= min_room_size): ## Only splits if there is space
			var w1 = randi_range(room_size, (w - room_size)) ## Randomizes split
			
			## create both leaves
			var w2 = w - w1
			leaf1 = {x = x, y = y, w = w1, h = h, split = 1}
			leaf2 = {x = x+w1, y = y, w = w2, h = h, split = 1}
			can_split = true
	else:
		var room_size = min_room_factor * h ## Used for random sized split
		if(room_size >= min_room_size):  ## Only splits if there is space
			var h1 = randi_range(room_size, (h - room_size)) ## Randomizes split
			
			## create both leaves
			var h2 = h - h1
			leaf1 = {x = x, y = y, w = w, h = h1, split = 0}
			leaf2 = {x = x, y = y+h1, w = w, h = h2, split = 0}
			can_split = true
			
	if(can_split): ## Appends both leaves to the tree
		leaf1.parent_id = parent_id
		tree[leaf_id] = leaf1
		tree[parent_id].l = leaf_id
		leaf_id += 1
		
		leaf2.parent_id = parent_id
		tree[leaf_id] = leaf2
		tree[parent_id].r = leaf_id
		leaf_id += 1
		
		leaves.append([tree[parent_id].l, tree[parent_id].r])
		
		create_leaf(tree[parent_id].l)
		create_leaf(tree[parent_id].r)

## Creates the rooms by using the smaller leaves in the tree
func create_rooms():
	var last_leaves = []
	
	## Populates the array with leaves without children.
	for current_leaf_id in tree:
		var leaf = tree[current_leaf_id]
		if !leaf.has("l"):
			last_leaves.append(leaf)
			
	## Randomly removes potential rooms until reaches max room amount.
	while last_leaves.size() > room_amount:
		last_leaves.remove_at(randi_range(0, last_leaves.size()-1))

	var room_id = 0
	for leaf in last_leaves: ## Appends rooms to room array
		var room = {}
		room.id = room_id
		
		## Randomly chooses room size
		room.w = randi_range(min_room_size, leaf.w) -1
		room.h = randi_range(min_room_size, leaf.h) -1
		
		room.x = leaf.x + floor((leaf.w - room.w) / 2.0) + 1
		room.y = leaf.y + floor((leaf.h - room.h) / 2.0) + 1
		room.split = leaf.split
		
		room.center = Vector2()
		room.center.x = floor(room.x + room.w/2.0)
		room.center.y = floor(room.y + room.h/2.0)
		rooms.append(room)
		room_id += 1
		
	## Sets the cells in every room to ground. NOTE: change.
	for i in range(rooms.size()):
		var r = rooms[i]
		for x in range(r.x, r.x+r.w):
			for y in range(r.y, r.y + r.h):
				if x == r.x or y == r.y or x == r.x + r.w-1 or y == r.y + r.h-1:
					set_cell(0, Vector2i(x, y), 1, WALL)
				else:
					set_cell(0, Vector2i(x, y), 1, GROUND)

## Joins rooms with corridors, by connecting every leaf pair.
func join_rooms():
	for sister in leaves:
		var a = sister[0]
		var b = sister[1]
		connect_leaves(tree[a], tree[b])
		
## Connects two leaves with corridors.
func connect_leaves(leaf1, leaf2):
	var x = min(leaf1.center.x, leaf2.center.x)
	var y = min(leaf1.center.y, leaf2.center.y)
	var w = 1
	var h = 1
	
	if(leaf1.split == 0):
		x -= floor(w/2.0)+1
		h = abs(leaf1.center.y - leaf2.center.y)
	else:
		y -= floor(h/2.0)+1
		w = abs(leaf1.center.x - leaf2.center.x)
		
	x = 0 if (x < 0) else x
	y = 0 if (y < 0) else y
	
	## Sets cells to ground.
	for i in range(x, x+w):
		for j in range(y, y+h):
			if(get_cell_atlas_coords(0, Vector2i(i, j)) == ROOF):
				set_cell(0, Vector2i(i,j), 1, GROUND)

## Clears corridors that have deadends.
func clear_deadends():
	var is_done = false
	
	while !is_done:
		is_done = true
		
		for cell in get_used_cells(0):
			if get_cell_atlas_coords(0, cell) != GROUND: continue
			
			if check_direct_neighbours(cell.x, cell.y, ROOF) == 3:
				set_cell(0, cell, 1, ROOF)
				is_done = false

## Adds walls to the paths
func add_walls():
	for cell in get_used_cells(0):
		if get_cell_atlas_coords(0, cell) != GROUND: continue
		
		var up = Vector2i(cell.x, cell.y-1)
		var down = Vector2i(cell.x, cell.y+1)
		var left = Vector2i(cell.x-1, cell.y)
		var right = Vector2i(cell.x+1, cell.y)
		
		if get_cell_atlas_coords(0, up) == ROOF: set_cell(0, up, 1, WALL)
		if get_cell_atlas_coords(0, down) == ROOF: set_cell(0, down, 1, WALL)
		if get_cell_atlas_coords(0, left) == ROOF: set_cell(0, left, 1, WALL)
		if get_cell_atlas_coords(0, right) == ROOF: set_cell(0, right, 1, WALL)
	
## Returns how many neighbours are roof tiles. No diagonals.
func check_direct_neighbours(x, y, cell_type):
	var count = 0
	
	if get_cell_atlas_coords(0, Vector2i(x, y-1)) == cell_type: count+=1
	if get_cell_atlas_coords(0, Vector2i(x, y+1)) == cell_type: count+=1
	if get_cell_atlas_coords(0, Vector2i(x-1, y)) == cell_type: count+=1
	if get_cell_atlas_coords(0, Vector2i(x+1, y)) == cell_type: count+=1
	return count
