class_name StaffData extends Resource

enum StaffRole {
	RECEPTIONIST, CNA, LPN, REGISTERED_NURSE, NURSE_PRACTITIONER,
	GENERAL_PRACTITIONER, EMERGENCY_PHYSICIAN, GENERAL_SURGEON,
	CARDIOLOGIST, ORTHOPEDIC_SURGEON, NEUROLOGIST, RADIOLOGIST,
	PATHOLOGIST, ANESTHESIOLOGIST, ONCOLOGIST, PHARMACIST,
	LAB_TECHNICIAN, JANITOR, ADMINISTRATOR
}

enum StaffCategory { ADMINISTRATIVE, NURSING, PHYSICIAN, SPECIALIST, SUPPORT }

@export var id: String = ""
@export var staff_name: String = ""
@export var role: StaffRole = StaffRole.RECEPTIONIST
@export var skill: float = 0.5
@export var salary: int = 33000
@export var fatigue: float = 0.0
@export var satisfaction: float = 80.0
@export var is_on_duty: bool = true
@export var assigned_room_id: String = ""
@export var assigned_department: int = -1
@export var current_task_id: String = ""
@export var hire_day: int = 0

var effective_skill: float:
	get: return skill * (1.0 - fatigue / 200.0)


func _init():
	id = RoomData.generate_uuid()


static func get_role_name(role: StaffRole) -> String:
	match role:
		StaffRole.RECEPTIONIST: return "Receptionist"
		StaffRole.CNA: return "Certified Nursing Assistant"
		StaffRole.LPN: return "Licensed Practical Nurse"
		StaffRole.REGISTERED_NURSE: return "Registered Nurse"
		StaffRole.NURSE_PRACTITIONER: return "Nurse Practitioner"
		StaffRole.GENERAL_PRACTITIONER: return "General Practitioner"
		StaffRole.EMERGENCY_PHYSICIAN: return "Emergency Physician"
		StaffRole.GENERAL_SURGEON: return "General Surgeon"
		StaffRole.CARDIOLOGIST: return "Cardiologist"
		StaffRole.ORTHOPEDIC_SURGEON: return "Orthopedic Surgeon"
		StaffRole.NEUROLOGIST: return "Neurologist"
		StaffRole.RADIOLOGIST: return "Radiologist"
		StaffRole.PATHOLOGIST: return "Pathologist"
		StaffRole.ANESTHESIOLOGIST: return "Anesthesiologist"
		StaffRole.ONCOLOGIST: return "Oncologist"
		StaffRole.PHARMACIST: return "Pharmacist"
		StaffRole.LAB_TECHNICIAN: return "Lab Technician"
		StaffRole.JANITOR: return "Janitor"
		StaffRole.ADMINISTRATOR: return "Administrator"
	return ""


static func get_role_short_name(role: StaffRole) -> String:
	match role:
		StaffRole.RECEPTIONIST: return "Recept."
		StaffRole.CNA: return "CNA"
		StaffRole.LPN: return "LPN"
		StaffRole.REGISTERED_NURSE: return "RN"
		StaffRole.NURSE_PRACTITIONER: return "NP"
		StaffRole.GENERAL_PRACTITIONER: return "GP"
		StaffRole.EMERGENCY_PHYSICIAN: return "ER Doc"
		StaffRole.GENERAL_SURGEON: return "Surgeon"
		StaffRole.CARDIOLOGIST: return "Cardio."
		StaffRole.ORTHOPEDIC_SURGEON: return "Ortho."
		StaffRole.NEUROLOGIST: return "Neuro."
		StaffRole.RADIOLOGIST: return "Radiol."
		StaffRole.PATHOLOGIST: return "Pathol."
		StaffRole.ANESTHESIOLOGIST: return "Anesth."
		StaffRole.ONCOLOGIST: return "Oncol."
		StaffRole.PHARMACIST: return "Pharm."
		StaffRole.LAB_TECHNICIAN: return "Lab Tech"
		StaffRole.JANITOR: return "Janitor"
		StaffRole.ADMINISTRATOR: return "Admin"
	return ""


static func get_role_category(role: StaffRole) -> StaffCategory:
	match role:
		StaffRole.RECEPTIONIST: return StaffCategory.ADMINISTRATIVE
		StaffRole.CNA: return StaffCategory.NURSING
		StaffRole.LPN: return StaffCategory.NURSING
		StaffRole.REGISTERED_NURSE: return StaffCategory.NURSING
		StaffRole.NURSE_PRACTITIONER: return StaffCategory.NURSING
		StaffRole.GENERAL_PRACTITIONER: return StaffCategory.PHYSICIAN
		StaffRole.EMERGENCY_PHYSICIAN: return StaffCategory.PHYSICIAN
		StaffRole.GENERAL_SURGEON: return StaffCategory.SPECIALIST
		StaffRole.CARDIOLOGIST: return StaffCategory.SPECIALIST
		StaffRole.ORTHOPEDIC_SURGEON: return StaffCategory.SPECIALIST
		StaffRole.NEUROLOGIST: return StaffCategory.SPECIALIST
		StaffRole.RADIOLOGIST: return StaffCategory.SPECIALIST
		StaffRole.PATHOLOGIST: return StaffCategory.SPECIALIST
		StaffRole.ANESTHESIOLOGIST: return StaffCategory.SPECIALIST
		StaffRole.ONCOLOGIST: return StaffCategory.SPECIALIST
		StaffRole.PHARMACIST: return StaffCategory.SUPPORT
		StaffRole.LAB_TECHNICIAN: return StaffCategory.SUPPORT
		StaffRole.JANITOR: return StaffCategory.SUPPORT
		StaffRole.ADMINISTRATOR: return StaffCategory.ADMINISTRATIVE
	return StaffCategory.SUPPORT


static func is_physician(role: StaffRole) -> bool:
	match role:
		StaffRole.GENERAL_PRACTITIONER: return true
		StaffRole.EMERGENCY_PHYSICIAN: return true
		StaffRole.GENERAL_SURGEON: return true
		StaffRole.CARDIOLOGIST: return true
		StaffRole.ORTHOPEDIC_SURGEON: return true
		StaffRole.NEUROLOGIST: return true
		StaffRole.RADIOLOGIST: return true
		StaffRole.PATHOLOGIST: return true
		StaffRole.ANESTHESIOLOGIST: return true
		StaffRole.ONCOLOGIST: return true
	return false
