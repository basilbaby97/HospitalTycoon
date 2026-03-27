extends Node

var _salary_ranges: Dictionary = {}

var _first_names: Array[String] = [
	"James", "Mary", "Robert", "Patricia", "John", "Jennifer", "Michael", "Linda",
	"David", "Elizabeth", "William", "Barbara", "Richard", "Susan", "Joseph", "Jessica",
	"Thomas", "Sarah", "Christopher", "Karen", "Charles", "Lisa", "Daniel", "Nancy",
	"Matthew", "Betty", "Anthony", "Margaret", "Mark", "Sandra", "Donald", "Ashley",
	"Steven", "Emily", "Andrew", "Donna", "Joshua", "Michelle", "Kenneth", "Carol"
]

var _last_names: Array[String] = [
	"Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
	"Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
	"Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson",
	"White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker",
	"Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores"
]


func _ready():
	_init_salary_ranges()


func _init_salary_ranges():
	_salary_ranges = {
		StaffData.StaffRole.RECEPTIONIST: {"min": 28000, "max": 38000, "base": 33000},
		StaffData.StaffRole.CNA: {"min": 30000, "max": 38000, "base": 34000},
		StaffData.StaffRole.LPN: {"min": 48000, "max": 64000, "base": 56000},
		StaffData.StaffRole.REGISTERED_NURSE: {"min": 70000, "max": 120000, "base": 95000},
		StaffData.StaffRole.NURSE_PRACTITIONER: {"min": 110000, "max": 140000, "base": 125000},
		StaffData.StaffRole.GENERAL_PRACTITIONER: {"min": 200000, "max": 280000, "base": 240000},
		StaffData.StaffRole.EMERGENCY_PHYSICIAN: {"min": 265000, "max": 420000, "base": 340000},
		StaffData.StaffRole.GENERAL_SURGEON: {"min": 300000, "max": 450000, "base": 375000},
		StaffData.StaffRole.CARDIOLOGIST: {"min": 350000, "max": 550000, "base": 450000},
		StaffData.StaffRole.ORTHOPEDIC_SURGEON: {"min": 400000, "max": 650000, "base": 525000},
		StaffData.StaffRole.NEUROLOGIST: {"min": 280000, "max": 450000, "base": 365000},
		StaffData.StaffRole.RADIOLOGIST: {"min": 300000, "max": 500000, "base": 400000},
		StaffData.StaffRole.PATHOLOGIST: {"min": 250000, "max": 400000, "base": 325000},
		StaffData.StaffRole.ANESTHESIOLOGIST: {"min": 350000, "max": 500000, "base": 425000},
		StaffData.StaffRole.ONCOLOGIST: {"min": 300000, "max": 500000, "base": 400000},
		StaffData.StaffRole.PHARMACIST: {"min": 100000, "max": 150000, "base": 125000},
		StaffData.StaffRole.LAB_TECHNICIAN: {"min": 45000, "max": 65000, "base": 55000},
		StaffData.StaffRole.JANITOR: {"min": 25000, "max": 35000, "base": 30000},
		StaffData.StaffRole.ADMINISTRATOR: {"min": 150000, "max": 300000, "base": 225000},
	}


func get_salary_range(role: StaffData.StaffRole) -> Dictionary:
	return _salary_ranges.get(role, {"min": 30000, "max": 50000, "base": 40000})


func generate_candidate(role: StaffData.StaffRole) -> Dictionary:
	var salary_range: Dictionary = get_salary_range(role)
	var skill_value: float = randf_range(0.3, 0.95)
	var salary_factor: float = randf_range(0.0, 1.0)
	var salary: int = int(lerpf(float(salary_range["min"]), float(salary_range["max"]), salary_factor))

	return {
		"name": generate_name(),
		"role": role,
		"skill": skill_value,
		"salary": salary,
		"satisfaction": randf_range(70.0, 95.0),
	}


func generate_name() -> String:
	var first: String = _first_names[randi() % _first_names.size()]
	var last: String = _last_names[randi() % _last_names.size()]
	return first + " " + last
