class_name InstalledEquipment extends Resource

@export var id: String = ""
@export var template_id: String = ""
@export var room_id: String = ""
@export var condition: float = 100.0
@export var install_day: int = 0

var is_operational: bool:
	get: return condition > 10.0


func _init():
	id = RoomData.generate_uuid()
