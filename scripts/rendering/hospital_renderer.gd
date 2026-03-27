extends Node2D

# References
var game_state: Dictionary = {}

# Node layers
var grid_layer: Node2D
var room_layer: Node2D
var equipment_layer: Node2D
var entity_layer: Node2D
var ui_overlay_layer: Node2D

# Sprite tracking
var _room_sprites: Dictionary = {}      # room_id -> Node2D
var _staff_sprites: Dictionary = {}     # staff_id -> Node2D
var _patient_sprites: Dictionary = {}   # patient_id -> Node2D
var _equipment_sprites: Dictionary = {} # equip_id -> Node2D

# Stable position tracking to avoid jitter from randf_range every frame
var _staff_target_positions: Dictionary = {}    # staff_id -> Vector2
var _patient_target_positions: Dictionary = {}  # patient_id -> Vector2

# Build mode
var build_mode_active: bool = false
var build_room_type: int = -1
var ghost_preview: Node2D = null

# Grid line drawing node
var _grid_lines_node: Node2D = null

# Colors for departments (keyed by RoomData.Department enum values)
const DEPARTMENT_COLORS: Dictionary = {
	0: Color(0.9, 0.2, 0.2, 0.7),   # EMERGENCY_DEPARTMENT - Red
	1: Color(0.2, 0.5, 0.9, 0.7),   # INTERNAL_MEDICINE - Blue
	2: Color(0.2, 0.8, 0.3, 0.7),   # SURGERY - Green
	3: Color(0.6, 0.8, 0.2, 0.7),   # ORTHOPEDICS - Yellow-Green
	4: Color(0.7, 0.2, 0.7, 0.7),   # CARDIOLOGY - Purple
	5: Color(0.9, 0.6, 0.2, 0.7),   # NEUROLOGY - Orange
	6: Color(1.0, 0.7, 0.8, 0.7),   # PEDIATRICS - Pink
	7: Color(0.9, 0.5, 0.6, 0.7),   # OBGYN - Rose
	8: Color(0.5, 0.2, 0.5, 0.7),   # ONCOLOGY - Dark Purple
	9: Color(0.4, 0.7, 0.9, 0.7),   # RADIOLOGY - Light Blue
	10: Color(0.3, 0.6, 0.6, 0.7),  # PATHOLOGY_LAB - Teal
	11: Color(0.2, 0.7, 0.5, 0.7),  # PHARMACY - Mint
	12: Color(0.8, 0.3, 0.3, 0.7),  # INTENSIVE_CARE - Dark Red
}

# Colors for staff roles (keyed by StaffData.StaffRole enum values)
const STAFF_COLORS: Dictionary = {
	0: Color.LIGHT_GRAY,     # RECEPTIONIST
	1: Color.SANDY_BROWN,    # CNA
	2: Color.BURLYWOOD,      # LPN
	3: Color.CORNFLOWER_BLUE,# REGISTERED_NURSE
	4: Color.STEEL_BLUE,     # NURSE_PRACTITIONER
	5: Color.WHITE,          # GENERAL_PRACTITIONER
	6: Color.RED,            # EMERGENCY_PHYSICIAN
	7: Color.GREEN,          # GENERAL_SURGEON
	8: Color.PURPLE,         # CARDIOLOGIST
	9: Color.DARK_GREEN,     # ORTHOPEDIC_SURGEON
	10: Color.ORANGE,        # NEUROLOGIST
	11: Color.LIGHT_BLUE,    # RADIOLOGIST
	12: Color.TEAL,          # PATHOLOGIST
	13: Color.DARK_CYAN,     # ANESTHESIOLOGIST
	14: Color.DARK_MAGENTA,  # ONCOLOGIST
	15: Color.MEDIUM_AQUAMARINE, # PHARMACIST
	16: Color.CADET_BLUE,    # LAB_TECHNICIAN
	17: Color.DARK_GRAY,     # JANITOR
	18: Color.GOLD,          # ADMINISTRATOR
}

