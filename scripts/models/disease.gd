class_name DiseaseData extends Resource

enum DiseaseSeverity { MILD, MODERATE, SEVERE, CRITICAL }

@export var id: String = ""
@export var disease_name: String = ""
@export var drg_code: String = ""
@export var icd_code: String = ""
@export var department: RoomData.Department = RoomData.Department.INTERNAL_MEDICINE
@export var severity: DiseaseSeverity = DiseaseSeverity.MODERATE
@export var symptoms: Array[Dictionary] = []
@export var required_tests: Array[int] = []
@export var treatment_room: RoomData.RoomType = RoomData.RoomType.GENERAL_WARD
@export var treatment_ticks: int = 8
@export var base_medicare_payment: float = 5000.0
@export var mortality_risk: float = 0.02


func _init():
	id = RoomData.generate_uuid()


static func get_severity_reputation_impact(sev: DiseaseSeverity) -> float:
	match sev:
		DiseaseSeverity.MILD: return 1.0
		DiseaseSeverity.MODERATE: return 1.5
		DiseaseSeverity.SEVERE: return 2.0
		DiseaseSeverity.CRITICAL: return 3.0
	return 1.0
