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
