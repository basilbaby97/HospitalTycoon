import Foundation

struct InsuranceData {
    struct PayerProfile {
        let type: PayerType
        let description: String
        let patientPercentage: Double
        let reimbursementVsMedicare: Double
        let avgClaimProcessingDays: Int
        let denialRate: Double
        let copayRange: ClosedRange<Int>
        let deductible: Int
        let coinsuranceRate: Double
    }

    static let profiles: [PayerProfile] = [
        PayerProfile(
            type: .medicare,
            description: "Federal health insurance for 65+ and disabled. Largest payer. DRG-based prospective payment.",
            patientPercentage: 0.30,
            reimbursementVsMedicare: 1.00,
            avgClaimProcessingDays: 21,
            denialRate: 0.10,
            copayRange: 0...0,
            deductible: 1_632,
            coinsuranceRate: 0.20
        ),
        PayerProfile(
            type: .medicaid,
            description: "State-run program for low-income individuals. Lower reimbursement rates. Varies by state.",
            patientPercentage: 0.15,
            reimbursementVsMedicare: 0.90,
            avgClaimProcessingDays: 38,
            denialRate: 0.18,
            copayRange: 0...5,
            deductible: 0,
            coinsuranceRate: 0.0
        ),
        PayerProfile(
            type: .medicareAdvantage,
            description: "Private insurers offering Medicare benefits. Slightly higher reimbursement than traditional Medicare.",
            patientPercentage: 0.10,
            reimbursementVsMedicare: 1.10,
            avgClaimProcessingDays: 17,
            denialRate: 0.15,
            copayRange: 20...75,
            deductible: 500,
            coinsuranceRate: 0.20
        ),
        PayerProfile(
            type: .unitedHealthcare,
            description: "Largest commercial insurer. Strong nationwide network. Premium reimbursement rates.",
            patientPercentage: 0.12,
            reimbursementVsMedicare: 1.37,
            avgClaimProcessingDays: 25,
            denialRate: 0.16,
            copayRange: 25...75,
            deductible: 1_500,
            coinsuranceRate: 0.20
        ),
        PayerProfile(
            type: .anthem,
            description: "Second-largest commercial insurer (Elevance Health). Strong in 14 states under Blue Cross brand.",
            patientPercentage: 0.08,
            reimbursementVsMedicare: 1.35,
            avgClaimProcessingDays: 25,
            denialRate: 0.14,
            copayRange: 30...80,
            deductible: 1_200,
            coinsuranceRate: 0.20
        ),
        PayerProfile(
            type: .aetna,
            description: "Major national insurer (CVS Health subsidiary). Fast claim processing.",
            patientPercentage: 0.07,
            reimbursementVsMedicare: 1.30,
            avgClaimProcessingDays: 17,
            denialRate: 0.12,
            copayRange: 25...60,
            deductible: 1_000,
            coinsuranceRate: 0.19
        ),
        PayerProfile(
            type: .cigna,
            description: "National and international presence. Moderate reimbursement.",
            patientPercentage: 0.05,
            reimbursementVsMedicare: 1.33,
            avgClaimProcessingDays: 25,
            denialRate: 0.15,
            copayRange: 25...70,
            deductible: 1_300,
            coinsuranceRate: 0.20
        ),
        PayerProfile(
            type: .humana,
            description: "Strong Medicare Advantage presence. Growing commercial segment.",
            patientPercentage: 0.03,
            reimbursementVsMedicare: 1.25,
            avgClaimProcessingDays: 17,
            denialRate: 0.13,
            copayRange: 20...50,
            deductible: 800,
            coinsuranceRate: 0.20
        ),
        PayerProfile(
            type: .blueCrossBlueshield,
            description: "Federation of 36 independent Blue plans. Highest commercial reimbursement rates.",
            patientPercentage: 0.05,
            reimbursementVsMedicare: 1.40,
            avgClaimProcessingDays: 22,
            denialRate: 0.11,
            copayRange: 30...100,
            deductible: 1_500,
            coinsuranceRate: 0.20
        ),
        PayerProfile(
            type: .selfPay,
            description: "Uninsured patients. Full charges billed but only ~20% collected. Financial assistance may apply.",
            patientPercentage: 0.05,
            reimbursementVsMedicare: 2.50,
            avgClaimProcessingDays: 0,
            denialRate: 0.0,
            copayRange: 0...0,
            deductible: 0,
            coinsuranceRate: 1.0
        ),
    ]

    static func profile(for type: PayerType) -> PayerProfile {
        profiles.first { $0.type == type }!
    }

    static func generateDefaultContracts(startDay: Int) -> [InsuranceContract] {
        // Start with government payers (always available) and a couple commercial
        return [
            InsuranceContract(payerType: .medicare, startDay: startDay, patientVolume: 30),
            InsuranceContract(payerType: .medicaid, startDay: startDay, patientVolume: 15),
            InsuranceContract(payerType: .medicareAdvantage, startDay: startDay, patientVolume: 10),
            InsuranceContract(payerType: .blueCrossBlueshield, startDay: startDay, patientVolume: 5),
        ]
    }
}
