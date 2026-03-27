class_name FinanceData extends Resource

enum TransactionType {
	PATIENT_REVENUE, INSURANCE_PAYMENT, CLAIM_DENIED, SALARY_EXPENSE,
	EQUIPMENT_PURCHASE, EQUIPMENT_MAINTENANCE, ROOM_CONSTRUCTION,
	ROOM_MAINTENANCE, SUPPLY_EXPENSE, LOAN_PAYMENT, LOAN_RECEIVED,
	APPEAL_COST, OTHER_REVENUE, OTHER_EXPENSE
}

@export var cash_balance: float = 5000000.0
@export var accounts_receivable: float = 0.0
@export var total_revenue: float = 0.0
@export var total_expenses: float = 0.0
@export var transactions: Array[Dictionary] = []
@export var monthly_revenue: Array[float] = []
@export var monthly_expenses: Array[float] = []


func record_payment(amount: float, type: TransactionType, description: String, day: int) -> void:
	cash_balance += amount
	total_revenue += amount
	var transaction := {
		"amount": amount,
		"type": type,
		"description": description,
		"day": day,
		"is_revenue": true
	}
	transactions.append(transaction)
	if transactions.size() > 200:
		transactions = transactions.slice(transactions.size() - 200)


func record_expense(amount: float, type: TransactionType, description: String, day: int) -> void:
	cash_balance -= amount
	total_expenses += amount
	var transaction := {
		"amount": amount,
		"type": type,
		"description": description,
		"day": day,
		"is_revenue": false
	}
	transactions.append(transaction)
	if transactions.size() > 200:
		transactions = transactions.slice(transactions.size() - 200)


func record_claim_submission(amount: float, day: int) -> void:
	accounts_receivable += amount
	var transaction := {
		"amount": amount,
		"type": TransactionType.INSURANCE_PAYMENT,
		"description": "Insurance claim submitted",
		"day": day,
		"is_revenue": false
	}
	transactions.append(transaction)
	if transactions.size() > 200:
		transactions = transactions.slice(transactions.size() - 200)


func record_claim_payment(amount: float, day: int) -> void:
	accounts_receivable -= amount
	cash_balance += amount
	total_revenue += amount
	var transaction := {
		"amount": amount,
		"type": TransactionType.INSURANCE_PAYMENT,
		"description": "Insurance claim paid",
		"day": day,
		"is_revenue": true
	}
	transactions.append(transaction)
	if transactions.size() > 200:
		transactions = transactions.slice(transactions.size() - 200)


static func is_revenue_type(type: TransactionType) -> bool:
	match type:
		TransactionType.PATIENT_REVENUE: return true
		TransactionType.INSURANCE_PAYMENT: return true
		TransactionType.LOAN_RECEIVED: return true
		TransactionType.OTHER_REVENUE: return true
	return false