# Colors for patient states (keyed by PatientData.PatientState enum values)
const PATIENT_STATE_COLORS: Dictionary = {
	0: Color.WHITE,          # ARRIVING
	1: Color.YELLOW,         # WAITING_FOR_REGISTRATION
	2: Color.LIGHT_YELLOW,   # REGISTERED
	3: Color.YELLOW,         # WAITING_FOR_EXAM
	4: Color.ORANGE,         # IN_EXAMINATION
	5: Color.SANDY_BROWN,    # AWAITING_TEST_RESULTS
	6: Color.CORNFLOWER_BLUE,# DIAGNOSED
	7: Color.DARK_ORANGE,    # WAITING_FOR_TREATMENT
	8: Color.RED,            # IN_TREATMENT
	9: Color.ORANGE_RED,     # ADMITTED
	10: Color.GREEN,         # RECOVERING
	11: Color.GRAY,          # DISCHARGED
	12: Color.DARK_RED,      # DECEASED
}


func _ready():
	grid_layer = Node2D.new()
	grid_layer.name = "GridLayer"
	room_layer = Node2D.new()
	room_layer.name = "RoomLayer"
	equipment_layer = Node2D.new()
	equipment_layer.name = "EquipmentLayer"
	entity_layer = Node2D.new()
	entity_layer.name = "EntityLayer"
	ui_overlay_layer = Node2D.new()
	ui_overlay_layer.name = "UIOverlayLayer"
	add_child(grid_layer)
	add_child(room_layer)
	add_child(equipment_layer)
	add_child(entity_layer)
	add_child(ui_overlay_layer)


func initialize(state: Dictionary):
	game_state = state
	_draw_grid()


func update_visuals():
	_update_rooms()
	_update_equipment()
	_update_staff()
	_update_patients()


# ---------------------------------------------------------------------------
# Grid drawing
# ---------------------------------------------------------------------------

func _draw_grid():
	# Background fill
	var grid_w: float = GameConstants.GRID_WIDTH * GameConstants.TILE_SIZE
	var grid_h: float = GameConstants.GRID_HEIGHT * GameConstants.TILE_SIZE

	var bg = ColorRect.new()
	bg.color = Color(0.15, 0.18, 0.15)
	bg.size = Vector2(grid_w, grid_h)
	bg.name = "GridBackground"
	grid_layer.add_child(bg)

	# Draw grid lines via a custom-draw node so they batch efficiently
	_grid_lines_node = Node2D.new()
	_grid_lines_node.name = "GridLines"
	_grid_lines_node.set_script(_create_grid_lines_script())
	_grid_lines_node.set_meta("grid_w", grid_w)
	_grid_lines_node.set_meta("grid_h", grid_h)
	_grid_lines_node.set_meta("tile_size", GameConstants.TILE_SIZE)
	_grid_lines_node.set_meta("cols", GameConstants.GRID_WIDTH)
	_grid_lines_node.set_meta("rows", GameConstants.GRID_HEIGHT)
	grid_layer.add_child(_grid_lines_node)


func _create_grid_lines_script() -> GDScript:
	var src = """extends Node2D

func _draw():
	var gw: float = get_meta("grid_w")
	var gh: float = get_meta("grid_h")
	var ts: float = get_meta("tile_size")
	var cols: int = get_meta("cols")
	var rows: int = get_meta("rows")
	var line_color := Color(0.25, 0.28, 0.25, 0.5)
	# Vertical lines
	for x_idx in range(cols + 1):
		var xp: float = x_idx * ts
		draw_line(Vector2(xp, 0), Vector2(xp, gh), line_color, 1.0)
	# Horizontal lines
	for y_idx in range(rows + 1):
		var yp: float = y_idx * ts
		draw_line(Vector2(0, yp), Vector2(gw, yp), line_color, 1.0)
"""
	var script = GDScript.new()
	script.source_code = src
	script.reload()
	return script


# ---------------------------------------------------------------------------
# Rooms
# ---------------------------------------------------------------------------

