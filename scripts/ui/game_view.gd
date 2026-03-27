extends Node2D

var hospital_name: String = "General Hospital"
var loaded_state: Dictionary = {}

var game_engine: Node
var hospital_renderer: Node2D
var game_state: Dictionary = {}
var _active_panel: String = ""

func _ready():
	if loaded_state.is_empty():
		game_state = _create_new_game_state()
	else:
		game_state = loaded_state

	game_engine = preload("res://scripts/engine/game_engine.gd").new()
	add_child(game_engine)
	game_engine.initialize(game_state)
	game_engine.tick_completed.connect(_on_tick)

	hospital_renderer = $HospitalRenderer
	hospital_renderer.set_script(preload("res://scripts/rendering/hospital_renderer.gd"))
	hospital_renderer.initialize(game_state)

	_setup_ui()

func _create_new_game_state() -> Dictionary:
	var grid := []
	for y in range(GameConstants.GRID_HEIGHT):
		var row := []
		for x in range(GameConstants.GRID_WIDTH):
			row.append({"type": 0, "room_id": ""})
		grid.append(row)

	return {
		"hospital_name": hospital_name,
		"hospital": {
			"grid_width": GameConstants.GRID_WIDTH,
			"grid_height": GameConstants.GRID_HEIGHT,
			"grid": grid,
			"rooms": [],
			"installed_equipment": []
		},
		"staff": [],
		"patients": [],
		"finance": {
			"cash_balance": float(GameConstants.STARTING_CASH),
			"accounts_receivable": 0.0,
			"total_revenue": 0.0,
			"total_expenses": 0.0,
			"transactions": [],
			"monthly_revenue": [],
			"monthly_expenses": []
		},
		"claims": [],
		"insurance_contracts": InsuranceDefs.get_default_contracts(),
		"current_day": 1,
		"current_hour": 8,
		"current_month": 1,
		"current_year": 2024,
		"game_speed": GameStateData.GameSpeed.PAUSED,
		"reputation": GameConstants.STARTING_REPUTATION,
		"total_patients_discharged": 0,
		"total_misdiagnoses": 0,
		"active_events": []
	}

func _setup_ui():
	var ui_root = $UILayer/UI
	_create_hud(ui_root)
	_create_toolbar(ui_root)
	_create_build_menu(ui_root)
	_create_staff_menu(ui_root)
	_create_finance_view(ui_root)
	_create_patient_list(ui_root)
	_create_event_banner(ui_root)

func _create_hud(parent: Control):
	var hud_bar = PanelContainer.new()
	hud_bar.name = "HUDBar"
	hud_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud_bar.custom_minimum_size = Vector2(0, 50)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)

	var cash_label = Label.new()
	cash_label.name = "CashLabel"
	cash_label.text = "$5,000,000"
	cash_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
	cash_label.add_theme_font_size_override("font_size", 18)
	hbox.add_child(cash_label)

	var ar_label = Label.new()
	ar_label.name = "ARLabel"
	ar_label.text = "AR: $0"
	ar_label.add_theme_font_size_override("font_size", 14)
	hbox.add_child(ar_label)

	var date_label = Label.new()
	date_label.name = "DateLabel"
	date_label.text = "Day 1 | 8:00"
	date_label.add_theme_font_size_override("font_size", 16)
	hbox.add_child(date_label)

	var rep_label = Label.new()
	rep_label.name = "RepLabel"
	rep_label.text = "Rep: 50"
	rep_label.add_theme_font_size_override("font_size", 14)
	hbox.add_child(rep_label)

	var patient_label = Label.new()
	patient_label.name = "PatientCountLabel"
	patient_label.text = "Patients: 0"
	patient_label.add_theme_font_size_override("font_size", 14)
	hbox.add_child(patient_label)

	var staff_label = Label.new()
	staff_label.name = "StaffCountLabel"
	staff_label.text = "Staff: 0"
	staff_label.add_theme_font_size_override("font_size", 14)
	hbox.add_child(staff_label)

	var speed_box = HBoxContainer.new()
	speed_box.name = "SpeedControls"
	var speed_labels = ["||", ">", ">>", ">>>"]
	for i in range(4):
		var btn = Button.new()
		btn.text = speed_labels[i]
		btn.custom_minimum_size = Vector2(45, 30)
		btn.pressed.connect(_on_speed_change.bind(i))
		speed_box.add_child(btn)
	hbox.add_child(speed_box)

	hud_bar.add_child(hbox)
	parent.add_child(hud_bar)

