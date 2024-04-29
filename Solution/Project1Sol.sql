-- Problem Statement 1: Jimmy, from the healthcare department, has requested a report that shows how the number of 
-- treatments each age category of patients has gone through in the year 2022.
-- The age category is as follows, Children (00-14 years), Youth (15-24 years), Adults (25-64 years), and 
-- Seniors (65 years and over).
-- Assist Jimmy in generating the report.
SELECT 
    CASE 
        WHEN age <= 14 THEN 'Children (00-14 years)'
        WHEN age <= 24 THEN 'Youth (15-24 years)'
        WHEN age <= 64 THEN 'Adults (25-64 years)'
        ELSE 'Seniors (65 years and over)' 
    END AS age_category,
    COUNT(Treatmentid) as num_treatments
FROM
    (SELECT 
        Treatmentid, 
        DATEDIFF(YEAR, dob, CURRENT_DATE) AS age 
    FROM 
        TREATMENT
    INNER JOIN 
        PATIENT ON TREATMENT.patientid = PATIENT.patientid 
    WHERE 
        YEAR(date) = 2022 
    ORDER BY 
        age
    ) AS AgeGroup
GROUP BY 
    age_category;


-- Problem Statement 2: Jimmy, from the healthcare department, wants to know which disease is 
-- infecting people of which gender more often.
-- Assist Jimmy with this purpose by generating a report that shows for each disease the male-to-female ratio. 
-- Sort the data in a way that is helpful for Jimmy.

WITH DISEASE_GENDER_COUNT AS (
    SELECT 
        DISEASE.DISEASEID,
        DISEASE.DISEASENAME,
        GENDER,
        COUNT(PERSONID) AS COUNT
    FROM
        PERSON
    JOIN PATIENT ON PERSON.PERSONID = PATIENT.PATIENTID
    JOIN TREATMENT ON PATIENT.PATIENTID = TREATMENT.PATIENTID
    JOIN DISEASE ON DISEASE.DISEASEID = TREATMENT.DISEASEID
    GROUP BY 
        DISEASE.DISEASEID,
        DISEASE.DISEASENAME,
        GENDER
    ORDER BY 
        DISEASE.DISEASEID,
        DISEASE.DISEASENAME,
        GENDER DESC
)

SELECT 
    T1.DISEASEID, 
    T2.DISEASENAME, 
    T1.COUNT AS MALECOUNT, 
    T2.COUNT AS FEMALECOUNT, 
    T1.COUNT / T2.COUNT AS MALE_TO_FEMALE_RATIO
FROM 
    DISEASE_GENDER_COUNT T1
JOIN 
    DISEASE_GENDER_COUNT T2 ON T1.DISEASEID = T2.DISEASEID
WHERE 
    T1.GENDER = 'male'
    AND T2.GENDER = 'female'
ORDER BY 
    MALE_TO_FEMALE_RATIO DESC;


-- Problem Statement 3: Jacob, from insurance management, has noticed that insurance claims are not made for all
--  the treatments. He also wants to figure out if the gender of the patient has any impact on the insurance claim.
-- Assist Jacob in this situation by generating a report that finds for each gender the number of treatments, 
-- number of claims, and treatment-to-claim ratio. And notice if there is a significant difference between 
-- the treatment-to-claim ratio of male and female patients.

WITH TreatmentClaims AS (
    SELECT
        P.gender,
        COUNT(DISTINCT T.treatmentID) AS num_treatments,
        COUNT(DISTINCT C.claimID) AS num_claims
    FROM
        Treatment T
    JOIN Person P ON T.patientID = P.personID
    LEFT JOIN Claim C ON T.claimID = C.claimID
    GROUP BY
        P.gender
),
TreatmentClaimRatio AS (
    SELECT
        gender,
        num_treatments,
        num_claims,
        CASE
            WHEN num_claims > 0 THEN num_treatments / num_claims
            ELSE 0
        END AS treatment_claim_ratio
    FROM
        TreatmentClaims
)
SELECT
    gender,
    num_treatments,
    num_claims,
    treatment_claim_ratio
FROM
    TreatmentClaimRatio
ORDER BY
    gender;

-- Problem Statement 4: The Healthcare department wants a report about the inventory of pharmacies. Generate a report 
-- on their behalf that shows how many units of medicine each pharmacy has in their inventory, the total maximum 
-- retail price of those medicines, and the total price of all the medicines after discount.
-- Note: discount field in keep signifies the percentage of discount on the maximum price.

SELECT
    K.pharmacyID,
    P.pharmacyName,
    SUM(K.quantity) AS total_units,
    SUM(M.maxPrice * K.quantity) AS total_max_retail_price,
    SUM((M.maxPrice * (100 - K.discount) / 100) * K.quantity) AS total_discounted_price
FROM
    Keep K
JOIN
    Medicine M ON K.medicineID = M.medicineID
JOIN
    Pharmacy P ON K.pharmacyID = P.pharmacyID
GROUP BY
    K.pharmacyID,
    P.pharmacyName;



-- Problem Statement 5: The healthcare department suspects that some pharmacies prescribe more medicines than others 
-- in a single prescription, for them, generate a report that finds for each pharmacy the maximum, minimum and 
-- average number of medicines prescribed in their prescriptions.

SELECT
    P.pharmacyID,
    P.pharmacyName,
    MAX(PT.num_medicines) AS max_medicines_per_prescription,
    MIN(PT.num_medicines) AS min_medicines_per_prescription,
    AVG(PT.num_medicines) AS avg_medicines_per_prescription
FROM
    Prescription PR
JOIN
    Pharmacy P ON PR.pharmacyID = P.pharmacyID
JOIN
    (
        SELECT
            prescriptionID,
            COUNT(*) AS num_medicines
        FROM
            Contain
        GROUP BY
            prescriptionID
    ) PT ON PR.prescriptionID = PT.prescriptionID
GROUP BY
    P.pharmacyID,
    P.pharmacyName;
