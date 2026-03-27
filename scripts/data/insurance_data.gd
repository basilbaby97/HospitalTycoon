extends Node


func get_default_contracts() -> Array[Dictionary]:
	return [
		{
			"id": "contract_medicare",
			"payer_type": InsuranceData.PayerType.MEDICARE,
			"negotiated_rate": 1.0,
			"active": true,
			"start_day": 1,
			"end_day": 365,
			"volume_discount": 0.0,
		},
		{
			"id": "contract_medicaid",
			"payer_type": InsuranceData.PayerType.MEDICAID,
			"negotiated_rate": 0.90,
			"active": true,
			"start_day": 1,
			"end_day": 365,
			"volume_discount": 0.0,
		},
		{
			"id": "contract_bcbs",
			"payer_type": InsuranceData.PayerType.BLUE_CROSS_BLUE_SHIELD,
			"negotiated_rate": 1.40,
			"active": true,
			"start_day": 1,
			"end_day": 365,
			"volume_discount": 0.02,
		},
	]


func get_payer_mix_weight(payer: InsuranceData.PayerType) -> float:
	match payer:
		InsuranceData.PayerType.MEDICARE: return 0.30
		InsuranceData.PayerType.MEDICAID: return 0.15
		InsuranceData.PayerType.MEDICARE_ADVANTAGE: return 0.10
		InsuranceData.PayerType.UNITED_HEALTHCARE: return 0.12
		InsuranceData.PayerType.ANTHEM: return 0.08
		InsuranceData.PayerType.AETNA: return 0.07
		InsuranceData.PayerType.CIGNA: return 0.05
		InsuranceData.PayerType.HUMANA: return 0.03
		InsuranceData.PayerType.BLUE_CROSS_BLUE_SHIELD: return 0.05
		InsuranceData.PayerType.SELF_PAY: return 0.05
	return 0.0


func get_all_payer_weights() -> Dictionary:
	return {
		InsuranceData.PayerType.MEDICARE: 0.30,
		InsuranceData.PayerType.MEDICAID: 0.15,
		InsuranceData.PayerType.MEDICARE_ADVANTAGE: 0.10,
		InsuranceData.PayerType.UNITED_HEALTHCARE: 0.12,
		InsuranceData.PayerType.ANTHEM: 0.08,
		InsuranceData.PayerType.AETNA: 0.07,
		InsuranceData.PayerType.CIGNA: 0.05,
		InsuranceData.PayerType.HUMANA: 0.03,
		InsuranceData.PayerType.BLUE_CROSS_BLUE_SHIELD: 0.05,
		InsuranceData.PayerType.SELF_PAY: 0.05,
	}


func pick_random_payer() -> InsuranceData.PayerType:
	var roll: float = randf()
	var cumulative: float = 0.0
	var weights: Dictionary = get_all_payer_weights()
	for payer_type in weights:
		cumulative += weights[payer_type]
		if roll <= cumulative:
			return payer_type
	return InsuranceData.PayerType.SELF_PAY
