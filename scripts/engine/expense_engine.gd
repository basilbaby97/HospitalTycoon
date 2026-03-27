extends RefCounted


func process_daily_salaries(state: Dictionary) -> void:
	var staff_list: Array = state.get("staff", [])
	if staff_list.is_empty():
		return

	var total_daily: float = 0.0
	for s in staff_list:
		var annual_salary: float = float(s.get("salary", 33000))
		total_daily += annual_salary / 365.0

	if total_daily > 0.0:
		_record_expense(state, total_daily, FinanceData.TransactionType.SALARY_EXPENSE, "Daily salary accrual")


func process_monthly_maintenance(state: Dictionary) -> void:
	var equipment: Array = state.get("hospital", {}).get("installed_equipment", [])
	if equipment.is_empty():
		return

	var total_maintenance: float = 0.0
	for equip in equipment:
		var annual_maint: float = _get_annual_maintenance_for_equipment(equip, state)
		total_maintenance += annual_maint / 12.0

	if total_maintenance > 0.0:
		_record_expense(state, total_maintenance, FinanceData.TransactionType.EQUIPMENT_MAINTENANCE, "Monthly equipment maintenance")


func process_monthly_supplies(state: Dictionary) -> void:
	var rooms: Array = state.get("hospital", {}).get("rooms", [])
	if rooms.is_empty():
		return

	var total_supply_cost: float = 0.0
	for room in rooms:
		if not room.get("is_operational", false):
			continue
		var room_type: int = room.get("type", 0)
		var room_supply_cost: float = _get_supply_cost_for_room(room_type)
		total_supply_cost += room_supply_cost

	if total_supply_cost > 0.0:
		_record_expense(state, total_supply_cost, FinanceData.TransactionType.SUPPLY_EXPENSE, "Monthly supply costs")


func degrade_equipment(state: Dictionary) -> void:
	var equipment: Array = state.get("hospital", {}).get("installed_equipment", [])
	if equipment.is_empty():
		return

	for i in range(equipment.size()):
		var condition: float = equipment[i].get("condition", 100.0)
		condition -= GameConstants.EQUIPMENT_DEGRADATION_PER_DAY

		if condition <= 0.0:
			condition = 0.0
			equipment[i]["condition"] = condition
			continue

		if condition < 10.0:
			var base_repair: float = _get_emergency_repair_cost(equipment[i], state)
			var repair_cost: float = base_repair * GameConstants.EMERGENCY_REPAIR_MULTIPLIER
			_record_expense(state, repair_cost, FinanceData.TransactionType.EQUIPMENT_MAINTENANCE,
				"Emergency repair: %s" % equipment[i].get("template_name", "Equipment"))
			condition = 50.0

		equipment[i]["condition"] = condition


func _get_annual_maintenance_for_equipment(equip: Dictionary, state: Dictionary) -> float:
	var template_id: String = equip.get("template_id", "")
	if template_id.is_empty():
		return 1200.0

	var catalog: Array = EquipmentCatalog.get_all_equipment()
	for template in catalog:
		if template.get("id", "") == template_id:
			return float(template.get("annual_maintenance", 1200))

	var category: int = equip.get("category", -1)
	match category:
		EquipmentData.EquipmentCategory.MRI_SCANNER:
			return 150000.0
		EquipmentData.EquipmentCategory.CT_SCANNER:
			return 100000.0
		EquipmentData.EquipmentCategory.XRAY_SYSTEM:
			return 15000.0
		EquipmentData.EquipmentCategory.ULTRASOUND:
			return 8000.0
		EquipmentData.EquipmentCategory.PATIENT_MONITOR:
			return 2000.0
		EquipmentData.EquipmentCategory.VENTILATOR:
			return 5000.0
		EquipmentData.EquipmentCategory.SURGICAL_ROBOT:
			return 200000.0
		EquipmentData.EquipmentCategory.CHEMISTRY_ANALYZER:
			return 12000.0
		EquipmentData.EquipmentCategory.HEMATOLOGY_ANALYZER:
			return 10000.0
		EquipmentData.EquipmentCategory.ECG_MACHINE:
			return 3000.0
		EquipmentData.EquipmentCategory.DEFIBRILLATOR:
			return 2500.0
		EquipmentData.EquipmentCategory.ANESTHESIA_SYSTEM:
			return 15000.0
		EquipmentData.EquipmentCategory.SURGICAL_TABLE:
			return 4000.0
		EquipmentData.EquipmentCategory.ENDOSCOPY_SYSTEM:
			return 20000.0
		EquipmentData.EquipmentCategory.INFUSION_PUMP:
			return 1500.0
		EquipmentData.EquipmentCategory.DIALYSIS_MACHINE:
			return 18000.0
		EquipmentData.EquipmentCategory.C_ARM:
			return 25000.0
		EquipmentData.EquipmentCategory.MAMMOGRAPHY:
			return 20000.0
		EquipmentData.EquipmentCategory.BONE_SCANNER:
			return 30000.0
		EquipmentData.EquipmentCategory.PULSE_OXIMETER:
			return 500.0
	return 1200.0


