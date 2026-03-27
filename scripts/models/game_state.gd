class_name GameStateData extends Resource

enum GameSpeed { PAUSED, NORMAL, FAST, FASTEST }

enum GameEventType {
	FLU_SEASON, EQUIPMENT_FAILURE, CMS_AUDIT, STAFF_BURNOUT,
	VIP_PATIENT, MALPRACTICE_LAWSUIT, INSURANCE_RATE_CHANGE,
	JOINT_COMMISSION_INSPECTION, COMMUNITY_OUTREACH,
	TECHNOLOGY_GRANT, NATURAL_DISASTER
}

@export var hospital_name: String = "General Hospital"
@export var hospital: Dictionary = {}
@export var staff: Array[Dictionary] = []
@export var patients: Array[Dictionary] = []
@export var finance: Dictionary = {}
@export var claims: Array[Dictionary] = []
@export var insurance_contracts: Array[Dictionary] = []
@export var current_day: int = 1
@export var current_hour: int = 8
@export var current_month: int = 1
@export var current_year: int = 2024
@export var game_speed: GameSpeed = GameSpeed.PAUSED
@export var reputation: float = 50.0
@export var total_patients_discharged: int = 0
@export var total_misdiagnoses: int = 0
@export var active_events: Array[Dictionary] = []


static func get_speed_interval(speed: GameSpeed) -> float:
	match speed:
		GameSpeed.PAUSED: return 0.0
		GameSpeed.NORMAL: return 1.0
		GameSpeed.FAST: return 0.5
		GameSpeed.FASTEST: return 0.25
	return 1.0
