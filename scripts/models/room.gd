class_name RoomData extends Resource

enum Department {
	EMERGENCY_DEPARTMENT, INTERNAL_MEDICINE, SURGERY, ORTHOPEDICS,
	CARDIOLOGY, NEUROLOGY, PEDIATRICS, OBGYN, ONCOLOGY,
	RADIOLOGY, PATHOLOGY_LAB, PHARMACY, INTENSIVE_CARE
}

enum RoomType {
	RECEPTION, GP_OFFICE, EXAMINATION_ROOM, EMERGENCY_BAY, TRIAGE_ROOM,
	OPERATING_ROOM, RECOVERY_ROOM, GENERAL_WARD, PRIVATE_ROOM, ICU_BAY,
	LABORATORY, BLOOD_BANK, RADIOLOGY_ROOM, PHARMACY_ROOM, PHYSICAL_THERAPY,
	ENDOSCOPY_ROOM, CATHETERIZATION_LAB, DIALYSIS_CENTER, CHEMOTHERAPY_ROOM,
	NURSERY_ROOM, DELIVERY_ROOM, RESTROOM, CAFETERIA, SUPPLY_ROOM,
	MAINTENANCE_ROOM, ADMINISTRATIVE_OFFICE, CONFERENCE_ROOM, STAFF_LOUNGE,
	PARKING, MORGUE
}

@export var id: String = ""
@export var type: RoomType = RoomType.RECEPTION
@export var origin_x: int = 0
@export var origin_y: int = 0
@export var width: int = 3
@export var height: int = 3
@export var department: Department = Department.EMERGENCY_DEPARTMENT
@export var assigned_staff_ids: Array[String] = []
@export var patient_capacity: int = 1
@export var is_operational: bool = false


func _init():
	id = generate_uuid()


static func generate_uuid() -> String:
	var chars = "abcdef0123456789"
	var uuid = ""
	for i in range(32):
		if i == 8 or i == 12 or i == 16 or i == 20:
			uuid += "-"
		uuid += chars[randi() % chars.length()]
	return uuid


static func get_department_name(dept: Department) -> String:
	match dept:
		Department.EMERGENCY_DEPARTMENT: return "Emergency Department"
		Department.INTERNAL_MEDICINE: return "Internal Medicine"
		Department.SURGERY: return "Surgery"
		Department.ORTHOPEDICS: return "Orthopedics"
		Department.CARDIOLOGY: return "Cardiology"
		Department.NEUROLOGY: return "Neurology"
		Department.PEDIATRICS: return "Pediatrics"
		Department.OBGYN: return "OB/GYN"
		Department.ONCOLOGY: return "Oncology"
		Department.RADIOLOGY: return "Radiology"
		Department.PATHOLOGY_LAB: return "Pathology Lab"
		Department.PHARMACY: return "Pharmacy"
		Department.INTENSIVE_CARE: return "Intensive Care"
	return ""


static func get_room_type_name(rt: RoomType) -> String:
	match rt:
		RoomType.RECEPTION: return "Reception"
		RoomType.GP_OFFICE: return "GP Office"
		RoomType.EXAMINATION_ROOM: return "Examination Room"
		RoomType.EMERGENCY_BAY: return "Emergency Bay"
		RoomType.TRIAGE_ROOM: return "Triage Room"
		RoomType.OPERATING_ROOM: return "Operating Room"
		RoomType.RECOVERY_ROOM: return "Recovery Room"
		RoomType.GENERAL_WARD: return "General Ward"
		RoomType.PRIVATE_ROOM: return "Private Room"
		RoomType.ICU_BAY: return "ICU Bay"
		RoomType.LABORATORY: return "Laboratory"
		RoomType.BLOOD_BANK: return "Blood Bank"
		RoomType.RADIOLOGY_ROOM: return "Radiology Room"
		RoomType.PHARMACY_ROOM: return "Pharmacy Room"
		RoomType.PHYSICAL_THERAPY: return "Physical Therapy"
		RoomType.ENDOSCOPY_ROOM: return "Endoscopy Room"
		RoomType.CATHETERIZATION_LAB: return "Catheterization Lab"
		RoomType.DIALYSIS_CENTER: return "Dialysis Center"
		RoomType.CHEMOTHERAPY_ROOM: return "Chemotherapy Room"
		RoomType.NURSERY_ROOM: return "Nursery Room"
		RoomType.DELIVERY_ROOM: return "Delivery Room"
		RoomType.RESTROOM: return "Restroom"
		RoomType.CAFETERIA: return "Cafeteria"
		RoomType.SUPPLY_ROOM: return "Supply Room"
		RoomType.MAINTENANCE_ROOM: return "Maintenance Room"
		RoomType.ADMINISTRATIVE_OFFICE: return "Administrative Office"
		RoomType.CONFERENCE_ROOM: return "Conference Room"
		RoomType.STAFF_LOUNGE: return "Staff Lounge"
		RoomType.PARKING: return "Parking"
		RoomType.MORGUE: return "Morgue"
	return ""
