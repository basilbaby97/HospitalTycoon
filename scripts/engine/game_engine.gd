extends Node

signal tick_completed
signal day_changed(day: int)
signal month_changed(month: int)
signal year_changed(year: int)
signal event_occurred(event: Dictionary)
signal patient_arrived(patient: Dictionary)
signal patient_discharged(patient: Dictionary)
signal financial_alert(message: String)

var game_state: Dictionary = {}
var _tick_timer: float = 0.0
var _is_running: bool = false

var time_manager: RefCounted
var patient_generator: RefCounted
var diagnosis_engine: RefCounted
var staff_ai: RefCounted
var revenue_engine: RefCounted
var expense_engine: RefCounted
var event_system: RefCounted


func _ready():
	time_manager = preload("res://scripts/engine/time_manager.gd").new()
	patient_generator = preload("res://scripts/engine/patient_generator.gd").new()
	diagnosis_engine = preload("res://scripts/engine/diagnosis_engine.gd").new()
	staff_ai = preload("res://scripts/engine/staff_ai.gd").new()
	revenue_engine = preload("res://scripts/engine/revenue_engine.gd").new()
	expense_engine = preload("res://scripts/engine/expense_engine.gd").new()
	event_system = preload("res://scripts/engine/event_system.gd").new()


func initialize(state: Dictionary) -> void:
	game_state = state
	if not game_state.has("patients"):
		game_state["patients"] = []
	if not game_state.has("staff"):
		game_state["staff"] = []
	if not game_state.has("claims"):
		game_state["claims"] = []
	if not game_state.has("active_events"):
		game_state["active_events"] = []
	if not game_state.has("hospital"):
		game_state["hospital"] = {}
	if not game_state.has("finance"):
		game_state["finance"] = {}
	if not game_state.get("hospital", {}).has("rooms"):
		game_state["hospital"]["rooms"] = []
	if not game_state.get("hospital", {}).has("installed_equipment"):
		game_state["hospital"]["installed_equipment"] = []
	if not game_state.get("finance", {}).has("cash_balance"):
		game_state["finance"]["cash_balance"] = GameConstants.STARTING_CASH
	if not game_state.get("finance", {}).has("accounts_receivable"):
		game_state["finance"]["accounts_receivable"] = 0.0
	if not game_state.get("finance", {}).has("total_revenue"):
		game_state["finance"]["total_revenue"] = 0.0
	if not game_state.get("finance", {}).has("total_expenses"):
		game_state["finance"]["total_expenses"] = 0.0
	if not game_state.get("finance", {}).has("transactions"):
		game_state["finance"]["transactions"] = []
	if not game_state.get("finance", {}).has("monthly_revenue"):
		game_state["finance"]["monthly_revenue"] = []
	if not game_state.get("finance", {}).has("monthly_expenses"):
		game_state["finance"]["monthly_expenses"] = []
	if not game_state.has("reputation"):
		game_state["reputation"] = GameConstants.STARTING_REPUTATION
	if not game_state.has("current_day"):
		game_state["current_day"] = 1
	if not game_state.has("current_hour"):
		game_state["current_hour"] = 8
	if not game_state.has("current_month"):
		game_state["current_month"] = 1
	if not game_state.has("current_year"):
		game_state["current_year"] = 2024
	if not game_state.has("game_speed"):
		game_state["game_speed"] = GameStateData.GameSpeed.PAUSED
	if not game_state.has("total_patients_discharged"):
		game_state["total_patients_discharged"] = 0
	if not game_state.has("total_misdiagnoses"):
		game_state["total_misdiagnoses"] = 0
	if not game_state.has("insurance_contracts"):
		game_state["insurance_contracts"] = []
	_is_running = true


func _process(delta: float) -> void:
	if not _is_running:
		return
	var speed = game_state.get("game_speed", GameStateData.GameSpeed.PAUSED)
	if speed == GameStateData.GameSpeed.PAUSED:
		return

	var interval = GameStateData.get_speed_interval(speed)
	if interval <= 0.0:
		return
	_tick_timer += delta
	if _tick_timer >= interval:
		_tick_timer -= interval
		_do_tick()


