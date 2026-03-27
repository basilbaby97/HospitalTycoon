extends Node


func initial_differential(symptoms: Array[Dictionary]) -> Array[Dictionary]:
	var scores: Array[Dictionary] = []
	var total_likelihood: float = 0.0

	for disease in DiseaseDefs.all_diseases:
		var likelihood: float = 1.0
		var disease_symptoms: Dictionary = {}
		for ds in disease.get("symptoms", []):
			disease_symptoms[ds.get("symptom")] = ds.get("probability", 0.5)

		for patient_symptom in symptoms:
			var sym = patient_symptom.get("symptom")
			if disease_symptoms.has(sym):
				likelihood *= disease_symptoms[sym]
			else:
				likelihood *= 0.1

		if likelihood > 0.0:
			scores.append({
				"disease_id": disease.get("id", ""),
				"disease_name": disease.get("name", ""),
				"probability": likelihood,
				"ruled_out": false,
			})
			total_likelihood += likelihood

	if total_likelihood > 0.0:
		for entry in scores:
			entry["probability"] = entry["probability"] / total_likelihood

	scores.sort_custom(func(a, b): return a.get("probability", 0) > b.get("probability", 0))

	var top_results: Array[Dictionary] = []
	for i in range(mini(5, scores.size())):
		top_results.append(scores[i])

	return top_results


func update_differential(current: Array[Dictionary], test_type: int, actual_disease_id: String, doctor_skill: float) -> Array[Dictionary]:
	var actual_disease: Dictionary = DiseaseDefs.find_by_id(actual_disease_id)
	var actual_required_tests: Array = actual_disease.get("required_tests", [])
	var test_is_relevant: bool = actual_required_tests.has(test_type)

	var total: float = 0.0

	for entry in current:
		if entry.get("ruled_out", false):
			continue

		var entry_disease: Dictionary = DiseaseDefs.find_by_id(entry.get("disease_id", ""))
		var entry_required: Array = entry_disease.get("required_tests", [])
		var relevant_for_entry: bool = entry_required.has(test_type)

		if entry.get("disease_id") == actual_disease_id and test_is_relevant:
			entry["probability"] *= 1.5 * (0.8 + doctor_skill * 0.4)
		elif not relevant_for_entry:
			entry["probability"] *= 0.7

		total += entry["probability"]

	if total > 0.0:
		for entry in current:
			if not entry.get("ruled_out", false):
				entry["probability"] = entry["probability"] / total

	for entry in current:
		if not entry.get("ruled_out", false) and entry.get("probability", 0) < 0.05:
			entry["ruled_out"] = true

	current.sort_custom(func(a, b):
		if a.get("ruled_out", false) != b.get("ruled_out", false):
			return not a.get("ruled_out", false)
		return a.get("probability", 0) > b.get("probability", 0)
	)

	return current


func generate_presenting_symptoms(disease_dict: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var disease_symptoms: Array = disease_dict.get("symptoms", [])

	for sym_entry in disease_symptoms:
		var prob: float = sym_entry.get("probability", 0.5)
		if randf() < prob:
			result.append({
				"symptom": sym_entry.get("symptom"),
				"severity": randf_range(0.3, 1.0),
			})

	if result.is_empty() and disease_symptoms.size() > 0:
		var first_sym: Dictionary = disease_symptoms[0]
		result.append({
			"symptom": first_sym.get("symptom"),
			"severity": randf_range(0.5, 1.0),
		})

	if randf() < 0.2:
		var all_symptom_values: Array = [
			PatientData.Symptom.FEVER, PatientData.Symptom.COUGH,
			PatientData.Symptom.SHORTNESS_OF_BREATH, PatientData.Symptom.CHEST_PAIN,
			PatientData.Symptom.HEADACHE, PatientData.Symptom.NAUSEA,
			PatientData.Symptom.VOMITING, PatientData.Symptom.ABDOMINAL_PAIN,
			PatientData.Symptom.DIARRHEA, PatientData.Symptom.FATIGUE,
			PatientData.Symptom.DIZZINESS, PatientData.Symptom.BACK_PAIN,
			PatientData.Symptom.JOINT_PAIN, PatientData.Symptom.RASH,
			PatientData.Symptom.SWELLING, PatientData.Symptom.BLURRED_VISION,
			PatientData.Symptom.CONFUSION, PatientData.Symptom.SEIZURE,
			PatientData.Symptom.PALPITATIONS, PatientData.Symptom.WEIGHT_LOSS,
			PatientData.Symptom.NIGHT_SWEATS, PatientData.Symptom.URINARY_FREQUENCY,
			PatientData.Symptom.BLOOD_IN_URINE, PatientData.Symptom.DIFFICULTY_SWALLOWING,
			PatientData.Symptom.NUMBNESS, PatientData.Symptom.WEAKNESS,
			PatientData.Symptom.HIP_PAIN, PatientData.Symptom.LEG_PAIN,
		]

		var existing_symptoms: Array = []
		for s in result:
			existing_symptoms.append(s.get("symptom"))

		var noise_sym = all_symptom_values[randi() % all_symptom_values.size()]
		if not existing_symptoms.has(noise_sym):
			result.append({
				"symptom": noise_sym,
				"severity": randf_range(0.1, 0.4),
			})

	return result
