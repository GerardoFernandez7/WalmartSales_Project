-- 1. Data preprocessing
/*	a. Create a Backup
	b. Delete Duplicates
	c. Standardize the data
		- Data is sorted first by store number (ascending) and second by date (ascending)
		- Date is in the format MM-DD-YYYY
		- Weekly Sales is rounded to the nearest 2 decimal places
		- Temperature is rounded to the nearest whole number
		- Fuel Price is rounded to the nearest 2 decimal places
		- CPI is rounded to the nearest 3 decimal places
		- Unemployment is rounded to the nearest 3 decimal places
		- Convert Holiday_Flag to int
		- Ensure that there is no missing data
	d. Remove unnecesary columns or Rows */

# a. Create a Backup
create table clean_walmart_sales
like walmart_sales;

insert clean_walmart_sales
select *
from walmart_sales;

select * from clean_walmart_sales;

# b. Delete Duplicates
with duplicateCTE as 
(
select *, row_number() over(partition by Store, `Date`, Weekly_Sales, Holiday_Flag, Temperature, Fuel_Price, CPI, Unemployment) as row_num
from clean_walmart_sales
)
select *
from duplicateCTE
where row_num >=2
;

-- There aren't duplicates

# c. Standardize the data
-- Data is sorted first by store number (ascending) and second by date (ascending)
alter table clean_walmart_sales
order by Store asc, `Date`asc;

-- Date is in the format MM-DD-YYYY
select *, DATE_FORMAT(`Date`, '%m-%d-%Y')
from clean_walmart_sales;

alter table clean_walmart_sales
add column New_Date varchar(10);

update clean_walmart_sales
set New_Date = DATE_FORMAT(`Date`, '%m-%d-%Y');

alter table clean_walmart_sales drop `Date`;

alter table clean_walmart_sales change column New_Date `Date`varchar(10);

-- Weekly Sales is rounded to the nearest 2 decimal places
update clean_walmart_sales
set Weekly_Sales = round(Weekly_Sales, 2);

-- Temperature is rounded to the nearest whole number
update clean_walmart_sales
set Temperature = round(Temperature, 0);

-- Fuel Price is rounded to the nearest 2 decimal places
update clean_walmart_sales
set Fuel_Price = round(Fuel_Price, 2);

-- CPI is rounded to the nearest 3 decimal places
update clean_walmart_sales
set CPI = round(CPI, 3);

-- Unemployment is rounded to the nearest 3 decimal places
update clean_walmart_sales
set Unemployment = round(Unemployment, 3);

-- Convert Holiday_Flag to int
alter table clean_walmart_sales
modify column Holiday_Flag int;

-- Ensure that there is no missing data
select *
from clean_walmart_sales
where "" or "null" or "Null";

select *
from clean_walmart_sales
where Store is null or Weekly_Sales is null or Holiday_Flag is null or Temperature is null or Fuel_Price is null or CPI is null or 
Unemployment is null or `Date` is null;

# d. Remove unnecesary columns or Rows
-- All data is important here	
select *
from clean_walmart_sales;

