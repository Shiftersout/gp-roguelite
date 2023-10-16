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
const ROOF = Vector2i(1, 0)

var tree = {} ## A dictionary with the entire tree.
var leaves = [] ## An array that has every id of every pair of leaves.
var leaf_id = 0 ## Current leaf id.
var rooms = [] ## An array containing all rooms in the map.

var path

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
	var rooms_c = []
	for i in rooms:
		rooms_c.append(i.center)
	path = find_mst(rooms_c)
	join_rooms()
	
## Fills the entire map with roof tiles.
func fill_roof():
	for x in range(0, map_w):
		for y in range(0, map_h):
			set_cell(0, Vector2(x, y), 2, Vector2i(1, 0))
	
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
		
		room.center = Vector2i()
		room.center.x = floor(room.x + room.w/2.0)
		room.center.y = floor(room.y + room.h/2.0)
		room.connected_rooms = []
		rooms.append(room)
		room_id += 1
		
	## Creates the rooms using the tilemap terrain function
	var cells_array = []
	for i in range(rooms.size()):
		var r = rooms[i]
		for x in range(r.x, r.x+r.w):
			for y in range(r.y, r.y + r.h):
				cells_array.append(Vector2i(x, y))
				
	set_cells_terrain_connect(0, cells_array, 0, 0, true)

## Joins rooms with corridors, by connecting every leaf pair.
func join_rooms():
	if path:
		for p in path.get_point_ids():
			for c in path.get_point_connections(p):
				##for each connection in every point in the AStar:
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				
				var center1 = Vector2i(pp.x, pp.y)
				var center2 = Vector2i(cp.x, cp.y)
				connect_rooms(center1, center2)

## Creates paths between two rooms
func connect_rooms(center1, center2):
	
	## Man, i'm sorry, but i don't know other way to do this.
	## Checks if we've alredy joined the rooms.
	for room1 in range(rooms.size()):
		if rooms[room1].center == center1:
			for room2 in range(rooms.size()):
				if rooms[room2].center == center2:
					for connection in rooms[room1].connected_rooms:
						if connection == room2:
							return null
	
	var x = min(center1.x, center2.x)
	var y = min(center1.y, center2.y)
	var w = 4
	var h = 4
	
	var cells_array = []
	
	##Checks if the connection is horizontal, vertical, or diagonal
	if(center1.x == center2.x):
		x -= floor(w/2.0)+1
		h = abs(center1.y - center2.y)
		
	elif(center1.y == center2.y):
		y -= floor(h/2.0)+1
		w = abs(center1.x - center2.x)
	
	
	##NEEDS TO BE FINISHED
	else:
		var xmin = min(center1.x, center2.x)
		var xmax = max(center1.x, center2.x)
		var ymin = min(center1.y, center2.y)
		var ymax = max(center1.y, center2.y)
		
		for i in range(xmin, xmax):
			for j in range(ymin, ymin+h):
				cells_array.append(Vector2i(i, j))
				
		if get_cell_atlas_coords(0, Vector2i(xmax+1, ymin)) == ROOF:
			xmin = xmax
			
		for i in range(xmin, xmin+h):
			for j in range(ymin, ymax):
				cells_array.append(Vector2i(i, j))
				
		set_cells_terrain_connect(0, cells_array, 0, 0, true)
		add_connection(center1, center2)
		return
		
	x = 0 if (x < 0) else x
	y = 0 if (y < 0) else y
	
	for i in range(x, x+w):
		for j in range(y, y+h):
			if get_cell_atlas_coords(0, Vector2i(i, j)) == ROOF:
				#set_cell(0, Vector2i(i,j), 1, GROUND)
				cells_array.append(Vector2i(i, j))
				
	set_cells_terrain_connect(0, cells_array, 0, 0, true)
	add_connection(center1, center2)

## Adds the connection bewteen each room so every room knows to wich other
## room it's connected to
func add_connection(point1, point2):
	for room1 in range(rooms.size()):
		if rooms[room1].center == point1:
			for room2 in range(rooms.size()):
				if rooms[room2].center == point2:
					rooms[room1].connected_rooms.append(room2)
					rooms[room2].connected_rooms.append(room1)

## Minnimum spanning tree algorythm, to figure out the shortest connection between rooms.
func find_mst(room_positions):
	path = AStar2D.new()
	path.add_point(path.get_available_point_id(), room_positions.pop_front())
	
	while room_positions:
		var min_dist = INF
		var min_pos = null
		var pos = null
		
		for p1 in path.get_point_ids():
			var pos1 = path.get_point_position(p1)
			
			for pos2 in room_positions:
				if pos1.distance_to(pos2) < min_dist:
					min_dist = pos1.distance_to(pos2)
					min_pos = pos2
					pos = pos1
					
		var n = path.get_available_point_id()
		path.add_point(n, min_pos)
		path.connect_points(path.get_closest_point(pos), n)
		room_positions.erase(min_pos)
	
	return path
