class_name PatientData extends Resource

enum PatientState {
	ARRIVING, WAITING_FOR_REGISTRATION, REGISTERED, WAITING_FOR_EXAM,
	IN_EXAMINATION, AWAITING_TEST_RESULTS, DIAGNOSED, WAITING_FOR_TREATMENT,
	IN_TREATMENT, ADMITTED, RECOVERING, DISCHARGED, DECEASED
}

enum Symptom {
	FEVER, COUGH, SHORTNESS_OF_BREATH, CHEST_PAIN, HEADACHE,
	NAUSEA, VOMITING, ABDOMINAL_PAIN, DIARRHEA, FATIGUE,
	DIZZINESS, BACK_PAIN, JOINT_PAIN, RASH, SWELLING,
	BLURRED_VISION, CONFUSION, SEIZURE, PALPITATIONS, WEIGHT_LOSS,
	NIGHT_SWEATS, URINARY_FREQUENCY, BLOOD_IN_URINE,
	DIFFICULTY_SWALLOWING, NUMBNESS, WEAKNESS, HIP_PAIN, LEG_PAIN
}

@export var id: String = ""
@export var patient_name: String = ""
@export var age: int = 45
@export var payer_type: int = 0
@export var presenting_symptoms: Array[Dictionary] = []
@export var actual_disease_id: String = ""
@export var state: PatientState = PatientState.ARRIVING
@export var current_room_id: String = ""
@export var assigned_doctor_id: String = ""
@export var differential_diagnosis: Array[Dictionary] = []
@export var ordered_tests: Array[int] = []
@export var current_test_in_progress: int = -1
@export var test_progress_ticks: int = 0
@export var performed_tests: Array[int] = []
@export var test_results: Array[Dictionary] = []
@export var confirmed_disease_id: String = ""
@export var treatment_progress_ticks: int = 0
@export var treatment_total_ticks: int = 0
@export var is_treatment_successful: int = -1
@export var satisfaction: float = 100.0
@export var wait_time_hours: int = 0
@export var arrival_day: int = 0
@export var arrival_hour: int = 0

var top_differential: Dictionary:
	get:
		var active = differential_diagnosis.filter(func(d): return not d.get("ruled_out", false))
		if active.is_empty():
			return {}
		active.sort_custom(func(a, b): return a.get("probability", 0) > b.get("probability", 0))
		return active[0]

var can_confirm_diagnosis: bool:
	get:
		var top = top_differential
		return not top.is_empty() and top.get("probability", 0) >= 0.85


func _init():
	id = RoomData.generate_uuid()


static func get_symptom_name(symptom: Symptom) -> String:
	match symptom:
		Symptom.FEVER: return "Fever"
		Symptom.COUGH: return "Cough"
		Symptom.SHORTNESS_OF_BREATH: return "Shortness of Breath"
		Symptom.CHEST_PAIN: return "Chest Pain"
		Symptom.HEADACHE: return "Headache"
		Symptom.NAUSEA: return "Nausea"
		Symptom.VOMITING: return "Vomiting"
		Symptom.ABDOMINAL_PAIN: return "Abdominal Pain"
		Symptom.DIARRHEA: return "Diarrhea"
		Symptom.FATIGUE: return "Fatigue"
		Symptom.DIZZINESS: return "Dizziness"
		Symptom.BACK_PAIN: return "Back Pain"
		Symptom.JOINT_PAIN: return "Joint Pain"
		Symptom.RASH: return "Rash"
		Symptom.SWELLING: return "Swelling"
		Symptom.BLURRED_VISION: return "Blurred Vision"
		Symptom.CONFUSION: return "Confusion"
		Symptom.SEIZURE: return "Seizure"
		Symptom.PALPITATIONS: return "Palpitations"
		Symptom.WEIGHT_LOSS: return "Weight Loss"
		Symptom.NIGHT_SWEATS: return "Night Sweats"
		Symptom.URINARY_FREQUENCY: return "Urinary Frequency"
		Symptom.BLOOD_IN_URINE: return "Blood in Urine"
		Symptom.DIFFICULTY_SWALLOWING: return "Difficulty Swallowing"
		Symptom.NUMBNESS: return "Numbness"
		Symptom.WEAKNESS: return "Weakness"
		Symptom.HIP_PAIN: return "Hip Pain"
		Symptom.LEG_PAIN: return "Leg Pain"
	return ""


static func get_state_name(state: PatientState) -> String:
	match state:
		PatientState.ARRIVING: return "Arriving"
		PatientState.WAITING_FOR_REGISTRATION: return "Waiting for Registration"
		PatientState.REGISTERED: return "Registered"
		PatientState.WAITING_FOR_EXAM: return "Waiting for Exam"
		PatientState.IN_EXAMINATION: return "In Examination"
		PatientState.AWAITING_TEST_RESULTS: return "Awaiting Test Results"
		PatientState.DIAGNOSED: return "Diagnosed"
		PatientState.WAITING_FOR_TREATMENT: return "Waiting for Treatment"
		PatientState.IN_TREATMENT: return "In Treatment"
		PatientState.ADMITTED: return "Admitted"
		PatientState.RECOVERING: return "Recovering"
		PatientState.DISCHARGED: return "Discharged"
		PatientState.DECEASED: return "Deceased"
	return ""
