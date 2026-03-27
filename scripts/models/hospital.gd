class_name HospitalData extends Resource

enum TileType { EMPTY, FLOOR, WALL, DOOR }

@export var grid_width: int = 60
@export var grid_height: int = 60
@export var grid: Array = []
@export var rooms: Array[Dictionary] = []
@export var installed_equipment: Array[Dictionary] = []


func _init():
	_init_grid()


func _init_grid() -> void:
	grid.clear()
	for y in range(grid_height):
		var row: Array = []
		for x in range(grid_width):
			row.append({"type": TileType.EMPTY, "room_id": ""})
		grid.append(row)


func can_place_room(origin_x: int, origin_y: int, w: int, h: int) -> bool:
	if origin_x < 0 or origin_y < 0:
		return false
	if origin_x + w > grid_width or origin_y + h > grid_height:
		return false
	for y in range(origin_y, origin_y + h):
		for x in range(origin_x, origin_x + w):
			var tile: Dictionary = grid[y][x]
			if tile.get("type", TileType.EMPTY) != TileType.EMPTY:
				return false
	return true


func place_room(room_dict: Dictionary) -> bool:
	var ox: int = room_dict.get("origin_x", 0)
	var oy: int = room_dict.get("origin_y", 0)
	var w: int = room_dict.get("width", 3)
	var h: int = room_dict.get("height", 3)
	var room_id: String = room_dict.get("id", "")

	if not can_place_room(ox, oy, w, h):
		return false

	for y in range(oy, oy + h):
		for x in range(ox, ox + w):
			var is_edge: bool = (x == ox or x == ox + w - 1 or y == oy or y == oy + h - 1)
			if is_edge:
				grid[y][x] = {"type": TileType.WALL, "room_id": room_id}
			else:
				grid[y][x] = {"type": TileType.FLOOR, "room_id": room_id}

	# Place a door at the center of the bottom wall
	var door_x: int = ox + w / 2
	var door_y: int = oy + h - 1
	grid[door_y][door_x] = {"type": TileType.DOOR, "room_id": room_id}

	rooms.append(room_dict)
	return true


func remove_room(room_id: String) -> void:
	var room_index: int = -1
	for i in range(rooms.size()):
		if rooms[i].get("id", "") == room_id:
			room_index = i
			break

	if room_index == -1:
		return

	var room_dict: Dictionary = rooms[room_index]
	var ox: int = room_dict.get("origin_x", 0)
	var oy: int = room_dict.get("origin_y", 0)
	var w: int = room_dict.get("width", 3)
	var h: int = room_dict.get("height", 3)

	for y in range(oy, oy + h):
		for x in range(ox, ox + w):
			grid[y][x] = {"type": TileType.EMPTY, "room_id": ""}

	rooms.remove_at(room_index)

	# Remove any equipment installed in this room
	var equip_to_remove: Array[int] = []
	for i in range(installed_equipment.size()):
		if installed_equipment[i].get("room_id", "") == room_id:
			equip_to_remove.append(i)
	equip_to_remove.reverse()
	for i in equip_to_remove:
		installed_equipment.remove_at(i)


func install_equipment(equip_dict: Dictionary) -> void:
	installed_equipment.append(equip_dict)


func get_room_at(x: int, y: int) -> Dictionary:
	if x < 0 or y < 0 or x >= grid_width or y >= grid_height:
		return {}
	var tile: Dictionary = grid[y][x]
	var room_id: String = tile.get("room_id", "")
	if room_id.is_empty():
		return {}
	for room in rooms:
		if room.get("id", "") == room_id:
			return room
	return {}


func get_equipment_in_room(room_id: String) -> Array:
	var result: Array = []
	for equip in installed_equipment:
		if equip.get("room_id", "") == room_id:
			result.append(equip)
	return result


func get_rooms_of_type(type: RoomData.RoomType) -> Array:
	var result: Array = []
	for room in rooms:
		if room.get("type", -1) == type:
			result.append(room)
	return result


func get_rooms_in_department(dept: RoomData.Department) -> Array:
	var result: Array = []
	for room in rooms:
		if room.get("department", -1) == dept:
			result.append(room)
	return result
