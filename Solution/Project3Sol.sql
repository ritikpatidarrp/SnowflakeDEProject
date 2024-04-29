-- Problem Statement 1:  Some complaints have been lodged by patients that they have been prescribed 
-- hospital-exclusive medicine that they can’t find elsewhere and facing problems due to that. Joshua, 
-- from the pharmacy management, wants to get a report of which pharmacies have prescribed hospital-exclusive 
-- medicines the most in the years 2021 and 2022. Assist Joshua to generate the report so that the pharmacies 
-- who prescribe hospital-exclusive medicine more often are advised to avoid such practice if possible.   

WITH HospitalExclusiveTreatments AS (
    SELECT
        Ph.pharmacyID,
        Ph.pharmacyName,
        COUNT(*) AS exclusive_treatments_count
    FROM
        Treatment Tr
    JOIN
        Prescription Pr ON Tr.treatmentID = Pr.treatmentID
    JOIN
        Contain Co ON Pr.prescriptionID = Co.prescriptionID
    JOIN
        Medicine M ON Co.medicineID = M.medicineID
    JOIN
        Pharmacy Ph ON Pr.pharmacyID = Ph.pharmacyID
    WHERE
        M.hospitalExclusive = 'Y'
        AND Tr.date >= '2021-01-01'
        AND Tr.date <= '2022-12-31'
    GROUP BY
        Ph.pharmacyID,
        Ph.pharmacyName
)
SELECT
    pharmacyID,
    pharmacyName,
    exclusive_treatments_count
FROM
    HospitalExclusiveTreatments
ORDER BY
    exclusive_treatments_count DESC;

-- Problem Statement 2: Insurance companies want to assess the performance of their insurance plans. 
-- Generate a report that shows each insurance plan, the company that issues the plan, and the number 
-- of treatments the plan was claimed for.

SELECT
    IP.uin AS insurance_plan_uin,
    IC.companyName AS insurance_company,
    COUNT(T.claimID) AS treatment_count
FROM
    InsurancePlan IP
JOIN
    InsuranceCompany IC ON IP.companyID = IC.companyID
LEFT JOIN
    Claim C ON IP.uin = C.uin
LEFT JOIN
    Treatment T ON C.claimID = T.claimID
GROUP BY
    IP.uin,
    IC.companyName;

-- Problem Statement 3: Insurance companies want to assess the performance of their insurance plans. 
-- Generate a report that shows each insurance company's name with their most and least claimed insurance plans.
WITH ClaimCounts AS (
    SELECT
        IC.companyName AS insurance_company,
        IP.uin AS insurance_plan_uin,
        COUNT(C.claimID) AS claim_count,
        ROW_NUMBER() OVER(PARTITION BY IC.companyID ORDER BY COUNT(C.claimID) DESC) AS rn_desc,
        ROW_NUMBER() OVER(PARTITION BY IC.companyID ORDER BY COUNT(C.claimID) ASC) AS rn_asc
    FROM
        InsuranceCompany IC
    JOIN
        InsurancePlan IP ON IC.companyID = IP.companyID
    LEFT JOIN
        Claim C ON IP.uin = C.uin
    GROUP BY
        IC.companyName,
        IC.companyID,
        IP.uin
)
SELECT
    insurance_company,
    MAX(CASE WHEN rn_desc = 1 THEN insurance_plan_uin END) AS most_claimed_insurance_plan,
    MAX(CASE WHEN rn_asc = 1 THEN insurance_plan_uin END) AS least_claimed_insurance_plan
FROM
    ClaimCounts
GROUP BY
    insurance_company;

-- Problem Statement 4:  The healthcare department wants a state-wise health report to assess which state 
-- requires more attention in the healthcare sector. Generate a report for them that shows the state name, 
-- number of registered people in the state, number of registered patients in the state, and the people-to-patient ratio. 
-- sort the data by people-to-patient ratio. 
WITH StateHealthStats AS (
    SELECT
        A.state AS state_name,
        COUNT(DISTINCT P.personID) AS registered_people,
        COUNT(DISTINCT CASE WHEN PT.patientID IS NOT NULL THEN PT.patientID END) AS registered_patients,
        CASE 
            WHEN COUNT(DISTINCT CASE WHEN PT.patientID IS NOT NULL THEN PT.patientID END) = 0 THEN 0
            ELSE COUNT(DISTINCT P.personID) / COUNT(DISTINCT CASE WHEN PT.patientID IS NOT NULL THEN PT.patientID END)
        END AS people_to_patient_ratio
    FROM
        Address A
    LEFT JOIN
        Person P ON A.addressID = P.addressID
    LEFT JOIN
        Patient PT ON P.personID = PT.patientID
    GROUP BY
        A.state
)
SELECT
    state_name,
    registered_people,
    registered_patients,
    people_to_patient_ratio
FROM
    StateHealthStats
ORDER BY
    people_to_patient_ratio DESC;


-- Problem Statement 5:  Jhonny, from the finance department of Arizona(AZ), has requested a report that lists 
-- the total quantity of medicine each pharmacy in his state has prescribed that falls under Tax criteria I for 
-- treatments that took place in 2021. Assist Jhonny in generating the report. 
WITH PharmacyMedicineQuantity AS (
    SELECT
        Ph.pharmacyID,
        SUM(K.quantity) AS total_quantity
    FROM
        Address A
    JOIN
        Pharmacy Ph ON A.addressID = Ph.addressID
    JOIN
        Keep K ON Ph.pharmacyID = K.pharmacyID
    JOIN
        Medicine M ON K.medicineID = M.medicineID
    JOIN
        Prescription Pr ON K.pharmacyID = Pr.pharmacyID
    JOIN
        Treatment T ON Pr.treatmentID = T.treatmentID
    WHERE
        M.taxCriteria = 'I'
        AND T.date >= '2021-01-01'
        AND T.date <= '2021-12-31'
        AND A.state = 'AZ'
    GROUP BY
        Ph.pharmacyID
)
SELECT
    PMQ.pharmacyID,
    Ph.pharmacyName,
    PMQ.total_quantity
FROM
    PharmacyMedicineQuantity PMQ
JOIN
    Pharmacy Ph ON PMQ.pharmacyID = Ph.pharmacyID;