func _get_supply_cost_for_room(room_type: int) -> float:
	match room_type:
		RoomData.RoomType.RECEPTION:
			return 200.0
		RoomData.RoomType.GP_OFFICE:
			return 400.0
		RoomData.RoomType.EXAMINATION_ROOM:
			return 600.0
		RoomData.RoomType.EMERGENCY_BAY:
			return 1200.0
		RoomData.RoomType.TRIAGE_ROOM:
			return 500.0
		RoomData.RoomType.OPERATING_ROOM:
			return 3000.0
		RoomData.RoomType.RECOVERY_ROOM:
			return 800.0
		RoomData.RoomType.GENERAL_WARD:
			return 500.0
		RoomData.RoomType.PRIVATE_ROOM:
			return 600.0
		RoomData.RoomType.ICU_BAY:
			return 2000.0
		RoomData.RoomType.LABORATORY:
			return 1500.0
		RoomData.RoomType.BLOOD_BANK:
			return 1000.0
		RoomData.RoomType.RADIOLOGY_ROOM:
			return 800.0
		RoomData.RoomType.PHARMACY_ROOM:
			return 2500.0
		RoomData.RoomType.PHYSICAL_THERAPY:
			return 400.0
		RoomData.RoomType.ENDOSCOPY_ROOM:
			return 1200.0
		RoomData.RoomType.CATHETERIZATION_LAB:
			return 2500.0
		RoomData.RoomType.DIALYSIS_CENTER:
			return 1800.0
		RoomData.RoomType.CHEMOTHERAPY_ROOM:
			return 3500.0
		RoomData.RoomType.NURSERY_ROOM:
			return 700.0
		RoomData.RoomType.DELIVERY_ROOM:
			return 1500.0
		RoomData.RoomType.RESTROOM:
			return 50.0
		RoomData.RoomType.CAFETERIA:
			return 800.0
		RoomData.RoomType.SUPPLY_ROOM:
			return 100.0
		RoomData.RoomType.MAINTENANCE_ROOM:
			return 150.0
		RoomData.RoomType.ADMINISTRATIVE_OFFICE:
			return 200.0
		RoomData.RoomType.CONFERENCE_ROOM:
			return 100.0
		RoomData.RoomType.STAFF_LOUNGE:
			return 300.0
		RoomData.RoomType.PARKING:
			return 50.0
		RoomData.RoomType.MORGUE:
			return 400.0
	return 500.0


func _get_emergency_repair_cost(equip: Dictionary, state: Dictionary) -> float:
	var category: int = equip.get("category", -1)
	match category:
		EquipmentData.EquipmentCategory.MRI_SCANNER:
			return 25000.0
		EquipmentData.EquipmentCategory.CT_SCANNER:
			return 18000.0
		EquipmentData.EquipmentCategory.XRAY_SYSTEM:
			return 3000.0
		EquipmentData.EquipmentCategory.ULTRASOUND:
			return 2000.0
		EquipmentData.EquipmentCategory.PATIENT_MONITOR:
			return 500.0
		EquipmentData.EquipmentCategory.VENTILATOR:
			return 1500.0
		EquipmentData.EquipmentCategory.SURGICAL_ROBOT:
			return 40000.0
		EquipmentData.EquipmentCategory.CHEMISTRY_ANALYZER:
			return 3000.0
		EquipmentData.EquipmentCategory.HEMATOLOGY_ANALYZER:
			return 2500.0
		EquipmentData.EquipmentCategory.ECG_MACHINE:
			return 800.0
		EquipmentData.EquipmentCategory.DEFIBRILLATOR:
			return 600.0
		EquipmentData.EquipmentCategory.ANESTHESIA_SYSTEM:
			return 4000.0
		EquipmentData.EquipmentCategory.SURGICAL_TABLE:
			return 1000.0
		EquipmentData.EquipmentCategory.ENDOSCOPY_SYSTEM:
			return 5000.0
		EquipmentData.EquipmentCategory.INFUSION_PUMP:
			return 400.0
		EquipmentData.EquipmentCategory.DIALYSIS_MACHINE:
			return 4500.0
		EquipmentData.EquipmentCategory.C_ARM:
			return 6000.0
		EquipmentData.EquipmentCategory.MAMMOGRAPHY:
			return 5000.0
		EquipmentData.EquipmentCategory.BONE_SCANNER:
			return 7000.0
		EquipmentData.EquipmentCategory.PULSE_OXIMETER:
			return 100.0
	return 500.0


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


func get_daily_operating_cost(state: Dictionary) -> float:
	var staff_list: Array = state.get("staff", [])
	var total: float = 0.0
	for s in staff_list:
		total += float(s.get("salary", 33000)) / 365.0
	return total


func get_monthly_expense_breakdown(state: Dictionary) -> Dictionary:
	var staff_cost: float = 0.0
	for s in state.get("staff", []):
		staff_cost += float(s.get("salary", 33000)) / 12.0

	var equip_maintenance: float = 0.0
	var equipment: Array = state.get("hospital", {}).get("installed_equipment", [])
	for equip in equipment:
		equip_maintenance += _get_annual_maintenance_for_equipment(equip, state) / 12.0

	var supply_cost: float = 0.0
	var rooms: Array = state.get("hospital", {}).get("rooms", [])
	for room in rooms:
		if room.get("is_operational", false):
			supply_cost += _get_supply_cost_for_room(room.get("type", 0))

	return {
		"salaries": staff_cost,
		"equipment_maintenance": equip_maintenance,
		"supplies": supply_cost,
		"total": staff_cost + equip_maintenance + supply_cost,
	}
