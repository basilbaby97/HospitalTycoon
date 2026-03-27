extends Node

var _definitions: Dictionary = {}


func _ready():
	_init_definitions()


func _init_definitions():
	_definitions[RoomData.RoomType.RECEPTION] = {
		"width": 3, "height": 3,
		"department": RoomData.Department.EMERGENCY_DEPARTMENT,
		"build_cost": 50000, "daily_maintenance": 50,
		"required_staff": [StaffData.StaffRole.RECEPTIONIST],
		"required_equipment": [],
		"patient_capacity": 0,
		"description": "Front desk for patient registration and check-in"
	}
	_definitions[RoomData.RoomType.GP_OFFICE] = {
		"width": 3, "height": 3,
		"department": RoomData.Department.INTERNAL_MEDICINE,
		"build_cost": 75000, "daily_maintenance": 75,
		"required_staff": [StaffData.StaffRole.GENERAL_PRACTITIONER],
		"required_equipment": [EquipmentData.EquipmentCategory.PATIENT_MONITOR],
		"patient_capacity": 1,
		"description": "General practitioner office for outpatient consultations"
	}
	_definitions[RoomData.RoomType.EXAMINATION_ROOM] = {
		"width": 3, "height": 3,
		"department": RoomData.Department.INTERNAL_MEDICINE,
		"build_cost": 100000, "daily_maintenance": 100,
		"required_staff": [StaffData.StaffRole.REGISTERED_NURSE, StaffData.StaffRole.GENERAL_PRACTITIONER],
		"required_equipment": [EquipmentData.EquipmentCategory.PATIENT_MONITOR, EquipmentData.EquipmentCategory.ECG_MACHINE],
		"patient_capacity": 1,
		"description": "Comprehensive examination room with diagnostic equipment"
	}
	_definitions[RoomData.RoomType.EMERGENCY_BAY] = {
		"width": 4, "height": 4,
		"department": RoomData.Department.EMERGENCY_DEPARTMENT,
		"build_cost": 150000, "daily_maintenance": 200,
		"required_staff": [StaffData.StaffRole.EMERGENCY_PHYSICIAN, StaffData.StaffRole.REGISTERED_NURSE],
		"required_equipment": [EquipmentData.EquipmentCategory.PATIENT_MONITOR, EquipmentData.EquipmentCategory.DEFIBRILLATOR],
		"patient_capacity": 2,
		"description": "Emergency treatment bay for acute care patients"
	}
	_definitions[RoomData.RoomType.TRIAGE_ROOM] = {
		"width": 2, "height": 3,
		"department": RoomData.Department.EMERGENCY_DEPARTMENT,
		"build_cost": 60000, "daily_maintenance": 60,
		"required_staff": [StaffData.StaffRole.REGISTERED_NURSE],
		"required_equipment": [EquipmentData.EquipmentCategory.PATIENT_MONITOR],
		"patient_capacity": 1,
		"description": "Initial assessment room for incoming emergency patients"
	}
	_definitions[RoomData.RoomType.OPERATING_ROOM] = {
		"width": 5, "height": 5,
		"department": RoomData.Department.SURGERY,
		"build_cost": 500000, "daily_maintenance": 500,
		"required_staff": [StaffData.StaffRole.GENERAL_SURGEON, StaffData.StaffRole.ANESTHESIOLOGIST, StaffData.StaffRole.REGISTERED_NURSE],
		"required_equipment": [EquipmentData.EquipmentCategory.ANESTHESIA_SYSTEM, EquipmentData.EquipmentCategory.SURGICAL_TABLE, EquipmentData.EquipmentCategory.PATIENT_MONITOR],
		"patient_capacity": 1,
		"description": "Sterile surgical suite for operative procedures"
	}
	_definitions[RoomData.RoomType.RECOVERY_ROOM] = {
		"width": 3, "height": 4,
		"department": RoomData.Department.SURGERY,
		"build_cost": 80000, "daily_maintenance": 80,
		"required_staff": [StaffData.StaffRole.REGISTERED_NURSE],
		"required_equipment": [EquipmentData.EquipmentCategory.PATIENT_MONITOR],
		"patient_capacity": 2,
		"description": "Post-operative recovery area for surgical patients"
	}
	_definitions[RoomData.RoomType.GENERAL_WARD] = {
		"width": 5, "height": 4,
		"department": RoomData.Department.INTERNAL_MEDICINE,
		"build_cost": 120000, "daily_maintenance": 120,
		"required_staff": [StaffData.StaffRole.REGISTERED_NURSE, StaffData.StaffRole.CNA],
		"required_equipment": [EquipmentData.EquipmentCategory.PATIENT_MONITOR],
		"patient_capacity": 4,
		"description": "Multi-bed ward for inpatient care and observation"
	}
	_definitions[RoomData.RoomType.PRIVATE_ROOM] = {
		"width": 3, "height": 3,
		"department": RoomData.Department.INTERNAL_MEDICINE,
		"build_cost": 90000, "daily_maintenance": 90,
		"required_staff": [StaffData.StaffRole.REGISTERED_NURSE],
		"required_equipment": [EquipmentData.EquipmentCategory.PATIENT_MONITOR],
		"patient_capacity": 1,
		"description": "Single-occupancy room for patients requiring privacy"
	}
	_definitions[RoomData.RoomType.ICU_BAY] = {
		"width": 4, "height": 4,
		"department": RoomData.Department.INTENSIVE_CARE,
		"build_cost": 300000, "daily_maintenance": 400,
		"required_staff": [StaffData.StaffRole.REGISTERED_NURSE, StaffData.StaffRole.GENERAL_PRACTITIONER],
		"required_equipment": [EquipmentData.EquipmentCategory.PATIENT_MONITOR, EquipmentData.EquipmentCategory.VENTILATOR, EquipmentData.EquipmentCategory.INFUSION_PUMP, EquipmentData.EquipmentCategory.DEFIBRILLATOR],
		"patient_capacity": 1,
		"description": "Intensive care unit bay with continuous monitoring and life support"
	}
	_definitions[RoomData.RoomType.LABORATORY] = {
		"width": 4, "height": 4,
		"department": RoomData.Department.PATHOLOGY_LAB,
		"build_cost": 200000, "daily_maintenance": 250,
		"required_staff": [StaffData.StaffRole.LAB_TECHNICIAN, StaffData.StaffRole.PATHOLOGIST],
		"required_equipment": [EquipmentData.EquipmentCategory.CHEMISTRY_ANALYZER, EquipmentData.EquipmentCategory.HEMATOLOGY_ANALYZER],
		"patient_capacity": 0,
		"description": "Clinical laboratory for blood work and specimen analysis"
	}
	_definitions[RoomData.RoomType.BLOOD_BANK] = {
		"width": 3, "height": 3,
		"department": RoomData.Department.PATHOLOGY_LAB,
		"build_cost": 150000, "daily_maintenance": 180,
		"required_staff": [StaffData.StaffRole.LAB_TECHNICIAN],
		"required_equipment": [EquipmentData.EquipmentCategory.CHEMISTRY_ANALYZER],
		"patient_capacity": 0,
		"description": "Blood storage and crossmatch facility for transfusion services"
	}
	_definitions[RoomData.RoomType.RADIOLOGY_ROOM] = {
		"width": 5, "height": 5,
		"department": RoomData.Department.RADIOLOGY,
		"build_cost": 400000, "daily_maintenance": 350,
		"required_staff": [StaffData.StaffRole.RADIOLOGIST, StaffData.StaffRole.LAB_TECHNICIAN],
		"required_equipment": [EquipmentData.EquipmentCategory.XRAY_SYSTEM],
		"patient_capacity": 1,
		"description": "Diagnostic imaging suite for X-ray, CT, MRI, and ultrasound"
	}
	_definitions[RoomData.RoomType.PHARMACY_ROOM] = {
		"width": 3, "height": 4,
		"department": RoomData.Department.PHARMACY,
		"build_cost": 100000, "daily_maintenance": 100,
		"required_staff": [StaffData.StaffRole.PHARMACIST],
		"required_equipment": [],
		"patient_capacity": 0,
		"description": "Medication dispensing and pharmaceutical services"
	}
	_definitions[RoomData.RoomType.PHYSICAL_THERAPY] = {
		"width": 4, "height": 4,
		"department": RoomData.Department.ORTHOPEDICS,
		"build_cost": 80000, "daily_maintenance": 80,
		"required_staff": [StaffData.StaffRole.REGISTERED_NURSE],
		"required_equipment": [],
		"patient_capacity": 2,
		"description": "Rehabilitation space for physical therapy and mobility recovery"
	}
	_definitions[RoomData.RoomType.ENDOSCOPY_ROOM] = {
		"width": 4, "height": 4,
		"department": RoomData.Department.SURGERY,
		"build_cost": 250000, "daily_maintenance": 200,
		"required_staff": [StaffData.StaffRole.GENERAL_SURGEON, StaffData.StaffRole.REGISTERED_NURSE],
		"required_equipment": [EquipmentData.EquipmentCategory.ENDOSCOPY_SYSTEM, EquipmentData.EquipmentCategory.PATIENT_MONITOR],
		"patient_capacity": 1,
		"description": "Procedure room for endoscopic diagnostic and therapeutic interventions"
	}
	_definitions[RoomData.RoomType.CATHETERIZATION_LAB] = {
		"width": 5, "height": 5,
		"department": RoomData.Department.CARDIOLOGY,
		"build_cost": 800000, "daily_maintenance": 600,
		"required_staff": [StaffData.StaffRole.CARDIOLOGIST, StaffData.StaffRole.REGISTERED_NURSE, StaffData.StaffRole.LAB_TECHNICIAN],
		"required_equipment": [EquipmentData.EquipmentCategory.C_ARM, EquipmentData.EquipmentCategory.PATIENT_MONITOR, EquipmentData.EquipmentCategory.ECG_MACHINE],
		"patient_capacity": 1,
		"description": "Cardiac catheterization lab for angiography and interventional cardiology"
	}
	_definitions[RoomData.RoomType.DIALYSIS_CENTER] = {
		"width": 5, "height": 4,
		"department": RoomData.Department.INTERNAL_MEDICINE,
		"build_cost": 350000, "daily_maintenance": 300,
		"required_staff": [StaffData.StaffRole.REGISTERED_NURSE, StaffData.StaffRole.LPN],
		"required_equipment": [EquipmentData.EquipmentCategory.DIALYSIS_MACHINE, EquipmentData.EquipmentCategory.PATIENT_MONITOR],
		"patient_capacity": 3,
		"description": "Hemodialysis treatment center for patients with renal failure"
	}
	_definitions[RoomData.RoomType.CHEMOTHERAPY_ROOM] = {
		"width": 4, "height": 4,
		"department": RoomData.Department.ONCOLOGY,
		"build_cost": 300000, "daily_maintenance": 280,
		"required_staff": [StaffData.StaffRole.ONCOLOGIST, StaffData.StaffRole.REGISTERED_NURSE],
		"required_equipment": [EquipmentData.EquipmentCategory.INFUSION_PUMP, EquipmentData.EquipmentCategory.PATIENT_MONITOR],
		"patient_capacity": 3,
		"description": "Infusion center for chemotherapy and immunotherapy treatments"
	}
	_definitions[RoomData.RoomType.NURSERY_ROOM] = {
		"width": 4, "height": 3,
		"department": RoomData.Department.PEDIATRICS,
		"build_cost": 100000, "daily_maintenance": 100,
		"required_staff": [StaffData.StaffRole.REGISTERED_NURSE, StaffData.StaffRole.CNA],
		"required_equipment": [EquipmentData.EquipmentCategory.PATIENT_MONITOR, EquipmentData.EquipmentCategory.PULSE_OXIMETER],
		"patient_capacity": 4,
		"description": "Neonatal nursery for newborn care and monitoring"
	}
	_definitions[RoomData.RoomType.DELIVERY_ROOM] = {
		"width": 4, "height": 4,
		"department": RoomData.Department.OBGYN,
		"build_cost": 200000, "daily_maintenance": 180,
		"required_staff": [StaffData.StaffRole.GENERAL_PRACTITIONER, StaffData.StaffRole.REGISTERED_NURSE],
		"required_equipment": [EquipmentData.EquipmentCategory.PATIENT_MONITOR, EquipmentData.EquipmentCategory.ULTRASOUND],
		"patient_capacity": 1,
		"description": "Labor and delivery suite for childbirth"
	}
	_definitions[RoomData.RoomType.RESTROOM] = {
		"width": 2, "height": 2,
		"department": RoomData.Department.EMERGENCY_DEPARTMENT,
		"build_cost": 20000, "daily_maintenance": 20,
		"required_staff": [StaffData.StaffRole.JANITOR],
		"required_equipment": [],
		"patient_capacity": 0,
		"description": "Public restroom facility"
	}
	_definitions[RoomData.RoomType.CAFETERIA] = {
		"width": 5, "height": 4,
		"department": RoomData.Department.EMERGENCY_DEPARTMENT,
		"build_cost": 80000, "daily_maintenance": 100,
		"required_staff": [],
		"required_equipment": [],
		"patient_capacity": 0,
		"description": "Dining area for staff, patients, and visitors"
	}
	_definitions[RoomData.RoomType.SUPPLY_ROOM] = {
		"width": 2, "height": 3,
		"department": RoomData.Department.EMERGENCY_DEPARTMENT,
		"build_cost": 30000, "daily_maintenance": 30,
		"required_staff": [],
		"required_equipment": [],
		"patient_capacity": 0,
		"description": "Storage room for medical supplies and consumables"
	}
	_definitions[RoomData.RoomType.MAINTENANCE_ROOM] = {
		"width": 3, "height": 3,
		"department": RoomData.Department.EMERGENCY_DEPARTMENT,
		"build_cost": 40000, "daily_maintenance": 40,
		"required_staff": [StaffData.StaffRole.JANITOR],
		"required_equipment": [],
		"patient_capacity": 0,
		"description": "Maintenance workshop for equipment repair and building upkeep"
	}
	_definitions[RoomData.RoomType.ADMINISTRATIVE_OFFICE] = {
		"width": 3, "height": 3,
		"department": RoomData.Department.EMERGENCY_DEPARTMENT,
		"build_cost": 60000, "daily_maintenance": 50,
		"required_staff": [StaffData.StaffRole.ADMINISTRATOR],
		"required_equipment": [],
		"patient_capacity": 0,
		"description": "Administrative office for hospital management and billing"
	}
	_definitions[RoomData.RoomType.CONFERENCE_ROOM] = {
		"width": 4, "height": 3,
		"department": RoomData.Department.EMERGENCY_DEPARTMENT,
		"build_cost": 50000, "daily_maintenance": 30,
		"required_staff": [],
		"required_equipment": [],
		"patient_capacity": 0,
		"description": "Meeting room for staff conferences and continuing education"
	}
	_definitions[RoomData.RoomType.STAFF_LOUNGE] = {
		"width": 3, "height": 3,
		"department": RoomData.Department.EMERGENCY_DEPARTMENT,
		"build_cost": 40000, "daily_maintenance": 30,
		"required_staff": [],
		"required_equipment": [],
		"patient_capacity": 0,
		"description": "Break room for staff rest and recovery"
	}
	_definitions[RoomData.RoomType.PARKING] = {
		"width": 6, "height": 6,
		"department": RoomData.Department.EMERGENCY_DEPARTMENT,
		"build_cost": 100000, "daily_maintenance": 50,
		"required_staff": [],
		"required_equipment": [],
		"patient_capacity": 0,
		"description": "Parking structure for patients, visitors, and staff"
	}
	_definitions[RoomData.RoomType.MORGUE] = {
		"width": 3, "height": 3,
		"department": RoomData.Department.PATHOLOGY_LAB,
		"build_cost": 75000, "daily_maintenance": 60,
		"required_staff": [StaffData.StaffRole.PATHOLOGIST],
		"required_equipment": [],
		"patient_capacity": 0,
		"description": "Mortuary facility for deceased patient holding and autopsies"
	}


func get_definition(room_type: RoomData.RoomType) -> Dictionary:
	return _definitions.get(room_type, {})


func get_definitions_for_department(dept: RoomData.Department) -> Array:
	var results: Array = []
	for room_type in _definitions:
		var defn: Dictionary = _definitions[room_type]
		if defn.get("department") == dept:
			var entry: Dictionary = defn.duplicate()
			entry["room_type"] = room_type
			results.append(entry)
	return results


func get_build_cost(room_type: RoomData.RoomType) -> int:
	return _definitions.get(room_type, {}).get("build_cost", 0)


func get_required_staff(room_type: RoomData.RoomType) -> Array:
	return _definitions.get(room_type, {}).get("required_staff", [])


func get_required_equipment(room_type: RoomData.RoomType) -> Array:
	return _definitions.get(room_type, {}).get("required_equipment", [])


func get_patient_capacity(room_type: RoomData.RoomType) -> int:
	return _definitions.get(room_type, {}).get("patient_capacity", 0)
