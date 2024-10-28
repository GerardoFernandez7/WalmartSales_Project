-- Exploratory Data Analysis 
# Min_Year: 2010, Max_Year: 2012
select min(right(`Date`, 4)) as Min_Year, max(right(`Date`, 4)) as Max_Year
from clean_walmart_sales;

# 450 Holidays, 5985 Work days
select Holiday_Flag, count(Holiday_Flag) 
from clean_walmart_sales
group by Holiday_Flag; 

# Average (Temperature: 60.7, Fuel_Price: 3.59$)
select avg(Temperature), avg(Fuel_Price)
from clean_walmart_sales;

# Weekly Sales by Store
# min: Store number 33, max: Store number 20
select Store, SUM(Weekly_Sales) as Total_Weekly_Sales
from clean_walmart_sales
group by Store
order by 2 desc;

# Top 10 Best CPI Stores
select Store, CPI, dense_rank() over(partition by Store order by CPI) as `rank`
from clean_walmart_sales
limit 10;

# Top 10 Worst CPI Stores
select Store, CPI, dense_rank() over(partition by Store order by CPI desc) as `rank`
from clean_walmart_sales
limit 10;

# Top 10 Stores Weekly Sales and Dates
select Store, Weekly_Sales, `Date`
from clean_walmart_sales
order by Weekly_Sales desc
limit 10;

# Correlation Coeficient between Fuel_Price and CPI (CTE)
with Common_Table_Expression as (
    select 
        avg(Fuel_Price)as avg_fuel_price, 
        avg(CPI) as avg_cpi
    from clean_walmart_sales
)
select  
    sum((Fuel_Price - Common_Table_Expression.avg_fuel_price) * (cpi - Common_Table_Expression.avg_cpi)) / 
    (sqrt(sum(power(Fuel_Price - Common_Table_Expression.avg_fuel_price, 2))) * sqrt(sum(power(CPI - Common_Table_Expression.avg_cpi, 2)))) 
    as correlation_coefficient
from 
    clean_walmart_sales, Common_Table_Expression;
-- There is no correlation

# Which stores in the dataset have the lowest and highest unemployment rate?  What factors do you think are 
# impacting the unemployment rate?
select Store, sum(Unemployment) as Unemployment, Temperature, Fuel_Price, CPI
from clean_walmart_sales
group by Store
order by 2 desc
limit 10;

# Which holidays affect weekly sales the most?
select Weekly_Sales, Holiday_Flag, `Date`,
case
	when `Date` like '12-3%' then 'New Year'
    when `Date` like '11-2%' then 'Thanksgiving'
end as Celebration
from clean_walmart_sales
where Holiday_Flag = 1
order by 1
limit 5;

# Is there any correlation between CPI and Weekly Sales? 
with Common_Table_Expression as (
    select 
        avg(Weekly_Sales)as avg_Weekly_Sales, 
        avg(CPI) as avg_cpi
    from clean_walmart_sales
)
select  
    sum((Weekly_Sales - Common_Table_Expression.avg_Weekly_Sales) * (cpi - Common_Table_Expression.avg_cpi)) / 
    (sqrt(sum(power(Weekly_Sales - Common_Table_Expression.avg_Weekly_Sales, 2))) * sqrt(sum(power(CPI - Common_Table_Expression.avg_cpi, 2)))) 
    as correlation_coefficient
from 
    clean_walmart_sales, Common_Table_Expression;
    -- There is no correlation
    
# How does the correlation differ when the Holiday Flag is 0 versus when the Holiday Flag is 1?
with CTE_Holiday_0 as (
    select 
        avg(Weekly_Sales) as avg_Weekly_Sales, 
        avg(CPI) as avg_CPI
    from clean_walmart_sales
    where Holiday_Flag = 0
),
CTE_Holiday_1 as (
    select 
        avg(Weekly_Sales) as avg_Weekly_Sales, 
        avg(CPI) as avg_CPI
    from clean_walmart_sales
    where Holiday_Flag = 1
)
select
    Holiday_Flag,
    sum((Weekly_Sales - avg_Weekly_Sales) * (CPI - avg_CPI)) / 
    (sqrt(sum(power(Weekly_Sales - avg_Weekly_Sales, 2))) * sqrt(sum(power(CPI - avg_CPI, 2)))) as correlation_coefficient
from 
    clean_walmart_sales,
    (select * from CTE_Holiday_0 union all select * from CTE_Holiday_1) as CTE
where 
    (Holiday_Flag = 0 and CTE.avg_Weekly_Sales = (select avg_Weekly_Sales from CTE_Holiday_0)) or
    (Holiday_Flag = 1 and CTE.avg_Weekly_Sales = (select avg_Weekly_Sales from CTE_Holiday_1))
group by Holiday_Flag, CTE.avg_Weekly_Sales, CTE.avg_CPI;

