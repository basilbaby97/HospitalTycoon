extends Node

var all_equipment: Array[Dictionary] = []


func _ready():
	_init_catalog()


func _init_catalog():
	all_equipment = [
		# ========== GE Healthcare (8 items) ==========
		{
			"id": "ge_signa_explorer",
			"name": "SIGNA Explorer 1.5T MRI",
			"brand": "GE Healthcare",
			"category": EquipmentData.EquipmentCategory.MRI_SCANNER,
			"purchase_cost": 1200000,
			"annual_maintenance": 100000,
			"installation_cost": 150000,
			"required_room_type": RoomData.RoomType.RADIOLOGY_ROOM,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.MRI_BRAIN]
		},
		{
			"id": "ge_signa_premier",
			"name": "SIGNA Premier 3T MRI",
			"brand": "GE Healthcare",
			"category": EquipmentData.EquipmentCategory.MRI_SCANNER,
			"purchase_cost": 2500000,
			"annual_maintenance": 180000,
			"installation_cost": 250000,
			"required_room_type": RoomData.RoomType.RADIOLOGY_ROOM,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.MRI_BRAIN]
		},
		{
			"id": "ge_revolution_ct",
			"name": "Revolution CT",
			"brand": "GE Healthcare",
			"category": EquipmentData.EquipmentCategory.CT_SCANNER,
			"purchase_cost": 350000,
			"annual_maintenance": 40000,
			"installation_cost": 50000,
			"required_room_type": RoomData.RoomType.RADIOLOGY_ROOM,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.CT_SCAN_CHEST, EquipmentData.DiagnosticTestType.CT_SCAN_ABDOMEN]
		},
		{
			"id": "ge_optima_xr240",
			"name": "Optima XR240amx",
			"brand": "GE Healthcare",
			"category": EquipmentData.EquipmentCategory.XRAY_SYSTEM,
			"purchase_cost": 120000,
			"annual_maintenance": 12000,
			"installation_cost": 15000,
			"required_room_type": RoomData.RoomType.RADIOLOGY_ROOM,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.CHEST_XRAY]
		},
		{
			"id": "ge_logiq_e10",
			"name": "LOGIQ E10",
			"brand": "GE Healthcare",
			"category": EquipmentData.EquipmentCategory.ULTRASOUND,
			"purchase_cost": 180000,
			"annual_maintenance": 15000,
			"installation_cost": 5000,
			"required_room_type": RoomData.RoomType.RADIOLOGY_ROOM,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.ABDOMINAL_ULTRASOUND]
		},
		{
			"id": "ge_carescape_b650",
			"name": "CARESCAPE B650",
			"brand": "GE Healthcare",
			"category": EquipmentData.EquipmentCategory.PATIENT_MONITOR,
			"purchase_cost": 15000,
			"annual_maintenance": 1500,
			"installation_cost": 500,
			"required_room_type": RoomData.RoomType.ICU_BAY,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.PHYSICAL_EXAM]
		},
		{
			"id": "ge_mac_5500",
			"name": "MAC 5500 HD ECG",
			"brand": "GE Healthcare",
			"category": EquipmentData.EquipmentCategory.ECG_MACHINE,
			"purchase_cost": 10000,
			"annual_maintenance": 1000,
			"installation_cost": 300,
			"required_room_type": RoomData.RoomType.EXAMINATION_ROOM,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.ECG]
		},
		{
			"id": "ge_aisys_cs2",
			"name": "Aisys CS2 Anesthesia",
			"brand": "GE Healthcare",
			"category": EquipmentData.EquipmentCategory.ANESTHESIA_SYSTEM,
			"purchase_cost": 75000,
			"annual_maintenance": 8000,
			"installation_cost": 5000,
			"required_room_type": RoomData.RoomType.OPERATING_ROOM,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": []
		},

		# ========== Siemens Healthineers (6 items) ==========
		{
			"id": "siemens_magnetom_sola",
			"name": "MAGNETOM Sola 1.5T MRI",
			"brand": "Siemens Healthineers",
			"category": EquipmentData.EquipmentCategory.MRI_SCANNER,
			"purchase_cost": 1300000,
			"annual_maintenance": 110000,
			"installation_cost": 160000,
			"required_room_type": RoomData.RoomType.RADIOLOGY_ROOM,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.MRI_BRAIN]
		},
		{
			"id": "siemens_magnetom_vida",
			"name": "MAGNETOM Vida 3T MRI",
			"brand": "Siemens Healthineers",
			"category": EquipmentData.EquipmentCategory.MRI_SCANNER,
			"purchase_cost": 2800000,
			"annual_maintenance": 200000,
			"installation_cost": 280000,
			"required_room_type": RoomData.RoomType.RADIOLOGY_ROOM,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.MRI_BRAIN]
		},
		{
			"id": "siemens_somatom",
			"name": "SOMATOM X.cite CT",
			"brand": "Siemens Healthineers",
			"category": EquipmentData.EquipmentCategory.CT_SCANNER,
			"purchase_cost": 400000,
			"annual_maintenance": 45000,
			"installation_cost": 55000,
			"required_room_type": RoomData.RoomType.RADIOLOGY_ROOM,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.CT_SCAN_CHEST, EquipmentData.DiagnosticTestType.CT_SCAN_ABDOMEN]
		},
		{
			"id": "siemens_ysio_max",
			"name": "Ysio Max Digital X-Ray",
			"brand": "Siemens Healthineers",
			"category": EquipmentData.EquipmentCategory.XRAY_SYSTEM,
			"purchase_cost": 150000,
			"annual_maintenance": 14000,
			"installation_cost": 18000,
			"required_room_type": RoomData.RoomType.RADIOLOGY_ROOM,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.CHEST_XRAY]
		},
		{
			"id": "siemens_acuson_sequoia",
			"name": "ACUSON Sequoia Ultrasound",
			"brand": "Siemens Healthineers",
			"category": EquipmentData.EquipmentCategory.ULTRASOUND,
			"purchase_cost": 200000,
			"annual_maintenance": 18000,
			"installation_cost": 6000,
			"required_room_type": RoomData.RoomType.RADIOLOGY_ROOM,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.ABDOMINAL_ULTRASOUND, EquipmentData.DiagnosticTestType.ECHOCARDIOGRAM]
		},
		{
			"id": "siemens_atellica",
			"name": "Atellica Solution Analyzer",
			"brand": "Siemens Healthineers",
			"category": EquipmentData.EquipmentCategory.CHEMISTRY_ANALYZER,
			"purchase_cost": 160000,
			"annual_maintenance": 20000,
			"installation_cost": 10000,
			"required_room_type": RoomData.RoomType.LABORATORY,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.COMPREHENSIVE_METABOLIC_PANEL, EquipmentData.DiagnosticTestType.BASIC_METABOLIC_PANEL, EquipmentData.DiagnosticTestType.LIVER_FUNCTION_TEST, EquipmentData.DiagnosticTestType.LIPID_PANEL, EquipmentData.DiagnosticTestType.THYROID_PANEL, EquipmentData.DiagnosticTestType.TROPONIN_LEVEL, EquipmentData.DiagnosticTestType.D_DIMER]
		},

		# ========== Philips Healthcare (8 items) ==========
		{
			"id": "philips_ingenia_ambition",
			"name": "Ingenia Ambition 1.5T MRI",
			"brand": "Philips Healthcare",
			"category": EquipmentData.EquipmentCategory.MRI_SCANNER,
			"purchase_cost": 1100000,
			"annual_maintenance": 95000,
			"installation_cost": 140000,
			"required_room_type": RoomData.RoomType.RADIOLOGY_ROOM,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.MRI_BRAIN]
		},
		{
			"id": "philips_ingenia_elition",
			"name": "Ingenia Elition 3T MRI",
			"brand": "Philips Healthcare",
			"category": EquipmentData.EquipmentCategory.MRI_SCANNER,
			"purchase_cost": 2600000,
			"annual_maintenance": 190000,
			"installation_cost": 260000,
			"required_room_type": RoomData.RoomType.RADIOLOGY_ROOM,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.MRI_BRAIN]
		},
		{
			"id": "philips_digitaldiagnost",
			"name": "DigitalDiagnost C90 X-Ray",
			"brand": "Philips Healthcare",
			"category": EquipmentData.EquipmentCategory.XRAY_SYSTEM,
			"purchase_cost": 130000,
			"annual_maintenance": 13000,
			"installation_cost": 16000,
			"required_room_type": RoomData.RoomType.RADIOLOGY_ROOM,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.CHEST_XRAY]
		},
		{
			"id": "philips_epiq_elite",
			"name": "EPIQ Elite Ultrasound",
			"brand": "Philips Healthcare",
			"category": EquipmentData.EquipmentCategory.ULTRASOUND,
			"purchase_cost": 250000,
			"annual_maintenance": 22000,
			"installation_cost": 8000,
			"required_room_type": RoomData.RoomType.RADIOLOGY_ROOM,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.ABDOMINAL_ULTRASOUND, EquipmentData.DiagnosticTestType.ECHOCARDIOGRAM]
		},
		{
			"id": "philips_intellivue_mx800",
			"name": "IntelliVue MX800 Monitor",
			"brand": "Philips Healthcare",
			"category": EquipmentData.EquipmentCategory.PATIENT_MONITOR,
			"purchase_cost": 18000,
			"annual_maintenance": 2000,
			"installation_cost": 600,
			"required_room_type": RoomData.RoomType.ICU_BAY,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.PHYSICAL_EXAM]
		},
		{
			"id": "philips_pagewriter_tc70",
			"name": "PageWriter TC70 ECG",
			"brand": "Philips Healthcare",
			"category": EquipmentData.EquipmentCategory.ECG_MACHINE,
			"purchase_cost": 8000,
			"annual_maintenance": 800,
			"installation_cost": 200,
			"required_room_type": RoomData.RoomType.EXAMINATION_ROOM,
			"tier": EquipmentData.EquipmentTier.BASIC,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.ECG]
		},
		{
			"id": "philips_heartstart_mrx",
			"name": "HeartStart MRx Defibrillator",
			"brand": "Philips Healthcare",
			"category": EquipmentData.EquipmentCategory.DEFIBRILLATOR,
			"purchase_cost": 15000,
			"annual_maintenance": 1500,
			"installation_cost": 300,
			"required_room_type": RoomData.RoomType.EMERGENCY_BAY,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": []
		},
		{
			"id": "philips_trilogy_evo",
			"name": "Trilogy Evo Ventilator",
			"brand": "Philips Healthcare",
			"category": EquipmentData.EquipmentCategory.VENTILATOR,
			"purchase_cost": 35000,
			"annual_maintenance": 4000,
			"installation_cost": 1000,
			"required_room_type": RoomData.RoomType.ICU_BAY,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": []
		},

		# ========== Intuitive Surgical (1 item) ==========
		{
			"id": "intuitive_davinci_5",
			"name": "da Vinci 5 Surgical System",
			"brand": "Intuitive Surgical",
			"category": EquipmentData.EquipmentCategory.SURGICAL_ROBOT,
			"purchase_cost": 2200000,
			"annual_maintenance": 200000,
			"installation_cost": 150000,
			"required_room_type": RoomData.RoomType.OPERATING_ROOM,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": []
		},

		# ========== Medtronic (1 item) ==========
		{
			"id": "medtronic_hugo_ras",
			"name": "Hugo RAS Surgical Robot",
			"brand": "Medtronic",
			"category": EquipmentData.EquipmentCategory.SURGICAL_ROBOT,
			"purchase_cost": 1800000,
			"annual_maintenance": 160000,
			"installation_cost": 120000,
			"required_room_type": RoomData.RoomType.OPERATING_ROOM,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": []
		},

		# ========== Roche Diagnostics (1 item) ==========
		{
			"id": "roche_cobas_8000",
			"name": "Cobas 8000 Modular Analyzer",
			"brand": "Roche Diagnostics",
			"category": EquipmentData.EquipmentCategory.CHEMISTRY_ANALYZER,
			"purchase_cost": 180000,
			"annual_maintenance": 22000,
			"installation_cost": 12000,
			"required_room_type": RoomData.RoomType.LABORATORY,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.COMPREHENSIVE_METABOLIC_PANEL, EquipmentData.DiagnosticTestType.BASIC_METABOLIC_PANEL, EquipmentData.DiagnosticTestType.LIVER_FUNCTION_TEST, EquipmentData.DiagnosticTestType.LIPID_PANEL, EquipmentData.DiagnosticTestType.THYROID_PANEL, EquipmentData.DiagnosticTestType.TROPONIN_LEVEL, EquipmentData.DiagnosticTestType.D_DIMER, EquipmentData.DiagnosticTestType.BLOOD_CULTURE]
		},

		# ========== Abbott (1 item) ==========
		{
			"id": "abbott_architect_c8000",
			"name": "Architect c8000 Analyzer",
			"brand": "Abbott",
			"category": EquipmentData.EquipmentCategory.CHEMISTRY_ANALYZER,
			"purchase_cost": 150000,
			"annual_maintenance": 18000,
			"installation_cost": 10000,
			"required_room_type": RoomData.RoomType.LABORATORY,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.COMPREHENSIVE_METABOLIC_PANEL, EquipmentData.DiagnosticTestType.BASIC_METABOLIC_PANEL, EquipmentData.DiagnosticTestType.LIVER_FUNCTION_TEST, EquipmentData.DiagnosticTestType.LIPID_PANEL, EquipmentData.DiagnosticTestType.TROPONIN_LEVEL]
		},

		# ========== Beckman Coulter (2 items) ==========
		{
			"id": "beckman_au5800",
			"name": "AU5800 Chemistry Analyzer",
			"brand": "Beckman Coulter",
			"category": EquipmentData.EquipmentCategory.CHEMISTRY_ANALYZER,
			"purchase_cost": 120000,
			"annual_maintenance": 14000,
			"installation_cost": 8000,
			"required_room_type": RoomData.RoomType.LABORATORY,
			"tier": EquipmentData.EquipmentTier.BASIC,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.BASIC_METABOLIC_PANEL, EquipmentData.DiagnosticTestType.COMPREHENSIVE_METABOLIC_PANEL, EquipmentData.DiagnosticTestType.LIVER_FUNCTION_TEST]
		},
		{
			"id": "beckman_dxh_900",
			"name": "DxH 900 Hematology Analyzer",
			"brand": "Beckman Coulter",
			"category": EquipmentData.EquipmentCategory.HEMATOLOGY_ANALYZER,
			"purchase_cost": 80000,
			"annual_maintenance": 10000,
			"installation_cost": 5000,
			"required_room_type": RoomData.RoomType.LABORATORY,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.COMPLETE_BLOOD_COUNT, EquipmentData.DiagnosticTestType.COAGULATION_PANEL]
		},

		# ========== Sysmex (1 item) ==========
		{
			"id": "sysmex_xn_series",
			"name": "XN-Series Hematology",
			"brand": "Sysmex",
			"category": EquipmentData.EquipmentCategory.HEMATOLOGY_ANALYZER,
			"purchase_cost": 70000,
			"annual_maintenance": 8000,
			"installation_cost": 4000,
			"required_room_type": RoomData.RoomType.LABORATORY,
			"tier": EquipmentData.EquipmentTier.BASIC,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.COMPLETE_BLOOD_COUNT, EquipmentData.DiagnosticTestType.COAGULATION_PANEL]
		},

		# ========== Hamilton Medical (1 item) ==========
		{
			"id": "hamilton_c6",
			"name": "Hamilton C6 Ventilator",
			"brand": "Hamilton Medical",
			"category": EquipmentData.EquipmentCategory.VENTILATOR,
			"purchase_cost": 45000,
			"annual_maintenance": 5000,
			"installation_cost": 1500,
			"required_room_type": RoomData.RoomType.ICU_BAY,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": []
		},

		# ========== Draeger (2 items) ==========
		{
			"id": "draeger_evita_v800",
			"name": "Evita V800 Ventilator",
			"brand": "Draeger",
			"category": EquipmentData.EquipmentCategory.VENTILATOR,
			"purchase_cost": 60000,
			"annual_maintenance": 6000,
			"installation_cost": 2000,
			"required_room_type": RoomData.RoomType.ICU_BAY,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": []
		},
		{
			"id": "draeger_perseus_a500",
			"name": "Perseus A500 Anesthesia",
			"brand": "Draeger",
			"category": EquipmentData.EquipmentCategory.ANESTHESIA_SYSTEM,
			"purchase_cost": 85000,
			"annual_maintenance": 9000,
			"installation_cost": 6000,
			"required_room_type": RoomData.RoomType.OPERATING_ROOM,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": []
		},

		# ========== Stryker (3 items) ==========
		{
			"id": "stryker_lifepak_15",
			"name": "LIFEPAK 15 Defibrillator",
			"brand": "Stryker",
			"category": EquipmentData.EquipmentCategory.DEFIBRILLATOR,
			"purchase_cost": 25000,
			"annual_maintenance": 2500,
			"installation_cost": 500,
			"required_room_type": RoomData.RoomType.EMERGENCY_BAY,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": []
		},
		{
			"id": "stryker_altus",
			"name": "Altus Surgical Table",
			"brand": "Stryker",
			"category": EquipmentData.EquipmentCategory.SURGICAL_TABLE,
			"purchase_cost": 50000,
			"annual_maintenance": 3000,
			"installation_cost": 2000,
			"required_room_type": RoomData.RoomType.OPERATING_ROOM,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": []
		},
		{
			"id": "stryker_mako",
			"name": "Mako SmartRobotics System",
			"brand": "Stryker",
			"category": EquipmentData.EquipmentCategory.SURGICAL_ROBOT,
			"purchase_cost": 1500000,
			"annual_maintenance": 140000,
			"installation_cost": 100000,
			"required_room_type": RoomData.RoomType.OPERATING_ROOM,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": []
		},

		# ========== ZOLL (1 item) ==========
		{
			"id": "zoll_r_series",
			"name": "R Series Defibrillator",
			"brand": "ZOLL",
			"category": EquipmentData.EquipmentCategory.DEFIBRILLATOR,
			"purchase_cost": 20000,
			"annual_maintenance": 2000,
			"installation_cost": 400,
			"required_room_type": RoomData.RoomType.EMERGENCY_BAY,
			"tier": EquipmentData.EquipmentTier.BASIC,
			"diagnostic_capabilities": []
		},

		# ========== Maquet / Getinge (1 item) ==========
		{
			"id": "maquet_magnus",
			"name": "Magnus Surgical Table",
			"brand": "Maquet",
			"category": EquipmentData.EquipmentCategory.SURGICAL_TABLE,
			"purchase_cost": 65000,
			"annual_maintenance": 4000,
			"installation_cost": 3000,
			"required_room_type": RoomData.RoomType.OPERATING_ROOM,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": []
		},

		# ========== Olympus (1 item) ==========
		{
			"id": "olympus_evis_x1",
			"name": "EVIS X1 Endoscopy System",
			"brand": "Olympus",
			"category": EquipmentData.EquipmentCategory.ENDOSCOPY_SYSTEM,
			"purchase_cost": 120000,
			"annual_maintenance": 12000,
			"installation_cost": 8000,
			"required_room_type": RoomData.RoomType.ENDOSCOPY_ROOM,
			"tier": EquipmentData.EquipmentTier.PREMIUM,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.ENDOSCOPY]
		},

		# ========== Karl Storz (1 item) ==========
		{
			"id": "karlstorz_image1s",
			"name": "IMAGE1 S Endoscopy System",
			"brand": "Karl Storz",
			"category": EquipmentData.EquipmentCategory.ENDOSCOPY_SYSTEM,
			"purchase_cost": 90000,
			"annual_maintenance": 9000,
			"installation_cost": 6000,
			"required_room_type": RoomData.RoomType.ENDOSCOPY_ROOM,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.ENDOSCOPY]
		},

		# ========== Fresenius (1 item) ==========
		{
			"id": "fresenius_5008s",
			"name": "5008S CorDiax Dialysis",
			"brand": "Fresenius",
			"category": EquipmentData.EquipmentCategory.DIALYSIS_MACHINE,
			"purchase_cost": 35000,
			"annual_maintenance": 4000,
			"installation_cost": 2000,
			"required_room_type": RoomData.RoomType.DIALYSIS_CENTER,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": []
		},

		# ========== Mindray (1 item) ==========
		{
			"id": "mindray_epm",
			"name": "ePM 12M Patient Monitor",
			"brand": "Mindray",
			"category": EquipmentData.EquipmentCategory.PATIENT_MONITOR,
			"purchase_cost": 8000,
			"annual_maintenance": 800,
			"installation_cost": 300,
			"required_room_type": RoomData.RoomType.GENERAL_WARD,
			"tier": EquipmentData.EquipmentTier.BASIC,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.PHYSICAL_EXAM]
		},

		# ========== Baxter (1 item) ==========
		{
			"id": "baxter_sigma_spectrum",
			"name": "Sigma Spectrum Infusion Pump",
			"brand": "Baxter",
			"category": EquipmentData.EquipmentCategory.INFUSION_PUMP,
			"purchase_cost": 5000,
			"annual_maintenance": 500,
			"installation_cost": 100,
			"required_room_type": RoomData.RoomType.GENERAL_WARD,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": []
		},

		# ========== Additional C-Arm (1 item) ==========
		{
			"id": "siemens_cios_alpha",
			"name": "Cios Alpha C-Arm",
			"brand": "Siemens Healthineers",
			"category": EquipmentData.EquipmentCategory.C_ARM,
			"purchase_cost": 120000,
			"annual_maintenance": 12000,
			"installation_cost": 8000,
			"required_room_type": RoomData.RoomType.CATHETERIZATION_LAB,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.CHEST_XRAY]
		},

		# ========== Additional Pulse Oximeter (1 item) ==========
		{
			"id": "masimo_rad97",
			"name": "Rad-97 Pulse Oximeter",
			"brand": "Masimo",
			"category": EquipmentData.EquipmentCategory.PULSE_OXIMETER,
			"purchase_cost": 4000,
			"annual_maintenance": 400,
			"installation_cost": 100,
			"required_room_type": RoomData.RoomType.GENERAL_WARD,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.PHYSICAL_EXAM]
		},

		# ========== Additional Basic Monitors (2 items) ==========
		{
			"id": "philips_efficia_cm120",
			"name": "Efficia CM120 Monitor",
			"brand": "Philips Healthcare",
			"category": EquipmentData.EquipmentCategory.PATIENT_MONITOR,
			"purchase_cost": 6000,
			"annual_maintenance": 600,
			"installation_cost": 200,
			"required_room_type": RoomData.RoomType.GENERAL_WARD,
			"tier": EquipmentData.EquipmentTier.BASIC,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.PHYSICAL_EXAM]
		},
		{
			"id": "ge_carescape_b450",
			"name": "CARESCAPE B450 Monitor",
			"brand": "GE Healthcare",
			"category": EquipmentData.EquipmentCategory.PATIENT_MONITOR,
			"purchase_cost": 12000,
			"annual_maintenance": 1200,
			"installation_cost": 400,
			"required_room_type": RoomData.RoomType.EMERGENCY_BAY,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.PHYSICAL_EXAM]
		},

		# ========== Additional Infusion Pump (1 item) ==========
		{
			"id": "bd_alaris_8015",
			"name": "Alaris 8015 Infusion Pump",
			"brand": "BD",
			"category": EquipmentData.EquipmentCategory.INFUSION_PUMP,
			"purchase_cost": 6000,
			"annual_maintenance": 600,
			"installation_cost": 150,
			"required_room_type": RoomData.RoomType.CHEMOTHERAPY_ROOM,
			"tier": EquipmentData.EquipmentTier.STANDARD,
			"diagnostic_capabilities": []
		},

		# ========== Additional Ultrasound Basic (1 item) ==========
		{
			"id": "ge_vscan_air",
			"name": "Vscan Air Handheld Ultrasound",
			"brand": "GE Healthcare",
			"category": EquipmentData.EquipmentCategory.ULTRASOUND,
			"purchase_cost": 8000,
			"annual_maintenance": 800,
			"installation_cost": 0,
			"required_room_type": RoomData.RoomType.EXAMINATION_ROOM,
			"tier": EquipmentData.EquipmentTier.BASIC,
			"diagnostic_capabilities": [EquipmentData.DiagnosticTestType.ABDOMINAL_ULTRASOUND]
		},
	]


func find_by_id(equip_id: String) -> Dictionary:
	for item in all_equipment:
		if item.get("id") == equip_id:
			return item
	return {}


func get_equipment_for_category(cat: EquipmentData.EquipmentCategory) -> Array:
	var results: Array = []
	for item in all_equipment:
		if item.get("category") == cat:
			results.append(item)
	return results


func get_equipment_for_room(room_type: RoomData.RoomType) -> Array:
	var results: Array = []
	for item in all_equipment:
		if item.get("required_room_type") == room_type:
			results.append(item)
	return results


func get_all_brands() -> Array[String]:
	var brands: Dictionary = {}
	for item in all_equipment:
		brands[item.get("brand", "")] = true
	var result: Array[String] = []
	for brand_name in brands:
		result.append(brand_name)
	result.sort()
	return result
