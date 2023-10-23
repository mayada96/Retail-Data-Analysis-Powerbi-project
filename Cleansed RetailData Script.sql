-- Cleansed AND Exploared Retail Data --

ALTER TABLE [RetailData]
ALTER COLUMN [BillDate] DATE; -- Change format of BillDate column to date; 

-- Removing Null values  --

DELETE FROM RetailData
WHERE Bill IS NULL;

DELETE FROM RetailData
WHERE [MerchandiseID] IS NULL;

DELETE FROM RetailData
WHERE [CustomerID] IS NULL;


-- Identifying and Removing Redundant data  --

with t as (
	SELECT *
	,ROW_NUMBER() over (partition by Bill
	,[MerchandiseID]
	,[Product]   -- giving all duplcate values value grater than 1
	,[Quota]
	,[BillDate]
	,[Amount]
	,[CustomerID]
	,[Country] order by [MerchandiseID]) AS RN
FROM RetailData)
DELETE FROM t WHERE rn >1;  -- Remove all duplicate values

--  Now we can extract cleansed RetailData table for visulization  --

SELECT  [Bill]
       ,[MerchandiseID]
       ,[Product]
       ,[Quota]           AS Quantity -- Changing the name of the column into more meaningful name 
       ,[BillDate]
       ,ROUND([Amount],2) AS Amount -- Extracting only tow decimal places 
       ,[CustomerID]
       ,[Country]
FROM [practice].[dbo].[RetailData] 
ORDER BY [MerchandiseID];

-- RFM analysis -- 

SELECT  MAX(BillDate) AS last_purchase_date -- featching last date of purchase " 2019-12-09 " 
FROM RetailData;

-- Now we can foumd the Recency, frequencyy, AND monetry for each customer 

DECLARE @followingdate DATE = '2020-01-01'; -- geting today's date to see most recency date of purchase 

WITH t1 AS (
SELECT  CustomerID
       ,DATEDIFF(DAY,MAX(Billdate),@followingdate) AS recency -- geting the diffrence of days BETWEEN current day AND last day of purchaes 
       ,COUNT(*)                                   AS fequency -- Times the customer made purchase 
       ,ROUND(SUM(Amount),2)                       AS monetry -- Amounts that customer Spend 
FROM RetailData
GROUP BY  CustomerID)
         ,rfm AS (
SELECT  *
       ,NTILE(5) over (order by recency DESC) AS recency_score -- grouping customer to 5 groups depending ON Recency purchaeses 
	   ,NTILE(5) over (order by fequency) AS fequency_score -- grouping customer to 5 groups depending ON Frequency of the purchase 
	   ,NTILE(5) over (order by monetry) AS monetry_score -- grouping customer to 5 groups depending ON Monetry of the purchase 
FROM t1 )
SELECT  CustomerID
       ,recency
       ,fequency
       ,monetry
       ,CONCAT(recency_score,fequency_score,monetry_score) AS RFM_Score -- gathering all scores to give the final rfm score WITH "555" AS the heighest score 
FROM rfm
ORDER BY RFM_Score DESC,recency DESC,fequency DESC,monetry DESC;
