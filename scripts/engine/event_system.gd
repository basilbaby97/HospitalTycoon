extends RefCounted

const EVENT_TITLES: Dictionary = {
	GameStateData.GameEventType.FLU_SEASON: "Flu Season",
	GameStateData.GameEventType.EQUIPMENT_FAILURE: "Equipment Failure",
	GameStateData.GameEventType.CMS_AUDIT: "CMS Audit",
	GameStateData.GameEventType.STAFF_BURNOUT: "Staff Burnout Crisis",
	GameStateData.GameEventType.VIP_PATIENT: "VIP Patient Arrival",
	GameStateData.GameEventType.MALPRACTICE_LAWSUIT: "Malpractice Lawsuit",
	GameStateData.GameEventType.INSURANCE_RATE_CHANGE: "Insurance Rate Change",
	GameStateData.GameEventType.JOINT_COMMISSION_INSPECTION: "Joint Commission Inspection",
	GameStateData.GameEventType.COMMUNITY_OUTREACH: "Community Outreach Success",
	GameStateData.GameEventType.TECHNOLOGY_GRANT: "Technology Grant Awarded",
	GameStateData.GameEventType.NATURAL_DISASTER: "Natural Disaster",
}

const EVENT_DESCRIPTIONS: Dictionary = {
	GameStateData.GameEventType.FLU_SEASON: "A seasonal flu outbreak increases patient volume and respiratory cases significantly.",
	GameStateData.GameEventType.EQUIPMENT_FAILURE: "A critical piece of equipment has suffered a major malfunction requiring immediate repair.",
	GameStateData.GameEventType.CMS_AUDIT: "The Centers for Medicare & Medicaid Services is conducting a billing audit. Compliance costs increased.",
	GameStateData.GameEventType.STAFF_BURNOUT: "Multiple staff members are experiencing burnout. Morale and efficiency have dropped.",
	GameStateData.GameEventType.VIP_PATIENT: "A high-profile patient has arrived, bringing media attention and potential reputation gains.",
	GameStateData.GameEventType.MALPRACTICE_LAWSUIT: "A former patient has filed a malpractice lawsuit. Legal costs and reputation damage expected.",
	GameStateData.GameEventType.INSURANCE_RATE_CHANGE: "Insurance companies have adjusted their reimbursement rates for the quarter.",
	GameStateData.GameEventType.JOINT_COMMISSION_INSPECTION: "The Joint Commission is performing a surprise inspection. All standards must be met.",
	GameStateData.GameEventType.COMMUNITY_OUTREACH: "Community outreach efforts have raised the hospital's public profile.",
	GameStateData.GameEventType.TECHNOLOGY_GRANT: "A technology foundation has awarded a grant for equipment upgrades.",
	GameStateData.GameEventType.NATURAL_DISASTER: "A natural disaster has caused a surge in emergency patients and potential facility damage.",
}


func check_for_events(state: Dictionary) -> void:
	var hour: int = state.get("current_hour", 8)
	if hour != 8:
		return

	_expire_events(state)

	if randf() >= GameConstants.EVENT_PROBABILITY_PER_DAY:
		return

	var already_active: Array = state.get("active_events", [])
	if already_active.size() >= 3:
		return

	var event: Dictionary = _generate_event(state)
	if event.is_empty():
		return

	var active_types: Array = []
	for e in already_active:
		active_types.append(e.get("type", -1))
	if active_types.has(event.get("type", -1)):
		return

	_apply_event(event, state)
	already_active.append(event)
	state["active_events"] = already_active


func _expire_events(state: Dictionary) -> void:
	var events: Array = state.get("active_events", [])
	var current_day: int = state.get("current_day", 1)
	var current_month: int = state.get("current_month", 1)
	var absolute_day: int = (current_month - 1) * GameConstants.DAYS_PER_MONTH + current_day

	var remaining: Array = []
	for evt in events:
		var start: int = evt.get("start_absolute_day", 0)
		var duration: int = evt.get("duration_days", 7)
		if absolute_day < start + duration:
			remaining.append(evt)
	state["active_events"] = remaining