func _do_tick() -> void:
	var prev_day = game_state.get("current_day", 1)
	var prev_month = game_state.get("current_month", 1)
	var prev_year = game_state.get("current_year", 2024)

	time_manager.advance_time(game_state)

	var new_day = game_state.get("current_day", 1)
	var new_month = game_state.get("current_month", 1)
	var new_year = game_state.get("current_year", 2024)

	if new_day != prev_day:
		_on_new_day()
		day_changed.emit(new_day)
	if new_month != prev_month:
		_on_new_month()
		month_changed.emit(new_month)
	if new_year != prev_year:
		year_changed.emit(new_year)

	patient_generator.generate_patients(game_state)
	diagnosis_engine.process_patients(game_state)
	staff_ai.assign_tasks(game_state)
	_update_staff_fatigue()
	event_system.check_for_events(game_state)
	_update_room_operational_status()

	tick_completed.emit()


func _on_new_day() -> void:
	expense_engine.process_daily_salaries(game_state)
	expense_engine.degrade_equipment(game_state)
	revenue_engine.process_claims_for_day(game_state)
	_apply_daily_reputation_decay()


func _on_new_month() -> void:
	expense_engine.process_monthly_maintenance(game_state)
	expense_engine.process_monthly_supplies(game_state)
	_record_monthly_snapshot()
	_check_financial_health()


func _update_staff_fatigue() -> void:
	var staff_list: Array = game_state.get("staff", [])
	for i in range(staff_list.size()):
		if staff_list[i].get("is_on_duty", false):
			staff_list[i]["fatigue"] = minf(
				GameConstants.MAX_STAFF_FATIGUE,
				staff_list[i].get("fatigue", 0.0) + GameConstants.FATIGUE_PER_HOUR
			)
		else:
			staff_list[i]["fatigue"] = maxf(
				0.0,
				staff_list[i].get("fatigue", 0.0) - GameConstants.REST_RECOVERY_PER_HOUR
			)


func _update_room_operational_status() -> void:
	var rooms: Array = game_state.get("hospital", {}).get("rooms", [])
	var staff_list: Array = game_state.get("staff", [])
	for i in range(rooms.size()):
		var room = rooms[i]
		var room_id: String = room.get("id", "")
		var room_type: int = room.get("type", 0)
		var required_roles: Array = _get_required_staff_for_room_type(room_type)
		if required_roles.is_empty():
			rooms[i]["is_operational"] = true
			continue
		var assigned = staff_list.filter(
			func(s): return s.get("assigned_room_id", "") == room_id
		)
		var has_all_staff: bool = true
		for req_role in required_roles:
			var found = assigned.any(
				func(s): return s.get("role", -1) == req_role and s.get("is_on_duty", false)
			)
			if not found:
				has_all_staff = false
				break
		rooms[i]["is_operational"] = has_all_staff


