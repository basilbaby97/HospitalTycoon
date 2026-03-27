class_name EquipmentData extends Resource

enum EquipmentCategory {
	MRI_SCANNER, CT_SCANNER, XRAY_SYSTEM, ULTRASOUND, PATIENT_MONITOR,
	VENTILATOR, SURGICAL_ROBOT, CHEMISTRY_ANALYZER, HEMATOLOGY_ANALYZER,
	ECG_MACHINE, DEFIBRILLATOR, ANESTHESIA_SYSTEM, SURGICAL_TABLE,
	ENDOSCOPY_SYSTEM, INFUSION_PUMP, DIALYSIS_MACHINE, C_ARM,
	MAMMOGRAPHY, BONE_SCANNER, PULSE_OXIMETER
}

enum EquipmentTier { BASIC, STANDARD, PREMIUM }

enum DiagnosticTestType {
	PHYSICAL_EXAM, COMPLETE_BLOOD_COUNT, BASIC_METABOLIC_PANEL,
	COMPREHENSIVE_METABOLIC_PANEL, CHEST_XRAY, CT_SCAN_CHEST,
	CT_SCAN_ABDOMEN, MRI_BRAIN, ECG, URINALYSIS,
	ABDOMINAL_ULTRASOUND, BLOOD_CULTURE, TROPONIN_LEVEL,
	D_DIMER, ARTERIAL_BLOOD_GAS, LIVER_FUNCTION_TEST,
	LIPID_PANEL, THYROID_PANEL, COAGULATION_PANEL,
	LUMBAR_PUNCTURE, ECHOCARDIOGRAM, STRESS_TEST, ENDOSCOPY
}

@export var id: String = ""
@export var template_name: String = ""
@export var brand: String = ""
@export var category: EquipmentCategory = EquipmentCategory.PATIENT_MONITOR
@export var purchase_cost: int = 0
@export var annual_maintenance: int = 0
@export var installation_cost: int = 0
@export var required_room_type: RoomData.RoomType = RoomData.RoomType.RADIOLOGY_ROOM
@export var tier: EquipmentTier = EquipmentTier.STANDARD
@export var diagnostic_capabilities: Array[int] = []


func _init():
	id = RoomData.generate_uuid()


static func get_test_display_name(test: DiagnosticTestType) -> String:
	match test:
		DiagnosticTestType.PHYSICAL_EXAM: return "Physical Exam"
		DiagnosticTestType.COMPLETE_BLOOD_COUNT: return "Complete Blood Count"
		DiagnosticTestType.BASIC_METABOLIC_PANEL: return "Basic Metabolic Panel"
		DiagnosticTestType.COMPREHENSIVE_METABOLIC_PANEL: return "Comprehensive Metabolic Panel"
		DiagnosticTestType.CHEST_XRAY: return "Chest X-Ray"
		DiagnosticTestType.CT_SCAN_CHEST: return "CT Scan - Chest"
		DiagnosticTestType.CT_SCAN_ABDOMEN: return "CT Scan - Abdomen"
		DiagnosticTestType.MRI_BRAIN: return "MRI - Brain"
		DiagnosticTestType.ECG: return "Electrocardiogram"
		DiagnosticTestType.URINALYSIS: return "Urinalysis"
		DiagnosticTestType.ABDOMINAL_ULTRASOUND: return "Abdominal Ultrasound"
		DiagnosticTestType.BLOOD_CULTURE: return "Blood Culture"
		DiagnosticTestType.TROPONIN_LEVEL: return "Troponin Level"
		DiagnosticTestType.D_DIMER: return "D-Dimer"
		DiagnosticTestType.ARTERIAL_BLOOD_GAS: return "Arterial Blood Gas"
		DiagnosticTestType.LIVER_FUNCTION_TEST: return "Liver Function Test"
		DiagnosticTestType.LIPID_PANEL: return "Lipid Panel"
		DiagnosticTestType.THYROID_PANEL: return "Thyroid Panel"
		DiagnosticTestType.COAGULATION_PANEL: return "Coagulation Panel"
		DiagnosticTestType.LUMBAR_PUNCTURE: return "Lumbar Puncture"
		DiagnosticTestType.ECHOCARDIOGRAM: return "Echocardiogram"
		DiagnosticTestType.STRESS_TEST: return "Stress Test"
		DiagnosticTestType.ENDOSCOPY: return "Endoscopy"
	return ""


