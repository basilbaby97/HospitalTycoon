extends RefCounted

const FIRST_NAMES: Array = [
	"James", "Mary", "Robert", "Patricia", "John", "Jennifer", "Michael", "Linda",
	"David", "Elizabeth", "William", "Barbara", "Richard", "Susan", "Joseph", "Jessica",
	"Thomas", "Sarah", "Charles", "Karen", "Daniel", "Lisa", "Matthew", "Nancy",
	"Anthony", "Betty", "Mark", "Margaret", "Donald", "Sandra", "Steven", "Ashley",
	"Andrew", "Dorothy", "Paul", "Kimberly", "Joshua", "Emily", "Kenneth", "Donna",
	"Kevin", "Michelle", "Brian", "Carol", "George", "Amanda", "Timothy", "Melissa",
	"Ronald", "Deborah", "Edward", "Stephanie", "Jason", "Rebecca", "Jeffrey", "Sharon",
	"Ryan", "Laura", "Jacob", "Cynthia",
]

const LAST_NAMES: Array = [
	"Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
	"Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
	"Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson",
	"White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson",
	"Walker", "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen",
	"Hill", "Flores", "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera",
	"Campbell", "Mitchell", "Carter", "Roberts",
]

const PAYER_WEIGHTS: Dictionary = {
	InsuranceData.PayerType.MEDICARE: 25.0,
	InsuranceData.PayerType.MEDICAID: 18.0,
	InsuranceData.PayerType.MEDICARE_ADVANTAGE: 8.0,
	InsuranceData.PayerType.UNITED_HEALTHCARE: 10.0,
	InsuranceData.PayerType.ANTHEM: 7.0,
	InsuranceData.PayerType.AETNA: 6.0,
	InsuranceData.PayerType.CIGNA: 6.0,
	InsuranceData.PayerType.HUMANA: 5.0,
	InsuranceData.PayerType.BLUE_CROSS_BLUE_SHIELD: 10.0,
	InsuranceData.PayerType.SELF_PAY: 5.0,
}


func generate_patients(state: Dictionary) -> void:
	var hour: int = state.get("current_hour", 8)
	if hour < GameConstants.OPERATING_HOURS_START or hour > GameConstants.OPERATING_HOURS_END:
		return

	var reputation: float = state.get("reputation", 50.0)
	var rate: float = GameConstants.BASE_PATIENT_ARRIVAL_RATE * (reputation / 50.0)

	var peak_modifier: float = _get_peak_hour_modifier(hour)
	rate *= peak_modifier

	var active_events: Array = state.get("active_events", [])
	var flu_active: bool = active_events.any(
		func(e): return e.get("type", -1) == GameStateData.GameEventType.FLU_SEASON
	)
	if flu_active:
		rate *= 1.5

	var disaster: bool = active_events.any(
		func(e): return e.get("type", -1) == GameStateData.GameEventType.NATURAL_DISASTER
	)
	if disaster:
		rate *= 2.0

	var vip: bool = active_events.any(
		func(e): return e.get("type", -1) == GameStateData.GameEventType.VIP_PATIENT
	)
	if vip:
		rate *= 1.2

	var room_count: int = state.get("hospital", {}).get("rooms", []).size()
	var size_modifier: float = clampf(float(room_count) / 10.0, 0.5, 3.0)
	rate *= size_modifier

	rate = minf(rate, float(GameConstants.MAX_PATIENTS_PER_HOUR))

	var patients_to_generate: int = 0
	if rate >= 1.0:
		patients_to_generate = int(rate)
		var fractional: float = rate - float(patients_to_generate)
		if randf() < fractional:
			patients_to_generate += 1
	else:
		if randf() < rate:
			patients_to_generate = 1

	for _i in range(patients_to_generate):
		var patient: Dictionary = _create_patient(state, flu_active)
		state.get("patients", []).append(patient)


func _get_peak_hour_modifier(hour: int) -> float:
	if hour >= 8 and hour <= 11:
		return 1.3
	elif hour >= 12 and hour <= 14:
		return 1.0
	elif hour >= 15 and hour <= 18:
		return 1.2
	elif hour >= 19 and hour <= 22:
		return 0.7
	elif hour >= 6 and hour <= 7:
		return 0.5
	return 0.3


