extends Node

enum MarginProfile { COST_CENTER, REVENUE_CENTER, PROFIT_CENTER }

var _definitions: Dictionary = {}

var _general_rooms: Array = [
	RoomData.RoomType.RECEPTION,
	RoomData.RoomType.RESTROOM,
	RoomData.RoomType.CAFETERIA,
	RoomData.RoomType.SUPPLY_ROOM,
	RoomData.RoomType.MAINTENANCE_ROOM,
	RoomData.RoomType.ADMINISTRATIVE_OFFICE,
	RoomData.RoomType.CONFERENCE_ROOM,
	RoomData.RoomType.STAFF_LOUNGE,
	RoomData.RoomType.PARKING,
	RoomData.RoomType.MORGUE,
	RoomData.RoomType.PRIVATE_ROOM,
	RoomData.RoomType.GENERAL_WARD,
]


func _ready():
	_init_definitions()


func _init_definitions():
	_definitions = {
		RoomData.Department.EMERGENCY_DEPARTMENT: {
			"name": "Emergency Department",
			"margin": MarginProfile.REVENUE_CENTER,
			"unlock_cost": 0,
			"rooms": [RoomData.RoomType.EMERGENCY_BAY, RoomData.RoomType.TRIAGE_ROOM]
		},
		RoomData.Department.INTERNAL_MEDICINE: {
			"name": "Internal Medicine",
			"margin": MarginProfile.REVENUE_CENTER,
			"unlock_cost": 0,
			"rooms": [RoomData.RoomType.GP_OFFICE, RoomData.RoomType.EXAMINATION_ROOM]
		},
		RoomData.Department.SURGERY: {
			"name": "Surgery",
			"margin": MarginProfile.PROFIT_CENTER,
			"unlock_cost": 750000,
			"rooms": [RoomData.RoomType.OPERATING_ROOM, RoomData.RoomType.RECOVERY_ROOM]
		},
		RoomData.Department.ORTHOPEDICS: {
			"name": "Orthopedics",
			"margin": MarginProfile.PROFIT_CENTER,
			"unlock_cost": 1000000,
			"rooms": [RoomData.RoomType.OPERATING_ROOM, RoomData.RoomType.PHYSICAL_THERAPY]
		},
		RoomData.Department.CARDIOLOGY: {
			"name": "Cardiology",
			"margin": MarginProfile.PROFIT_CENTER,
			"unlock_cost": 1500000,
			"rooms": [RoomData.RoomType.CATHETERIZATION_LAB, RoomData.RoomType.GENERAL_WARD]
		},
		RoomData.Department.NEUROLOGY: {
			"name": "Neurology",
			"margin": MarginProfile.REVENUE_CENTER,
			"unlock_cost": 1200000,
			"rooms": [RoomData.RoomType.EXAMINATION_ROOM, RoomData.RoomType.GENERAL_WARD]
		},
		RoomData.Department.PEDIATRICS: {
			"name": "Pediatrics",
			"margin": MarginProfile.REVENUE_CENTER,
			"unlock_cost": 500000,
			"rooms": [RoomData.RoomType.NURSERY_ROOM, RoomData.RoomType.GENERAL_WARD]
		},
		RoomData.Department.OBGYN: {
			"name": "OB/GYN",
			"margin": MarginProfile.REVENUE_CENTER,
			"unlock_cost": 600000,
			"rooms": [RoomData.RoomType.DELIVERY_ROOM, RoomData.RoomType.NURSERY_ROOM]
		},
		RoomData.Department.ONCOLOGY: {
			"name": "Oncology",
			"margin": MarginProfile.PROFIT_CENTER,
			"unlock_cost": 2000000,
			"rooms": [RoomData.RoomType.CHEMOTHERAPY_ROOM, RoomData.RoomType.GENERAL_WARD]
		},
		RoomData.Department.RADIOLOGY: {
			"name": "Radiology",
			"margin": MarginProfile.COST_CENTER,
			"unlock_cost": 800000,
			"rooms": [RoomData.RoomType.RADIOLOGY_ROOM]
		},
		RoomData.Department.PATHOLOGY_LAB: {
			"name": "Pathology Lab",
			"margin": MarginProfile.COST_CENTER,
			"unlock_cost": 400000,
			"rooms": [RoomData.RoomType.LABORATORY, RoomData.RoomType.BLOOD_BANK]
		},
		RoomData.Department.PHARMACY: {
			"name": "Pharmacy",
			"margin": MarginProfile.COST_CENTER,
			"unlock_cost": 200000,
			"rooms": [RoomData.RoomType.PHARMACY_ROOM]
		},
		RoomData.Department.INTENSIVE_CARE: {
			"name": "Intensive Care",
			"margin": MarginProfile.REVENUE_CENTER,
			"unlock_cost": 1800000,
			"rooms": [RoomData.RoomType.ICU_BAY]
		},
	}


func get_definition(dept: RoomData.Department) -> Dictionary:
	return _definitions.get(dept, {})


func get_available_rooms(dept: RoomData.Department) -> Array:
	return _definitions.get(dept, {}).get("rooms", [])


func get_general_rooms() -> Array:
	return _general_rooms


func get_all_available_rooms(dept: RoomData.Department) -> Array:
	var rooms: Array = []
	rooms.append_array(get_available_rooms(dept))
	rooms.append_array(_general_rooms)
	return rooms


func get_unlock_cost(dept: RoomData.Department) -> int:
	return _definitions.get(dept, {}).get("unlock_cost", 0)


func get_margin_profile(dept: RoomData.Department) -> MarginProfile:
	return _definitions.get(dept, {}).get("margin", MarginProfile.COST_CENTER)
