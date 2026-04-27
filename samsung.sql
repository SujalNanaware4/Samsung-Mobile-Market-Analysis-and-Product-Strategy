SELECT * FROM samsung_analysis.mobiletable;
ALTER TABLE mobiletable 
ADD COLUMN price_clean INT,
ADD COLUMN battery_clean INT,
ADD COLUMN spec_score_clean INT;

#View all phones sorted by spec score (highest first)
SELECT
    `Brand Name`,
    `Model Name`,
    `Price`,
    `SPECS SCORE`,
    `RAM_Storage`,
    `Battery`,
    `Camera`
FROM MobileTable
ORDER BY CAST(SUBSTRING_INDEX(`SPECS SCORE`, '\n', 1) AS UNSIGNED) DESC;
#Total phones count per brand
SELECT
    `Brand Name`,
    COUNT(*) AS total_phones
FROM MobileTable
GROUP BY `Brand Name`
ORDER BY total_phones DESC;
# Count of phones per price segment

SELECT
    CASE 
        WHEN CAST(REPLACE(`Price `, ',', '') AS UNSIGNED) < 15000 THEN 'Budget'
        WHEN CAST(REPLACE(`Price `, ',', '') AS UNSIGNED) < 35000 THEN 'Mid-Range'
        WHEN CAST(REPLACE(`Price `, ',', '') AS UNSIGNED) < 60000 THEN 'Premium'
        ELSE 'Flagship'
    END AS price_segment,
    COUNT(*) AS total_phones
FROM MobileTable
GROUP BY price_segment
ORDER BY FIELD(price_segment, 'Budget', 'Mid-Range', 'Premium', 'Flagship');
# All Samsung phones
SELECT
    `Model Name`,
    `Price `,
    `SPECS SCORE`,
    `RAM_Storage`,
    `Battery `
FROM MobileTable
WHERE `Brand Name` = 'Samsung'
ORDER BY CAST(REPLACE(`Price `, ',', '') AS UNSIGNED) DESC;
#SECTION 4 : BRAND COMPARISON QUERIES
#Brand-wise average of all key specs

SELECT
    `Brand Name`,
    COUNT(*) AS total_phones,
    ROUND(AVG(CAST(REPLACE(`Price `, ',', '') AS UNSIGNED))) AS avg_price,
    ROUND(AVG(CAST(SUBSTRING_INDEX(`SPECS SCORE`, '\n', 1) AS UNSIGNED)), 1) AS avg_spec_score,
    ROUND(AVG(CAST(SUBSTRING_INDEX(`Battery `, ' mAh', 1) AS UNSIGNED))) AS avg_battery_mah
FROM MobileTable
GROUP BY `Brand Name`
ORDER BY avg_spec_score DESC;
# Top 3 phones per brand by spec score

SELECT * FROM (
    SELECT 
        `Brand Name`, `Model Name`, `Price `, `SPECS SCORE`,
        RANK() OVER (
            PARTITION BY `Brand Name` 
            ORDER BY CAST(SUBSTRING_INDEX(`SPECS SCORE`, '\n', 1) AS UNSIGNED) DESC
        ) AS rnk
    FROM MobileTable
) AS ranked
WHERE rnk <= 3;
#SECTION 5 : GAP ANALYSIS — SAMSUNG VS COMPETITORS
# Samsung vs each competitor brand — detailed gap table


SELECT
    c.`Brand Name` AS competitor,
    s.avg_spec AS samsung_avg_spec,
    c.avg_spec AS competitor_avg_spec,
    ROUND(c.avg_spec - s.avg_spec, 1) AS spec_gap
FROM
    (SELECT AVG(CAST(SUBSTRING_INDEX(`SPECS SCORE`, '\n', 1) AS UNSIGNED)) AS avg_spec 
     FROM MobileTable WHERE `Brand Name` = 'Samsung') AS s,
    (SELECT `Brand Name`, AVG(CAST(SUBSTRING_INDEX(`SPECS SCORE`, '\n', 1) AS UNSIGNED)) AS avg_spec 
     FROM MobileTable WHERE `Brand Name` != 'Samsung' GROUP BY `Brand Name`) AS c
ORDER BY spec_gap DESC;
#SECTION 6 : FEATURE-SPECIFIC ANALYSIS
#Charging speed comparison

SELECT
    `Brand Name`,
    ROUND(AVG(CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(`Battery `, ' with ', -1), 'W', 1) AS UNSIGNED)), 1) AS avg_charging_watt
FROM MobileTable
GROUP BY `Brand Name`
ORDER BY avg_charging_watt DESC;
# Best value phones (highest spec score per rupee)

SELECT
    `Brand Name`,
    `Model Name`,
    `Price `,
    `SPECS SCORE`,
    ROUND(
        CAST(SUBSTRING_INDEX(`SPECS SCORE`, '\n', 1) AS UNSIGNED) / 
        (CAST(REPLACE(`Price `, ',', '') AS UNSIGNED) / 10000), 2
    ) AS value_score
FROM MobileTable
ORDER BY value_score DESC
LIMIT 20;
#SECTION 8 : POWER BI READY QUERIES
# [Power BI] Brand overview card data

SELECT
    `Brand Name`,
    COUNT(*) AS total_phones,
    ROUND(AVG(CAST(REPLACE(`Price `, ',', '') AS UNSIGNED))) AS avg_price,
    ROUND(AVG(CAST(SUBSTRING_INDEX(`SPECS SCORE`, '\n', 1) AS UNSIGNED)), 1) AS avg_spec_score
FROM MobileTable
GROUP BY `Brand Name`;
#[Power BI] Full phone list with value score

SELECT
    `Brand Name`,
    `Model Name`,
    `Price `,
    `SPECS SCORE`,
    `RAM_Storage`,
    `Battery `,
    `Camera `,
    ROUND(
        CAST(SUBSTRING_INDEX(`SPECS SCORE`, '\n', 1) AS UNSIGNED) / 
        (CAST(REPLACE(`Price `, ',', '') AS UNSIGNED) / 10000), 2
    ) AS value_score
FROM MobileTable;