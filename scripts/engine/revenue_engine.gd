extends RefCounted


func submit_claim(patient: Dictionary, state: Dictionary) -> void:
	var confirmed_id: String = patient.get("confirmed_disease_id", "")
	var disease: Dictionary = _get_disease_by_id(confirmed_id)
	var payer_type: int = patient.get("payer_type", InsuranceData.PayerType.MEDICARE)

	var base_payment: float = disease.get("base_medicare_payment", 5000.0)
	var test_charges: float = _calculate_test_charges(patient)
	var total_charges: float = base_payment + test_charges

	var reimbursement_rate: float = InsuranceData.get_reimbursement_rate(payer_type)
	var contract_rate: float = _get_contract_rate(payer_type, state)
	var effective_rate: float = reimbursement_rate * contract_rate

	var expected_reimbursement: float = total_charges * effective_rate

	var cpt_codes: Array = _collect_cpt_codes(patient, disease)

	var current_day: int = state.get("current_day", 1)
	var current_month: int = state.get("current_month", 1)
	var absolute_day: int = (current_month - 1) * GameConstants.DAYS_PER_MONTH + current_day

	var claim: Dictionary = {
		"id": RoomData.generate_uuid(),
		"patient_id": patient.get("id", ""),
		"patient_name": patient.get("patient_name", ""),
		"payer_type": payer_type,
		"drg_code": disease.get("drg_code", ""),
		"icd_code": disease.get("icd_code", ""),
		"cpt_codes": cpt_codes,
		"total_charges": total_charges,
		"expected_reimbursement": expected_reimbursement,
		"status": ClaimData.ClaimStatus.SUBMITTED,
		"submitted_day": absolute_day,
		"paid_day": -1,
		"actual_payment": 0.0,
		"denial_reason": -1,
		"appeal_status": -1,
		"processing_days_required": InsuranceData.get_processing_days(payer_type),
		"days_in_processing": 0,
	}

	var claims: Array = state.get("claims", [])
	claims.append(claim)
	state["claims"] = claims

	var finance: Dictionary = state.get("finance", {})
	finance["accounts_receivable"] = finance.get("accounts_receivable", 0.0) + expected_reimbursement


