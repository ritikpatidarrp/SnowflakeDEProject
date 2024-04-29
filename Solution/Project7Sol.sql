--1

CREATE OR REPLACE PROCEDURE CheckClaimStatus(diseaseID INT) RETURNS VARCHAR
LANGUAGE SQL
AS
DECLARE avg_claim_count FLOAT; current_claim_count INT; res VARCHAR(100);
BEGIN
-- Calculate the average number of claims for all diseases 
SELECT AVG(claim_count) INTO :avg_claim_count FROM (
SELECT COUNT(claimID) AS claim_count FROM project_db.my_schema.treatment GROUP BY diseaseID
) AS avg_counts;
-- Get the current claim count for the passed diseaseID 
SELECT COUNT(claimID) INTO :current_claim_count FROM project_db.my_schema.treatment
WHERE diseaseID = :diseaseID;
-- Compare current claim count with the average
IF (:current_claim_count > :avg_claim_count) THEN
res := 'claimed higher than average'; ELSE
res := 'claimed lower than average'; END IF;
-- Return the result
RETURN res; END;
-- Enter diseaseID
CALL CheckClaimStatus(11);


--2
CREATE OR REPLACE PROCEDURE GetGenderWiseReport(disease_id INT) RETURNS TABLE (
disease_name VARCHAR, number_of_male_treated INT, number_of_female_treated INT, more_treated_gender VARCHAR
)
LANGUAGE SQL AS
DECLARE
male_count INT; female_count INT;
res RESULTSET DEFAULT
(SELECT diseaseName, male_count, female_count, more_treated_gender FROM (
SELECT d.diseaseName,
count(distinct CASE WHEN p.gender = 'male' THEN t.patientID END) AS
male_count,
count(distinct CASE WHEN p.gender = 'female' THEN t.patientID END) AS
female_count, CASE
WHEN male_count > female_count THEN 'male' WHEN female_count > male_count THEN 'female' ELSE 'same'
END AS more_treated_gender
FROM project_db.my_schema.treatment t
JOIN project_db.my_schema.person p ON t.patientID = p.personID JOIN project_db.my_schema.disease d ON t.diseaseID = d.diseaseID WHERE t.diseaseID = :disease_id
GROUP BY d.diseaseName
)); BEGIN
RETURN TABLE (res); END;
CALL GetGenderWiseReport(11);


--3

WITH ClaimsCount AS (
SELECT ip.uin AS plan_uin,
ic.companyName AS company_name,
ip.planName AS plan_name,
COUNT(*) AS total_claims,
ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS rank_most, ROW_NUMBER() OVER (ORDER BY COUNT(*) ASC) AS rank_least
FROM project_db.my_schema.claim c
JOIN project_db.my_schema.InsurancePlan ip ON c.uin = ip.uin
JOIN project_db.my_schema.InsuranceCompany ic ON ip.companyID = ic.companyID GROUP BY ip.uin, ic.companyName, ip.planName
ORDER BY ic.companyname )
SELECT plan_name, company_name,
'most claimed' AS claim_type FROM ClaimsCount
WHERE rank_most <= 3
UNION ALL
SELECT plan_name, company_name,
'least claimed' AS claim_type FROM ClaimsCount
WHERE rank_least <= 3;
-- company wise most and least 3 plans 
WITH PlanClaims AS (
SELECT
ic.companyName,
ip.planName,
COUNT(*) AS total_claims,
ROW_NUMBER() OVER (PARTITION BY ic.companyName ORDER BY COUNT(*)
DESC) AS most_claimed_rank,
ROW_NUMBER() OVER (PARTITION BY ic.companyName ORDER BY COUNT(*)
ASC) AS least_claimed_rank FROM
Claim c JOIN
InsurancePlan ip ON c.uin = ip.uin JOIN
InsuranceCompany ic ON ip.companyID = ic.companyID GROUP BY
ip.planName, ic.companyName ORDER BY ic.companyname
) SELECT
companyName, planName, total_claims, CASE
WHEN most_claimed_rank <= 3 THEN 'Most Claimed' WHEN least_claimed_rank <= 3 THEN 'Least Claimed' ELSE NULL
END AS claim_status FROM
PlanClaims WHERE
most_claimed_rank <= 3 OR least_claimed_rank <= 3 ORDER BY
companyName, claim_status DESC;

--4

WITH PatientCategories AS ( SELECT p.patientID,
CASE
WHEN p.dob >= '2005-01-01' AND ps.gender = 'male' THEN 'YoungMale' WHEN p.dob >= '2005-01-01' AND ps.gender = 'female' THEN 'YoungFemale' WHEN p.dob >= '1985-01-01' AND ps.gender = 'male' THEN 'AdultMale' WHEN p.dob >= '1985-01-01' AND ps.gender = 'female' THEN 'AdultFemale' WHEN p.dob >= '1970-01-01' AND ps.gender = 'male' THEN 'MidAgeMale' WHEN p.dob >= '1970-01-01' AND ps.gender = 'female' THEN 'MidAgeFemale' WHEN ps.gender = 'male' THEN 'ElderMale'
ELSE 'ElderFemale'
END AS patient_category
FROM project_db.my_schema.patient p
JOIN project_db.my_schema.person ps ON p.patientID = ps.personID ),
DiseasePatientCategories AS ( SELECT t.diseaseID,
pc.patient_category,
COUNT(DISTINCT pc.patientID) AS patient_count,
RANK() OVER(PARTITION BY t.diseaseID ORDER BY patient_count DESC) AS
category_rank
FROM project_db.my_schema.treatment t
JOIN PatientCategories pc ON t.patientID = pc.patientID GROUP BY t.diseaseID, pc.patient_category
)
SELECT d.diseaseName,
dpc.patient_category,
dpc.patient_count
FROM DiseasePatientCategories dpc
JOIN project_db.my_schema.disease d ON dpc.diseaseID = d.diseaseID WHERE dpc.category_rank = 1;


--5
SELECT m.companyName, m.productName,
m.description, m.maxPrice, CASE
WHEN m.maxPrice > 1000 THEN 'Pricey'
ELSE 'Affordable' END AS price_category
FROM project_db.my_schema.Medicine m WHERE m.maxPrice > 1000 OR m.maxPrice <= 5 ORDER BY m.maxPrice DESC;