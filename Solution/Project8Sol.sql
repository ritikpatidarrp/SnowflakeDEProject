--1

SELECT DATEDIFF(hour, dob , GETDATE())/8766 AS age, count(*) AS numTreatments
FROM PATIENT
JOIN Treatment ON Treatment.patientID = Patient.patientID
group by DATEDIFF(hour, dob , GETDATE())/8766
order by numTreatments desc;

--2
SELECT 
    a.city,
    COUNT(DISTINCT p.personid) AS no_of_people,
    COUNT(DISTINCT ic.companyid) AS no_of_companies,
    COUNT(DISTINCT ph.pharmacyid) AS no_of_pharmacy
FROM 
    ADDRESS a
LEFT JOIN 
    Person p ON a.ADDRESSID = p.ADDRESSID
LEFT JOIN 
    INSURANCECOMPANY ic ON a.ADDRESSID = ic.ADDRESSID
LEFT JOIN 
    PHARMACY ph ON a.ADDRESSID = ph.ADDRESSID
GROUP BY 
    a.city
order by
    COUNT(DISTINCT p.personid) desc;

--3
select C.prescriptionID, sum(quantity) as totalQuantity,

CASE WHEN sum(quantity) < 20 THEN 'Low Quantity'

WHEN sum(quantity) < 50 THEN 'Medium Quantity'

ELSE 'High Quantity' END AS Tag

FROM PRESCRIPTION P

JOIN Contain C

on P.prescriptionID = C.prescriptionID

JOIN Pharmacy on Pharmacy.pharmacyID = P.pharmacyID

where Pharmacy.pharmacyName = 'Ally Scripts'

group by C.prescriptionID;

--4
SELECT 
     P.prescriptionID,
    SUM(C.QUANTITY)as TOTAL_QUANTITY
FROM 
    Prescription P
LEFT JOIN 
    Contain C ON P.prescriptionID = C.prescriptionID
GROUP BY 
    P.PRESCRIPTIONID
HAVING 
    SUM(C.QUANTITY) > (SELECT AVG(quantity) FROM Contain)
ORDER BY 
     P.PRESCRIPTIONID;


--5
SELECT Disease.diseaseName, COUNT(*) as numClaims

FROM Disease

JOIN Treatment ON Disease.diseaseID = Treatment.diseaseID

JOIN Claim On Treatment.claimID = Claim.claimID

WHERE diseaseName like '%p%'

GROUP BY diseaseName;


