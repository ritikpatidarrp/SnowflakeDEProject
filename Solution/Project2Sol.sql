-- Problem Statement 1: A company needs to set up 3 new pharmacies, they have come up with an idea that
--  the pharmacy can be set up in cities where the pharmacy-to-prescription ratio is the lowest and 
--  the number of prescriptions should exceed 100. Assist the company to identify those cities where 
--  the pharmacy can be set up.
use warehouse healthcare_wh;
use database healthcare_db;
use schema healthcare_schema;

SELECT 
    A.city, 
    COUNT(DISTINCT Pr.prescriptionId) AS no_Prescription,
    COUNT(DISTINCT Ph.pharmacyId) / COUNT(DISTINCT Pr.prescriptionId) AS pharmacies_to_prescription_ratio
FROM 
    Address A
JOIN 
    Pharmacy Ph ON A.addressID = Ph.addressID
JOIN 
    Prescription Pr ON Ph.pharmacyID = Pr.pharmacyID
GROUP BY 
    A.city
HAVING 
    COUNT(DISTINCT Pr.prescriptionId) > 100
ORDER BY 
    pharmacies_to_prescription_ratio
LIMIT 
    3;


-- Problem Statement 2: The State of Alabama (AL) is trying to manage its healthcare resources more efficiently.
-- For each city in their state, they need to identify the disease for which the maximum number of patients 
-- have gone for treatment. Assist the state for this purpose.
-- Note: The state of Alabama is represented as AL in Address Table.

WITH AlabamaPatients AS (
    SELECT 
        A.city,
        T.diseaseID,
        D.diseaseName,
        ROW_NUMBER() OVER (PARTITION BY A.city ORDER BY COUNT(*) DESC) AS rn
    FROM 
        Address A
    JOIN 
        Person P ON A.addressID = P.addressID
    JOIN 
        Patient Pt ON P.personID = Pt.patientid
    JOIN 
        Treatment T ON Pt.patientID = T.patientID
    JOIN 
        Disease D ON T.diseaseID = D.diseaseID
    WHERE 
        A.state = 'AL'
    GROUP BY 
        A.city, T.diseaseID, D.diseaseName
)
SELECT 
    city,
    diseaseID,
    diseaseName
FROM 
    AlabamaPatients
WHERE 
    rn = 1;


-- Problem Statement 3: The healthcare department needs a report about insurance plans. 
-- The report is required to include the insurance plan, which was claimed the most and least for each disease. 
--  Assist to create such a report.
WITH InsuranceClaims AS (
    SELECT 
        IP.planName,
        T.diseaseID,
        COUNT(*) AS claimCount,
        ROW_NUMBER() OVER (PARTITION BY T.diseaseID ORDER BY COUNT(*) DESC) AS most_rn,
        ROW_NUMBER() OVER (PARTITION BY T.diseaseID ORDER BY COUNT(*) ASC) AS least_rn
    FROM 
        Treatment T
    JOIN 
        Claim C ON T.claimID = C.claimID
    JOIN 
        InsurancePlan IP ON C.uin = IP.uin
    GROUP BY 
        IP.planName, T.diseaseID
)
SELECT 
    D.diseaseName,
    MAX(CASE WHEN most_rn = 1 THEN planName END) AS most_claimed_plan,
    MAX(CASE WHEN least_rn = 1 THEN planName END) AS least_claimed_plan
FROM 
    InsuranceClaims IC
JOIN 
    Disease D ON IC.diseaseID = D.diseaseID
GROUP BY 
    D.diseaseName;


-- Problem Statement 4: The Healthcare department wants to know which disease is most likely to infect 
-- multiple people in the same household. For each disease find the number of households that has more 
-- than one patient with the same disease. 
-- Note: 2 people are considered to be in the same household if they have the same address. 
WITH household_disease AS (
    SELECT 
        t.diseaseid AS diseaseid,
        d.diseaseName AS diseaseName,
        p.addressID AS addressid,
        COUNT(p.personID) AS cnt
    FROM 
        treatment t
    JOIN 
        patient pt ON pt.patientid = t.patientid
    JOIN 
        person p ON p.personid = pt.patientid
    JOIN 
        disease d ON d.diseaseid = t.diseaseid
    GROUP BY 
        1, 2, 3
    HAVING 
        cnt >= 2
)
SELECT 
    diseaseid, 
    diseaseName, 
    COUNT(DISTINCT addressid) AS count
FROM 
    household_disease
GROUP BY 
    diseaseid, diseaseName
ORDER BY 
    count DESC;


-- Problem Statement 5:  An Insurance company wants a state wise report of the treatments to claim ratio 
-- between 1st April 2021 and 31st March 2022 (days both included). Assist them to create such a report.
WITH treatment_counts AS (
    SELECT 
        a.state AS state,
        COUNT(*) AS treatment_count
    FROM 
        treatment t
    JOIN 
        patient pt ON t.patientID = pt.patientID
    JOIN 
        person p ON pt.patientID = p.personID
    JOIN
        address a ON p.addressID = a.addressID
    WHERE 
        t.date >= '2021-04-01' AND t.date <= '2022-03-31'
    GROUP BY 
        a.state
),
claim_counts AS (
    SELECT 
        a.state AS state,
        COUNT(*) AS claim_count
    FROM 
        claim c
    JOIN 
        treatment t ON c.claimid = t.claimID
    JOIN
        patient pt on pt.patientid = t.patientID
    JOIN 
        person p ON pt.patientID = p.personID
    JOIN
        address a ON p.addressID = a.addressID
    WHERE 
        t.date >= '2021-04-01' AND t.date <= '2022-03-31'
    GROUP BY 
        a.state
)
SELECT 
    tc.state,
    tc.treatment_count,
    cc.claim_count,
    CASE 
        WHEN cc.claim_count = 0 THEN 0
        ELSE tc.treatment_count / cc.claim_count
    END AS treatment_to_claim_ratio
FROM 
    treatment_counts tc
LEFT JOIN 
    claim_counts cc ON tc.state = cc.state;
