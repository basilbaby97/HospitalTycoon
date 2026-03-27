extends Camera2D

const PAN_SPEED := 500.0
const ZOOM_SPEED := 0.1
const MIN_ZOOM := 0.3
const MAX_ZOOM := 3.0

var _is_dragging := false
var _drag_start := Vector2.ZERO

func _ready():
	zoom = Vector2(1.0, 1.0)
	# Center on grid
	position = Vector2(
		GameConstants.GRID_WIDTH * GameConstants.TILE_SIZE / 2.0,
		GameConstants.GRID_HEIGHT * GameConstants.TILE_SIZE / 2.0
	)

func _process(delta: float):
	var move = Vector2.ZERO
	if Input.is_action_pressed("camera_pan_up"):
		move.y -= 1
	if Input.is_action_pressed("camera_pan_down"):
		move.y += 1
	if Input.is_action_pressed("camera_pan_left"):
		move.x -= 1
	if Input.is_action_pressed("camera_pan_right"):
		move.x += 1
	if move != Vector2.ZERO:
		position += move.normalized() * PAN_SPEED * delta / zoom.x
	_clamp_position()

func _unhandled_input(event: InputEvent):
	# Mouse wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at(get_global_mouse_position(), ZOOM_SPEED)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at(get_global_mouse_position(), -ZOOM_SPEED)

	# Middle mouse drag
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		_is_dragging = event.pressed
		_drag_start = event.position
	elif event is InputEventMouseMotion and _is_dragging:
		position -= event.relative / zoom.x

func _zoom_at(target: Vector2, factor: float):
	var old_zoom = zoom
	zoom = (zoom + Vector2.ONE * factor).clamp(Vector2.ONE * MIN_ZOOM, Vector2.ONE * MAX_ZOOM)
	# Adjust position to zoom toward mouse
	var zoom_change = zoom - old_zoom
	position += (target - position) * (zoom_change.x / zoom.x)
	_clamp_position()

func _clamp_position():
	var grid_size = Vector2(
		GameConstants.GRID_WIDTH * GameConstants.TILE_SIZE,
		GameConstants.GRID_HEIGHT * GameConstants.TILE_SIZE
	)
	position = position.clamp(-grid_size * 0.2, grid_size * 1.2)

func center_on(pos: Vector2):
	position = pos

func zoom_to_fit():
	var grid_size = Vector2(
		GameConstants.GRID_WIDTH * GameConstants.TILE_SIZE,
		GameConstants.GRID_HEIGHT * GameConstants.TILE_SIZE
	)
	var viewport_size = get_viewport_rect().size
	var zoom_x = viewport_size.x / grid_size.x
	var zoom_y = viewport_size.y / grid_size.y
	var fit_zoom = min(zoom_x, zoom_y)
	zoom = Vector2.ONE * clamp(fit_zoom, MIN_ZOOM, MAX_ZOOM)
	position = grid_size / 2.0