func _create_toolbar(parent: Control):
	var toolbar = HBoxContainer.new()
	toolbar.name = "Toolbar"
	toolbar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	toolbar.anchor_top = 1.0
	toolbar.offset_top = -55
	toolbar.offset_bottom = 0
	toolbar.alignment = BoxContainer.ALIGNMENT_CENTER
	toolbar.add_theme_constant_override("separation", 10)

	var bg = PanelContainer.new()
	bg.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bg.anchor_top = 1.0
	bg.offset_top = -55
	bg.name = "ToolbarBg"
	parent.add_child(bg)

	var tabs = ["Build", "Staff", "Patients", "Finance", "Insurance"]
	for tab_name in tabs:
		var btn = Button.new()
		btn.text = tab_name
		btn.custom_minimum_size = Vector2(120, 45)
		btn.name = tab_name + "Btn"
		btn.pressed.connect(_on_tab_pressed.bind(tab_name.to_lower()))
		toolbar.add_child(btn)

	var save_btn = Button.new()
	save_btn.text = "Save"
	save_btn.custom_minimum_size = Vector2(80, 45)
	save_btn.pressed.connect(_on_save)
	toolbar.add_child(save_btn)

	var menu_btn = Button.new()
	menu_btn.text = "Menu"
	menu_btn.custom_minimum_size = Vector2(80, 45)
	menu_btn.pressed.connect(_on_menu)
	toolbar.add_child(menu_btn)

	parent.add_child(toolbar)

func _create_build_menu(parent: Control):
	var panel = PanelContainer.new()
	panel.name = "BuildMenu"
	panel.visible = false
	panel.anchor_top = 0.06
	panel.anchor_bottom = 0.92
	panel.anchor_left = 0.0
	panel.anchor_right = 0.0
	panel.offset_right = 320

	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	var vbox = VBoxContainer.new()
	vbox.name = "BuildContent"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var title = Label.new()
	title.text = "BUILD ROOMS"
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)

	var dept_label = Label.new()
	dept_label.text = "Select Department:"
	dept_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(dept_label)

	for dept_val in range(13):
		var dept_btn = Button.new()
		dept_btn.text = RoomData.get_department_name(dept_val)
		dept_btn.pressed.connect(_on_department_selected.bind(dept_val))
		vbox.add_child(dept_btn)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	var room_list = VBoxContainer.new()
	room_list.name = "RoomList"
	vbox.add_child(room_list)

	scroll.add_child(vbox)
	panel.add_child(scroll)
	parent.add_child(panel)

func _create_staff_menu(parent: Control):
	var panel = PanelContainer.new()
	panel.name = "StaffMenu"
	panel.visible = false
	panel.anchor_top = 0.06
	panel.anchor_bottom = 0.92
	panel.offset_right = 360

	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	var vbox = VBoxContainer.new()
	vbox.name = "StaffContent"

	var title = Label.new()
	title.text = "STAFF MANAGEMENT"
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)

	var cost_label = Label.new()
	cost_label.name = "AnnualCostLabel"
	cost_label.text = "Annual Labor Cost: $0"
	cost_label.add_theme_font_size_override("font_size", 12)
	cost_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
	vbox.add_child(cost_label)

	var hire_btn = Button.new()
	hire_btn.text = "Hire New Staff"
	hire_btn.custom_minimum_size = Vector2(0, 40)
	hire_btn.pressed.connect(_show_hire_dialog)
	vbox.add_child(hire_btn)

	var roster = VBoxContainer.new()
	roster.name = "Roster"
	vbox.add_child(roster)

	scroll.add_child(vbox)
	panel.add_child(scroll)
	parent.add_child(panel)