func _update_rooms():
	var current_room_ids: Dictionary = {}
	var rooms_array: Array = game_state.get("hospital", {}).get("rooms", [])
	for room in rooms_array:
		var room_id: String = room.get("id", "")
		current_room_ids[room_id] = true
		if not _room_sprites.has(room_id):
			_create_room_sprite(room)
		_update_room_sprite(room)
	# Remove sprites for rooms that no longer exist
	for id in _room_sprites.keys():
		if not current_room_ids.has(id):
			_room_sprites[id].queue_free()
			_room_sprites.erase(id)


func _create_room_sprite(room: Dictionary):
	var sprite = Node2D.new()
	sprite.name = "Room_" + room.get("id", "unknown")

	var room_w: float = room.get("width", 3) * GameConstants.TILE_SIZE
	var room_h: float = room.get("height", 3) * GameConstants.TILE_SIZE

	# Floor color
	var floor_rect = ColorRect.new()
	floor_rect.name = "Floor"
	var dept: int = room.get("department", 0)
	floor_rect.color = DEPARTMENT_COLORS.get(dept, Color(0.5, 0.5, 0.5, 0.7))
	floor_rect.size = Vector2(room_w, room_h)
	sprite.add_child(floor_rect)

	# Wall outline
	var outline: Line2D = _create_outline(Vector2(room_w, room_h), Color(0.3, 0.3, 0.3))
	outline.name = "Outline"
	sprite.add_child(outline)

	# Room label
	var label = Label.new()
	label.name = "RoomLabel"
	label.text = RoomData.get_room_type_name(room.get("type", 0))
	label.add_theme_font_size_override("font_size", 10)
	label.position = Vector2(4, 4)
	sprite.add_child(label)

	# Capacity label
	var cap_label = Label.new()
	cap_label.name = "CapLabel"
	var capacity: int = room.get("patient_capacity", 0)
	cap_label.text = "Cap: " + str(capacity) if capacity > 0 else ""
	cap_label.add_theme_font_size_override("font_size", 8)
	cap_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	cap_label.position = Vector2(4, room_h - 16)
	sprite.add_child(cap_label)

	# Operational status indicator (small colored square, top-right corner)
	var status_indicator = ColorRect.new()
	status_indicator.name = "StatusIndicator"
	status_indicator.size = Vector2(8, 8)
	status_indicator.position = Vector2(room_w - 12, 4)
	status_indicator.color = Color.RED
	sprite.add_child(status_indicator)

	# Door marker (small gap on the bottom wall)
	var door = ColorRect.new()
	door.name = "Door"
	door.color = Color(0.4, 0.3, 0.2)
	door.size = Vector2(GameConstants.TILE_SIZE * 0.5, 4)
	door.position = Vector2(room_w / 2.0 - door.size.x / 2.0, room_h - 2)
	sprite.add_child(door)

	sprite.position = Vector2(
		room.get("origin_x", 0) * GameConstants.TILE_SIZE,
		room.get("origin_y", 0) * GameConstants.TILE_SIZE
	)
	room_layer.add_child(sprite)
	_room_sprites[room.get("id", "")] = sprite


func _update_room_sprite(room: Dictionary):
	var sprite: Node2D = _room_sprites.get(room.get("id", ""))
	if sprite == null:
		return
	# Update operational status color
	var indicator: ColorRect = sprite.get_node_or_null("StatusIndicator") as ColorRect
	if indicator:
		if room.get("is_operational", false):
			indicator.color = Color.GREEN
		else:
			indicator.color = Color.RED
	# Update floor color in case department changed
	var floor_rect: ColorRect = sprite.get_node_or_null("Floor") as ColorRect
	if floor_rect:
		var dept: int = room.get("department", 0)
		floor_rect.color = DEPARTMENT_COLORS.get(dept, Color(0.5, 0.5, 0.5, 0.7))


func _create_outline(rect_size: Vector2, color: Color) -> Line2D:
	var line = Line2D.new()
	line.points = [
		Vector2.ZERO,
		Vector2(rect_size.x, 0),
		rect_size,
		Vector2(0, rect_size.y),
		Vector2.ZERO
	]
	line.width = 2.0
	line.default_color = color
	return line


