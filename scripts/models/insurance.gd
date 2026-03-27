class_name InsuranceData extends Resource

enum PayerType {
	MEDICARE, MEDICAID, MEDICARE_ADVANTAGE, UNITED_HEALTHCARE,
	ANTHEM, AETNA, CIGNA, HUMANA, BLUE_CROSS_BLUE_SHIELD, SELF_PAY
}

@export var id: String = ""
@export var payer_type: PayerType = PayerType.MEDICARE
@export var negotiated_rate: float = 1.0
@export var active: bool = true
@export var start_day: int = 1
@export var end_day: int = 365
@export var volume_discount: float = 0.0


func _init():
	id = RoomData.generate_uuid()


static func get_payer_name(payer: PayerType) -> String:
	match payer:
		PayerType.MEDICARE: return "Medicare"
		PayerType.MEDICAID: return "Medicaid"
		PayerType.MEDICARE_ADVANTAGE: return "Medicare Advantage"
		PayerType.UNITED_HEALTHCARE: return "United Healthcare"
		PayerType.ANTHEM: return "Anthem"
		PayerType.AETNA: return "Aetna"
		PayerType.CIGNA: return "Cigna"
		PayerType.HUMANA: return "Humana"
		PayerType.BLUE_CROSS_BLUE_SHIELD: return "Blue Cross Blue Shield"
		PayerType.SELF_PAY: return "Self Pay"
	return ""


static func get_reimbursement_rate(payer: PayerType) -> float:
	match payer:
		PayerType.MEDICARE: return 1.0
		PayerType.MEDICAID: return 0.90
		PayerType.MEDICARE_ADVANTAGE: return 1.10
		PayerType.UNITED_HEALTHCARE: return 1.37
		PayerType.ANTHEM: return 1.35
		PayerType.AETNA: return 1.30
		PayerType.CIGNA: return 1.33
		PayerType.HUMANA: return 1.25
		PayerType.BLUE_CROSS_BLUE_SHIELD: return 1.40
		PayerType.SELF_PAY: return 0.20
	return 1.0


static func get_denial_rate(payer: PayerType) -> float:
	match payer:
		PayerType.MEDICARE: return 0.10
		PayerType.MEDICAID: return 0.12
		PayerType.MEDICARE_ADVANTAGE: return 0.13
		PayerType.UNITED_HEALTHCARE: return 0.18
		PayerType.ANTHEM: return 0.15
		PayerType.AETNA: return 0.16
		PayerType.CIGNA: return 0.17
		PayerType.HUMANA: return 0.14
		PayerType.BLUE_CROSS_BLUE_SHIELD: return 0.12
		PayerType.SELF_PAY: return 0.0
	return 0.10


static func get_processing_days(payer: PayerType) -> int:
	match payer:
		PayerType.MEDICARE: return 14
		PayerType.MEDICAID: return 21
		PayerType.MEDICARE_ADVANTAGE: return 18
		PayerType.UNITED_HEALTHCARE: return 30
		PayerType.ANTHEM: return 28
		PayerType.AETNA: return 35
		PayerType.CIGNA: return 32
		PayerType.HUMANA: return 25
		PayerType.BLUE_CROSS_BLUE_SHIELD: return 22
		PayerType.SELF_PAY: return 45
	return 30
