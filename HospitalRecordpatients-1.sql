SELECT * FROM patients_table

SELECT * FROM encounters_table

SELECT * FROM procedures_table

-- DATA PREPARATION
--Renaming some columns header
EXEC sp_rename 'patients_table.FIRST','FIRST_NAME','COLUMN'

EXEC sp_rename 'patients_table.LAST','LAST_NAME','COLUMN'

-- Finding and handling missing value,and Cleaning columns
SELECT DISTINCT MARITAL FROM patients_table

UPDATE patients_table
SET MARITAL = 'M'
WHERE MARITAL is null

UPDATE patients_table
SET MARITAL = 'Married'
WHERE MARITAL = 'M'

UPDATE patients_table
SET MARITAL = 'Single'
WHERE MARITAL = 'S'

UPDATE patients_table
SET GENDER = 'Male'
WHERE GENDER = 'M'

UPDATE patients_table
SET GENDER = 'Female'
WHERE GENDER = 'F'

UPDATE patients_table
SET FIRST_NAME = LEFT(FIRST_NAME,LEN(FIRST_NAME)-3);

UPDATE patients_table
SET LAST_NAME = LEFT(LAST_NAME,LEN(LAST_NAME)-3);

--Removing columns not needed for my analysis
ALTER TABLE patients_table
DROP COLUMN ZIP 

ALTER TABLE patients_table
DROP COLUMN LAT

ALTER TABLE patients_table
DROP COLUMN LON

ALTER TABLE patients_table
DROP COLUMN PREFIX,SUFFIX,MAIDEN

-- Q1 Total Patients
SELECT COUNT(*) Total_Patients
FROM patients_table

-- Q2 How Often Patient Visit 
SELECT PATIENT, COUNT(*) AS [HOW OFTEN PATIENT VISIT]
FROM encounters_table
GROUP BY PATIENT
ORDER BY [HOW OFTEN PATIENT VISIT] DESC

-- Q3 Patients Age distribution
ALTER TABLE patients_table
ADD AGE INT

UPDATE patients_table
SET [AGE] = DATEDIFF(year,birthdate,getdate())
FROM patients_table

-- Patient Age Distribution
SELECT CASE
           WHEN [AGE] < 40 THEN 'Youth'
           WHEN AGE BETWEEN 40 AND 70 THEN 'Adult'
           ELSE 'Elderly'
        END AS Age_Bracket, COUNT(*) AS AGE_DISTRIBUTION
FROM patients_table
GROUP BY CASE
             WHEN AGE < 40 THEN 'Youth'
             WHEN AGE BETWEEN 40 AND 70 THEN 'Adult'
             ELSE 'Elderly'
        END

-- Q4 Patients Gender Distribution
SELECT GENDER, COUNT(*) AS Gender_Distribution
FROM patients_table
GROUP BY GENDER

-- Q5 Appointment summary
SELECT COUNT(*) Total_Appointment
FROM encounters_table

-- Q6 Most common visit reason
SELECT DESCRIPTION, COUNT(*) AS [NO OF VISIT TIME]
FROM encounters_table
GROUP BY DESCRIPTION
ORDER BY [NO OF VISIT TIME] DESC

-- Q7 Appointment Class Trends
SELECT ENCOUNTERCLASS, COUNT(*) AS [MOST COMMON]
FROM encounters_table
GROUP BY ENCOUNTERCLASS
ORDER BY [MOST COMMON] DESC

-- Q8 Number of times Per patient visit to the hospital
SELECT FIRST_NAME, COUNT(*) AS [TOTAL NO OF VISIT]
FROM patients_table
JOIN encounters_table
ON patients_table.Id = encounters_table.PATIENT
GROUP BY FIRST_NAME
ORDER BY [TOTAL NO OF VISIT] DESC

-- Q9 Treatment summary
-- Most Common Treatment
SELECT DESCRIPTION, COUNT(*) AS [COMMON TREATMENT]
FROM procedures_table
GROUP BY DESCRIPTION
ORDER BY [COMMON TREATMENT] DESC

-- Q10 Average Treatemt Cost
SELECT AVG(BASE_COST) AS [AVERAGE TREATMENT COST]
FROM procedures_table

-- Q11 REVENUE SUMMARY 
-- Top Patient Per Revenue
SELECT FIRST_NAME, SUM(TOTAL_CLAIM_COST) AS [PATIENT PER REVENUE]
FROM patients_table
JOIN encounters_table
ON patients_table.Id =encounters_table.PATIENT
GROUP BY FIRST_NAME
ORDER BY [PATIENT PER REVENUE]DESC

-- Q12 Patient Average Spending Per Treatment Cost
SELECT FIRST_NAME, AVG(BASE_COST) AS [AVERAGE SPENDING TREATMENT COST]
FROM patients_table
JOIN procedures_table
ON patients_table.Id = procedures_table.PATIENT
GROUP BY FIRST_NAME
ORDER BY [AVERAGE SPENDING TREATMENT COST]DESC

-- Q13 MOST COMMON TREATMENT PER REVENUE
SELECT DESCRIPTION, SUM(BASE_COST) AS REVENUE
FROM procedures_table
GROUP BY DESCRIPTION
ORDER BY REVENUE DESC

-- Q14 REVENUE PER PAYER
SELECT NAME, SUM(PAYER_COVERAGE) AS [INSURANCE PAYMENT]
FROM payers_table
JOIN encounters_table
ON encounters_table.PAYER = payers_table.Id
GROUP BY NAME
ORDER BY [INSURANCE PAYMENT]DESC

-- Q15 ADVANCED INSIGHTS
-- Patient Lifetime Value
SELECT FIRST_NAME, SUM(BASE_COST) AS [PATIENT LIFETIME VALUE]
FROM patients_table
JOIN procedures_table
ON patients_table.Id =procedures_table.PATIENT
GROUP BY FIRST_NAME
ORDER BY [PATIENT LIFETIME VALUE]DESC

-- Q16 New Patient VS Repeated Patient
SELECT CASE
           WHEN VisitCount = 1 THEN 'One-time Patient'
           ELSE 'Repeat Patient'
      END AS PatientType,
      COUNT(*) AS [Number Of Patients]
FROM
   (SELECT PATIENT, COUNT(*) AS VisitCount
   FROM encounters_table
   GROUP BY PATIENT)
 AS PatientVisits
GROUP BY
   CASE
      WHEN VisitCount = 1 THEN 'One-time Patient'
      ELSE 'Repeat Patient'
  END;