func _create_finance_view(parent: Control):
	var panel = PanelContainer.new()
	panel.name = "FinanceView"
	panel.visible = false
	panel.anchor_top = 0.06
	panel.anchor_bottom = 0.92
	panel.offset_right = 420

	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	var vbox = VBoxContainer.new()
	vbox.name = "FinanceContent"

	var title = Label.new()
	title.text = "FINANCIAL DASHBOARD"
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)

	var metrics = ["Cash Balance", "Accounts Receivable", "Total Revenue", "Total Expenses", "Net Income", "Operating Margin", "Claims Pending", "Denial Rate"]
	for metric in metrics:
		var row = HBoxContainer.new()
		var lbl = Label.new()
		lbl.text = metric + ":"
		lbl.custom_minimum_size = Vector2(180, 0)
		lbl.add_theme_font_size_override("font_size", 13)
		row.add_child(lbl)
		var val_lbl = Label.new()
		val_lbl.name = metric.replace(" ", "") + "Val"
		val_lbl.text = "$0"
		val_lbl.add_theme_font_size_override("font_size", 13)
		val_lbl.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
		row.add_child(val_lbl)
		vbox.add_child(row)

	var claims_title = Label.new()
	claims_title.text = "\nRecent Claims:"
	claims_title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(claims_title)

	var claims_list = VBoxContainer.new()
	claims_list.name = "ClaimsList"
	vbox.add_child(claims_list)

	scroll.add_child(vbox)
	panel.add_child(scroll)
	parent.add_child(panel)

func _create_patient_list(parent: Control):
	var panel = PanelContainer.new()
	panel.name = "PatientList"
	panel.visible = false
	panel.anchor_top = 0.06
	panel.anchor_bottom = 0.92
	panel.offset_right = 420

	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	var vbox = VBoxContainer.new()
	vbox.name = "PatientContent"

	var title = Label.new()
	title.text = "PATIENTS"
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)

	var summary = HBoxContainer.new()
	summary.name = "Summary"
	for chip_name in ["All", "Waiting", "Exam", "Treatment", "Recovery"]:
		var chip = Button.new()
		chip.text = chip_name
		chip.custom_minimum_size = Vector2(70, 30)
		summary.add_child(chip)
	vbox.add_child(summary)

	var patient_rows = VBoxContainer.new()
	patient_rows.name = "PatientRows"
	vbox.add_child(patient_rows)

	scroll.add_child(vbox)
	panel.add_child(scroll)
	parent.add_child(panel)

func _create_event_banner(parent: Control):
	var banner = VBoxContainer.new()
	banner.name = "EventBanner"
	banner.anchor_left = 1.0
	banner.anchor_right = 1.0
	banner.anchor_top = 0.06
	banner.offset_left = -320
	banner.custom_minimum_size = Vector2(300, 0)
	parent.add_child(banner)

# === Tick Update ===

func _on_tick():
	hospital_renderer.update_visuals()
	_update_hud()
	_update_active_panel()
	_update_events()

func _update_hud():
	var ui = $UILayer/UI
	var hud_bar = ui.get_node_or_null("HUDBar")
	if hud_bar == null:
		return
	var hbox = hud_bar.get_child(0)
	var finance = game_state.get("finance", {})

	hbox.get_node("CashLabel").text = "$%s" % _fmt(finance.get("cash_balance", 0))
	hbox.get_node("ARLabel").text = "AR: $%s" % _fmt(finance.get("accounts_receivable", 0))
	hbox.get_node("DateLabel").text = "Day %d | %02d:00 | M%d Y%d" % [
		game_state.get("current_day", 1), game_state.get("current_hour", 8),
		game_state.get("current_month", 1), game_state.get("current_year", 2024)]
	hbox.get_node("RepLabel").text = "Rep: %d" % int(game_state.get("reputation", 50))

	var active_patients = game_state.get("patients", []).filter(
		func(p): return p.get("state", 0) != PatientData.PatientState.DISCHARGED and p.get("state", 0) != PatientData.PatientState.DECEASED)
	hbox.get_node("PatientCountLabel").text = "Patients: %d" % active_patients.size()
	hbox.get_node("StaffCountLabel").text = "Staff: %d" % game_state.get("staff", []).size()

func _update_active_panel():
	match _active_panel:
		"staff": _update_staff_panel()
		"patients": _update_patient_panel()
		"finance": _update_finance_panel()

