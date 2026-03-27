extends RefCounted

var _revenue_engine: RefCounted = null


func _get_revenue_engine() -> RefCounted:
	if _revenue_engine == null:
		_revenue_engine = preload("res://scripts/engine/revenue_engine.gd").new()
	return _revenue_engine


func process_patients(state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	for i in range(patients.size()):
		_process_patient(i, state)

	_cleanup_discharged(state)


func _cleanup_discharged(state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	var discharged: Array = patients.filter(
		func(p): return p.get("state", 0) == PatientData.PatientState.DISCHARGED \
			or p.get("state", 0) == PatientData.PatientState.DECEASED
	)
	if discharged.size() > 50:
		state["patients"] = patients.filter(
			func(p): return p.get("state", 0) != PatientData.PatientState.DISCHARGED \
				and p.get("state", 0) != PatientData.PatientState.DECEASED
		)


func _process_patient(i: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	if i >= patients.size():
		return
	var patient: Dictionary = patients[i]

	match patient.get("state", 0):
		PatientData.PatientState.ARRIVING:
			_handle_arriving(i, state)
		PatientData.PatientState.WAITING_FOR_REGISTRATION:
			_handle_waiting_for_registration(i, state)
		PatientData.PatientState.REGISTERED:
			_handle_registered(i, state)
		PatientData.PatientState.WAITING_FOR_EXAM:
			_handle_waiting_for_exam(i, state)
		PatientData.PatientState.IN_EXAMINATION:
			_handle_in_examination(i, state)
		PatientData.PatientState.AWAITING_TEST_RESULTS:
			_handle_awaiting_test_results(i, state)
		PatientData.PatientState.DIAGNOSED:
			_handle_diagnosed(i, state)
		PatientData.PatientState.WAITING_FOR_TREATMENT:
			_handle_waiting_for_treatment(i, state)
		PatientData.PatientState.IN_TREATMENT:
			_handle_in_treatment(i, state)
		PatientData.PatientState.ADMITTED:
			_handle_admitted(i, state)
		PatientData.PatientState.RECOVERING:
			_handle_recovering(i, state)
		PatientData.PatientState.DISCHARGED:
			pass
		PatientData.PatientState.DECEASED:
			pass


func _handle_arriving(i: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	var rooms: Array = state.get("hospital", {}).get("rooms", [])

	var reception = _find_operational_room_of_type(RoomData.RoomType.RECEPTION, rooms, state)
	if reception.is_empty():
		_reduce_satisfaction(i, state, 1.0)
		return

	var room_id: String = reception.get("id", "")
	var patients_in_room: int = _count_patients_in_room(room_id, patients)
	var capacity: int = reception.get("patient_capacity", 1)
	if patients_in_room >= capacity:
		_reduce_satisfaction(i, state, 1.0)
		return

	patients[i]["current_room_id"] = room_id
	patients[i]["state"] = PatientData.PatientState.WAITING_FOR_REGISTRATION


func _handle_waiting_for_registration(i: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	var staff_list: Array = state.get("staff", [])
	var room_id: String = patients[i].get("current_room_id", "")

	var has_receptionist: bool = staff_list.any(
		func(s): return s.get("assigned_room_id", "") == room_id \
			and s.get("role", -1) == StaffData.StaffRole.RECEPTIONIST \
			and s.get("is_on_duty", false)
	)

	if has_receptionist:
		patients[i]["state"] = PatientData.PatientState.REGISTERED
	else:
		patients[i]["wait_time_hours"] = patients[i].get("wait_time_hours", 0) + 1
		_reduce_satisfaction(i, state, GameConstants.WAIT_TIME_PENALTY_PER_HOUR)
		if patients[i].get("satisfaction", 100.0) <= 10.0:
			_leave_against_medical_advice(i, state)


func _handle_registered(i: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	var rooms: Array = state.get("hospital", {}).get("rooms", [])

	var exam_room: Dictionary = _find_operational_room_of_type(RoomData.RoomType.GP_OFFICE, rooms, state)
	if exam_room.is_empty():
		exam_room = _find_operational_room_of_type(RoomData.RoomType.EXAMINATION_ROOM, rooms, state)
	if exam_room.is_empty():
		exam_room = _find_operational_room_of_type(RoomData.RoomType.EMERGENCY_BAY, rooms, state)

	if exam_room.is_empty():
		_reduce_satisfaction(i, state, 0.5)
		return

	var room_id: String = exam_room.get("id", "")
	var patients_in_room: int = _count_patients_in_room(room_id, patients)
	var capacity: int = exam_room.get("patient_capacity", 1)
	if patients_in_room >= capacity:
		_reduce_satisfaction(i, state, 0.5)
		return

	patients[i]["current_room_id"] = room_id
	patients[i]["state"] = PatientData.PatientState.WAITING_FOR_EXAM


func _handle_waiting_for_exam(i: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	var staff_list: Array = state.get("staff", [])

	var doctor_id: String = patients[i].get("assigned_doctor_id", "")
	if doctor_id.is_empty():
		patients[i]["wait_time_hours"] = patients[i].get("wait_time_hours", 0) + 1
		_reduce_satisfaction(i, state, GameConstants.WAIT_TIME_PENALTY_PER_HOUR)
		if patients[i].get("satisfaction", 100.0) <= 10.0:
			_leave_against_medical_advice(i, state)
		return

	var doctor_found: bool = staff_list.any(
		func(s): return s.get("id", "") == doctor_id and s.get("is_on_duty", false)
	)
	if not doctor_found:
		patients[i]["assigned_doctor_id"] = ""
		return

	_generate_initial_differential(i, state)

	var tests: Array = _determine_tests(patients[i], state)
	patients[i]["ordered_tests"] = tests

	patients[i]["state"] = PatientData.PatientState.IN_EXAMINATION


func _handle_in_examination(i: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	var patient: Dictionary = patients[i]

	var physical_exam: int = EquipmentData.DiagnosticTestType.PHYSICAL_EXAM
	var performed: Array = patient.get("performed_tests", [])
	if not performed.has(physical_exam):
		performed.append(physical_exam)
		patients[i]["performed_tests"] = performed
		_apply_physical_exam_to_differential(i, state)

	var ordered: Array = patient.get("ordered_tests", [])
	var pending_tests: Array = []
	for test in ordered:
		if not performed.has(test) and test != physical_exam:
			pending_tests.append(test)

	if pending_tests.is_empty():
		var diff: Array = patients[i].get("differential_diagnosis", [])
		var top: Dictionary = _get_top_differential(diff)
		if not top.is_empty() and top.get("probability", 0.0) >= GameConstants.CONFIDENCE_THRESHOLD:
			_confirm_diagnosis(i, state)
		else:
			var additional: Array = _suggest_additional_tests(patients[i], state)
			if additional.is_empty():
				_confirm_diagnosis(i, state)
			else:
				patients[i]["ordered_tests"] = ordered + additional
				patients[i]["state"] = PatientData.PatientState.AWAITING_TEST_RESULTS
	else:
		patients[i]["state"] = PatientData.PatientState.AWAITING_TEST_RESULTS


func _handle_awaiting_test_results(i: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	var patient: Dictionary = patients[i]

	var current_test: int = patient.get("current_test_in_progress", -1)
	var ordered: Array = patient.get("ordered_tests", [])
	var performed: Array = patient.get("performed_tests", [])

	if current_test == -1:
		var next_test: int = -1
		for test in ordered:
			if not performed.has(test):
				next_test = test
				break
		if next_test == -1:
			var diff: Array = patients[i].get("differential_diagnosis", [])
			var top: Dictionary = _get_top_differential(diff)
			if not top.is_empty() and top.get("probability", 0.0) >= GameConstants.CONFIDENCE_THRESHOLD:
				_confirm_diagnosis(i, state)
			else:
				var additional: Array = _suggest_additional_tests(patient, state)
				if not additional.is_empty():
					patients[i]["ordered_tests"] = ordered + additional
				else:
					_confirm_diagnosis(i, state)
			return

		if not _can_perform_test(next_test, state):
			_reduce_satisfaction(i, state, 1.0)
			var skip_and_continue: bool = true
			for test in ordered:
				if not performed.has(test) and test != next_test and _can_perform_test(test, state):
					next_test = test
					skip_and_continue = false
					break
			if skip_and_continue:
				return

		var test_room: Dictionary = _find_room_for_test(next_test, state)
		if test_room.is_empty():
			_reduce_satisfaction(i, state, 0.5)
			return

		patients[i]["current_test_in_progress"] = next_test
		patients[i]["test_progress_ticks"] = 0
		patients[i]["current_room_id"] = test_room.get("id", "")
	else:
		var ticks: int = patient.get("test_progress_ticks", 0) + 1
		patients[i]["test_progress_ticks"] = ticks
		var required_ticks: int = EquipmentData.get_test_ticks_required(current_test)
		if ticks >= required_ticks:
			_complete_test(i, current_test, state)
			performed = patients[i].get("performed_tests", [])
			patients[i]["current_test_in_progress"] = -1
			patients[i]["test_progress_ticks"] = 0

			var has_more: bool = false
			for test in ordered:
				if not performed.has(test):
					has_more = true
					break
			if not has_more:
				var diff: Array = patients[i].get("differential_diagnosis", [])
				var top: Dictionary = _get_top_differential(diff)
				if not top.is_empty() and top.get("probability", 0.0) >= GameConstants.CONFIDENCE_THRESHOLD:
					_confirm_diagnosis(i, state)
				else:
					var additional: Array = _suggest_additional_tests(patients[i], state)
					if not additional.is_empty():
						patients[i]["ordered_tests"] = ordered + additional
					else:
						_confirm_diagnosis(i, state)


func _handle_diagnosed(i: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	patients[i]["state"] = PatientData.PatientState.WAITING_FOR_TREATMENT


func _handle_waiting_for_treatment(i: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	var rooms: Array = state.get("hospital", {}).get("rooms", [])

	var disease: Dictionary = _get_disease_for_patient(patients[i])
	var treatment_room_type: int = disease.get("treatment_room", RoomData.RoomType.GENERAL_WARD)

	var treatment_room: Dictionary = _find_operational_room_of_type(treatment_room_type, rooms, state)
	if treatment_room.is_empty():
		treatment_room = _find_operational_room_of_type(RoomData.RoomType.GENERAL_WARD, rooms, state)
	if treatment_room.is_empty():
		treatment_room = _find_operational_room_of_type(RoomData.RoomType.PRIVATE_ROOM, rooms, state)

	if treatment_room.is_empty():
		patients[i]["wait_time_hours"] = patients[i].get("wait_time_hours", 0) + 1
		_reduce_satisfaction(i, state, GameConstants.WAIT_TIME_PENALTY_PER_HOUR)
		if patients[i].get("satisfaction", 100.0) <= 10.0:
			_leave_against_medical_advice(i, state)
		return

	var room_id: String = treatment_room.get("id", "")
	var patients_in_room: int = _count_patients_in_room(room_id, patients)
	var capacity: int = treatment_room.get("patient_capacity", 1)
	if patients_in_room >= capacity:
		patients[i]["wait_time_hours"] = patients[i].get("wait_time_hours", 0) + 1
		_reduce_satisfaction(i, state, GameConstants.WAIT_TIME_PENALTY_PER_HOUR)
		return

	patients[i]["current_room_id"] = room_id
	patients[i]["treatment_progress_ticks"] = 0
	var severity: int = disease.get("severity", DiseaseData.DiseaseSeverity.MODERATE)
	if severity == DiseaseData.DiseaseSeverity.CRITICAL or severity == DiseaseData.DiseaseSeverity.SEVERE:
		patients[i]["state"] = PatientData.PatientState.ADMITTED
	else:
		patients[i]["state"] = PatientData.PatientState.IN_TREATMENT


func _handle_in_treatment(i: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	var patient: Dictionary = patients[i]

	var progress: int = patient.get("treatment_progress_ticks", 0) + 1
	patients[i]["treatment_progress_ticks"] = progress
	var total: int = patient.get("treatment_total_ticks", 8)

	if progress >= total:
		_complete_treatment(i, state)


func _handle_admitted(i: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	var patient: Dictionary = patients[i]

	var progress: int = patient.get("treatment_progress_ticks", 0) + 1
	patients[i]["treatment_progress_ticks"] = progress
	var total: int = patient.get("treatment_total_ticks", 8)

	var disease: Dictionary = _get_disease_for_patient(patient)
	var mortality_risk: float = disease.get("mortality_risk", 0.02)
	var doctor_id: String = patient.get("assigned_doctor_id", "")
	var staff_list: Array = state.get("staff", [])
	var doctor_skill: float = 0.5
	for s in staff_list:
		if s.get("id", "") == doctor_id:
			doctor_skill = s.get("skill", 0.5) * (1.0 - s.get("fatigue", 0.0) / 200.0)
			break

	var adjusted_mortality: float = mortality_risk * (1.0 - doctor_skill * 0.5)
	if randf() < adjusted_mortality * 0.01:
		patients[i]["state"] = PatientData.PatientState.DECEASED
		patients[i]["is_treatment_successful"] = 0
		state["reputation"] = clampf(
			state.get("reputation", 50.0) + GameConstants.MISDIAGNOSIS_PENALTY,
			0.0, GameConstants.MAX_REPUTATION
		)
		_free_doctor(doctor_id, staff_list)
		return

	if progress >= total:
		_complete_treatment(i, state)


func _handle_recovering(i: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	var patient: Dictionary = patients[i]

	var progress: int = patient.get("treatment_progress_ticks", 0) + 1
	patients[i]["treatment_progress_ticks"] = progress

	var recovery_ticks: int = patient.get("recovery_total_ticks", 12)
	if progress >= recovery_ticks:
		_discharge_patient(i, state)


# --- Differential Diagnosis Helpers ---

func _generate_initial_differential(i: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	var patient: Dictionary = patients[i]
	var symptoms: Array = patient.get("presenting_symptoms", [])
	var symptom_ids: Array = []
	for s in symptoms:
		symptom_ids.append(s.get("symptom", 0))

	var all_diseases: Array = DiseaseDefs.get_all_diseases()
	if all_diseases.is_empty():
		all_diseases = [_get_fallback_disease_list()]

	var differential: Array = []
	for disease in all_diseases:
		var disease_symptoms: Array = disease.get("symptoms", [])
		var match_count: int = 0
		var total_disease_symptoms: int = disease_symptoms.size()
		if total_disease_symptoms == 0:
			continue
		for ds in disease_symptoms:
			if symptom_ids.has(ds.get("symptom", -1)):
				match_count += 1

		if match_count > 0:
			var symptom_match_ratio: float = float(match_count) / float(total_disease_symptoms)
			var base_prob: float = symptom_match_ratio * 0.6
			differential.append({
				"disease_id": disease.get("id", ""),
				"disease_name": disease.get("name", "Unknown"),
				"probability": base_prob,
				"ruled_out": false,
			})

	differential.sort_custom(func(a, b): return a.get("probability", 0) > b.get("probability", 0))

	if differential.size() > 10:
		differential = differential.slice(0, 10)

	_normalize_probabilities(differential)
	patients[i]["differential_diagnosis"] = differential


func _apply_physical_exam_to_differential(i: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	var patient: Dictionary = patients[i]
	var diff: Array = patient.get("differential_diagnosis", [])
	var actual_disease_id: String = patient.get("actual_disease_id", "")

	for j in range(diff.size()):
		if diff[j].get("ruled_out", false):
			continue
		if diff[j].get("disease_id", "") == actual_disease_id:
			diff[j]["probability"] = diff[j].get("probability", 0.0) + 0.15
		else:
			diff[j]["probability"] = diff[j].get("probability", 0.0) + randf_range(-0.05, 0.05)
		diff[j]["probability"] = clampf(diff[j].get("probability", 0.0), 0.01, 0.99)

	_normalize_probabilities(diff)
	patients[i]["differential_diagnosis"] = diff


func _normalize_probabilities(diff: Array) -> void:
	var active: Array = diff.filter(func(d): return not d.get("ruled_out", false))
	if active.is_empty():
		return
	var total: float = 0.0
	for d in active:
		total += d.get("probability", 0.0)
	if total <= 0.0:
		return
	for j in range(diff.size()):
		if not diff[j].get("ruled_out", false):
			diff[j]["probability"] = diff[j].get("probability", 0.0) / total


func _get_top_differential(diff: Array) -> Dictionary:
	var active: Array = diff.filter(func(d): return not d.get("ruled_out", false))
	if active.is_empty():
		return {}
	active.sort_custom(func(a, b): return a.get("probability", 0) > b.get("probability", 0))
	return active[0]


# --- Test Management ---

func _determine_tests(patient: Dictionary, state: Dictionary) -> Array:
	var diff: Array = patient.get("differential_diagnosis", [])
	var active: Array = diff.filter(func(d): return not d.get("ruled_out", false))
	active.sort_custom(func(a, b): return a.get("probability", 0) > b.get("probability", 0))

	var top_candidates: Array = active.slice(0, mini(3, active.size()))
	var tests_needed: Array = []
	var performed: Array = patient.get("performed_tests", [])

	for candidate in top_candidates:
		var disease_id: String = candidate.get("disease_id", "")
		var disease: Dictionary = _get_disease_by_id(disease_id)
		var required: Array = disease.get("required_tests", [])
		for test in required:
			if not tests_needed.has(test) and not performed.has(test):
				if test != EquipmentData.DiagnosticTestType.PHYSICAL_EXAM:
					tests_needed.append(test)

	if tests_needed.is_empty() and not active.is_empty():
		tests_needed.append(EquipmentData.DiagnosticTestType.COMPLETE_BLOOD_COUNT)

	return tests_needed


func _can_perform_test(test_type: int, state: Dictionary) -> bool:
	var required_room_type: int = EquipmentData.get_test_required_room(test_type)
	var rooms: Array = state.get("hospital", {}).get("rooms", [])
	var matching_rooms: Array = rooms.filter(
		func(r): return r.get("type", -1) == required_room_type and r.get("is_operational", false)
	)
	if matching_rooms.is_empty():
		return false

	var required_equip: int = EquipmentData.get_test_required_equipment(test_type)
	var installed: Array = state.get("hospital", {}).get("installed_equipment", [])
	for room in matching_rooms:
		var room_id: String = room.get("id", "")
		var has_equip: bool = installed.any(
			func(e): return e.get("room_id", "") == room_id \
				and e.get("category", -1) == required_equip \
				and e.get("condition", 0.0) > 10.0
		)
		if has_equip:
			return true

	if test_type == EquipmentData.DiagnosticTestType.PHYSICAL_EXAM:
		return not matching_rooms.is_empty()

	return false


func _find_room_for_test(test_type: int, state: Dictionary) -> Dictionary:
	var required_room_type: int = EquipmentData.get_test_required_room(test_type)
	var rooms: Array = state.get("hospital", {}).get("rooms", [])
	var patients: Array = state.get("patients", [])
	var installed: Array = state.get("hospital", {}).get("installed_equipment", [])
	var required_equip: int = EquipmentData.get_test_required_equipment(test_type)

	var matching_rooms: Array = rooms.filter(
		func(r): return r.get("type", -1) == required_room_type and r.get("is_operational", false)
	)

	for room in matching_rooms:
		var room_id: String = room.get("id", "")
		var capacity: int = room.get("patient_capacity", 1)
		var occupancy: int = _count_patients_in_room(room_id, patients)
		if occupancy >= capacity:
			continue

		if test_type == EquipmentData.DiagnosticTestType.PHYSICAL_EXAM:
			return room

		var has_equip: bool = installed.any(
			func(e): return e.get("room_id", "") == room_id \
				and e.get("category", -1) == required_equip \
				and e.get("condition", 0.0) > 10.0
		)
		if has_equip:
			return room

	return {}


func _complete_test(patient_idx: int, test_type: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	if patient_idx >= patients.size():
		return
	var patient: Dictionary = patients[patient_idx]
	var actual_disease_id: String = patient.get("actual_disease_id", "")
	var diff: Array = patient.get("differential_diagnosis", [])

	var performed: Array = patient.get("performed_tests", [])
	if not performed.has(test_type):
		performed.append(test_type)
		patients[patient_idx]["performed_tests"] = performed

	var doctor_id: String = patient.get("assigned_doctor_id", "")
	var staff_list: Array = state.get("staff", [])
	var doctor_skill: float = 0.5
	for s in staff_list:
		if s.get("id", "") == doctor_id:
			doctor_skill = s.get("skill", 0.5) * (1.0 - s.get("fatigue", 0.0) / 200.0)
			break

	var is_positive_for_actual: bool = randf() < (0.7 + doctor_skill * 0.25)

	var test_result: Dictionary = {
		"test_type": test_type,
		"test_name": EquipmentData.get_test_display_name(test_type),
		"cpt_code": EquipmentData.get_test_cpt_code(test_type),
		"is_abnormal": is_positive_for_actual,
		"confidence": 0.7 + doctor_skill * 0.2,
	}
	var results: Array = patient.get("test_results", [])
	results.append(test_result)
	patients[patient_idx]["test_results"] = results

	_bayesian_update(patient_idx, test_type, is_positive_for_actual, doctor_skill, state)

	var test_cost: float = EquipmentData.get_test_hospital_cost(test_type)
	var finance: Dictionary = state.get("finance", {})
	finance["cash_balance"] = finance.get("cash_balance", 0.0) - test_cost
	finance["total_expenses"] = finance.get("total_expenses", 0.0) + test_cost


func _bayesian_update(patient_idx: int, test_type: int, is_abnormal: bool, doctor_skill: float, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	var patient: Dictionary = patients[patient_idx]
	var diff: Array = patient.get("differential_diagnosis", [])
	var actual_disease_id: String = patient.get("actual_disease_id", "")

	var sensitivity: float = 0.80 + doctor_skill * 0.15
	var specificity: float = 0.85 + doctor_skill * 0.10

	for j in range(diff.size()):
		if diff[j].get("ruled_out", false):
			continue
		var disease_id: String = diff[j].get("disease_id", "")
		var disease: Dictionary = _get_disease_by_id(disease_id)
		var required_tests: Array = disease.get("required_tests", [])
		var is_relevant_test: bool = required_tests.has(test_type)
		var prior: float = diff[j].get("probability", 0.1)

		if is_relevant_test:
			if disease_id == actual_disease_id:
				if is_abnormal:
					var likelihood: float = sensitivity
					var evidence: float = prior * likelihood + (1.0 - prior) * (1.0 - specificity)
					if evidence > 0.0:
						diff[j]["probability"] = (prior * likelihood) / evidence
				else:
					var likelihood: float = 1.0 - sensitivity
					var evidence: float = prior * likelihood + (1.0 - prior) * specificity
					if evidence > 0.0:
						diff[j]["probability"] = (prior * likelihood) / evidence
			else:
				if is_abnormal:
					var likelihood: float = 1.0 - specificity
					var evidence: float = prior * likelihood + (1.0 - prior) * sensitivity
					if evidence > 0.0:
						diff[j]["probability"] = (prior * likelihood) / evidence
				else:
					var likelihood: float = specificity
					var evidence: float = prior * likelihood + (1.0 - prior) * (1.0 - sensitivity)
					if evidence > 0.0:
						diff[j]["probability"] = (prior * likelihood) / evidence
		else:
			if is_abnormal:
				diff[j]["probability"] = prior * 0.95
			else:
				diff[j]["probability"] = prior * 1.02

		diff[j]["probability"] = clampf(diff[j].get("probability", 0.0), 0.001, 0.999)

		if diff[j]["probability"] < 0.02:
			diff[j]["ruled_out"] = true

	_normalize_probabilities(diff)
	patients[patient_idx]["differential_diagnosis"] = diff


func _suggest_additional_tests(patient: Dictionary, state: Dictionary) -> Array:
	var diff: Array = patient.get("differential_diagnosis", [])
	var performed: Array = patient.get("performed_tests", [])
	var ordered: Array = patient.get("ordered_tests", [])

	var active: Array = diff.filter(func(d): return not d.get("ruled_out", false))
	active.sort_custom(func(a, b): return a.get("probability", 0) > b.get("probability", 0))

	var top: Array = active.slice(0, mini(3, active.size()))
	var additional: Array = []

	for candidate in top:
		var disease_id: String = candidate.get("disease_id", "")
		var disease: Dictionary = _get_disease_by_id(disease_id)
		var required: Array = disease.get("required_tests", [])
		for test in required:
			if not performed.has(test) and not ordered.has(test) and not additional.has(test):
				if _can_perform_test(test, state):
					additional.append(test)

	if additional.is_empty() and active.size() > 1:
		var advanced_tests: Array = [
			EquipmentData.DiagnosticTestType.COMPREHENSIVE_METABOLIC_PANEL,
			EquipmentData.DiagnosticTestType.CT_SCAN_CHEST,
			EquipmentData.DiagnosticTestType.CT_SCAN_ABDOMEN,
			EquipmentData.DiagnosticTestType.MRI_BRAIN,
		]
		for test in advanced_tests:
			if not performed.has(test) and not ordered.has(test) and _can_perform_test(test, state):
				additional.append(test)
				break

	return additional


func _confirm_diagnosis(patient_idx: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	if patient_idx >= patients.size():
		return
	var patient: Dictionary = patients[patient_idx]
	var diff: Array = patient.get("differential_diagnosis", [])
	var top: Dictionary = _get_top_differential(diff)

	if top.is_empty():
		patients[patient_idx]["confirmed_disease_id"] = patient.get("actual_disease_id", "")
	else:
		patients[patient_idx]["confirmed_disease_id"] = top.get("disease_id", "")

	var actual: String = patient.get("actual_disease_id", "")
	var confirmed: String = patients[patient_idx].get("confirmed_disease_id", "")
	if actual != confirmed:
		state["total_misdiagnoses"] = state.get("total_misdiagnoses", 0) + 1
		state["reputation"] = clampf(
			state.get("reputation", 50.0) + GameConstants.MISDIAGNOSIS_PENALTY,
			0.0, GameConstants.MAX_REPUTATION
		)

	var disease: Dictionary = _get_disease_by_id(confirmed)
	patients[patient_idx]["treatment_total_ticks"] = disease.get("treatment_ticks", 8)

	patients[patient_idx]["state"] = PatientData.PatientState.DIAGNOSED

	_free_doctor(patient.get("assigned_doctor_id", ""), state.get("staff", []))


func _complete_treatment(patient_idx: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	if patient_idx >= patients.size():
		return
	var patient: Dictionary = patients[patient_idx]

	var actual: String = patient.get("actual_disease_id", "")
	var confirmed: String = patient.get("confirmed_disease_id", "")
	var correct_diagnosis: bool = (actual == confirmed)

	var doctor_id: String = patient.get("assigned_doctor_id", "")
	var staff_list: Array = state.get("staff", [])
	var doctor_skill: float = 0.5
	for s in staff_list:
		if s.get("id", "") == doctor_id:
			doctor_skill = s.get("skill", 0.5) * (1.0 - s.get("fatigue", 0.0) / 200.0)
			break

	var base_success: float = 0.85 if correct_diagnosis else 0.40
	var skill_bonus: float = doctor_skill * 0.15
	var success_chance: float = clampf(base_success + skill_bonus, 0.1, 0.99)

	var disease: Dictionary = _get_disease_by_id(actual)
	var mortality_risk: float = disease.get("mortality_risk", 0.02)

	if randf() < success_chance:
		patients[patient_idx]["is_treatment_successful"] = 1
		var severity: int = disease.get("severity", DiseaseData.DiseaseSeverity.MODERATE)
		var rep_bonus: float = GameConstants.SUCCESSFUL_TREATMENT_BONUS * DiseaseData.get_severity_reputation_impact(severity)
		state["reputation"] = clampf(
			state.get("reputation", 50.0) + rep_bonus,
			0.0, GameConstants.MAX_REPUTATION
		)
		var needs_recovery: bool = severity >= DiseaseData.DiseaseSeverity.SEVERE
		if needs_recovery:
			patients[patient_idx]["treatment_progress_ticks"] = 0
			patients[patient_idx]["recovery_total_ticks"] = 12 + randi() % 12
			patients[patient_idx]["state"] = PatientData.PatientState.RECOVERING
		else:
			_discharge_patient(patient_idx, state)
	else:
		if randf() < mortality_risk:
			patients[patient_idx]["is_treatment_successful"] = 0
			patients[patient_idx]["state"] = PatientData.PatientState.DECEASED
			state["reputation"] = clampf(
				state.get("reputation", 50.0) + GameConstants.MISDIAGNOSIS_PENALTY * 2.0,
				0.0, GameConstants.MAX_REPUTATION
			)
		else:
			patients[patient_idx]["is_treatment_successful"] = 0
			patients[patient_idx]["treatment_progress_ticks"] = 0
			patients[patient_idx]["recovery_total_ticks"] = 12 + randi() % 24
			patients[patient_idx]["state"] = PatientData.PatientState.RECOVERING
			state["reputation"] = clampf(
				state.get("reputation", 50.0) + GameConstants.MISDIAGNOSIS_PENALTY,
				0.0, GameConstants.MAX_REPUTATION
			)


func _discharge_patient(patient_idx: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	if patient_idx >= patients.size():
		return
	var patient: Dictionary = patients[patient_idx]

	patients[patient_idx]["state"] = PatientData.PatientState.DISCHARGED
	state["total_patients_discharged"] = state.get("total_patients_discharged", 0) + 1

	_free_doctor(patient.get("assigned_doctor_id", ""), state.get("staff", []))

	_get_revenue_engine().submit_claim(patients[patient_idx], state)

	var satisfaction: float = patient.get("satisfaction", 100.0)
	if satisfaction >= 80.0:
		state["reputation"] = clampf(
			state.get("reputation", 50.0) + 0.5,
			0.0, GameConstants.MAX_REPUTATION
		)
	elif satisfaction < 40.0:
		state["reputation"] = clampf(
			state.get("reputation", 50.0) - 1.0,
			0.0, GameConstants.MAX_REPUTATION
		)


func _leave_against_medical_advice(i: int, state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	patients[i]["state"] = PatientData.PatientState.DISCHARGED
	patients[i]["is_treatment_successful"] = 0
	state["reputation"] = clampf(
		state.get("reputation", 50.0) - 2.0,
		0.0, GameConstants.MAX_REPUTATION
	)
	_free_doctor(patients[i].get("assigned_doctor_id", ""), state.get("staff", []))


# --- Utility Helpers ---

func _find_operational_room_of_type(room_type: int, rooms: Array, state: Dictionary) -> Dictionary:
	for room in rooms:
		if room.get("type", -1) == room_type and room.get("is_operational", false):
			return room
	return {}


func _count_patients_in_room(room_id: String, patients: Array) -> int:
	var count: int = 0
	for p in patients:
		if p.get("current_room_id", "") == room_id:
			var s: int = p.get("state", 0)
			if s != PatientData.PatientState.DISCHARGED and s != PatientData.PatientState.DECEASED:
				count += 1
	return count


func _reduce_satisfaction(i: int, state: Dictionary, amount: float) -> void:
	var patients: Array = state.get("patients", [])
	if i >= patients.size():
		return
	patients[i]["satisfaction"] = maxf(0.0, patients[i].get("satisfaction", 100.0) - amount)


func _free_doctor(doctor_id: String, staff_list: Array) -> void:
	if doctor_id.is_empty():
		return
	for i in range(staff_list.size()):
		if staff_list[i].get("id", "") == doctor_id:
			staff_list[i]["current_task_id"] = ""
			break


func _get_disease_by_id(disease_id: String) -> Dictionary:
	if disease_id.is_empty():
		return _get_fallback_disease_list()
	var all_diseases: Array = DiseaseDefs.get_all_diseases()
	for d in all_diseases:
		if d.get("id", "") == disease_id:
			return d
	return _get_fallback_disease_list()


func _get_disease_for_patient(patient: Dictionary) -> Dictionary:
	var confirmed: String = patient.get("confirmed_disease_id", "")
	if not confirmed.is_empty():
		return _get_disease_by_id(confirmed)
	var actual: String = patient.get("actual_disease_id", "")
	return _get_disease_by_id(actual)


func _get_fallback_disease_list() -> Dictionary:
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
