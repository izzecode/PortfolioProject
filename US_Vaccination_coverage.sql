CREATE TABLE vaccination_coverage_staging (
    Vaccine TEXT,
    Combined_Dose TEXT,
    Geography_Type TEXT,
    Geography TEXT,
    Birth_Year TEXT,
    Dimension_Type TEXT,
    Dimension TEXT,
    Estimate_percentage TEXT,
    "95%_CI" TEXT,
    "95%_CI_Midpoint" TEXT,
    Sample_Size TEXT
);

SELECT *
FROM vaccination_coverage_staging;

-- Returning the coloum to the right datatype after importing the dataset
DROP TABLE IF EXISTS vaccination_coverage;
CREATE TABLE vaccination_coverage(
    Vaccine TEXT,
    Combined_Dose TEXT,
    Geography_Type TEXT,
    Geography TEXT,
    Birth_Year TEXT,
    Dimension_Type TEXT,
    Dimension TEXT,
    Estimate_percentage NUMERIC,  
    "95%_CI" TEXT,                    
    "95%_CI_Midpoint" NUMERIC,   
    Sample_Size BIGINT
);

INSERT INTO vaccination_coverage (
    Vaccine, Combined_Dose, Geography_Type, Geography, Birth_Year,
    Dimension_Type, Dimension, Estimate_percentage, "95%_CI",
    "95%_CI_Midpoint", Sample_Size
)
SELECT
    Vaccine,
    Combined_Dose,
    Geography_Type,
    Geography,
    Birth_Year,
    Dimension_Type,
    Dimension,

    CASE 
        WHEN Estimate_percentage ~ '^[0-9.]+$' THEN Estimate_percentage::NUMERIC
        ELSE NULL
    END AS Estimate_percentage,

    "95%_CI",

    CASE 
        WHEN "95%_CI_Midpoint" ~ '^[0-9.]+$' THEN "95%_CI_Midpoint"::NUMERIC
        ELSE NULL
    END AS "95%_CI_Midpoint",

    CASE 
        WHEN Sample_Size ~ '^[0-9.]+$' THEN Sample_Size::BIGINT
        ELSE NULL
    END AS Sample_Size

FROM vaccination_coverage_staging;

--hightest vaccine coverage by state

SELECT Geography, ROUND (AVG(estimate_percentage), 2) AS avg_coverage
FROM vaccination_coverage
WHERE Geography IN (
    'Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','Florida',
    'Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine',
    'Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska',
    'Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota',
    'Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island','South Carolina','South Dakota','Tennessee',
    'Texas','Utah','Vermont','Virginia','Washington','West Virginia','Wisconsin','Wyoming'
)
GROUP BY Geography
ORDER BY avg_coverage DESC;


---YEAR over year changes


SELECT 
    Geography,
    Birth_Year,
    ROUND(AVG(Estimate_percentage), 2) AS avg_coverage,
    ROUND(
        (AVG(Estimate_percentage) - LAG(AVG(Estimate_percentage)) OVER (PARTITION BY Geography ORDER BY Birth_Year)),
        2
    ) AS yoy_change
FROM vaccination_coverage
WHERE Geography IN (
    'Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','Florida',
    'Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine',
    'Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska',
    'Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota',
    'Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island','South Carolina','South Dakota','Tennessee',
    'Texas','Utah','Vermont','Virginia','Washington','West Virginia','Wisconsin','Wyoming'
)
GROUP BY Geography, Birth_Year
ORDER BY Geography, Birth_Year;

---How Insurance coverage affect vaccination coverage

SELECT DISTINCT Dimension_Type
FROM vaccination_coverage;

SELECT 
    Dimension AS Insurance_Status,
    ROUND(AVG(Estimate_percentage), 2) AS Average_Coverage
FROM vaccination_coverage
WHERE Dimension_Type = 'Insurance Coverage'
GROUP BY Dimension
ORDER BY Average_Coverage DESC;

--- How Urbanicity affect vaccination coverage

SELECT 
    Dimension AS Insurance_Status,
    ROUND(AVG(Estimate_percentage), 2) AS Average_Coverage
FROM vaccination_coverage
WHERE Dimension_Type = 'Urbanicity'
GROUP BY Dimension
ORDER BY Average_Coverage DESC;

SELECT AVG (estimate_percentage)
FROM vaccination_coverage;


--

SELECT vaccine, ROUND (AVG(estimate_percentage),2) AS avg_coverage
FROM vaccination_coverage
GROUP BY vaccine
ORDER BY avg_coverage DESC;

-- Percentage of children that complete all required vaccines (7-Series Completion)
SELECT vaccine, AVG(estimate_percentage)
FROM vaccination_coverage
WHERE vaccine LIKE '%Combined%'
GROUP BY vaccine;

-- Geographic Distribution of 7-Series Vaccination Completion

SELECT Geography, ROUND(AVG(estimate_percentage), 2) AS avg_7series_coverage
FROM vaccination_coverage
WHERE vaccine ILIKE '%Combined%'
AND Geography IN (
    'Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','Florida',
    'Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine',
    'Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska',
    'Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota',
    'Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island','South Carolina','South Dakota','Tennessee',
    'Texas','Utah','Vermont','Virginia','Washington','West Virginia','Wisconsin','Wyoming'
)
GROUP BY Geography