func _update_events():
	var banner = $UILayer/UI.get_node_or_null("EventBanner")
	if banner == null:
		return
	for child in banner.get_children():
		child.queue_free()
	for event in game_state.get("active_events", []):
		var lbl = Label.new()
		lbl.text = event.get("title", "Event")
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
		banner.add_child(lbl)

# === Tab Handling ===

func _on_tab_pressed(tab: String):
	var ui = $UILayer/UI
	for panel_name in ["BuildMenu", "StaffMenu", "PatientList", "FinanceView"]:
		var p = ui.get_node_or_null(panel_name)
		if p:
			p.visible = false

	if _active_panel == tab:
		_active_panel = ""
		return

	_active_panel = tab
	match tab:
		"build":
			ui.get_node("BuildMenu").visible = true
		"staff":
			ui.get_node("StaffMenu").visible = true
			_update_staff_panel()
		"patients":
			ui.get_node("PatientList").visible = true
			_update_patient_panel()
		"finance":
			ui.get_node("FinanceView").visible = true
			_update_finance_panel()
		"insurance":
			pass

func _on_speed_change(speed: int):
	game_state["game_speed"] = speed

func _on_department_selected(dept: int):
	var build_menu = $UILayer/UI.get_node_or_null("BuildMenu")
	if build_menu == null:
		return
	var room_list: VBoxContainer
	for child in build_menu.get_children():
		var rl = child.find_child("RoomList", true, false)
		if rl:
			room_list = rl
			break
	if room_list == null:
		return

	for child in room_list.get_children():
		child.queue_free()

	var rooms = DepartmentDefs.get_available_rooms(dept)
	for room_type in rooms:
		var def = RoomDefs.get_definition(room_type)
		var btn = Button.new()
		btn.text = "%s - $%s (%dx%d)" % [
			RoomData.get_room_type_name(room_type),
			_fmt(def.get("build_cost", 0)),
			def.get("width", 3), def.get("height", 3)]
		btn.pressed.connect(_on_build_room.bind(room_type, dept))
		room_list.add_child(btn)

func _on_build_room(room_type: int, dept: int):
	hospital_renderer.enter_build_mode(room_type)

# === Staff Panel ===

func _update_staff_panel():
	var panel = $UILayer/UI.get_node_or_null("StaffMenu")
	if panel == null:
		return
	var roster: VBoxContainer
	for child in panel.get_children():
		var r = child.find_child("Roster", true, false)
		if r:
			roster = r
			break
	if roster == null:
		return

	for child in roster.get_children():
		child.queue_free()

	var total_cost := 0
	for staff in game_state.get("staff", []):
		total_cost += staff.get("salary", 0)
		var row = HBoxContainer.new()
		var name_lbl = Label.new()
		name_lbl.text = "%s (%s)" % [staff.get("staff_name", ""), StaffData.get_role_short_name(staff.get("role", 0))]
		name_lbl.custom_minimum_size = Vector2(180, 0)
		name_lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(name_lbl)

		var skill = staff.get("skill", 0.5) * (1.0 - staff.get("fatigue", 0) / 200.0)
		var skill_lbl = Label.new()
		skill_lbl.text = "%d%%" % int(skill * 100)
		skill_lbl.add_theme_font_size_override("font_size", 12)
		skill_lbl.add_theme_color_override("font_color", Color(0.2, 0.8, 0.8))
		row.add_child(skill_lbl)

		var sal_lbl = Label.new()
		sal_lbl.text = "$%s" % _fmt(staff.get("salary", 0))
		sal_lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(sal_lbl)

		var duty_lbl = Label.new()
		duty_lbl.text = "On" if staff.get("is_on_duty", true) else "Off"
		duty_lbl.add_theme_font_size_override("font_size", 11)
		duty_lbl.add_theme_color_override("font_color", Color.GREEN if staff.get("is_on_duty", true) else Color.RED)
		row.add_child(duty_lbl)

		roster.add_child(row)

	var cost_lbl = panel.find_child("AnnualCostLabel", true, false)
	if cost_lbl:
		cost_lbl.text = "Annual Labor Cost: $%s" % _fmt(total_cost)

# === Patient Panel ===