func _generate_event(state: Dictionary) -> Dictionary:
	var weights: Dictionary = _calculate_event_weights(state)
	var event_type: int = _weighted_random_select(weights)

	var current_day: int = state.get("current_day", 1)
	var current_month: int = state.get("current_month", 1)
	var absolute_day: int = (current_month - 1) * GameConstants.DAYS_PER_MONTH + current_day

	var duration: int = _get_event_duration(event_type)
	var financial_impact: float = _get_financial_impact(event_type, state)
	var reputation_impact: float = _get_reputation_impact(event_type)

	var event: Dictionary = {
		"id": RoomData.generate_uuid(),
		"type": event_type,
		"title": EVENT_TITLES.get(event_type, "Unknown Event"),
		"description": EVENT_DESCRIPTIONS.get(event_type, "An unexpected event has occurred."),
		"start_absolute_day": absolute_day,
		"start_day": current_day,
		"start_month": current_month,
		"duration_days": duration,
		"financial_impact": financial_impact,
		"reputation_impact": reputation_impact,
		"is_positive": _is_positive_event(event_type),
	}

	return event


func _calculate_event_weights(state: Dictionary) -> Dictionary:
	var weights: Dictionary = {
		GameStateData.GameEventType.FLU_SEASON: 10.0,
		GameStateData.GameEventType.EQUIPMENT_FAILURE: 12.0,
		GameStateData.GameEventType.CMS_AUDIT: 8.0,
		GameStateData.GameEventType.STAFF_BURNOUT: 10.0,
		GameStateData.GameEventType.VIP_PATIENT: 8.0,
		GameStateData.GameEventType.MALPRACTICE_LAWSUIT: 6.0,
		GameStateData.GameEventType.INSURANCE_RATE_CHANGE: 10.0,
		GameStateData.GameEventType.JOINT_COMMISSION_INSPECTION: 5.0,
		GameStateData.GameEventType.COMMUNITY_OUTREACH: 10.0,
		GameStateData.GameEventType.TECHNOLOGY_GRANT: 6.0,
		GameStateData.GameEventType.NATURAL_DISASTER: 3.0,
	}

	var month: int = state.get("current_month", 1)
	if month >= 10 or month <= 2:
		weights[GameStateData.GameEventType.FLU_SEASON] *= 2.5

	var equipment: Array = state.get("hospital", {}).get("installed_equipment", [])
	var low_condition_count: int = 0
	for equip in equipment:
		if equip.get("condition", 100.0) < 40.0:
			low_condition_count += 1
	if low_condition_count > 0:
		weights[GameStateData.GameEventType.EQUIPMENT_FAILURE] *= (1.0 + float(low_condition_count) * 0.5)

	var staff_list: Array = state.get("staff", [])
	var fatigued_count: int = 0
	for s in staff_list:
		if s.get("fatigue", 0.0) > 70.0:
			fatigued_count += 1
	if fatigued_count > 2:
		weights[GameStateData.GameEventType.STAFF_BURNOUT] *= 2.0

	var reputation: float = state.get("reputation", 50.0)
	if reputation > 75.0:
		weights[GameStateData.GameEventType.VIP_PATIENT] *= 1.5
		weights[GameStateData.GameEventType.COMMUNITY_OUTREACH] *= 1.5
		weights[GameStateData.GameEventType.TECHNOLOGY_GRANT] *= 1.5

	if reputation < 30.0:
		weights[GameStateData.GameEventType.MALPRACTICE_LAWSUIT] *= 2.0
		weights[GameStateData.GameEventType.CMS_AUDIT] *= 1.5
		weights[GameStateData.GameEventType.JOINT_COMMISSION_INSPECTION] *= 1.5

	var misdiagnoses: int = state.get("total_misdiagnoses", 0)
	if misdiagnoses > 5:
		weights[GameStateData.GameEventType.MALPRACTICE_LAWSUIT] *= 1.5
		weights[GameStateData.GameEventType.CMS_AUDIT] *= 1.3

	if month >= 6 and month <= 9:
		weights[GameStateData.GameEventType.NATURAL_DISASTER] *= 2.0

	return weights