# ---------------------------------------------------------------------------
# Equipment
# ---------------------------------------------------------------------------

func _update_equipment():
	var current_ids: Dictionary = {}
	var equip_array: Array = game_state.get("equipment", [])
	for equip in equip_array:
		var eid: String = equip.get("id", "")
		current_ids[eid] = true
		if not _equipment_sprites.has(eid):
			_create_equipment_sprite(equip)
		_update_equipment_sprite(equip)
	for id in _equipment_sprites.keys():
		if not current_ids.has(id):
			_equipment_sprites[id].queue_free()
			_equipment_sprites.erase(id)


func _create_equipment_sprite(equip: Dictionary):
	var sprite = Node2D.new()
	sprite.name = "Equip_" + equip.get("id", "unknown")

	# Small colored square representing the equipment
	var icon = ColorRect.new()
	icon.name = "Icon"
	icon.size = Vector2(12, 12)
	icon.color = Color(0.6, 0.6, 0.8, 0.9)
	icon.position = Vector2(-6, -6)
	sprite.add_child(icon)

	# Equipment label
	var label = Label.new()
	label.name = "EquipLabel"
	var tmpl: String = equip.get("template_name", "")
	label.text = tmpl.substr(0, 8) if tmpl.length() > 8 else tmpl
	label.add_theme_font_size_override("font_size", 7)
	label.position = Vector2(8, -6)
	sprite.add_child(label)

	# Condition bar background
	var cond_bg = ColorRect.new()
	cond_bg.name = "CondBG"
	cond_bg.size = Vector2(12, 3)
	cond_bg.color = Color(0.3, 0.3, 0.3)
	cond_bg.position = Vector2(-6, 8)
	sprite.add_child(cond_bg)

	# Condition bar fill
	var cond_fill = ColorRect.new()
	cond_fill.name = "CondFill"
	cond_fill.size = Vector2(12, 3)
	cond_fill.color = Color.GREEN
	cond_fill.position = Vector2(-6, 8)
	sprite.add_child(cond_fill)

	equipment_layer.add_child(sprite)
	_equipment_sprites[equip.get("id", "")] = sprite

	# Position inside its room
	_position_equipment_in_room(equip, sprite)


func _update_equipment_sprite(equip: Dictionary):
	var sprite: Node2D = _equipment_sprites.get(equip.get("id", ""))
	if sprite == null:
		return
	# Update condition bar
	var condition: float = equip.get("condition", 1.0)
	var cond_fill: ColorRect = sprite.get_node_or_null("CondFill") as ColorRect
	if cond_fill:
		cond_fill.size.x = 12.0 * clampf(condition, 0.0, 1.0)
		if condition > 0.6:
			cond_fill.color = Color.GREEN
		elif condition > 0.3:
			cond_fill.color = Color.YELLOW
		else:
			cond_fill.color = Color.RED


func _position_equipment_in_room(equip: Dictionary, sprite: Node2D):
	var room_id: String = equip.get("installed_room_id", "")
	if room_id == "":
		sprite.visible = false
		return
	var room: Dictionary = _find_room(room_id)
	if room.is_empty():
		sprite.visible = false
		return
	sprite.visible = true
	# Place equipment at a deterministic offset within the room based on its id hash
	var hash_val: int = equip.get("id", "x").hash()
	var margin: float = 0.8
	var ox: float = room.get("origin_x", 0) + margin + fmod(abs(float(hash_val % 1000)) / 1000.0 * (room.get("width", 3) - 2 * margin), room.get("width", 3) - 2 * margin)
	var oy: float = room.get("origin_y", 0) + margin + fmod(abs(float((hash_val / 1000) % 1000)) / 1000.0 * (room.get("height", 3) - 2 * margin), room.get("height", 3) - 2 * margin)
	sprite.position = Vector2(ox * GameConstants.TILE_SIZE, oy * GameConstants.TILE_SIZE)


# ---------------------------------------------------------------------------
# Staff
# ---------------------------------------------------------------------------