func _get_required_staff_for_room_type(room_type: int) -> Array:
	match room_type:
		RoomData.RoomType.RECEPTION:
			return [StaffData.StaffRole.RECEPTIONIST]
		RoomData.RoomType.GP_OFFICE:
			return [StaffData.StaffRole.GENERAL_PRACTITIONER]
		RoomData.RoomType.EXAMINATION_ROOM:
			return [StaffData.StaffRole.GENERAL_PRACTITIONER, StaffData.StaffRole.REGISTERED_NURSE]
		RoomData.RoomType.EMERGENCY_BAY:
			return [StaffData.StaffRole.EMERGENCY_PHYSICIAN, StaffData.StaffRole.REGISTERED_NURSE]
		RoomData.RoomType.TRIAGE_ROOM:
			return [StaffData.StaffRole.REGISTERED_NURSE]
		RoomData.RoomType.OPERATING_ROOM:
			return [StaffData.StaffRole.GENERAL_SURGEON, StaffData.StaffRole.ANESTHESIOLOGIST, StaffData.StaffRole.REGISTERED_NURSE]
		RoomData.RoomType.RECOVERY_ROOM:
			return [StaffData.StaffRole.REGISTERED_NURSE]
		RoomData.RoomType.GENERAL_WARD:
			return [StaffData.StaffRole.REGISTERED_NURSE]
		RoomData.RoomType.PRIVATE_ROOM:
			return [StaffData.StaffRole.REGISTERED_NURSE]
		RoomData.RoomType.ICU_BAY:
			return [StaffData.StaffRole.REGISTERED_NURSE]
		RoomData.RoomType.LABORATORY:
			return [StaffData.StaffRole.LAB_TECHNICIAN]
		RoomData.RoomType.BLOOD_BANK:
			return [StaffData.StaffRole.LAB_TECHNICIAN]
		RoomData.RoomType.RADIOLOGY_ROOM:
			return [StaffData.StaffRole.RADIOLOGIST]
		RoomData.RoomType.PHARMACY_ROOM:
			return [StaffData.StaffRole.PHARMACIST]
		RoomData.RoomType.PHYSICAL_THERAPY:
			return [StaffData.StaffRole.REGISTERED_NURSE]
		RoomData.RoomType.ENDOSCOPY_ROOM:
			return [StaffData.StaffRole.GENERAL_PRACTITIONER, StaffData.StaffRole.REGISTERED_NURSE]
		RoomData.RoomType.CATHETERIZATION_LAB:
			return [StaffData.StaffRole.CARDIOLOGIST, StaffData.StaffRole.REGISTERED_NURSE]
		RoomData.RoomType.DIALYSIS_CENTER:
			return [StaffData.StaffRole.REGISTERED_NURSE]
		RoomData.RoomType.CHEMOTHERAPY_ROOM:
			return [StaffData.StaffRole.ONCOLOGIST, StaffData.StaffRole.REGISTERED_NURSE]
		RoomData.RoomType.NURSERY_ROOM:
			return [StaffData.StaffRole.REGISTERED_NURSE]
		RoomData.RoomType.DELIVERY_ROOM:
			return [StaffData.StaffRole.REGISTERED_NURSE]
		RoomData.RoomType.MORGUE:
			return [StaffData.StaffRole.PATHOLOGIST]
	return []


func _apply_daily_reputation_decay() -> void:
	var rep: float = game_state.get("reputation", 50.0)
	if rep > GameConstants.STARTING_REPUTATION:
		rep -= GameConstants.DAILY_REPUTATION_DECAY
	elif rep < GameConstants.STARTING_REPUTATION:
		rep += GameConstants.DAILY_REPUTATION_DECAY * 0.5
	game_state["reputation"] = clampf(rep, 0.0, GameConstants.MAX_REPUTATION)


func _record_monthly_snapshot() -> void:
	var finance = game_state.get("finance", {})
	var monthly_rev: Array = finance.get("monthly_revenue", [])
	var monthly_exp: Array = finance.get("monthly_expenses", [])
	monthly_rev.append(finance.get("total_revenue", 0.0))
	monthly_exp.append(finance.get("total_expenses", 0.0))
	finance["monthly_revenue"] = monthly_rev
	finance["monthly_expenses"] = monthly_exp


func _check_financial_health() -> void:
	var cash: float = game_state.get("finance", {}).get("cash_balance", 0.0)
	if cash < 0:
		financial_alert.emit("Hospital is operating at a deficit! Cash balance: $%s" % str(int(cash)))
	elif cash < 100000:
		financial_alert.emit("Low cash reserves: $%s" % str(int(cash)))


func set_speed(speed: int) -> void:
	game_state["game_speed"] = speed


func pause() -> void:
	game_state["game_speed"] = GameStateData.GameSpeed.PAUSED


func resume(speed: int = GameStateData.GameSpeed.NORMAL) -> void:
	game_state["game_speed"] = speed


func get_patient_count_by_state(state: int) -> int:
	var patients: Array = game_state.get("patients", [])
	var count: int = 0
	for p in patients:
		if p.get("state", 0) == state:
			count += 1
	return count


func get_active_patient_count() -> int:
	var patients: Array = game_state.get("patients", [])
	var count: int = 0
	for p in patients:
		var s = p.get("state", 0)
		if s != PatientData.PatientState.DISCHARGED and s != PatientData.PatientState.DECEASED:
			count += 1
	return count
