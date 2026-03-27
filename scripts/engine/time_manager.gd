extends RefCounted


func advance_time(state: Dictionary) -> void:
	state["current_hour"] = state.get("current_hour", 8) + 1

	if state["current_hour"] >= 24:
		state["current_hour"] = 0
		state["current_day"] = state.get("current_day", 1) + 1
		_on_new_day(state)

	if state["current_day"] > GameConstants.DAYS_PER_MONTH:
		state["current_day"] = 1
		state["current_month"] = state.get("current_month", 1) + 1
		_on_new_month(state)

	if state["current_month"] > GameConstants.MONTHS_PER_YEAR:
		state["current_month"] = 1
		state["current_year"] = state.get("current_year", 2024) + 1


func _on_new_day(state: Dictionary) -> void:
	_process_daily_salary_accrual(state)
	_degrade_equipment(state)
	_decay_reputation(state)
	_expire_events(state)
	_process_patient_wait_times(state)


func _on_new_month(state: Dictionary) -> void:
	_deduct_monthly_maintenance(state)
	_deduct_monthly_supplies(state)
	_record_monthly_financials(state)


func _process_daily_salary_accrual(state: Dictionary) -> void:
	var staff_list: Array = state.get("staff", [])
	var total_daily_salary: float = 0.0
	for s in staff_list:
		var annual: float = float(s.get("salary", 33000))
		total_daily_salary += annual / 365.0
	if total_daily_salary > 0.0:
		_record_expense(state, total_daily_salary, FinanceData.TransactionType.SALARY_EXPENSE, "Daily salary accrual")


func _degrade_equipment(state: Dictionary) -> void:
	var equipment: Array = state.get("hospital", {}).get("installed_equipment", [])
	for i in range(equipment.size()):
		var cond: float = equipment[i].get("condition", 100.0)
		cond -= GameConstants.EQUIPMENT_DEGRADATION_PER_DAY
		if cond < 0.0:
			cond = 0.0
		equipment[i]["condition"] = cond

		if cond < 10.0 and cond > 0.0:
			var repair_cost: float = 500.0 * GameConstants.EMERGENCY_REPAIR_MULTIPLIER
			equipment[i]["condition"] = 50.0
			_record_expense(state, repair_cost, FinanceData.TransactionType.EQUIPMENT_MAINTENANCE, "Emergency equipment repair")


func _decay_reputation(state: Dictionary) -> void:
	var rep: float = state.get("reputation", 50.0)
	if rep > GameConstants.STARTING_REPUTATION:
		rep = maxf(GameConstants.STARTING_REPUTATION, rep - GameConstants.DAILY_REPUTATION_DECAY)
	state["reputation"] = clampf(rep, 0.0, GameConstants.MAX_REPUTATION)


func _expire_events(state: Dictionary) -> void:
	var events: Array = state.get("active_events", [])
	var current_day: int = state.get("current_day", 1)
	var current_month: int = state.get("current_month", 1)
	var absolute_day: int = (current_month - 1) * GameConstants.DAYS_PER_MONTH + current_day
	var remaining: Array = []
	for evt in events:
		var start_day: int = evt.get("start_absolute_day", 0)
		var duration: int = evt.get("duration_days", 7)
		if absolute_day < start_day + duration:
			remaining.append(evt)
	state["active_events"] = remaining


func _process_patient_wait_times(state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	for i in range(patients.size()):
		var patient_state: int = patients[i].get("state", 0)
		if patient_state == PatientData.PatientState.WAITING_FOR_REGISTRATION \
			or patient_state == PatientData.PatientState.WAITING_FOR_EXAM \
			or patient_state == PatientData.PatientState.WAITING_FOR_TREATMENT:
			patients[i]["wait_time_hours"] = patients[i].get("wait_time_hours", 0) + 1


func _deduct_monthly_maintenance(state: Dictionary) -> void:
	var equipment: Array = state.get("hospital", {}).get("installed_equipment", [])
	var total_maintenance: float = 0.0
	for equip in equipment:
		var template_id: String = equip.get("template_id", "")
		var annual_maint: float = _get_equipment_annual_maintenance(template_id)
		total_maintenance += annual_maint / 12.0
	if total_maintenance > 0.0:
		_record_expense(state, total_maintenance, FinanceData.TransactionType.EQUIPMENT_MAINTENANCE, "Monthly equipment maintenance")


func _deduct_monthly_supplies(state: Dictionary) -> void:
	var rooms: Array = state.get("hospital", {}).get("rooms", [])
	var operational_count: int = 0
	for room in rooms:
		if room.get("is_operational", false):
			operational_count += 1
	var supply_cost: float = operational_count * 500.0
	if supply_cost > 0.0:
		_record_expense(state, supply_cost, FinanceData.TransactionType.SUPPLY_EXPENSE, "Monthly supply costs")


func _record_monthly_financials(state: Dictionary) -> void:
	var finance: Dictionary = state.get("finance", {})
	var monthly_rev: Array = finance.get("monthly_revenue", [])
	var monthly_exp: Array = finance.get("monthly_expenses", [])
	monthly_rev.append(finance.get("total_revenue", 0.0))
	monthly_exp.append(finance.get("total_expenses", 0.0))
	finance["monthly_revenue"] = monthly_rev
	finance["monthly_expenses"] = monthly_exp


func _get_equipment_annual_maintenance(template_id: String) -> float:
	if template_id.is_empty():
		return 1200.0
	return 1200.0


func _record_expense(state: Dictionary, amount: float, type: int, description: String) -> void:
	var finance: Dictionary = state.get("finance", {})
	finance["cash_balance"] = finance.get("cash_balance", 0.0) - amount
	finance["total_expenses"] = finance.get("total_expenses", 0.0) + amount
	var transactions: Array = finance.get("transactions", [])
	transactions.append({
		"amount": amount,
		"type": type,
		"description": description,
		"day": state.get("current_day", 1),
		"month": state.get("current_month", 1),
		"is_revenue": false,
	})
	if transactions.size() > 200:
		transactions = transactions.slice(transactions.size() - 200)
	finance["transactions"] = transactions


func get_absolute_day(state: Dictionary) -> int:
	var year: int = state.get("current_year", 2024)
	var month: int = state.get("current_month", 1)
	var day: int = state.get("current_day", 1)
	return (year - 2024) * GameConstants.MONTHS_PER_YEAR * GameConstants.DAYS_PER_MONTH \
		+ (month - 1) * GameConstants.DAYS_PER_MONTH + day


func get_time_string(state: Dictionary) -> String:
	var hour: int = state.get("current_hour", 8)
	var period: String = "AM" if hour < 12 else "PM"
	var display_hour: int = hour % 12
	if display_hour == 0:
		display_hour = 12
	return "%d:00 %s" % [display_hour, period]


func get_date_string(state: Dictionary) -> String:
	return "Month %d, Day %d, Year %d" % [
		state.get("current_month", 1),
		state.get("current_day", 1),
		state.get("current_year", 2024),
	]
