--1
SELECT state,
gender,
COUNT(DISTINCT t.patientid) AS num_patients FROM
project_db.my_schema.treatment t JOIN
project_db.my_schema.patient p ON t.patientID = p.patientID JOIN
project_db.my_schema.person ps ON p.patientID = ps.personID JOIN
project_db.my_schema.address a ON ps.addressID = a.addressID JOIN
project_db.my_schema.disease d ON t.diseaseID = d.diseaseID WHERE
d.diseaseName = 'Autism' GROUP BY
ROLLUP (state, gender) ORDER BY
state NULLS LAST, gender NULLS LAST;
-----------------------------------------------------------------------------------------------------------------
-- 2
 SELECT
ic.companyName AS insurance_company, ip.planName AS insurance_plan, YEAR(t.date) AS claim_year,
COUNT(*) AS claims
FROM Treatment t
JOIN
Claim c ON t.claimID = c.claimID
JOIN
InsurancePlan ip ON c.uin = ip.uin
JOIN
InsuranceCompany ic ON ip.companyID = ic.companyID
WHERE
YEAR(t.date) IN (2022, 2021, 2020)
GROUP BY
ROLLUP(ic.companyName, ip.planName, YEAR(t.date))
ORDER BY insurance_company, insurance_plan, claim_year DESC;
--3
a.state AS state,
d.diseaseName AS disease,
COUNT(t.treatmentID) AS num_treatments,
RANK() OVER (PARTITION BY a.state ORDER BY COUNT(t.treatmentID) DESC) AS
rank_most_affected,
RANK() OVER (PARTITION BY a.state ORDER BY COUNT(t.treatmentID) ASC) AS
rank_least_affected FROM
Treatment t JOIN

 Patient p ON t.patientID = p.patientID JOIN
Person ps ON p.patientID = ps.personID JOIN
Address a ON ps.addressID = a.addressID JOIN
Disease d ON t.diseaseID = d.diseaseID WHERE
YEAR(t.date) = 2022 GROUP BY
ROLLUP (a.state, d.diseaseName) HAVING
a.state IS NOT NULL ORDER BY
a.state, num_treatments DESC )
SELECT dc.state,
dc.disease, dc.num_treatments, CASE
WHEN dc.rank_most_affected = 2 THEN 'Most Treated' WHEN dc.rank_least_affected = 1 THEN 'Least Treated' ELSE NULL
END AS status FROM
DiseaseCounts dc WHERE
dc.rank_most_affected = 2 OR dc.rank_least_affected = 1 ORDER BY
dc.state, dc. num_treatments DESC;

--4
WITH PharmacyPrescriptions AS ( SELECT

 ph.pharmacyName AS pharmacy_name,
d.diseaseName AS disease,
COUNT(p.prescriptionID) AS prescriptions_per_disease, COUNT(p.prescriptionID) OVER (PARTITION BY ph.pharmacyName) AS
total_prescriptions_per_pharmacy FROM
Prescription p JOIN
Pharmacy ph ON p.pharmacyID = ph.pharmacyID JOIN
Treatment t ON p.treatmentID = t.treatmentID JOIN
Disease d ON t.diseaseID = d.diseaseID WHERE
YEAR(t.date) = 2022 GROUP BY
ph.pharmacyName, d.diseaseName, p.prescriptionid )
SELECT
pharmacy_name,
disease,
prescriptions_per_disease,
total_prescriptions_per_pharmacy,
SUM(prescriptions_per_disease) OVER (PARTITION BY disease) AS
total_prescriptions_per_disease FROM
PharmacyPrescriptions ORDER BY
pharmacy_name, disease;
SELECT
COALESCE(ph.pharmacyName, 'Total') AS pharmacy_name, COALESCE(d.diseaseName, 'Total') AS disease, COUNT(p.prescriptionID) AS prescriptions_per_disease, COUNT(p.prescriptionID) OVER (PARTITION BY ph.pharmacyName) AS
total_prescriptions_per_pharmacy,
SUM(COUNT(p.prescriptionID)) OVER (PARTITION BY d.diseaseName) AS
total_prescriptions_per_disease FROM
Prescription p JOIN

Pharmacy ph ON p.pharmacyID = ph.pharmacyID JOIN
Treatment t ON p.treatmentID = t.treatmentID JOIN
Disease d ON t.diseaseID = d.diseaseID WHERE
YEAR(t.date) = 2022 GROUP BY
ROLLUP (pharmacyName, diseaseName, prescriptionid) ORDER BY
disease,pharmacy_name; 


--5
SELECT
COALESCE(d.diseaseName, 'Total') AS disease, COALESCE(p.gender, 'Total') AS gender, COUNT(DISTINCT p.personID) AS treatments_count
FROM Treatment t
JOIN
Disease d ON t.diseaseID = d.diseaseID
JOIN
Person p ON t.patientID = p.personID
WHERE
YEAR(t.date) = 2022
GROUP BY
ROLLUP (d.diseaseName, p.gender)
ORDER BY disease, gender;