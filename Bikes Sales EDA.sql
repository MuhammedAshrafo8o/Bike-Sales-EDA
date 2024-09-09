-- Select all records from the 'sales2' table.
SELECT * FROM sales2;

-- Find duplicate records based on specific columns and count them.
SELECT 
    `Date`, `Day`, `Month`, `Year`, Customer_Age, Age_Group, 
    Customer_Gender, Country, State, Product_Category, Sub_Category, 
    Product, Order_Quantity, Unit_Cost, Unit_Price, Profit, Cost, Revenue, 
    COUNT(*) AS duplicated
FROM sales2
GROUP BY `Date`, `Day`, `Month`, `Year`, Customer_Age, Age_Group, 
         Customer_Gender, Country, State, Product_Category, Sub_Category, 
         Product, Order_Quantity, Unit_Cost, Unit_Price, Profit, Cost, Revenue
HAVING COUNT(*) > 1;

-- Delete duplicate records while keeping one copy using a CTE (Common Table Expression).
WITH CTE AS (
  SELECT 
    `Date`, `Day`, `Month`, `Year`, Customer_Age, Age_Group, 
    Customer_Gender, Country, State, Product_Category, Sub_Category, 
    Product, Order_Quantity, Unit_Cost, Unit_Price, Profit, Cost, Revenue,
    ROW_NUMBER() OVER (PARTITION BY `Date`, `Day`, `Month`, `Year`, Customer_Age, 
                       Age_Group, Customer_Gender, Country, State, Product_Category, 
                       Sub_Category, Product, Order_Quantity, Unit_Cost, Unit_Price, 
                       Profit, Cost, Revenue ORDER BY temp_id) AS duplicated
  FROM sales2
)
DELETE FROM CTE WHERE duplicated > 1;

-- Add a unique auto-incrementing primary key column called 'temp_id' to the table.
ALTER TABLE sales ADD temp_id INT AUTO_INCREMENT PRIMARY KEY;

-- Delete duplicate rows using the temp_id and keeping the first row of each duplicate.
DELETE t1
FROM sales2 t1
JOIN (
  SELECT 
    temp_id, ROW_NUMBER() OVER (PARTITION BY `Date`, `Day`, `Month`, `Year`, 
                                Customer_Age, Age_Group, Customer_Gender, Country, 
                                State, Product_Category, Sub_Category, Product, 
                                Order_Quantity, Unit_Cost, Unit_Price, Profit, 
                                Cost, Revenue ORDER BY temp_id) AS rn
  FROM sales2
) t2 ON t1.temp_id = t2.temp_id
WHERE t2.rn > 1;

-- Remove the 'temp_id' column after completing the operation.
ALTER TABLE sales DROP COLUMN temp_id;

-- Calculate the total sales (revenue) by country.
SELECT Country, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Country
ORDER BY Total_Sales DESC;

-- Calculate total sales by state within each country.
SELECT Country, State, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Country, State
ORDER BY Total_Sales DESC;

-- Calculate total sales for male vs. female customers.
SELECT Customer_Gender, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Customer_Gender
ORDER BY Total_Sales DESC;

-- Calculate total sales by gender in each country.
SELECT Country, Customer_Gender, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Country, Customer_Gender
ORDER BY Total_Sales DESC;

-- Find top-selling products based on sales and the number of sales.
SELECT Product, SUM(revenue) AS Total_Sales, COUNT(*) AS Number_Of_Sales
FROM sales2
GROUP BY Product
ORDER BY Number_Of_Sales DESC;

-- Calculate total sales by product category.
SELECT Product_Category, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Product_Category
ORDER BY Total_Sales DESC;

-- Calculate total sales by product sub-category.
SELECT Sub_Category, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Sub_Category
ORDER BY Total_Sales DESC;

-- Calculate total sales by age group.
SELECT Age_Group, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Age_Group
ORDER BY Total_Sales DESC;

-- Calculate total sales by age group and product.
SELECT Age_Group, Product, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Age_Group, Product
ORDER BY Total_Sales DESC;

-- Calculate total sales by year and month to observe sales trends over time.
SELECT `Year`, `Month`, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY `Year`, `Month`
ORDER BY `Year`, `Month`;

-- Calculate total sales by year to observe yearly sales trends.
SELECT `Year`, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY `Year`
ORDER BY `Year` DESC;

-- Find the relationship between order quantity and total profit.
SELECT Order_Quantity, SUM(Profit) AS Total_Profit
FROM sales2
GROUP BY Order_Quantity
ORDER BY Total_Profit DESC;

-- Find the maximum profit for orders where Order_Quantity = 1.
SELECT MAX(profit)
FROM sales2
WHERE Order_Quantity = 1;

-- Identify products with high sales volume but low profit.
SELECT Product, SUM(Order_Quantity) AS Total_Quantity, SUM(Profit) AS Total_Profit
FROM sales2
GROUP BY Product
HAVING SUM(Profit) < 100000  -- Adjust this threshold based on your analysis.
ORDER BY Total_Quantity DESC;

-- Calculate total revenue and total cost by country.
SELECT Country, SUM(Revenue) AS Total_Revenue, SUM(Cost) AS Total_Cost
FROM sales2
GROUP BY Country
ORDER BY Total_Revenue DESC;

-- Identify outliers in sales by checking for extreme values (high or low).
SELECT *
FROM sales2
WHERE revenue > (SELECT AVG(revenue) + 2 * STDDEV(revenue) FROM sales2) 
   OR revenue < (SELECT AVG(revenue) - 2 * STDDEV(revenue) FROM sales2);