static func get_test_cpt_code(test: DiagnosticTestType) -> String:
	match test:
		DiagnosticTestType.PHYSICAL_EXAM: return "99213"
		DiagnosticTestType.COMPLETE_BLOOD_COUNT: return "85025"
		DiagnosticTestType.BASIC_METABOLIC_PANEL: return "80048"
		DiagnosticTestType.COMPREHENSIVE_METABOLIC_PANEL: return "80053"
		DiagnosticTestType.CHEST_XRAY: return "71046"
		DiagnosticTestType.CT_SCAN_CHEST: return "71260"
		DiagnosticTestType.CT_SCAN_ABDOMEN: return "74178"
		DiagnosticTestType.MRI_BRAIN: return "70553"
		DiagnosticTestType.ECG: return "93000"
		DiagnosticTestType.URINALYSIS: return "81003"
		DiagnosticTestType.ABDOMINAL_ULTRASOUND: return "76700"
		DiagnosticTestType.BLOOD_CULTURE: return "87040"
		DiagnosticTestType.TROPONIN_LEVEL: return "84484"
		DiagnosticTestType.D_DIMER: return "85379"
		DiagnosticTestType.ARTERIAL_BLOOD_GAS: return "82803"
		DiagnosticTestType.LIVER_FUNCTION_TEST: return "80076"
		DiagnosticTestType.LIPID_PANEL: return "80061"
		DiagnosticTestType.THYROID_PANEL: return "84443"
		DiagnosticTestType.COAGULATION_PANEL: return "85610"
		DiagnosticTestType.LUMBAR_PUNCTURE: return "62270"
		DiagnosticTestType.ECHOCARDIOGRAM: return "93306"
		DiagnosticTestType.STRESS_TEST: return "93015"
		DiagnosticTestType.ENDOSCOPY: return "43239"
	return ""


static func get_test_hospital_cost(test: DiagnosticTestType) -> float:
	match test:
		DiagnosticTestType.PHYSICAL_EXAM: return 25.0
		DiagnosticTestType.COMPLETE_BLOOD_COUNT: return 12.0
		DiagnosticTestType.BASIC_METABOLIC_PANEL: return 15.0
		DiagnosticTestType.COMPREHENSIVE_METABOLIC_PANEL: return 22.0
		DiagnosticTestType.CHEST_XRAY: return 45.0
		DiagnosticTestType.CT_SCAN_CHEST: return 250.0
		DiagnosticTestType.CT_SCAN_ABDOMEN: return 275.0
		DiagnosticTestType.MRI_BRAIN: return 400.0
		DiagnosticTestType.ECG: return 20.0
		DiagnosticTestType.URINALYSIS: return 8.0
		DiagnosticTestType.ABDOMINAL_ULTRASOUND: return 85.0
		DiagnosticTestType.BLOOD_CULTURE: return 35.0
		DiagnosticTestType.TROPONIN_LEVEL: return 18.0
		DiagnosticTestType.D_DIMER: return 22.0
		DiagnosticTestType.ARTERIAL_BLOOD_GAS: return 30.0
		DiagnosticTestType.LIVER_FUNCTION_TEST: return 18.0
		DiagnosticTestType.LIPID_PANEL: return 20.0
		DiagnosticTestType.THYROID_PANEL: return 25.0
		DiagnosticTestType.COAGULATION_PANEL: return 16.0
		DiagnosticTestType.LUMBAR_PUNCTURE: return 180.0
		DiagnosticTestType.ECHOCARDIOGRAM: return 150.0
		DiagnosticTestType.STRESS_TEST: return 120.0
		DiagnosticTestType.ENDOSCOPY: return 350.0
	return 0.0


