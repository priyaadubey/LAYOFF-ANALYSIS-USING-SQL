# LAYOFF-ANALYSIS-USING-SQL
##  Project Overview  
This project analyzes **global layoffs** using **SQL** covering **data cleaning, exploratory data analysis (EDA), advanced analytics and automation with triggers and stored procedures**. The objective is to extract meaningful insights and automate key operations using **MySQL**.  

##  Technologies Used  
- **MySQL**  
- **CTEs & Window Functions**  
- **Stored Procedures & Triggers**  

---

##  Steps in Analysis  

###  1. **Data Cleaning & Standardization**  
- **Removed duplicates** using window functions.  
- **Trimmed whitespace** and standardized text fields (e.g., "Crypto currency","Crypto" and "Crypto " → "Crypto").  
- **Fixed incorrect country names** (e.g., "United States." → "United States").  
- **Converted date column** into proper `DATE` format.  
- **Handled missing/null values** for improved data accuracy.  

###  2. **Exploratory Data Analysis (EDA)**  
- **Identified total layoffs & percentage trends.**  
- **Ranked top companies with the highest layoffs.**  
- **Analyzed industry & country-wise layoff distributions.**  
- **Tracked layoffs based on company funding stage.**  
- **Examined yearly layoff trends.**  

###  3. **Advanced SQL Analysis**  
- **Rolling 3-Month Layoff Trends:** Used window functions to smooth layoffs over time.  
- **Top 3 Companies by Layoffs Per Year:** Identified companies with the highest layoffs annually.  
- **Layoff Recovery Analysis:** Found companies that **re-hired** employees after layoffs.  
- **Industry Year-Over-Year Layoff Changes:** Detected industries most affected by layoffs over time.  
- **Country Layoff Share:** Measured each country's contribution to total layoffs.  

###  4. **Automating Data Operations**  
- **Trigger for Layoff Logging:** Automatically logs new layoffs into a separate table for record-keeping.  
- **Stored Procedure for Layoff Prediction:** Forecasts layoffs for the next year based on a user-defined growth factor.  

---