func process_claims_for_day(state: Dictionary) -> void:
	var claims: Array = state.get("claims", [])
	var finance: Dictionary = state.get("finance", {})
	var current_day: int = state.get("current_day", 1)
	var current_month: int = state.get("current_month", 1)
	var absolute_day: int = (current_month - 1) * GameConstants.DAYS_PER_MONTH + current_day

	for i in range(claims.size()):
		var claim: Dictionary = claims[i]
		var status: int = claim.get("status", ClaimData.ClaimStatus.SUBMITTED)

		match status:
			ClaimData.ClaimStatus.SUBMITTED:
				claims[i]["status"] = ClaimData.ClaimStatus.ADJUDICATING
				claims[i]["days_in_processing"] = 0

			ClaimData.ClaimStatus.ADJUDICATING:
				claims[i]["days_in_processing"] = claims[i].get("days_in_processing", 0) + 1
				var days_processing: int = claims[i].get("days_in_processing", 0)
				var required_days: int = claims[i].get("processing_days_required", 30)

				if days_processing >= required_days:
					var payer_type: int = claim.get("payer_type", InsuranceData.PayerType.MEDICARE)
					var denial_rate: float = InsuranceData.get_denial_rate(payer_type)

					if randf() < denial_rate:
						claims[i]["status"] = ClaimData.ClaimStatus.DENIED
						claims[i]["denial_reason"] = _generate_denial_reason()
						var expected: float = claim.get("expected_reimbursement", 0.0)
						finance["accounts_receivable"] = finance.get("accounts_receivable", 0.0) - expected

						if expected >= 5000.0:
							claims[i]["status"] = ClaimData.ClaimStatus.APPEALED
							claims[i]["appeal_status"] = ClaimData.AppealStatus.PENDING
							finance["accounts_receivable"] = finance.get("accounts_receivable", 0.0) + expected
							var appeal_cost: float = 150.0
							finance["cash_balance"] = finance.get("cash_balance", 0.0) - appeal_cost
							finance["total_expenses"] = finance.get("total_expenses", 0.0) + appeal_cost
					else:
						var expected: float = claim.get("expected_reimbursement", 0.0)
						var variance: float = randf_range(0.92, 1.05)
						var actual_payment: float = expected * variance
						claims[i]["status"] = ClaimData.ClaimStatus.PAID
						claims[i]["paid_day"] = absolute_day
						claims[i]["actual_payment"] = actual_payment
						finance["accounts_receivable"] = finance.get("accounts_receivable", 0.0) - expected
						finance["cash_balance"] = finance.get("cash_balance", 0.0) + actual_payment
						finance["total_revenue"] = finance.get("total_revenue", 0.0) + actual_payment
						_record_transaction(finance, actual_payment, FinanceData.TransactionType.INSURANCE_PAYMENT,
							"Claim paid: %s" % claim.get("patient_name", ""), current_day)

			ClaimData.ClaimStatus.APPEALED:
				claims[i]["days_in_processing"] = claims[i].get("days_in_processing", 0) + 1
				var appeal_days: int = claims[i].get("days_in_processing", 0)
				var appeal_processing_time: int = 14

				if appeal_days >= appeal_processing_time:
					var denial_reason: int = claims[i].get("denial_reason", 0)
					var appeal_success: float = ClaimData.get_appeal_success_rate(denial_reason)

					if randf() < appeal_success:
						var expected: float = claim.get("expected_reimbursement", 0.0)
						var actual_payment: float = expected * 0.90
						claims[i]["status"] = ClaimData.ClaimStatus.PAID
						claims[i]["appeal_status"] = ClaimData.AppealStatus.WON
						claims[i]["paid_day"] = absolute_day
						claims[i]["actual_payment"] = actual_payment
						finance["accounts_receivable"] = finance.get("accounts_receivable", 0.0) - expected
						finance["cash_balance"] = finance.get("cash_balance", 0.0) + actual_payment
						finance["total_revenue"] = finance.get("total_revenue", 0.0) + actual_payment
						_record_transaction(finance, actual_payment, FinanceData.TransactionType.INSURANCE_PAYMENT,
							"Appeal won: %s" % claim.get("patient_name", ""), current_day)
					else:
						var expected: float = claim.get("expected_reimbursement", 0.0)
						claims[i]["status"] = ClaimData.ClaimStatus.DENIED
						claims[i]["appeal_status"] = ClaimData.AppealStatus.LOST
						finance["accounts_receivable"] = finance.get("accounts_receivable", 0.0) - expected
						_record_transaction(finance, 0.0, FinanceData.TransactionType.CLAIM_DENIED,
							"Appeal lost: %s" % claim.get("patient_name", ""), current_day)

			ClaimData.ClaimStatus.PAID:
				pass
			ClaimData.ClaimStatus.DENIED:
				pass
			ClaimData.ClaimStatus.APPEAL_WON:
				pass
			ClaimData.ClaimStatus.APPEAL_LOST:
				pass

	_cleanup_old_claims(state)


func _calculate_test_charges(patient: Dictionary) -> float:
	var total: float = 0.0
	var performed: Array = patient.get("performed_tests", [])
	for test in performed:
		total += EquipmentData.get_test_charge(test)
	return total


func _collect_cpt_codes(patient: Dictionary, disease: Dictionary) -> Array:
	var codes: Array = []
	var performed: Array = patient.get("performed_tests", [])
	for test in performed:
		var code: String = EquipmentData.get_test_cpt_code(test)
		if not code.is_empty() and not codes.has(code):
			codes.append(code)
	codes.append("99213")
	return codes


func _get_contract_rate(payer_type: int, state: Dictionary) -> float:
	var contracts: Array = state.get("insurance_contracts", [])
	for contract in contracts:
		if contract.get("payer_type", -1) == payer_type and contract.get("active", false):
			return contract.get("negotiated_rate", 1.0)
	return 1.0


