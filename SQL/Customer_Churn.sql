CREATE DATABASE CUSTOMER_CHURN;
USE CUSTOMER_CHURN;

SELECT * FROM TELCO;

--NUMBER OF RECORDS
SELECT COUNT(*) AS RECORD_COUNT FROM TELCO;
/*
RECORD_COUNT
7043
*/

SELECT Churn_Value, COUNT(*) AS Total
FROM TELCO
GROUP BY Churn_Value;

SELECT [Churn_Label], COUNT(*) AS Total
FROM TELCO
GROUP BY [Churn_Label];

--WHERE CHURN LABEL IS YES
SELECT COUNT(*) FROM TELCO
WHERE CHURN_LABEL = 'YES';
--1869 customers have churned

SELECT COUNT(*) AS Active_Customers
FROM TELCO
WHERE [Churn_Label] = 'No';
/*
Active_Customers
5174
*/

--OVERALL CHURN RATE
SELECT
    ROUND(
        COUNT(CASE WHEN [Churn_Label] = 'Yes' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS Churn_Rate
FROM TELCO;
/*
Churn_Rate
26.540000000000
*/

--Revenue Lost due to Churn
SELECT ROUND(SUM(Monthly_Charges),2) AS REVENUE_LOST
FROM TELCO
WHERE Churn_Label = 'YES';
/*
REVENUE_LOST
139130.85
If churned customers had stayed, this monthly revenue could have been retained.
*/

--CLTV Lost due to Churn
SELECT ROUND(SUM(CLTV),2) AS CLTV_LOST
FROM TELCO
WHERE Churn_Label = 'YES';
/*
CLTV_LOST
7755256
Shows the total lifetime value lost because customers churned.
*/

--Average Customer Tenure
SELECT AVG(Tenure_Months) AS AVG_TENURE_MONTHS
FROM TELCO;
/*
AVG_TENURE_MONTHS
32
Shows how long customers stay with the company on average.
*/

--Customer Retention Rate
SELECT
    COUNT(*) AS Total_Customers,
    COUNT(CASE WHEN [Churn_Label]='No' THEN 1 END) AS Retained_Customers,
    ROUND(
        COUNT(CASE WHEN [Churn_Label]='No' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS Retention_Rate
FROM TELCO;
/*
Total_Customers	Retained_Customers	Retention_Rate
7043	                    5174	73.460000000000
If the customers stay then the rentention rate would be this
*/


--GENDER WISE CHURNED CUSTOMER COUNT
SELECT GENDER,COUNT(*) AS CHURN_COUNT FROM TELCO
WHERE CHURN_LABEL = 'YES'
GROUP BY Gender;
/*
GENDER	CHURN_COUNT
Male	930
Female	939
*/

--CUSTOMER DISTRIBUTION BY SENIOR CITIZEN
SELECT Senior_Citizen,COUNT(*) AS TOTAL_CUSTOMERS FROM TELCO
GROUP BY Senior_Citizen;
/*
Senior_Citizen	TOTAL_CUSTOMERS
Yes	            1142
No	            5901
*/

--CUSTOMER DISTRIBUTION BY PARTNER
SELECT PARTNER,COUNT(*) AS TOTAL_CUSTOMERS FROM TELCO
GROUP BY Partner;
/*
PARTNER	TOTAL_CUSTOMERS
Yes 	3402
No	    3641
*/

--CUSTOMER DISTRIBUTION BY DEPENDENTS
SELECT Dependents,COUNT(*) AS TOTAL_CUSTOMERS FROM TELCO
GROUP BY Dependents;
/*
Dependents	TOTAL_CUSTOMERS
Yes     	1627
No	        5416
*/

--CUSTOMER SEGMENT DISTRIBUTION
SELECT Customer_Segment,COUNT(*) AS TOTAL_CUSTOMERS
FROM TELCO
GROUP BY Customer_Segment
ORDER BY TOTAL_CUSTOMERS DESC;
/*
Customer_Segment	TOTAL_CUSTOMERS
Loyal Customer	    3001
New Customer	    2186
Regular Customer	1856
*/

SELECT
    [Revenue_Segment],
    COUNT(*) AS Total_Customers
FROM TELCO
GROUP BY [Revenue_Segment]
ORDER BY Total_Customers DESC;
/*
Revenue_Segment	Total_Customers
High	        2160
Low	            1838
Premium	        1739
Medium	        1306
*/

SELECT ROUND(AVG(Monthly_Charges),2) AS AVERAGE_MONTHLYCHARGES FROM TELCO;
/*
AVERAGE_MONTHLYCHARGES
64.76
*/

SELECT
ROUND(AVG([Total_Charges]),2) AS Average_Total_Charges
FROM TELCO;
/*
Average_Total_Charges
2283.3
*/

SELECT
ROUND(AVG(CLTV),2) AS Average_CLTV
FROM TELCO;
/*
Average_CLTV
4400
*/

--Top Revenue Customers
SELECT TOP 10 CustomerID,Total_Charges,
ROW_NUMBER()
OVER (ORDER BY TOTAL_CHARGES DESC) AS RN
FROM TELCO;
/*
CustomerID	Total_Charges	RN
2889-FPWRM	8684.7998046875	1
7569-NMZYQ	8672.4501953125	2
9739-JLPQJ	8670.099609375	3
9788-HNGUT	8594.400390625	4
8879-XUAHX	8564.75     	5
9924-JPRMC	8547.150390625	6
0675-NCDYU	8543.25	        7
6650-BWFRT	8529.5      	8
0164-APGRB	8496.7001953125	9
1488-PBLJN	8477.7001953125	10
*/

--Revenue Difference
SELECT CUSTOMERID,TOTAL_CHARGES,
LAG(Total_Charges)
OVER
(ORDER BY TOTAL_CHARGES) AS PREVIOUS_REV
FROM TELCO;
--Compare each customer's Total Charges with the previous customer

--Revenue Percentile Groups
SELECT CUSTOMERID,TOTAL_CHARGES ,
NTILE(4)
OVER
(ORDER BY TOTAL_CHARGES DESC) AS REVENUE_GROUPS
FROM TELCO;

--Top Churned Cities
SELECT TOP 10 CITY,COUNT(*) AS CHURNED_CUSTOMERS
FROM TELCO
WHERE Churn_Label='YES'
GROUP BY City
ORDER BY CHURNED_CUSTOMERS DESC;
/*
CITY	      CHURNED_CUSTOMERS
Los Angeles	  90
San Diego	  50
San Francisco 31
San Jose	  29
Sacramento	  26
Fresno	      16
Long Beach	  15
Glendale	  13
Oakland	      13
Modesto	      12
*/

--Contract-wise Churn Ranking
SELECT Contract,COUNT(*) AS CHURNED_CUSTOMERS
,RANK()
OVER
(ORDER BY COUNT(*) DESC) AS RNK
FROM TELCO
WHERE Churn_Label='YES'
GROUP BY Contract;
/*
Contract	CHURNED_CUSTOMERS	RNK
Month-to-month	1655	        1
One year    	166         	2
Two year     	48          	3
*/

SELECT MAX(TENURE_MONTHS) FROM TELCO;
SELECT MAX(MONTHLY_CHARGES) FROM TELCO;
SELECT MAX(CLTV) FROM TELCO;

WITH CustomerSegments AS
(
SELECT
    CustomerID,
    [Tenure_Months],
    [Monthly_Charges],
    CLTV,

    CASE
        WHEN [Tenure_Months] >= 48
             AND [Monthly_Charges] >= 80
             AND CLTV >= 5000
        THEN 'Champions'

        WHEN [Tenure_Months] >= 24
             AND [Monthly_Charges] >= 60
             AND CLTV >= 3000
        THEN 'Loyal'

        WHEN [Tenure_Months] < 24
             AND [Monthly_Charges] >= 40
             AND CLTV >= 2000
        THEN 'At Risk'

        ELSE 'Potential Churn'
    END AS Customer_Segment

FROM TELCO
)

SELECT
    Customer_Segment,
    COUNT(*) AS Total_Customers
FROM CustomerSegments
GROUP BY Customer_Segment
ORDER BY Total_Customers DESC;
/*
Customer_Segment	Total_Customers
Potential Churn 	2530
At Risk         	2183
Loyal           	1615
Champions       	715
*/

--VIEW CUSTOMER CHURN
CREATE VIEW vw_customer_churn AS
SELECT
    CustomerID,
    Gender,
    City,
    State,
    Contract,
    [Internet_Service],
    [Payment_Method],
    [Tenure_Months],
    [Monthly_Charges],
    [Total_Charges],
    CLTV,
    [Churn_Label],
    [Churn_Reason]
FROM TELCO;
SELECT * FROM vw_customer_churn;

--REVENUE SUMMARY
CREATE VIEW vw_revenue_summary AS
SELECT
    Contract,
    COUNT(*) AS Total_Customers,
    SUM([Monthly_Charges]) AS Total_Monthly_Revenue,
    AVG([Monthly_Charges]) AS Avg_Monthly_Revenue,
    SUM([Total_Charges]) AS Total_Revenue
FROM TELCO
GROUP BY Contract;
SELECT * FROM vw_revenue_summary;

--CITYPERFORMANCE
CREATE VIEW vw_city_performance AS
SELECT
    City,
    COUNT(*) AS Total_Customers,
    SUM([Monthly_Charges]) AS Revenue,
    COUNT(CASE WHEN [Churn_Label] = 'Yes' THEN 1 END) AS Churned_Customers
FROM TELCO
GROUP BY City;
SELECT * FROM vw_city_performance;

--RETENTION METRICS
CREATE VIEW vw_retention_metrics AS
SELECT
    Contract,
    COUNT(*) AS Total_Customers,
    COUNT(CASE WHEN [Churn_Label] = 'No' THEN 1 END) AS Retained_Customers,
    ROUND(
        COUNT(CASE WHEN [Churn_Label] = 'No' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS Retention_Rate
FROM TELCO
GROUP BY Contract;
SELECT * FROM vw_retention_metrics;

--CUSTOMER CHURN SUMMARRY
CREATE PROCEDURE sp_CustomerChurnSummary
AS
BEGIN

    SELECT
        COUNT(*) AS Total_Customers,
        COUNT(CASE WHEN [Churn_Label]='Yes' THEN 1 END) AS Churned_Customers,
        ROUND(
            COUNT(CASE WHEN [Churn_Label]='Yes' THEN 1 END) *100.0/COUNT(*),
            2
        ) AS Churn_Rate
    FROM TELCO;

END;
EXEC sp_CustomerChurnSummary;
/*
Total_Customers	Churned_Customers	Churn_Rate
7043         	1869             	26.540000000000
*/

--REVENUE SUMMARY
CREATE PROCEDURE sp_RevenueSummary
AS
BEGIN

    SELECT
        SUM([Monthly_Charges]) AS Total_Monthly_Revenue,
        SUM([Total_Charges]) AS Total_Revenue,
        AVG([Monthly_Charges]) AS Average_Monthly_Revenue
    FROM TELCO;

END;
EXEC sp_RevenueSummary;
/*
Total_Monthly_Revenue	Total_Revenue	    Average_Monthly_Revenue
456116.60014534     	16056168.7038231	64.7616924812353
*/

--CUSTOMER SEARCH BY CITY
CREATE PROCEDURE sp_CustomersByCity
@City VARCHAR(50)
AS
BEGIN
SELECT
CustomerID,
Gender,
City,
Contract,
[Monthly_Charges],
[Churn_Label]
FROM TELCO
WHERE City=@City;
END;
EXEC sp_CustomersByCity @City='Los Angeles';

--CHURN ANALYSIS BY CONTRACT 
CREATE PROCEDURE sp_ChurnByContract
@Contract VARCHAR(50)
AS
BEGIN
SELECT
CustomerID,
Contract,
[Monthly_Charges],
CLTV,
[Churn_Label],
[Churn_Reason]
FROM TELCO
WHERE Contract=@Contract;
END;
EXEC sp_ChurnByContract @Contract='Month-to-Month';

--REVENUE BY STATE
CREATE PROCEDURE sp_RevenueByState
AS
BEGIN
SELECT
State,
SUM([Monthly_Charges]) AS Revenue
FROM TELCO
GROUP BY State
ORDER BY Revenue DESC;
END;
EXEC sp_RevenueByState;
/*
State   	Revenue
California	456116.60014534
*/