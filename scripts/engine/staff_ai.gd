extends RefCounted


func assign_tasks(state: Dictionary) -> void:
	_assign_staff_to_rooms(state)
	_manage_shifts(state)
	_assign_doctors_to_patients(state)


func _assign_staff_to_rooms(state: Dictionary) -> void:
	var rooms: Array = state.get("hospital", {}).get("rooms", [])
	var staff_list: Array = state.get("staff", [])

	for room in rooms:
		var room_id: String = room.get("id", "")
		var room_type: int = room.get("type", 0)
		var required_roles: Array = _get_required_roles(room_type)

		for req_role in required_roles:
			var already_assigned: bool = staff_list.any(
				func(s): return s.get("assigned_room_id", "") == room_id \
					and s.get("role", -1) == req_role \
					and s.get("is_on_duty", false)
			)
			if already_assigned:
				continue

			var best_candidate_idx: int = -1
			var best_skill: float = -1.0
			for i in range(staff_list.size()):
				var s: Dictionary = staff_list[i]
				if s.get("role", -1) != req_role:
					continue
				if not s.get("is_on_duty", false):
					continue
				if s.get("assigned_room_id", "") != "":
					continue
				if s.get("fatigue", 0.0) >= GameConstants.MAX_STAFF_FATIGUE:
					continue
				var eff_skill: float = s.get("skill", 0.5) * (1.0 - s.get("fatigue", 0.0) / 200.0)
				if eff_skill > best_skill:
					best_skill = eff_skill
					best_candidate_idx = i
			if best_candidate_idx >= 0:
				staff_list[best_candidate_idx]["assigned_room_id"] = room_id


func _manage_shifts(state: Dictionary) -> void:
	var staff_list: Array = state.get("staff", [])
	for i in range(staff_list.size()):
		var s: Dictionary = staff_list[i]
		var fatigue: float = s.get("fatigue", 0.0)
		var on_duty: bool = s.get("is_on_duty", false)

		if on_duty and fatigue >= GameConstants.MAX_STAFF_FATIGUE:
			staff_list[i]["is_on_duty"] = false
			staff_list[i]["assigned_room_id"] = ""
			staff_list[i]["current_task_id"] = ""

		if not on_duty and fatigue <= 20.0:
			staff_list[i]["is_on_duty"] = true


func _assign_doctors_to_patients(state: Dictionary) -> void:
	var patients: Array = state.get("patients", [])
	var staff_list: Array = state.get("staff", [])

	for i in range(patients.size()):
		var patient: Dictionary = patients[i]
		var p_state: int = patient.get("state", 0)
		if p_state != PatientData.PatientState.WAITING_FOR_EXAM:
			continue
		if patient.get("assigned_doctor_id", "") != "":
			continue

		var doctor_idx: int = _find_available_doctor(staff_list)
		if doctor_idx >= 0:
			patients[i]["assigned_doctor_id"] = staff_list[doctor_idx].get("id", "")
			staff_list[doctor_idx]["current_task_id"] = patient.get("id", "")


func _find_available_doctor(staff_list: Array) -> int:
	var best_idx: int = -1
	var best_score: float = -1.0
	for i in range(staff_list.size()):
		var s: Dictionary = staff_list[i]
		if not StaffData.is_physician(s.get("role", -1)):
			continue
		if not s.get("is_on_duty", false):
			continue
		if s.get("current_task_id", "") != "":
			continue
		if s.get("fatigue", 0.0) >= GameConstants.MAX_STAFF_FATIGUE:
			continue
		var eff_skill: float = s.get("skill", 0.5) * (1.0 - s.get("fatigue", 0.0) / 200.0)
		if eff_skill > best_score:
			best_score = eff_skill
			best_idx = i
	return best_idx


func _get_required_roles(room_type: int) -> Array:
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
		RoomData.RoomType.RESTROOM:
			return []
		RoomData.RoomType.CAFETERIA:
			return []
		RoomData.RoomType.SUPPLY_ROOM:
			return []
		RoomData.RoomType.MAINTENANCE_ROOM:
			return [StaffData.StaffRole.JANITOR]
		RoomData.RoomType.ADMINISTRATIVE_OFFICE:
			return [StaffData.StaffRole.ADMINISTRATOR]
		RoomData.RoomType.CONFERENCE_ROOM:
			return []
		RoomData.RoomType.STAFF_LOUNGE:
			return []
		RoomData.RoomType.PARKING:
			return []
	return []


func is_room_adequately_staffed(room: Dictionary, state: Dictionary) -> bool:
	var room_id: String = room.get("id", "")
	var room_type: int = room.get("type", 0)
	var required_roles: Array = _get_required_roles(room_type)
	var staff_list: Array = state.get("staff", [])

	if required_roles.is_empty():
		return true

	for req_role in required_roles:
		var has_role: bool = staff_list.any(
			func(s): return s.get("assigned_room_id", "") == room_id \
				and s.get("role", -1) == req_role \
				and s.get("is_on_duty", false)
		)
		if not has_role:
			return false
	return true


func find_best_doctor(department: int, state: Dictionary) -> Dictionary:
	var staff_list: Array = state.get("staff", [])
	var best: Dictionary = {}
	var best_score: float = -1.0

	for s in staff_list:
		if not StaffData.is_physician(s.get("role", -1)):
			continue
		if not s.get("is_on_duty", false):
			continue
		if s.get("fatigue", 0.0) >= GameConstants.MAX_STAFF_FATIGUE:
			continue
		var matches_dept: bool = s.get("assigned_department", -1) == department or s.get("assigned_department", -1) == -1
		if not matches_dept:
			continue
		var eff_skill: float = s.get("skill", 0.5) * (1.0 - s.get("fatigue", 0.0) / 200.0)
		if eff_skill > best_score:
			best_score = eff_skill
			best = s
	return best


func get_staff_utilization(state: Dictionary) -> float:
	var staff_list: Array = state.get("staff", [])
	if staff_list.is_empty():
		return 0.0
	var busy_count: int = 0
	for s in staff_list:
		if s.get("is_on_duty", false) and (s.get("assigned_room_id", "") != "" or s.get("current_task_id", "") != ""):
			busy_count += 1
	return float(busy_count) / float(staff_list.size())


func get_on_duty_count(state: Dictionary) -> int:
	var count: int = 0
	for s in state.get("staff", []):
		if s.get("is_on_duty", false):
			count += 1
	return count


func get_resting_count(state: Dictionary) -> int:
	var count: int = 0
	for s in state.get("staff", []):
		if not s.get("is_on_duty", false):
			count += 1
	return count