func _generate_denial_reason() -> int:
	var reasons: Array = [
		ClaimData.DenialReason.MEDICAL_NECESSITY,
		ClaimData.DenialReason.PRIOR_AUTHORIZATION,
		ClaimData.DenialReason.CODING_ERROR,
		ClaimData.DenialReason.PATIENT_ELIGIBILITY,
		ClaimData.DenialReason.DUPLICATE_CLAIM,
		ClaimData.DenialReason.TIMELY_FILING_LIMIT,
		ClaimData.DenialReason.OUT_OF_NETWORK,
		ClaimData.DenialReason.EXPERIMENTAL_PROCEDURE,
	]
	var weights: Array = [30.0, 20.0, 15.0, 12.0, 8.0, 7.0, 5.0, 3.0]
	var total: float = 0.0
	for w in weights:
		total += w
	var roll: float = randf() * total
	var cumulative: float = 0.0
	for j in range(reasons.size()):
		cumulative += weights[j]
		if roll <= cumulative:
			return reasons[j]
	return ClaimData.DenialReason.MEDICAL_NECESSITY


func _record_transaction(finance: Dictionary, amount: float, type: int, description: String, day: int) -> void:
	var transactions: Array = finance.get("transactions", [])
	transactions.append({
		"amount": amount,
		"type": type,
		"description": description,
		"day": day,
		"is_revenue": amount > 0.0,
	})
	if transactions.size() > 200:
		transactions = transactions.slice(transactions.size() - 200)
	finance["transactions"] = transactions


func _cleanup_old_claims(state: Dictionary) -> void:
	var claims: Array = state.get("claims", [])
	var completed: Array = claims.filter(
		func(c): return c.get("status", 0) == ClaimData.ClaimStatus.PAID \
			or (c.get("status", 0) == ClaimData.ClaimStatus.DENIED and c.get("appeal_status", -1) != ClaimData.AppealStatus.PENDING)
	)
	if completed.size() > 100:
		var active: Array = claims.filter(
			func(c): return c.get("status", 0) != ClaimData.ClaimStatus.PAID \
				and not (c.get("status", 0) == ClaimData.ClaimStatus.DENIED and c.get("appeal_status", -1) != ClaimData.AppealStatus.PENDING)
		)
		var recent_completed: Array = completed.slice(completed.size() - 50)
		state["claims"] = active + recent_completed


func _get_disease_by_id(disease_id: String) -> Dictionary:
	if disease_id.is_empty():
		return {"base_medicare_payment": 2500.0, "drg_code": "DRG079", "icd_code": "J00", "required_tests": []}
	var all_diseases: Array = DiseaseDefs.get_all_diseases()
	for d in all_diseases:
		if d.get("id", "") == disease_id:
			return d
	return {"base_medicare_payment": 2500.0, "drg_code": "DRG079", "icd_code": "J00", "required_tests": []}


func get_total_ar(state: Dictionary) -> float:
	return state.get("finance", {}).get("accounts_receivable", 0.0)


func get_claim_stats(state: Dictionary) -> Dictionary:
	var claims: Array = state.get("claims", [])
	var submitted: int = 0
	var adjudicating: int = 0
	var paid: int = 0
	var denied: int = 0
	var appealed: int = 0
	var total_paid: float = 0.0

	for c in claims:
		match c.get("status", 0):
			ClaimData.ClaimStatus.SUBMITTED:
				submitted += 1
			ClaimData.ClaimStatus.ADJUDICATING:
				adjudicating += 1
			ClaimData.ClaimStatus.PAID:
				paid += 1
				total_paid += c.get("actual_payment", 0.0)
			ClaimData.ClaimStatus.DENIED:
				denied += 1
			ClaimData.ClaimStatus.APPEALED:
				appealed += 1

	return {
		"submitted": submitted,
		"adjudicating": adjudicating,
		"paid": paid,
		"denied": denied,
		"appealed": appealed,
		"total_paid": total_paid,
	}