func _create_patient(state: Dictionary, flu_season: bool) -> Dictionary:
	var payer_type: int = _select_weighted_payer()
	var disease: Dictionary = _select_disease(flu_season)
	var symptoms: Array = _generate_presenting_symptoms(disease)
	var patient_name: String = _generate_name()
	var age: int = _generate_age(payer_type)

	var patient: Dictionary = {
		"id": RoomData.generate_uuid(),
		"patient_name": patient_name,
		"age": age,
		"payer_type": payer_type,
		"presenting_symptoms": symptoms,
		"actual_disease_id": disease.get("id", ""),
		"state": PatientData.PatientState.ARRIVING,
		"current_room_id": "",
		"assigned_doctor_id": "",
		"differential_diagnosis": [],
		"ordered_tests": [],
		"current_test_in_progress": -1,
		"test_progress_ticks": 0,
		"performed_tests": [],
		"test_results": [],
		"confirmed_disease_id": "",
		"treatment_progress_ticks": 0,
		"treatment_total_ticks": disease.get("treatment_ticks", 8),
		"is_treatment_successful": -1,
		"satisfaction": 100.0,
		"wait_time_hours": 0,
		"arrival_day": state.get("current_day", 1),
		"arrival_hour": state.get("current_hour", 8),
		"arrival_month": state.get("current_month", 1),
	}
	return patient


func _select_weighted_payer() -> int:
	var total_weight: float = 0.0
	for w in PAYER_WEIGHTS.values():
		total_weight += w
	var roll: float = randf() * total_weight
	var cumulative: float = 0.0
	for payer_type in PAYER_WEIGHTS:
		cumulative += PAYER_WEIGHTS[payer_type]
		if roll <= cumulative:
			return payer_type
	return InsuranceData.PayerType.MEDICARE


func _select_disease(flu_season: bool) -> Dictionary:
	var diseases: Array = DiseaseDefs.get_all_diseases()
	if diseases.is_empty():
		return _get_fallback_disease()

	if flu_season:
		var respiratory: Array = diseases.filter(
			func(d): return d.get("department", -1) == RoomData.Department.INTERNAL_MEDICINE
		)
		if not respiratory.is_empty() and randf() < 0.4:
			return respiratory[randi() % respiratory.size()]

	return diseases[randi() % diseases.size()]


func _get_fallback_disease() -> Dictionary:
	return {
		"id": "fallback_disease",
		"disease_name": "Common Cold",
		"drg_code": "DRG079",
		"icd_code": "J00",
		"department": RoomData.Department.INTERNAL_MEDICINE,
		"severity": DiseaseData.DiseaseSeverity.MILD,
		"symptoms": [
			{"symptom": PatientData.Symptom.FEVER, "probability": 0.8},
			{"symptom": PatientData.Symptom.COUGH, "probability": 0.9},
			{"symptom": PatientData.Symptom.FATIGUE, "probability": 0.7},
			{"symptom": PatientData.Symptom.HEADACHE, "probability": 0.5},
		],
		"required_tests": [
			EquipmentData.DiagnosticTestType.PHYSICAL_EXAM,
			EquipmentData.DiagnosticTestType.COMPLETE_BLOOD_COUNT,
		],
		"treatment_room": RoomData.RoomType.GP_OFFICE,
		"treatment_ticks": 4,
		"base_medicare_payment": 2500.0,
		"mortality_risk": 0.001,
	}


func _generate_presenting_symptoms(disease: Dictionary) -> Array:
	var disease_symptoms: Array = disease.get("symptoms", [])
	var presenting: Array = []

	for sym_entry in disease_symptoms:
		var prob: float = sym_entry.get("probability", 0.5)
		if randf() < prob:
			presenting.append({
				"symptom": sym_entry.get("symptom", 0),
				"severity": randf_range(0.3, 1.0),
			})

	if presenting.is_empty() and not disease_symptoms.is_empty():
		var forced = disease_symptoms[0]
		presenting.append({
			"symptom": forced.get("symptom", 0),
			"severity": randf_range(0.5, 1.0),
		})

	var possible_noise: Array = [
		PatientData.Symptom.FATIGUE,
		PatientData.Symptom.HEADACHE,
		PatientData.Symptom.NAUSEA,
		PatientData.Symptom.DIZZINESS,
		PatientData.Symptom.BACK_PAIN,
	]
	if randf() < 0.3:
		var noise_symptom: int = possible_noise[randi() % possible_noise.size()]
		var already_present: bool = presenting.any(
			func(s): return s.get("symptom", -1) == noise_symptom
		)
		if not already_present:
			presenting.append({
				"symptom": noise_symptom,
				"severity": randf_range(0.1, 0.4),
			})

	return presenting


func _generate_name() -> String:
	var first: String = FIRST_NAMES[randi() % FIRST_NAMES.size()]
	var last: String = LAST_NAMES[randi() % LAST_NAMES.size()]
	return "%s %s" % [first, last]


func _generate_age(payer_type: int) -> int:
	match payer_type:
		InsuranceData.PayerType.MEDICARE, InsuranceData.PayerType.MEDICARE_ADVANTAGE:
			return randi_range(65, 95)
		InsuranceData.PayerType.MEDICAID:
			return randi_range(1, 70)
		InsuranceData.PayerType.SELF_PAY:
			return randi_range(18, 60)
		_:
			return randi_range(18, 80)
