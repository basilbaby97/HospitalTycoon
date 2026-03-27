extends Node

var all_codes: Array[Dictionary] = []


func _ready():
	_init_codes()


func _init_codes():
	all_codes = [
		# ========== Evaluation & Management (E&M) ==========
		{
			"code": "99213",
			"description": "Office Visit Level 3",
			"category": "E&M",
			"hospital_cost": 50,
			"charge_amount": 150,
			"medicare_reimbursement": 75,
		},
		{
			"code": "99214",
			"description": "Office Visit Level 4",
			"category": "E&M",
			"hospital_cost": 75,
			"charge_amount": 225,
			"medicare_reimbursement": 110,
		},
		{
			"code": "99215",
			"description": "Office Visit Level 5",
			"category": "E&M",
			"hospital_cost": 110,
			"charge_amount": 350,
			"medicare_reimbursement": 165,
		},
		{
			"code": "99283",
			"description": "Emergency Dept Visit Level 3",
			"category": "E&M",
			"hospital_cost": 150,
			"charge_amount": 600,
			"medicare_reimbursement": 225,
		},
		{
			"code": "99285",
			"description": "Emergency Dept Visit Level 5",
			"category": "E&M",
			"hospital_cost": 350,
			"charge_amount": 1800,
			"medicare_reimbursement": 560,
		},

		# ========== Surgery ==========
		{
			"code": "27447",
			"description": "Total Knee Arthroplasty",
			"category": "Surgery",
			"hospital_cost": 6000,
			"charge_amount": 45000,
			"medicare_reimbursement": 18000,
		},
		{
			"code": "44970",
			"description": "Laparoscopic Appendectomy",
			"category": "Surgery",
			"hospital_cost": 3500,
			"charge_amount": 22000,
			"medicare_reimbursement": 8500,
		},
		{
			"code": "47562",
			"description": "Laparoscopic Cholecystectomy",
			"category": "Surgery",
			"hospital_cost": 3200,
			"charge_amount": 20000,
			"medicare_reimbursement": 7800,
		},
		{
			"code": "27236",
			"description": "Open Treatment Hip Fracture",
			"category": "Surgery",
			"hospital_cost": 5500,
			"charge_amount": 38000,
			"medicare_reimbursement": 15000,
		},
		{
			"code": "44120",
			"description": "Small Bowel Resection",
			"category": "Surgery",
			"hospital_cost": 5000,
			"charge_amount": 35000,
			"medicare_reimbursement": 14000,
		},

		# ========== Radiology ==========
		{
			"code": "71046",
			"description": "Chest X-Ray 2 Views",
			"category": "Radiology",
			"hospital_cost": 45,
			"charge_amount": 350,
			"medicare_reimbursement": 28,
		},
		{
			"code": "71260",
			"description": "CT Chest with Contrast",
			"category": "Radiology",
			"hospital_cost": 250,
			"charge_amount": 2200,
			"medicare_reimbursement": 270,
		},
		{
			"code": "70553",
			"description": "MRI Brain with and without Contrast",
			"category": "Radiology",
			"hospital_cost": 400,
			"charge_amount": 3500,
			"medicare_reimbursement": 520,
		},
		{
			"code": "76700",
			"description": "Ultrasound Abdomen Complete",
			"category": "Radiology",
			"hospital_cost": 85,
			"charge_amount": 550,
			"medicare_reimbursement": 100,
		},
		{
			"code": "74178",
			"description": "CT Abdomen and Pelvis with Contrast",
			"category": "Radiology",
			"hospital_cost": 275,
			"charge_amount": 2500,
			"medicare_reimbursement": 310,
		},

		# ========== Laboratory ==========
		{
			"code": "85025",
			"description": "Complete Blood Count (CBC)",
			"category": "Lab",
			"hospital_cost": 12,
			"charge_amount": 95,
			"medicare_reimbursement": 11,
		},
		{
			"code": "80048",
			"description": "Basic Metabolic Panel (BMP)",
			"category": "Lab",
			"hospital_cost": 15,
			"charge_amount": 120,
			"medicare_reimbursement": 14,
		},
		{
			"code": "80053",
			"description": "Comprehensive Metabolic Panel (CMP)",
			"category": "Lab",
			"hospital_cost": 22,
			"charge_amount": 185,
			"medicare_reimbursement": 18,
		},
		{
			"code": "87040",
			"description": "Blood Culture",
			"category": "Lab",
			"hospital_cost": 35,
			"charge_amount": 250,
			"medicare_reimbursement": 40,
		},
		{
			"code": "84484",
			"description": "Troponin Quantitative",
			"category": "Lab",
			"hospital_cost": 18,
			"charge_amount": 145,
			"medicare_reimbursement": 22,
		},
		{
			"code": "85379",
			"description": "D-Dimer Quantitative",
			"category": "Lab",
			"hospital_cost": 22,
			"charge_amount": 180,
			"medicare_reimbursement": 20,
		},
		{
			"code": "82803",
			"description": "Arterial Blood Gas",
			"category": "Lab",
			"hospital_cost": 30,
			"charge_amount": 240,
			"medicare_reimbursement": 35,
		},
		{
			"code": "81003",
			"description": "Urinalysis Automated",
			"category": "Lab",
			"hospital_cost": 8,
			"charge_amount": 65,
			"medicare_reimbursement": 5,
		},
		{
			"code": "80076",
			"description": "Liver Function Panel",
			"category": "Lab",
			"hospital_cost": 18,
			"charge_amount": 140,
			"medicare_reimbursement": 16,
		},
		{
			"code": "80061",
			"description": "Lipid Panel",
			"category": "Lab",
			"hospital_cost": 20,
			"charge_amount": 160,
			"medicare_reimbursement": 18,
		},
		{
			"code": "84443",
			"description": "Thyroid Stimulating Hormone (TSH)",
			"category": "Lab",
			"hospital_cost": 25,
			"charge_amount": 200,
			"medicare_reimbursement": 23,
		},
		{
			"code": "85610",
			"description": "Prothrombin Time (PT/INR)",
			"category": "Lab",
			"hospital_cost": 16,
			"charge_amount": 130,
			"medicare_reimbursement": 8,
		},

		# ========== Medicine / Cardiology ==========
		{
			"code": "93000",
			"description": "Electrocardiogram (ECG) 12-Lead",
			"category": "Medicine",
			"hospital_cost": 20,
			"charge_amount": 175,
			"medicare_reimbursement": 25,
		},
		{
			"code": "93306",
			"description": "Echocardiogram Complete",
			"category": "Medicine",
			"hospital_cost": 150,
			"charge_amount": 1800,
			"medicare_reimbursement": 340,
		},
		{
			"code": "93015",
			"description": "Cardiovascular Stress Test",
			"category": "Medicine",
			"hospital_cost": 120,
			"charge_amount": 1500,
			"medicare_reimbursement": 280,
		},

		# ========== Procedures ==========
		{
			"code": "43239",
			"description": "Upper GI Endoscopy with Biopsy",
			"category": "Procedure",
			"hospital_cost": 350,
			"charge_amount": 3200,
			"medicare_reimbursement": 680,
		},
		{
			"code": "62270",
			"description": "Lumbar Puncture",
			"category": "Procedure",
			"hospital_cost": 180,
			"charge_amount": 1200,
			"medicare_reimbursement": 240,
		},
	]


func find_by_code(code: String) -> Dictionary:
	for entry in all_codes:
		if entry.get("code") == code:
			return entry
	return {}


func get_codes_for_category(category: String) -> Array:
	var results: Array = []
	for entry in all_codes:
		if entry.get("category") == category:
			results.append(entry)
	return results