func _weighted_random_select(weights: Dictionary) -> int:
	var total: float = 0.0
	for w in weights.values():
		total += w
	var roll: float = randf() * total
	var cumulative: float = 0.0
	for event_type in weights:
		cumulative += weights[event_type]
		if roll <= cumulative:
			return event_type
	return GameStateData.GameEventType.FLU_SEASON


func _get_event_duration(event_type: int) -> int:
	match event_type:
		GameStateData.GameEventType.FLU_SEASON:
			return randi_range(14, 30)
		GameStateData.GameEventType.EQUIPMENT_FAILURE:
			return randi_range(1, 5)
		GameStateData.GameEventType.CMS_AUDIT:
			return randi_range(3, 7)
		GameStateData.GameEventType.STAFF_BURNOUT:
			return randi_range(5, 14)
		GameStateData.GameEventType.VIP_PATIENT:
			return randi_range(2, 5)
		GameStateData.GameEventType.MALPRACTICE_LAWSUIT:
			return randi_range(14, 30)
		GameStateData.GameEventType.INSURANCE_RATE_CHANGE:
			return randi_range(30, 60)
		GameStateData.GameEventType.JOINT_COMMISSION_INSPECTION:
			return randi_range(1, 3)
		GameStateData.GameEventType.COMMUNITY_OUTREACH:
			return randi_range(7, 14)
		GameStateData.GameEventType.TECHNOLOGY_GRANT:
			return 1
		GameStateData.GameEventType.NATURAL_DISASTER:
			return randi_range(3, 10)
	return 7


func _get_financial_impact(event_type: int, state: Dictionary) -> float:
	match event_type:
		GameStateData.GameEventType.FLU_SEASON:
			return 0.0
		GameStateData.GameEventType.EQUIPMENT_FAILURE:
			return -randf_range(5000.0, 50000.0)
		GameStateData.GameEventType.CMS_AUDIT:
			return -randf_range(10000.0, 100000.0)
		GameStateData.GameEventType.STAFF_BURNOUT:
			return -randf_range(2000.0, 10000.0)
		GameStateData.GameEventType.VIP_PATIENT:
			return randf_range(10000.0, 50000.0)
		GameStateData.GameEventType.MALPRACTICE_LAWSUIT:
			return -randf_range(50000.0, 500000.0)
		GameStateData.GameEventType.INSURANCE_RATE_CHANGE:
			return randf_range(-20000.0, 20000.0)
		GameStateData.GameEventType.JOINT_COMMISSION_INSPECTION:
			var rep: float = state.get("reputation", 50.0)
			if rep >= 70.0:
				return randf_range(5000.0, 20000.0)
			else:
				return -randf_range(10000.0, 50000.0)
		GameStateData.GameEventType.COMMUNITY_OUTREACH:
			return -randf_range(5000.0, 15000.0)
		GameStateData.GameEventType.TECHNOLOGY_GRANT:
			return randf_range(100000.0, 500000.0)
		GameStateData.GameEventType.NATURAL_DISASTER:
			return -randf_range(50000.0, 200000.0)
	return 0.0


func _get_reputation_impact(event_type: int) -> float:
	match event_type:
		GameStateData.GameEventType.FLU_SEASON:
			return 0.0
		GameStateData.GameEventType.EQUIPMENT_FAILURE:
			return -3.0
		GameStateData.GameEventType.CMS_AUDIT:
			return -5.0
		GameStateData.GameEventType.STAFF_BURNOUT:
			return -2.0
		GameStateData.GameEventType.VIP_PATIENT:
			return 5.0
		GameStateData.GameEventType.MALPRACTICE_LAWSUIT:
			return -10.0
		GameStateData.GameEventType.INSURANCE_RATE_CHANGE:
			return 0.0
		GameStateData.GameEventType.JOINT_COMMISSION_INSPECTION:
			return -2.0
		GameStateData.GameEventType.COMMUNITY_OUTREACH:
			return 5.0
		GameStateData.GameEventType.TECHNOLOGY_GRANT:
			return 3.0
		GameStateData.GameEventType.NATURAL_DISASTER:
			return -5.0
	return 0.0


