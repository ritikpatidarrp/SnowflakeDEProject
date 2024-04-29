create stage healthcare_stage;

put file://Address/Address.csv @healthcare_stage;
put file://Claim/Claim.csv @healthcare_stage;
put file://Contain/Contain.csv @healthcare_stage;
put file://Disease/Disease.csv @healthcare_stage;
put file://InsuranceCompany/InsuranceCompany.csv @healthcare_stage;
put file://InsurancePlan/InsurancePlan.csv @healthcare_stage;
put file://Keep/Keep.csv @healthcare_stage;
put file://Medicine/Medicine.csv @healthcare_stage;
put file://Patient/Patient.csv @healthcare_stage;
put file://Person/Person.csv @healthcare_stage;
put file://Pharmacy/Pharmacy.csv @healthcare_stage;
put file://Prescription/Prescription.csv @healthcare_stage;
put file://Treatment/Treatment.csv @healthcare_stage;

-- Address table
DROP TABLE IF EXISTS Address;
CREATE TABLE Address (
    addressID INTEGER PRIMARY KEY,
    address1 VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(20),
    zip INTEGER
);
COPY INTO Address
FROM @healthcare_stage/Address.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Claim table
DROP TABLE IF EXISTS Claim;
CREATE TABLE Claim (
    claimID BIGINT NOT NULL PRIMARY KEY,
    balance BIGINT NOT NULL,
    uin VARCHAR(22) NOT NULL
);
COPY INTO Claim
FROM @healthcare_stage/Claim.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 ENCODING = 'ISO88591')
ON_ERROR = 'CONTINUE';

-- Contain table
DROP TABLE IF EXISTS Contain;
CREATE TABLE Contain (
    prescriptionID BIGINT NOT NULL,
    medicineID INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    PRIMARY KEY (prescriptionID, medicineID)
);
COPY INTO Contain
FROM @healthcare_stage/Contain.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Disease table
DROP TABLE IF EXISTS Disease;
CREATE TABLE Disease (
    diseaseID INTEGER NOT NULL PRIMARY KEY,
    diseaseName VARCHAR(100) NOT NULL,
    description VARCHAR(1000) NOT NULL
);
COPY INTO Disease
FROM @healthcare_stage/Disease.csv
FILE_FORMAT = (
    TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"'
)
ON_ERROR = 'CONTINUE';

-- InsuranceCompany table
DROP TABLE IF EXISTS InsuranceCompany;
CREATE TABLE InsuranceCompany (
    companyID INTEGER PRIMARY KEY,
    companyName VARCHAR(100),
    addressID INTEGER
);
COPY INTO InsuranceCompany
FROM @healthcare_stage/InsuranceCompany.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 ENCODING = 'ISO88591')
ON_ERROR = 'CONTINUE';

-- InsurancePlan table
DROP TABLE IF EXISTS InsurancePlan;
CREATE TABLE InsurancePlan (
    uin VARCHAR(25) PRIMARY KEY,
    planName VARCHAR(100),
    companyID INTEGER
);
COPY INTO InsurancePlan
FROM @healthcare_stage/InsurancePlan.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 ENCODING = 'ISO88591')
ON_ERROR = 'CONTINUE';

-- Keep table
DROP TABLE IF EXISTS Keep;
CREATE TABLE Keep (
    pharmacyID INTEGER,
    medicineID INTEGER,
    quantity INTEGER,
    discount INTEGER,
    PRIMARY KEY (pharmacyID, medicineID)
);
COPY INTO Keep
FROM @healthcare_stage/Keep.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Medicine table
DROP TABLE IF EXISTS Medicine;
CREATE TABLE Medicine (
    medicineID INTEGER PRIMARY KEY,
    companyName VARCHAR(101),
    productName VARCHAR(174),
    description VARCHAR(161),
    substanceName VARCHAR(255),
    productType INTEGER,
    taxCriteria VARCHAR(3),
    hospitalExclusive VARCHAR(1),
    governmentDiscount VARCHAR(1),
    taxImunity VARCHAR(1),
    maxPrice NUMERIC(9, 2)
);
COPY INTO Medicine
FROM @healthcare_stage/Medicine.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Patient table
DROP TABLE IF EXISTS Patient;
CREATE TABLE Patient (
    patientID INTEGER PRIMARY KEY,
    ssn INTEGER,
    dob DATE
);
COPY INTO Patient
FROM @healthcare_stage/Patient.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Person table
DROP TABLE IF EXISTS Person;
CREATE TABLE Person (
    personID INTEGER PRIMARY KEY,
    personName VARCHAR(22),
    phoneNumber BIGINT,
    gender VARCHAR(6),
    addressID INTEGER
);
COPY INTO Person
FROM @healthcare_stage/Person.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Pharmacy table
DROP TABLE IF EXISTS Pharmacy;
CREATE TABLE Pharmacy (
    pharmacyID INTEGER NOT NULL PRIMARY KEY,
    pharmacyName VARCHAR(33) NOT NULL,
    phone BIGINT NOT NULL,
    addressID INTEGER NOT NULL
);
COPY INTO Pharmacy
FROM @healthcare_stage/Pharmacy.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Prescription table
DROP TABLE IF EXISTS Prescription;
CREATE TABLE Prescription (
    prescriptionID BIGINT PRIMARY KEY,
    pharmacyID INTEGER,
    treatmentID INTEGER
);
COPY INTO Prescription
FROM @healthcare_stage/Prescription.csv
FILE_FORMAT = (
    TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"'
)
ON_ERROR = 'CONTINUE';

-- Treatment table
DROP TABLE IF EXISTS Treatment;
CREATE TABLE Treatment (
    treatmentID INTEGER PRIMARY KEY,
    date DATE,
    patientID INTEGER,
    diseaseID INTEGER,
    claimID BIGINT
);
COPY INTO Treatment
FROM @healthcare_stage/Treatment.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';
