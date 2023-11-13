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
## Tileset ID
@export var tileset_id : int = 2

@export_group("Other options")
## Generate on _ready()
@export var auto_generate : bool = false
## enemy scenes
@export var enemy1 : Resource
@export var enemy2 : Resource
@export var hard_enemy : Resource
@export var npc : Resource

var player : CharacterBody2D

const ROOF = Vector2i(1, 0)
var terrain_id = tileset_id-2

var tree = {} ## A dictionary with the entire tree.
var leaves = [] ## An array that has every id of every pair of leaves.
var leaf_id = 0 ## Current leaf id.

var rooms = [] ## An array containing all rooms in the map.
var enemy_rooms = [] ## An array containing indexes to enemy rooms.
var end_rooms = [] ## An array containing indexes to end rooms.
var spawn_room : int ## The room in wich the player spawns.
var item_room : int ## The room with a garanteed item.
var npc_room : int ## The room with an NPC.
var boss_room : int ##The boss room.

var hard_rooms = [] ## An array containing the indexes of hard enemy rooms
var normal_rooms = [] ## An array containing the indexes of normal enemy rooms
var enemy_rooms_nodes = [] ## An array containing the nodes with enemies

var path

var enemy_scenes = [] ##An array containing the enemy scenes
var item_scenes = []

## NOTE: change.
func _ready():
	item_scenes.append(load("res://Scenes/Itens/dagger_item.tscn"))
	item_scenes.append(load("res://Scenes/Itens/sword_item.tscn"))
	item_scenes.append(load("res://Scenes/Itens/hammer_item.tscn"))
	
	global_position = Vector2.ZERO
	player = get_tree().get_first_node_in_group("player")
	enemy_scenes.append(enemy1)
	enemy_scenes.append(enemy2)
	enemy_scenes.append(hard_enemy)
	
	## Working with seeds is not necessary for now.
	randomize()
	if auto_generate:
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
	
	if set_special_rooms():
		create_enemies()
		spawn_player()
		spawn_npc()
		spawn_item()
	
	
## Fills the entire map with roof tiles.
func fill_roof():
	for x in range(0, map_w):
		for y in range(0, map_h):
			set_cell(0, Vector2(x, y), tileset_id, Vector2i(1, 0))
	
## Starts/restarts the tree dictionary.
func start_tree():
	rooms = []
	end_rooms = []
	enemy_rooms = []
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
				
	set_cells_terrain_connect(0, cells_array, terrain_id, 0, true)

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
			
		if get_cell_atlas_coords(0, Vector2i(xmax+1, ymin)) == ROOF:
			xmin = xmax
			
		for i in range(xmin, xmin+h):
			for j in range(ymin, ymax):
				cells_array.append(Vector2i(i, j))
				
		set_cells_terrain_connect(0, cells_array, terrain_id, 0, true)
		add_connection(center1, center2)
		return
		
	x = 0 if (x < 0) else x
	y = 0 if (y < 0) else y
	
	for i in range(x, x+w):
		for j in range(y, y+h):
			if get_cell_atlas_coords(0, Vector2i(i, j)) == ROOF:
				cells_array.append(Vector2i(i, j))
				
	set_cells_terrain_connect(0, cells_array, terrain_id, 0, true)
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

## Sets values for spawn, boss, item and boss room.
func set_special_rooms():
	## find every room that has only 1 connected room
	for i in range(0, rooms.size()):
		if rooms[i].connected_rooms.size() == 1 && end_rooms.size() < 4:
			end_rooms.append(i)
		else:
			enemy_rooms.append(i)
	
	## Creates everything again if there isn't at least 4 end rooms
	if end_rooms.size() < 4:
		print_debug("Falhou! Criando de novo")
		generate()
		return false
	
	## Shuffles the array and sets randomly the dedicated rooms
	end_rooms.shuffle()
	spawn_room = end_rooms[0]
	item_room = end_rooms[1]
	npc_room = end_rooms[2]
	boss_room = end_rooms[3]
	
	return true

func create_enemies():
	enemy_rooms.shuffle()
	var hard_rooms_amount = ceil(room_amount/3.0)
	
	for i in range(0, hard_rooms_amount-1):
		if enemy_rooms[i]:
			hard_rooms.append(enemy_rooms[i])
	
	for i in range(hard_rooms_amount-1, enemy_rooms.size()):
		if enemy_rooms[i]:
			normal_rooms.append(enemy_rooms[i])
		
	print_debug(enemy_rooms)
	print_debug(hard_rooms)
	print_debug(normal_rooms)
	add_enemies(4, hard_rooms)
	add_enemies(3, normal_rooms)
	
func add_enemies(amount : int, room_array):
	for i in room_array:
		var new_room = Node2D.new()
		new_room.y_sort_enabled = true
		var new_enemies = []
		
		new_room.name = "room_" + str(i)
		new_room.position = Vector2(rooms[i].x*16, rooms[i].y*16)
		add_child(new_room)
		enemy_rooms_nodes.append(new_room)
		
		if amount < 4:
			for o in range(0, amount):
				new_enemies.append(enemy_scenes[randi_range(0, 1)].instantiate())
				new_room.add_child(new_enemies[o])
				
		else:
			var o = 0
			while o < 3:
				new_enemies.append(enemy_scenes[randi_range(0, 1)].instantiate())
				new_room.add_child(new_enemies[o])
				o+=1
			
			while o <= amount-1:
				new_enemies.append(enemy_scenes[2].instantiate())
				new_room.add_child(new_enemies[o])
				o+=1
			
		for o in new_room.get_children():
			var random_x = randi_range(32, (rooms[i].w * 16) - 32)
			var random_y = randi_range(32, (rooms[i].h * 16) - 32)
			o.position = Vector2(random_x, random_y)
			
			o.room_top_left = Vector2(rooms[i].x+2, rooms[i].y+2)
			o.room_size = Vector2(rooms[i].w-4, rooms[i].h-4)
			o.room_index = i

func spawn_player():
	player.position = Vector2(rooms[spawn_room].center.x*16, rooms[spawn_room].center.y*16)
	
func spawn_npc():
	var npc_instance = npc.instantiate()
	npc_instance.global_position = Vector2(rooms[npc_room].center.x*16, rooms[npc_room].center.y*16)
	add_child(npc_instance)

func spawn_item():
	var item_instance = item_scenes[randi_range(0, item_scenes.size()-1)].instantiate()
	item_instance.global_position = Vector2(rooms[item_room].center.x*16, rooms[item_room].center.y*16)
	add_child(item_instance)