func _update_patient_panel():
	var panel = $UILayer/UI.get_node_or_null("PatientList")
	if panel == null:
		return
	var rows: VBoxContainer
	for child in panel.get_children():
		var r = child.find_child("PatientRows", true, false)
		if r:
			rows = r
			break
	if rows == null:
		return

	for child in rows.get_children():
		child.queue_free()

	var active = game_state.get("patients", []).filter(
		func(p): return p.get("state", 0) != PatientData.PatientState.DISCHARGED and p.get("state", 0) != PatientData.PatientState.DECEASED)

	for patient in active:
		var row = HBoxContainer.new()

		var dot = ColorRect.new()
		dot.custom_minimum_size = Vector2(10, 10)
		dot.color = _patient_state_color(patient.get("state", 0))
		row.add_child(dot)

		var name_lbl = Label.new()
		name_lbl.text = "%s (%d)" % [patient.get("patient_name", ""), patient.get("age", 0)]
		name_lbl.custom_minimum_size = Vector2(140, 0)
		name_lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(name_lbl)

		var state_lbl = Label.new()
		state_lbl.text = PatientData.get_state_name(patient.get("state", 0))
		state_lbl.add_theme_font_size_override("font_size", 11)
		state_lbl.add_theme_color_override("font_color", _patient_state_color(patient.get("state", 0)))
		state_lbl.custom_minimum_size = Vector2(120, 0)
		row.add_child(state_lbl)

		var payer_lbl = Label.new()
		payer_lbl.text = InsuranceData.get_payer_name(patient.get("payer_type", 0))
		payer_lbl.add_theme_font_size_override("font_size", 10)
		payer_lbl.add_theme_color_override("font_color", Color(0.3, 0.6, 1.0))
		row.add_child(payer_lbl)

		var sat_lbl = Label.new()
		sat_lbl.text = "Sat: %d%%" % int(patient.get("satisfaction", 100))
		sat_lbl.add_theme_font_size_override("font_size", 10)
		if patient.get("satisfaction", 100) < 60:
			sat_lbl.add_theme_color_override("font_color", Color.RED)
		row.add_child(sat_lbl)

		rows.add_child(row)

# === Finance Panel ===

func _update_finance_panel():
	var panel = $UILayer/UI.get_node_or_null("FinanceView")
	if panel == null:
		return
	var finance = game_state.get("finance", {})
	var content = panel.find_child("FinanceContent", true, false)
	if content == null:
		return

	var revenue = finance.get("total_revenue", 0)
	var expenses = finance.get("total_expenses", 0)
	var net = revenue - expenses
	var margin = revenue if revenue > 0 else 1.0
	var pending = game_state.get("claims", []).filter(func(c): return c.get("status", 0) < 2).size()
	var denied = game_state.get("claims", []).filter(func(c): return c.get("status", 0) == 3).size()
	var total_claims = max(1, game_state.get("claims", []).size())

	var vals = {
		"CashBalanceVal": "$%s" % _fmt(finance.get("cash_balance", 0)),
		"AccountsReceivableVal": "$%s" % _fmt(finance.get("accounts_receivable", 0)),
		"TotalRevenueVal": "$%s" % _fmt(revenue),
		"TotalExpensesVal": "$%s" % _fmt(expenses),
		"NetIncomeVal": "$%s" % _fmt(net),
		"OperatingMarginVal": "%.1f%%" % (net / margin * 100.0),
		"ClaimsPendingVal": str(pending),
		"DenialRateVal": "%.1f%%" % (float(denied) / float(total_claims) * 100.0),
	}
	for key in vals:
		var node = content.find_child(key, true, false)
		if node:
			node.text = vals[key]

# === Hire Staff ===

func _show_hire_dialog():
	var dialog = AcceptDialog.new()
	dialog.title = "Hire Staff - Select Role"
	dialog.size = Vector2(450, 650)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(420, 550)
	var vbox = VBoxContainer.new()

	for role_val in range(19):
		var range_data = StaffTemplates.get_salary_range(role_val)
		var btn = Button.new()
		btn.text = "%s  ($%s - $%s/yr)" % [
			StaffData.get_role_name(role_val),
			_fmt(range_data.get("min", 0)),
			_fmt(range_data.get("max", 0))]
		btn.pressed.connect(_hire_role.bind(role_val, dialog))
		vbox.add_child(btn)

	scroll.add_child(vbox)
	dialog.add_child(scroll)
	add_child(dialog)
	dialog.popup_centered()

