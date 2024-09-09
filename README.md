
# Sales Data Analysis

This project performs data cleaning and exploratory data analysis (EDA) on the sales dataset. The dataset contains information about customer demographics, sales transactions, and product categories. Below is a detailed breakdown of the steps used for cleaning and analyzing the data.

## Table of Contents
1. [Data Cleaning](#data-cleaning)
    - Handling Duplicate Records
    - Managing Temporary Columns
2. [Exploratory Data Analysis (EDA)](#exploratory-data-analysis)
    - Sales Insights by Country, State, and Gender
    - Product and Category Sales Analysis
    - Sales Trends and Customer Demographics
    - Identifying Sales Outliers

## Data Cleaning

### 1. Handling Duplicate Records
Before analyzing the data, we need to clean up duplicate records that may exist in the dataset. The following steps outline the process:

- **Identifying Duplicate Records**:
  We check for duplicate rows by grouping the data based on all relevant columns and using `COUNT(*)` to identify duplicates.

  ```sql
  SELECT 
      `Date`, `Day`, `Month`, `Year`, Customer_Age, Age_Group, 
      Customer_Gender, Country, State, Product_Category, Sub_Category, 
      Product, Order_Quantity, Unit_Cost, Unit_Price, Profit, Cost, Revenue, 
      COUNT(*) AS duplicated
  FROM sales2
  GROUP BY 
      `Date`, `Day`, `Month`, `Year`, Customer_Age, Age_Group, 
      Customer_Gender, Country, State, Product_Category, Sub_Category, 
      Product, Order_Quantity, Unit_Cost, Unit_Price, Profit, Cost, Revenue
  HAVING COUNT(*) > 1;
  ```

- **Deleting Duplicate Records**:
  After identifying duplicates, we use a `ROW_NUMBER()` function to assign a unique number to each row within a duplicate set and delete the extra rows.

  ```sql
  WITH CTE AS (
    SELECT 
      `Date`, `Day`, `Month`, `Year`, Customer_Age, Age_Group, 
      Customer_Gender, Country, State, Product_Category, Sub_Category, 
      Product, Order_Quantity, Unit_Cost, Unit_Price, Profit, Cost, Revenue,
      ROW_NUMBER() OVER (PARTITION BY 
        `Date`, `Day`, `Month`, `Year`, Customer_Age, Age_Group, 
        Customer_Gender, Country, State, Product_Category, Sub_Category, 
        Product, Order_Quantity, Unit_Cost, Unit_Price, Profit, Cost, Revenue 
        ORDER BY temp_id) AS duplicated
    FROM sales2
  )
  DELETE FROM CTE WHERE duplicated > 1;
  ```

- **Adding and Dropping Temporary Columns**:
  We temporarily add an auto-incrementing `temp_id` column to facilitate duplicate deletion, then drop it after the operation is complete.

  ```sql
  ALTER TABLE sales2 ADD temp_id INT AUTO_INCREMENT PRIMARY KEY;

  DELETE t1
  FROM sales2 t1
  JOIN (
    SELECT 
      temp_id, 
      ROW_NUMBER() OVER (PARTITION BY ... ORDER BY temp_id) AS rn
    FROM sales2
  ) t2 ON t1.temp_id = t2.temp_id
  WHERE t2.rn > 1;

  ALTER TABLE sales2 DROP COLUMN temp_id;
  ```

## Exploratory Data Analysis (EDA)

Once the data has been cleaned, we proceed with analyzing it to extract meaningful insights.

### 1. Sales Insights by Country and State
We analyze the total sales (`Revenue`) in each country and break it down further by state.

```sql
-- Total Sales by Country:
SELECT Country, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Country
ORDER BY Total_Sales DESC;

-- Sales by State within Each Country:
SELECT Country, State, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Country, State
ORDER BY Total_Sales DESC;
```

### 2. Sales Insights by Gender
We investigate the total sales for male vs. female customers as well as gender-wise sales by country.

```sql
-- Total Sales for Male vs. Female:
SELECT Customer_Gender, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Customer_Gender
ORDER BY Total_Sales DESC;

-- Gender-wise Sales by Country:
SELECT Country, Customer_Gender, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Country, Customer_Gender
ORDER BY Total_Sales DESC;
```

### 3. Product and Category Sales Analysis
We explore which products and product categories contribute the most to the total sales.

```sql
-- Top-Selling Products:
SELECT Product, SUM(revenue) AS Total_Sales, COUNT(*) AS Number_Of_Sales
FROM sales2
GROUP BY Product
ORDER BY Number_Of_Sales DESC;

-- Sales by Product Category:
SELECT Product_Category, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Product_Category
ORDER BY Total_Sales DESC;

-- Sales by Product Sub-Category:
SELECT Sub_Category, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Sub_Category
ORDER BY Total_Sales DESC;
```

### 4. Customer Demographics Analysis
We examine how customer age groups and gender influence sales and purchasing behavior.

```sql
-- Sales by Age Group:
SELECT Age_Group, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Age_Group
ORDER BY Total_Sales DESC;

-- Sales by Age Group and Products:
SELECT Age_Group, Product, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY Age_Group, Product
ORDER BY Total_Sales DESC;
```

### 5. Sales Trends Over Time
We analyze how sales have evolved over time by year and month.

```sql
-- Sales by Year and Month:
SELECT `Year`, `Month`, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY `Year`, `Month`
ORDER BY `Year`, `Month`;

-- Sales by Year:
SELECT `Year`, SUM(revenue) AS Total_Sales
FROM sales2
GROUP BY `Year`
ORDER BY `Year` DESC;
```

### 6. Profit and Quantity Relationship
We explore the relationship between order quantity and profit, as well as identifying products with high sales volume but low profit.

```sql
-- Relationship Between Order Quantity and Profit:
SELECT Order_Quantity, SUM(Profit) AS Total_Profit
FROM sales2
GROUP BY Order_Quantity
ORDER BY Total_Profit DESC;

-- Products with High Sales Volume but Low Profit:
SELECT Product, SUM(Order_Quantity) AS Total_Quantity, SUM(Profit) AS Total_Profit
FROM sales2
GROUP BY Product
HAVING SUM(Profit) < 100000  -- Adjust this threshold based on analysis
ORDER BY Total_Quantity DESC;
```

### 7. Identifying Sales Outliers
Finally, we look for outliers in sales by identifying records where the sales values are significantly higher or lower than the average.

```sql
-- Identify Sales Outliers:
SELECT *
FROM sales2
WHERE revenue > (SELECT AVG(revenue) + 2 * STDDEV(revenue) FROM sales2) 
   OR revenue < (SELECT AVG(revenue) - 2 * STDDEV(revenue) FROM sales2);
```