func _update_staff():
	var current_ids: Dictionary = {}
	var staff_array: Array = game_state.get("staff", [])
	for staff in staff_array:
		var sid: String = staff.get("id", "")
		current_ids[sid] = true
		if not _staff_sprites.has(sid):
			_create_staff_sprite(staff)
		_position_staff_sprite(staff)
	for id in _staff_sprites.keys():
		if not current_ids.has(id):
			_staff_sprites[id].queue_free()
			_staff_sprites.erase(id)
			_staff_target_positions.erase(id)


func _create_staff_sprite(staff: Dictionary):
	var sprite = Node2D.new()
	sprite.name = "Staff_" + staff.get("id", "unknown")
	sprite.set_script(preload("res://scripts/rendering/circle_sprite.gd"))
	var role: int = staff.get("role", 0)
	sprite.color = STAFF_COLORS.get(role, Color.WHITE)
	sprite.radius = 6.0

	# Role abbreviation label
	var role_label = Label.new()
	role_label.name = "RoleLabel"
	role_label.text = StaffData.get_role_short_name(role)
	role_label.add_theme_font_size_override("font_size", 7)
	role_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	role_label.position = Vector2(8, -10)
	sprite.add_child(role_label)

	# Name label (first name only)
	var name_label = Label.new()
	name_label.name = "NameLabel"
	var full_name: String = staff.get("staff_name", "")
	var parts: PackedStringArray = full_name.split(" ")
	name_label.text = parts[0] if parts.size() > 0 else ""
	name_label.add_theme_font_size_override("font_size", 8)
	name_label.position = Vector2(8, -1)
	sprite.add_child(name_label)

	# Fatigue indicator bar
	var fatigue_bg = ColorRect.new()
	fatigue_bg.name = "FatigueBG"
	fatigue_bg.size = Vector2(12, 2)
	fatigue_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	fatigue_bg.position = Vector2(-6, 9)
	sprite.add_child(fatigue_bg)

	var fatigue_fill = ColorRect.new()
	fatigue_fill.name = "FatigueFill"
	fatigue_fill.size = Vector2(12, 2)
	fatigue_fill.color = Color.GREEN
	fatigue_fill.position = Vector2(-6, 9)
	sprite.add_child(fatigue_fill)

	entity_layer.add_child(sprite)
	_staff_sprites[staff.get("id", "")] = sprite


func _position_staff_sprite(staff: Dictionary):
	var sid: String = staff.get("id", "")
	var sprite: Node2D = _staff_sprites.get(sid)
	if sprite == null:
		return

	# Update fatigue bar
	var fatigue: float = staff.get("fatigue", 0.0)
	var fatigue_fill: ColorRect = sprite.get_node_or_null("FatigueFill") as ColorRect
	if fatigue_fill:
		var ratio: float = clampf(fatigue / GameConstants.MAX_STAFF_FATIGUE, 0.0, 1.0)
		fatigue_fill.size.x = 12.0 * ratio
		if ratio < 0.4:
			fatigue_fill.color = Color.GREEN
		elif ratio < 0.7:
			fatigue_fill.color = Color.YELLOW
		else:
			fatigue_fill.color = Color.RED

	# Dim sprite if off duty
	var on_duty: bool = staff.get("is_on_duty", true)
	sprite.modulate = Color.WHITE if on_duty else Color(0.5, 0.5, 0.5, 0.6)

	# Determine target position inside assigned room
	var room_id: String = staff.get("assigned_room_id", "")
	if room_id != "":
		var room: Dictionary = _find_room(room_id)
		if not room.is_empty():
			# Only compute a new random target when the room assignment changes
			if not _staff_target_positions.has(sid) or _staff_target_positions[sid].get("room_id", "") != room_id:
				var target = Vector2(
					(room.get("origin_x", 0) + _stable_rand(sid, 0, 0.5, room.get("width", 3) - 0.5)) * GameConstants.TILE_SIZE,
					(room.get("origin_y", 0) + _stable_rand(sid, 1, 0.5, room.get("height", 3) - 0.5)) * GameConstants.TILE_SIZE
				)
				_staff_target_positions[sid] = {"room_id": room_id, "pos": target}
			sprite.position = sprite.position.lerp(_staff_target_positions[sid].get("pos", sprite.position), 0.1)
	else:
		# Unassigned staff sit in a waiting area off-grid
		var fallback = Vector2(-GameConstants.TILE_SIZE * 2, sid.hash() % 10 * GameConstants.TILE_SIZE)
		sprite.position = sprite.position.lerp(fallback, 0.1)