func _hire_role(role: int, dialog: Node):
	var candidate = StaffTemplates.generate_candidate(role)
	game_state.get("staff", []).append(candidate)
	var finance = game_state.get("finance", {})
	finance.get("transactions", []).append({
		"type": FinanceData.TransactionType.SALARY_EXPENSE,
		"amount": 0,
		"description": "Hired %s" % candidate.get("staff_name", ""),
		"day": game_state.get("current_day", 1)
	})
	dialog.queue_free()
	_update_staff_panel()

# === Build Mode Input ===

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if hospital_renderer and hospital_renderer.build_mode_active:
			var world_pos = $Camera2D.get_global_mouse_position()
			var grid_pos = hospital_renderer.grid_position_from_world(world_pos)
			_try_place_room(grid_pos)

func _try_place_room(grid_pos: Vector2i):
	var room_type = hospital_renderer.build_room_type
	var def = RoomDefs.get_definition(room_type)
	var w = def.get("width", 3)
	var h = def.get("height", 3)
	var cost = def.get("build_cost", 0)
	var finance = game_state.get("finance", {})

	if finance.get("cash_balance", 0) < cost:
		return

	var hospital = game_state.get("hospital", {})
	var grid = hospital.get("grid", [])
	for dy in range(h):
		for dx in range(w):
			var x = grid_pos.x + dx
			var y = grid_pos.y + dy
			if x < 0 or x >= GameConstants.GRID_WIDTH or y < 0 or y >= GameConstants.GRID_HEIGHT:
				return
			if grid[y][x].get("type", 0) != 0:
				return

	var room_id = RoomData.generate_uuid()
	var room = {
		"id": room_id,
		"type": room_type,
		"origin_x": grid_pos.x,
		"origin_y": grid_pos.y,
		"width": w,
		"height": h,
		"department": def.get("department", 0),
		"assigned_staff_ids": [],
		"patient_capacity": def.get("patient_capacity", 1),
		"is_operational": false
	}
	hospital.get("rooms", []).append(room)

	for dy in range(h):
		for dx in range(w):
			var is_wall = (dx == 0 or dx == w - 1 or dy == 0 or dy == h - 1)
			grid[grid_pos.y + dy][grid_pos.x + dx] = {
				"type": 2 if is_wall else 1,
				"room_id": room_id
			}

	finance["cash_balance"] = finance.get("cash_balance", 0) - cost
	finance.get("transactions", []).append({
		"type": FinanceData.TransactionType.ROOM_CONSTRUCTION,
		"amount": cost,
		"description": "Built %s" % RoomData.get_room_type_name(room_type),
		"day": game_state.get("current_day", 1)
	})

	hospital_renderer.exit_build_mode()

func _on_save():
	SaveManager.save_game(game_state)

func _on_menu():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

# === Helpers ===

func _patient_state_color(state_val: int) -> Color:
	match state_val:
		PatientData.PatientState.ARRIVING, PatientData.PatientState.WAITING_FOR_REGISTRATION:
			return Color.WHITE
		PatientData.PatientState.REGISTERED, PatientData.PatientState.WAITING_FOR_EXAM:
			return Color.YELLOW
		PatientData.PatientState.IN_EXAMINATION, PatientData.PatientState.AWAITING_TEST_RESULTS:
			return Color.ORANGE
		PatientData.PatientState.DIAGNOSED, PatientData.PatientState.WAITING_FOR_TREATMENT:
			return Color.ORANGE
		PatientData.PatientState.IN_TREATMENT, PatientData.PatientState.ADMITTED:
			return Color.RED
		PatientData.PatientState.RECOVERING:
			return Color.GREEN
		PatientData.PatientState.DISCHARGED:
			return Color.GREEN
		PatientData.PatientState.DECEASED:
			return Color.GRAY
	return Color.WHITE

static func _fmt(num) -> String:
	var n = int(num)
	var s = str(absi(n))
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	if n < 0:
		result = "-" + result
	return result