func _is_positive_event(event_type: int) -> bool:
	match event_type:
		GameStateData.GameEventType.VIP_PATIENT:
			return true
		GameStateData.GameEventType.COMMUNITY_OUTREACH:
			return true
		GameStateData.GameEventType.TECHNOLOGY_GRANT:
			return true
	return false


func _apply_event(event: Dictionary, state: Dictionary) -> void:
	var event_type: int = event.get("type", -1)
	var finance: Dictionary = state.get("finance", {})
	var financial_impact: float = event.get("financial_impact", 0.0)
	var reputation_impact: float = event.get("reputation_impact", 0.0)

	state["reputation"] = clampf(
		state.get("reputation", 50.0) + reputation_impact,
		0.0, GameConstants.MAX_REPUTATION
	)

	if financial_impact > 0.0:
		finance["cash_balance"] = finance.get("cash_balance", 0.0) + financial_impact
		finance["total_revenue"] = finance.get("total_revenue", 0.0) + financial_impact
		_record_transaction(finance, financial_impact, FinanceData.TransactionType.OTHER_REVENUE,
			event.get("title", "Event"), state.get("current_day", 1))
	elif financial_impact < 0.0:
		finance["cash_balance"] = finance.get("cash_balance", 0.0) + financial_impact
		finance["total_expenses"] = finance.get("total_expenses", 0.0) + absf(financial_impact)
		_record_transaction(finance, financial_impact, FinanceData.TransactionType.OTHER_EXPENSE,
			event.get("title", "Event"), state.get("current_day", 1))

	match event_type:
		GameStateData.GameEventType.EQUIPMENT_FAILURE:
			_apply_equipment_failure(state)
		GameStateData.GameEventType.STAFF_BURNOUT:
			_apply_staff_burnout(state)
		GameStateData.GameEventType.VIP_PATIENT:
			_apply_vip_patient(state)
		GameStateData.GameEventType.MALPRACTICE_LAWSUIT:
			pass
		GameStateData.GameEventType.CMS_AUDIT:
			pass
		GameStateData.GameEventType.INSURANCE_RATE_CHANGE:
			_apply_insurance_rate_change(state)
		GameStateData.GameEventType.JOINT_COMMISSION_INSPECTION:
			_apply_inspection(state)
		GameStateData.GameEventType.FLU_SEASON:
			pass
		GameStateData.GameEventType.COMMUNITY_OUTREACH:
			pass
		GameStateData.GameEventType.TECHNOLOGY_GRANT:
			_apply_technology_grant(state)
		GameStateData.GameEventType.NATURAL_DISASTER:
			_apply_natural_disaster(state)


func _apply_equipment_failure(state: Dictionary) -> void:
	var equipment: Array = state.get("hospital", {}).get("installed_equipment", [])
	if equipment.is_empty():
		return
	var idx: int = randi() % equipment.size()
	equipment[idx]["condition"] = 0.0


func _apply_staff_burnout(state: Dictionary) -> void:
	var staff_list: Array = state.get("staff", [])
	if staff_list.is_empty():
		return
	var affected_count: int = maxi(1, staff_list.size() / 5)
	var indices: Array = []
	for i in range(staff_list.size()):
		indices.append(i)
	indices.shuffle()
	for j in range(mini(affected_count, indices.size())):
		var idx: int = indices[j]
		staff_list[idx]["fatigue"] = minf(GameConstants.MAX_STAFF_FATIGUE, staff_list[idx].get("fatigue", 0.0) + 40.0)
		staff_list[idx]["satisfaction"] = maxf(0.0, staff_list[idx].get("satisfaction", 80.0) - 20.0)
		if staff_list[idx].get("fatigue", 0.0) >= GameConstants.MAX_STAFF_FATIGUE:
			staff_list[idx]["is_on_duty"] = false
			staff_list[idx]["assigned_room_id"] = ""
			staff_list[idx]["current_task_id"] = ""


