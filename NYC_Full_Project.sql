-- Create and import tables from EXCEL

-- Create Energy table
CREATE TABLE energy
(HomePerformanceProjectID varchar(50),
GasUtility varchar(50),
ElectricUtility varchar(50),
MeasureType varchar(50),
EstimatedAnnualkWhSavings int,
EstimatedAnnualMMBtuSavings int,
FirstYearEnergySavings$Estimate int
);

-- Load data into the Energy table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/residential_existing_homes_energy.csv'
INTO TABLE energy
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Create ProjectLocation table
CREATE TABLE ProjectLocation
(HomePerformanceProjectID varchar(50),
HomePerformanceSiteID varchar(50),
ProjectCounty varchar(50),
ProjectCity varchar(50),
ProjectZip int,
CustomerType varchar(50),
YearHomeBuilt int,
SizeofHome int,
VolumeofHome int,
NumberofUnits int
);

-- Load data into the ProjectLocation table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/residential_existing_homes_ProjectLocation.csv'
INTO TABLE ProjectLocation
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Create Finance table
CREATE TABLE Finance
(HomePerformanceProjectID varchar(50),
ProjectCompletionDate date,
TotalProjectCost int,
TotalIncentives int,
TypeofProgramFinancing varchar(50),
AmountFinancedThroughProgram int,
HomeownerReducedCostAuditYN bool
);

-- Load data into the Finance table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/residential_existing_homes_FinanceCSV.csv'
INTO TABLE Finance
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- What type of household and energy efficiency projects should incentives be invested on? 

-- CREATE TEMPORARY TABLE AND INSERT YEAR BUILT AND SIZE OF HOME RANGES
DROP TABLE IF exists Temp_BP_ST;
CREATE TEMPORARY TABLE Temp_BP_ST (
HomePerformanceProjectID varchar(50),
YearHomeBuilt int,
SizeofHome int,
BuiltPeriod varchar(50),
SizeType varchar(50)
);

-- INSERT DATA INTO TEMPORARY TABLE
INSERT INTO Temp_BP_ST
SELECT HomePerformanceProjectID, YearHomeBuilt, SizeofHome,
CASE 
	WHEN YearHomeBuilt <= 1900 THEN '<=1900'
    WHEN YearHomeBuilt BETWEEN 1900 AND 1950 THEN '1900-1950'
	WHEN YearHomeBuilt BETWEEN 1950 AND 2000 THEN '1950-2000'
    ELSE '>2000'
END AS BuiltPeriod,
CASE
	WHEN SizeofHome <= 500 THEN 'Small'
    WHEN SizeofHome BETWEEN 500 AND 1000 THEN 'Medium Low'
    WHEN SizeofHome BETWEEN 1500 AND 2000 THEN 'Medium High'     
    ELSE 'Big'
END AS SizeType
FROM projectlocation;

-- Shows temp table
SELECT *
FROM Temp_BP_ST;

-- Looking at energy savings by size type
SELECT SizeType, COUNT(SizeType), AVG(FirstYearEnergySavings$Estimate), AVG(EstimatedAnnualkWhSavings), AVG(EstimatedAnnualMMBtuSavings)
FROM Temp_BP_ST AS tbs
JOIN energy AS en
	ON tbs.HomePerformanceProjectID = en.HomePerformanceProjectID
GROUP BY SizeType
ORDER BY AVG(FirstYearEnergySavings$Estimate) DESC;

-- Looking at energy savings by built period
SELECT BuiltPeriod, COUNT(BuiltPeriod), AVG(FirstYearEnergySavings$Estimate), AVG(EstimatedAnnualkWhSavings), AVG(EstimatedAnnualMMBtuSavings)
FROM Temp_BP_ST AS tbs
JOIN energy AS en
	ON tbs.HomePerformanceProjectID = en.HomePerformanceProjectID
GROUP BY BuiltPeriod
ORDER BY AVG(FirstYearEnergySavings$Estimate) DESC;

-- Looking at energy savings by measure type
SELECT MeasureType, COUNT(MeasureType), AVG(FirstYearEnergySavings$Estimate), AVG(EstimatedAnnualkWhSavings), AVG(EstimatedAnnualMMBtuSavings)
FROM energy
GROUP BY MeasureType
ORDER BY AVG(FirstYearEnergySavings$Estimate) DESC