# ---------------------------------------------------------------------------
# Patients
# ---------------------------------------------------------------------------

func _update_patients():
	var current_ids: Dictionary = {}
	var patient_array: Array = game_state.get("patients", [])
	for patient in patient_array:
		var pid: String = patient.get("id", "")
		var state_val: int = patient.get("state", 0)
		# Skip rendering discharged/deceased patients
		if state_val == PatientData.PatientState.DISCHARGED or state_val == PatientData.PatientState.DECEASED:
			continue
		current_ids[pid] = true
		if not _patient_sprites.has(pid):
			_create_patient_sprite(patient)
		_position_patient_sprite(patient)
	for id in _patient_sprites.keys():
		if not current_ids.has(id):
			_patient_sprites[id].queue_free()
			_patient_sprites.erase(id)
			_patient_target_positions.erase(id)


func _create_patient_sprite(patient: Dictionary):
	var sprite = Node2D.new()
	sprite.name = "Patient_" + patient.get("id", "unknown")
	sprite.set_script(preload("res://scripts/rendering/circle_sprite.gd"))
	sprite.radius = 5.0
	var state_val: int = patient.get("state", 0)
	sprite.color = PATIENT_STATE_COLORS.get(state_val, Color.WHITE)

	# Patient name label
	var name_label = Label.new()
	name_label.name = "NameLabel"
	var full_name: String = patient.get("patient_name", "")
	var parts: PackedStringArray = full_name.split(" ")
	name_label.text = parts[0] if parts.size() > 0 else ""
	name_label.add_theme_font_size_override("font_size", 7)
	name_label.position = Vector2(7, -4)
	sprite.add_child(name_label)

	# State label
	var state_label = Label.new()
	state_label.name = "StateLabel"
	state_label.text = PatientData.get_state_name(state_val)
	state_label.add_theme_font_size_override("font_size", 6)
	state_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	state_label.position = Vector2(7, 5)
	sprite.add_child(state_label)

	entity_layer.add_child(sprite)
	_patient_sprites[patient.get("id", "")] = sprite


func _position_patient_sprite(patient: Dictionary):
	var pid: String = patient.get("id", "")
	var sprite: Node2D = _patient_sprites.get(pid)
	if sprite == null:
		return

	# Update color and state label based on current state
	var state_val: int = patient.get("state", 0)
	sprite.color = PATIENT_STATE_COLORS.get(state_val, Color.WHITE)
	sprite.queue_redraw()

	var state_label: Label = sprite.get_node_or_null("StateLabel") as Label
	if state_label:
		state_label.text = PatientData.get_state_name(state_val)

	# Position inside current room
	var room_id: String = patient.get("current_room_id", "")
	if room_id != "":
		var room: Dictionary = _find_room(room_id)
		if not room.is_empty():
			if not _patient_target_positions.has(pid) or _patient_target_positions[pid].get("room_id", "") != room_id:
				var target = Vector2(
					(room.get("origin_x", 0) + _stable_rand(pid, 2, 0.5, room.get("width", 3) - 0.5)) * GameConstants.TILE_SIZE,
					(room.get("origin_y", 0) + _stable_rand(pid, 3, 0.5, room.get("height", 3) - 0.5)) * GameConstants.TILE_SIZE
				)
				_patient_target_positions[pid] = {"room_id": room_id, "pos": target}
			sprite.position = sprite.position.lerp(_patient_target_positions[pid].get("pos", sprite.position), 0.1)
	else:
		# Patients without a room gather near the hospital entrance (top-left area)
		var entrance_y: float = _stable_rand(pid, 4, 1.0, 5.0) * GameConstants.TILE_SIZE
		var entrance_x: float = _stable_rand(pid, 5, 0.5, 3.0) * GameConstants.TILE_SIZE
		sprite.position = sprite.position.lerp(Vector2(entrance_x, entrance_y), 0.1)