func _apply_vip_patient(state: Dictionary) -> void:
	var patient: Dictionary = {
		"id": RoomData.generate_uuid(),
		"patient_name": "VIP Patient",
		"age": randi_range(40, 70),
		"payer_type": InsuranceData.PayerType.BLUE_CROSS_BLUE_SHIELD,
		"presenting_symptoms": [{"symptom": PatientData.Symptom.CHEST_PAIN, "severity": 0.6}],
		"actual_disease_id": "",
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
		"treatment_total_ticks": 6,
		"is_treatment_successful": -1,
		"satisfaction": 100.0,
		"wait_time_hours": 0,
		"arrival_day": state.get("current_day", 1),
		"arrival_hour": state.get("current_hour", 8),
		"arrival_month": state.get("current_month", 1),
		"is_vip": true,
	}

	var all_diseases: Array = DiseaseDefs.get_all_diseases()
	if not all_diseases.is_empty():
		var d: Dictionary = all_diseases[randi() % all_diseases.size()]
		patient["actual_disease_id"] = d.get("id", "")
		patient["treatment_total_ticks"] = d.get("treatment_ticks", 6)
		var syms: Array = d.get("symptoms", [])
		var presenting: Array = []
		for s in syms:
			if randf() < s.get("probability", 0.5):
				presenting.append({"symptom": s.get("symptom", 0), "severity": randf_range(0.4, 0.9)})
		if not presenting.is_empty():
			patient["presenting_symptoms"] = presenting

	state.get("patients", []).append(patient)


func _apply_insurance_rate_change(state: Dictionary) -> void:
	var contracts: Array = state.get("insurance_contracts", [])
	for i in range(contracts.size()):
		var change: float = randf_range(-0.05, 0.05)
		contracts[i]["negotiated_rate"] = clampf(
			contracts[i].get("negotiated_rate", 1.0) + change,
			0.7, 1.5
		)


func _apply_inspection(state: Dictionary) -> void:
	var reputation: float = state.get("reputation", 50.0)
	if reputation >= 70.0:
		state["reputation"] = clampf(reputation + 5.0, 0.0, GameConstants.MAX_REPUTATION)
	else:
		state["reputation"] = clampf(reputation - 5.0, 0.0, GameConstants.MAX_REPUTATION)


func _apply_technology_grant(state: Dictionary) -> void:
	var equipment: Array = state.get("hospital", {}).get("installed_equipment", [])
	for i in range(equipment.size()):
		equipment[i]["condition"] = minf(100.0, equipment[i].get("condition", 50.0) + 20.0)


func _apply_natural_disaster(state: Dictionary) -> void:
	var equipment: Array = state.get("hospital", {}).get("installed_equipment", [])
	if equipment.is_empty():
		return
	var damage_count: int = maxi(1, equipment.size() / 4)
	var indices: Array = []
	for i in range(equipment.size()):
		indices.append(i)
	indices.shuffle()
	for j in range(mini(damage_count, indices.size())):
		var idx: int = indices[j]
		equipment[idx]["condition"] = maxf(0.0, equipment[idx].get("condition", 100.0) - randf_range(20.0, 50.0))


func _record_transaction(finance: Dictionary, amount: float, type: int, description: String, day: int) -> void:
	var transactions: Array = finance.get("transactions", [])
	transactions.append({
		"amount": absf(amount),
		"type": type,
		"description": description,
		"day": day,
		"is_revenue": amount > 0.0,
	})
	if transactions.size() > 200:
		transactions = transactions.slice(transactions.size() - 200)
	finance["transactions"] = transactions


func get_active_event_descriptions(state: Dictionary) -> Array:
	var result: Array = []
	for evt in state.get("active_events", []):
		result.append({
			"title": evt.get("title", ""),
			"description": evt.get("description", ""),
			"is_positive": evt.get("is_positive", false),
		})
	return result
