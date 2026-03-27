class_name ClaimData extends Resource

enum ClaimStatus { SUBMITTED, ADJUDICATING, PAID, DENIED, APPEALED, APPEAL_WON, APPEAL_LOST }

enum DenialReason {
	MEDICAL_NECESSITY, PRIOR_AUTHORIZATION, OUT_OF_NETWORK,
	CODING_ERROR, DUPLICATE_CLAIM, TIMELY_FILING_LIMIT,
	PATIENT_ELIGIBILITY, EXPERIMENTAL_PROCEDURE
}

enum AppealStatus { PENDING, IN_REVIEW, WON, LOST }

@export var id: String = ""
@export var patient_id: String = ""
@export var patient_name: String = ""
@export var payer_type: InsuranceData.PayerType = InsuranceData.PayerType.MEDICARE
@export var drg_code: String = ""
@export var cpt_codes: Array[String] = []
@export var total_charges: float = 0.0
@export var expected_reimbursement: float = 0.0
@export var status: ClaimStatus = ClaimStatus.SUBMITTED
@export var submitted_day: int = 0
@export var paid_day: int = -1
@export var actual_payment: float = 0.0
@export var denial_reason: int = -1
@export var appeal_status: int = -1


func _init():
	id = RoomData.generate_uuid()


static func get_denial_reason_name(reason: DenialReason) -> String:
	match reason:
		DenialReason.MEDICAL_NECESSITY: return "Medical Necessity"
		DenialReason.PRIOR_AUTHORIZATION: return "Prior Authorization Required"
		DenialReason.OUT_OF_NETWORK: return "Out of Network"
		DenialReason.CODING_ERROR: return "Coding Error"
		DenialReason.DUPLICATE_CLAIM: return "Duplicate Claim"
		DenialReason.TIMELY_FILING_LIMIT: return "Timely Filing Limit Exceeded"
		DenialReason.PATIENT_ELIGIBILITY: return "Patient Eligibility Issue"
		DenialReason.EXPERIMENTAL_PROCEDURE: return "Experimental Procedure"
	return ""


static func get_appeal_success_rate(reason: DenialReason) -> float:
	match reason:
		DenialReason.MEDICAL_NECESSITY: return 0.65
		DenialReason.PRIOR_AUTHORIZATION: return 0.70
		DenialReason.OUT_OF_NETWORK: return 0.50
		DenialReason.CODING_ERROR: return 0.85
		DenialReason.DUPLICATE_CLAIM: return 0.80
		DenialReason.TIMELY_FILING_LIMIT: return 0.55
		DenialReason.PATIENT_ELIGIBILITY: return 0.60
		DenialReason.EXPERIMENTAL_PROCEDURE: return 0.50
	return 0.50