# ---------------------------------------------------------------------------
# Utility
# ---------------------------------------------------------------------------

func _find_room(room_id: String) -> Dictionary:
	var rooms_array: Array = game_state.get("hospital", {}).get("rooms", [])
	for room in rooms_array:
		if room.get("id", "") == room_id:
			return room
	return {}


## Returns a deterministic pseudo-random float in [min_val, max_val] based on the
## given id string and a salt integer so that positions remain stable across frames.
func _stable_rand(id: String, salt: int, min_val: float, max_val: float) -> float:
	var h: int = (id + str(salt)).hash()
	var t: float = fmod(abs(float(h)) / 2147483647.0, 1.0)
	return min_val + t * (max_val - min_val)


# ---------------------------------------------------------------------------
# Build mode
# ---------------------------------------------------------------------------

func enter_build_mode(room_type: int):
	build_mode_active = true
	build_room_type = room_type
	if ghost_preview != null:
		ghost_preview.queue_free()
	ghost_preview = Node2D.new()
	ghost_preview.name = "GhostPreview"
	ghost_preview.modulate = Color(1, 1, 1, 0.5)
	ui_overlay_layer.add_child(ghost_preview)

	# Create a semi-transparent room preview
	var room_def: Dictionary = _get_room_definition(room_type)
	var w: float = room_def.get("width", 3) * GameConstants.TILE_SIZE
	var h: float = room_def.get("height", 3) * GameConstants.TILE_SIZE
	var dept: int = room_def.get("department", 0)

	var preview_rect = ColorRect.new()
	preview_rect.name = "PreviewRect"
	preview_rect.size = Vector2(w, h)
	preview_rect.color = DEPARTMENT_COLORS.get(dept, Color(0.5, 0.5, 0.5, 0.5))
	ghost_preview.add_child(preview_rect)

	var preview_outline: Line2D = _create_outline(Vector2(w, h), Color.WHITE)
	preview_outline.name = "PreviewOutline"
	ghost_preview.add_child(preview_outline)

	var preview_label = Label.new()
	preview_label.name = "PreviewLabel"
	preview_label.text = RoomData.get_room_type_name(room_type)
	preview_label.add_theme_font_size_override("font_size", 10)
	preview_label.position = Vector2(4, 4)
	ghost_preview.add_child(preview_label)


func exit_build_mode():
	build_mode_active = false
	build_room_type = -1
	if ghost_preview != null:
		ghost_preview.queue_free()
		ghost_preview = null


func update_ghost_position(grid_pos: Vector2i):
	if ghost_preview == null:
		return
	ghost_preview.position = Vector2(
		grid_pos.x * GameConstants.TILE_SIZE,
		grid_pos.y * GameConstants.TILE_SIZE
	)


func set_ghost_valid(is_valid: bool):
	if ghost_preview == null:
		return
	var preview_outline: Line2D = ghost_preview.get_node_or_null("PreviewOutline") as Line2D
	if preview_outline:
		preview_outline.default_color = Color.GREEN if is_valid else Color.RED
	ghost_preview.modulate = Color(1, 1, 1, 0.5) if is_valid else Color(1, 0.3, 0.3, 0.5)


func grid_position_from_world(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(world_pos.x / GameConstants.TILE_SIZE),
		int(world_pos.y / GameConstants.TILE_SIZE)
	)


func _get_room_definition(room_type: int) -> Dictionary:
	# Try to get from RoomDefinitions autoload, fall back to defaults
	if Engine.has_singleton("RoomDefinitions"):
		var rd = Engine.get_singleton("RoomDefinitions")
		if rd.has_method("get_definition"):
			return rd.get_definition(room_type)
	# Fallback default sizes
	return {"width": 3, "height": 3, "department": 0}