static func get_test_charge(test: DiagnosticTestType) -> float:
	match test:
		DiagnosticTestType.PHYSICAL_EXAM: return 150.0
		DiagnosticTestType.COMPLETE_BLOOD_COUNT: return 95.0
		DiagnosticTestType.BASIC_METABOLIC_PANEL: return 120.0
		DiagnosticTestType.COMPREHENSIVE_METABOLIC_PANEL: return 185.0
		DiagnosticTestType.CHEST_XRAY: return 350.0
		DiagnosticTestType.CT_SCAN_CHEST: return 2200.0
		DiagnosticTestType.CT_SCAN_ABDOMEN: return 2500.0
		DiagnosticTestType.MRI_BRAIN: return 3500.0
		DiagnosticTestType.ECG: return 175.0
		DiagnosticTestType.URINALYSIS: return 65.0
		DiagnosticTestType.ABDOMINAL_ULTRASOUND: return 550.0
		DiagnosticTestType.BLOOD_CULTURE: return 250.0
		DiagnosticTestType.TROPONIN_LEVEL: return 145.0
		DiagnosticTestType.D_DIMER: return 180.0
		DiagnosticTestType.ARTERIAL_BLOOD_GAS: return 240.0
		DiagnosticTestType.LIVER_FUNCTION_TEST: return 140.0
		DiagnosticTestType.LIPID_PANEL: return 160.0
		DiagnosticTestType.THYROID_PANEL: return 200.0
		DiagnosticTestType.COAGULATION_PANEL: return 130.0
		DiagnosticTestType.LUMBAR_PUNCTURE: return 1200.0
		DiagnosticTestType.ECHOCARDIOGRAM: return 1800.0
		DiagnosticTestType.STRESS_TEST: return 1500.0
		DiagnosticTestType.ENDOSCOPY: return 3200.0
	return 0.0


static func get_test_ticks_required(test: DiagnosticTestType) -> int:
	match test:
		DiagnosticTestType.PHYSICAL_EXAM: return 1
		DiagnosticTestType.COMPLETE_BLOOD_COUNT: return 2
		DiagnosticTestType.BASIC_METABOLIC_PANEL: return 2
		DiagnosticTestType.COMPREHENSIVE_METABOLIC_PANEL: return 3
		DiagnosticTestType.CHEST_XRAY: return 1
		DiagnosticTestType.CT_SCAN_CHEST: return 2
		DiagnosticTestType.CT_SCAN_ABDOMEN: return 2
		DiagnosticTestType.MRI_BRAIN: return 4
		DiagnosticTestType.ECG: return 1
		DiagnosticTestType.URINALYSIS: return 1
		DiagnosticTestType.ABDOMINAL_ULTRASOUND: return 2
		DiagnosticTestType.BLOOD_CULTURE: return 6
		DiagnosticTestType.TROPONIN_LEVEL: return 2
		DiagnosticTestType.D_DIMER: return 2
		DiagnosticTestType.ARTERIAL_BLOOD_GAS: return 1
		DiagnosticTestType.LIVER_FUNCTION_TEST: return 2
		DiagnosticTestType.LIPID_PANEL: return 2
		DiagnosticTestType.THYROID_PANEL: return 3
		DiagnosticTestType.COAGULATION_PANEL: return 2
		DiagnosticTestType.LUMBAR_PUNCTURE: return 3
		DiagnosticTestType.ECHOCARDIOGRAM: return 3
		DiagnosticTestType.STRESS_TEST: return 4
		DiagnosticTestType.ENDOSCOPY: return 4
	return 1


static func get_test_required_room(test: DiagnosticTestType) -> RoomData.RoomType:
	match test:
		DiagnosticTestType.PHYSICAL_EXAM: return RoomData.RoomType.EXAMINATION_ROOM
		DiagnosticTestType.COMPLETE_BLOOD_COUNT: return RoomData.RoomType.LABORATORY
		DiagnosticTestType.BASIC_METABOLIC_PANEL: return RoomData.RoomType.LABORATORY
		DiagnosticTestType.COMPREHENSIVE_METABOLIC_PANEL: return RoomData.RoomType.LABORATORY
		DiagnosticTestType.CHEST_XRAY: return RoomData.RoomType.RADIOLOGY_ROOM
		DiagnosticTestType.CT_SCAN_CHEST: return RoomData.RoomType.RADIOLOGY_ROOM
		DiagnosticTestType.CT_SCAN_ABDOMEN: return RoomData.RoomType.RADIOLOGY_ROOM
		DiagnosticTestType.MRI_BRAIN: return RoomData.RoomType.RADIOLOGY_ROOM
		DiagnosticTestType.ECG: return RoomData.RoomType.EXAMINATION_ROOM
		DiagnosticTestType.URINALYSIS: return RoomData.RoomType.LABORATORY
		DiagnosticTestType.ABDOMINAL_ULTRASOUND: return RoomData.RoomType.RADIOLOGY_ROOM
		DiagnosticTestType.BLOOD_CULTURE: return RoomData.RoomType.LABORATORY
		DiagnosticTestType.TROPONIN_LEVEL: return RoomData.RoomType.LABORATORY
		DiagnosticTestType.D_DIMER: return RoomData.RoomType.LABORATORY
		DiagnosticTestType.ARTERIAL_BLOOD_GAS: return RoomData.RoomType.ICU_BAY
		DiagnosticTestType.LIVER_FUNCTION_TEST: return RoomData.RoomType.LABORATORY
		DiagnosticTestType.LIPID_PANEL: return RoomData.RoomType.LABORATORY
		DiagnosticTestType.THYROID_PANEL: return RoomData.RoomType.LABORATORY
		DiagnosticTestType.COAGULATION_PANEL: return RoomData.RoomType.LABORATORY
		DiagnosticTestType.LUMBAR_PUNCTURE: return RoomData.RoomType.OPERATING_ROOM
		DiagnosticTestType.ECHOCARDIOGRAM: return RoomData.RoomType.EXAMINATION_ROOM
		DiagnosticTestType.STRESS_TEST: return RoomData.RoomType.EXAMINATION_ROOM
		DiagnosticTestType.ENDOSCOPY: return RoomData.RoomType.ENDOSCOPY_ROOM
	return RoomData.RoomType.EXAMINATION_ROOM


static func get_test_required_equipment(test: DiagnosticTestType) -> EquipmentCategory:
	match test:
		DiagnosticTestType.PHYSICAL_EXAM: return EquipmentCategory.PATIENT_MONITOR
		DiagnosticTestType.COMPLETE_BLOOD_COUNT: return EquipmentCategory.HEMATOLOGY_ANALYZER
		DiagnosticTestType.BASIC_METABOLIC_PANEL: return EquipmentCategory.CHEMISTRY_ANALYZER
		DiagnosticTestType.COMPREHENSIVE_METABOLIC_PANEL: return EquipmentCategory.CHEMISTRY_ANALYZER
		DiagnosticTestType.CHEST_XRAY: return EquipmentCategory.XRAY_SYSTEM
		DiagnosticTestType.CT_SCAN_CHEST: return EquipmentCategory.CT_SCANNER
		DiagnosticTestType.CT_SCAN_ABDOMEN: return EquipmentCategory.CT_SCANNER
		DiagnosticTestType.MRI_BRAIN: return EquipmentCategory.MRI_SCANNER
		DiagnosticTestType.ECG: return EquipmentCategory.ECG_MACHINE
		DiagnosticTestType.URINALYSIS: return EquipmentCategory.CHEMISTRY_ANALYZER
		DiagnosticTestType.ABDOMINAL_ULTRASOUND: return EquipmentCategory.ULTRASOUND
		DiagnosticTestType.BLOOD_CULTURE: return EquipmentCategory.CHEMISTRY_ANALYZER
		DiagnosticTestType.TROPONIN_LEVEL: return EquipmentCategory.CHEMISTRY_ANALYZER
		DiagnosticTestType.D_DIMER: return EquipmentCategory.CHEMISTRY_ANALYZER
		DiagnosticTestType.ARTERIAL_BLOOD_GAS: return EquipmentCategory.CHEMISTRY_ANALYZER
		DiagnosticTestType.LIVER_FUNCTION_TEST: return EquipmentCategory.CHEMISTRY_ANALYZER
		DiagnosticTestType.LIPID_PANEL: return EquipmentCategory.CHEMISTRY_ANALYZER
		DiagnosticTestType.THYROID_PANEL: return EquipmentCategory.CHEMISTRY_ANALYZER
		DiagnosticTestType.COAGULATION_PANEL: return EquipmentCategory.HEMATOLOGY_ANALYZER
		DiagnosticTestType.LUMBAR_PUNCTURE: return EquipmentCategory.PATIENT_MONITOR
		DiagnosticTestType.ECHOCARDIOGRAM: return EquipmentCategory.ULTRASOUND
		DiagnosticTestType.STRESS_TEST: return EquipmentCategory.ECG_MACHINE
		DiagnosticTestType.ENDOSCOPY: return EquipmentCategory.ENDOSCOPY_SYSTEM
	return EquipmentCategory.PATIENT_MONITOR
