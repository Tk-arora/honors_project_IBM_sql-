# honors_project_IBM_sql-

Final Project: Advanced SQL Techniques


Scenario
You have to analyse the following datasets for the city of Chicago, as available on the Chicago City data portal.

Socioeconomic indicators in Chicago
Chicago public schools
Chicago crime data
Based on the information available in the different tables, you have to run specific queries using Advanced SQL techniques that generate the required result sets.

Objectives
After completing this lab, you will be able to:

Use joins to query data from multiple tables

Create and query views

Write and run stored procedures

Use transactions

Software Used in this Lab


# README: Chicago Public Schools and Crime Data Analysis with SQL

## Overview
This project involves analyzing datasets from the Chicago Crime Data, Socioeconomic Data, and Public Schools. Through SQL queries, views, and stored procedures, we explore relationships between these datasets and derive insights, such as crime incidents at schools, school attendance based on hardship index, and dynamically updating leader scores for schools.

## Datasets Used
1. **chicago_crime**: Crime data in Chicago.
   - Example query: `SELECT * FROM chicago_crime LIMIT 1;`
2. **chicago_socioeconomic_data**: Socioeconomic data by community area.
   - Example query: `SELECT * FROM chicago_socioeconomic_data LIMIT 1;`
3. **chicago_public_schools**: Data on Chicago public schools, including attendance, safety, and community details.
   - Example query: `SELECT * FROM chicago_public_schools LIMIT 1;`

## Exercises

### Exercise 1: Using Joins
1. **Query to List Crimes at Schools**  
   This query identifies crimes that took place at schools, including the case number, crime type, and community name.
   ```sql
   SELECT cc.CASE_NUMBER, cc.PRIMARY_TYPE, cs.COMMUNITY_AREA_NAME
   FROM chicago_crime AS cc
   LEFT JOIN chicago_socioeconomic_data AS cs 
   ON cc.COMMUNITY_AREA_NUMBER = cs.COMMUNITY_AREA_NUMBER;
   ```

2. **Query for Schools in High-Hardship Areas**  
   This query lists school names, community names, and average attendance for communities with a hardship index of 98.
   ```sql
   SELECT cp.NAME_OF_SCHOOL, cp.COMMUNITY_AREA_NAME, cp.AVERAGE_STUDENT_ATTENDANCE
   FROM chicago_public_schools AS cp
   LEFT JOIN chicago_socioeconomic_data AS cs 
   ON cp.COMMUNITY_AREA_NUMBER = cs.COMMUNITY_AREA_NUMBER
   WHERE cs.HARDSHIP_INDEX = 98;
   ```

### Exercise 2: Creating a View
1. **Create a View**  
   A view is created to show select columns from the `chicago_public_schools` table with new column names.
   ```sql
   CREATE VIEW new_table AS
   SELECT 
       NAME_OF_SCHOOL AS School_Name, 
       Safety_Icon AS Safety_Rating, 
       Family_Involvement_Icon AS Family_Rating, 
       Environment_Icon AS Environment_Rating, 
       Instruction_Icon AS Instruction_Rating, 
       Leaders_Icon AS Leaders_Rating, 
       Teachers_Icon AS Teachers_Rating
   FROM chicago_public_schools;
   ```

2. **Retrieve Data from the View**  
   This query returns all columns from the created view.
   ```sql
   SELECT * FROM new_table;
   ```

3. **Retrieve Specific Columns from the View**  
   Query to return only the school name and leaders rating from the view.
   ```sql
   SELECT School_Name, Leaders_Rating FROM new_table;
   ```

### Exercise 3: Creating a Stored Procedure
1. **Create a Stored Procedure for Leader Score Updates**  
   This procedure updates the `Leaders_Score` and `Leaders_Icon` for a school based on the given score.
   ```sql
   DELIMITER //
   CREATE PROCEDURE UPDATE_LEADERS_SCORE(
       IN in_School_ID INT,
       IN in_Leader_Score INT
   )
   BEGIN
       -- Update Leaders_Score
       UPDATE chicago_public_schools
       SET Leaders_Score = in_Leader_Score
       WHERE School_ID = in_School_ID;

       -- Update Leaders_Icon based on score
       UPDATE chicago_public_schools
       SET Leaders_Icon = CASE
           WHEN in_Leader_Score BETWEEN 80 AND 99 THEN 'Very strong'
           WHEN in_Leader_Score BETWEEN 60 AND 79 THEN 'Strong'
           WHEN in_Leader_Score BETWEEN 40 AND 59 THEN 'Average'
           WHEN in_Leader_Score BETWEEN 20 AND 39 THEN 'Weak'
           WHEN in_Leader_Score BETWEEN 0 AND 19 THEN 'Very weak'
           ELSE 'Unknown'
       END
       WHERE School_ID = in_School_ID;
   END //
   DELIMITER ;
   ```

2. **Call the Stored Procedure**  
   A sample query to call the stored procedure and update the leader score for a specific school:
   ```sql
   CALL UPDATE_LEADERS_SCORE(609993, 65);
   ```

3. **Enhanced Stored Procedure with Transaction Management**  
   The updated stored procedure includes transaction handling, rolling back changes if the leader score is invalid.
   ```sql
   DELIMITER //
   CREATE PROCEDURE UPDATE_LEADERS_SCORE(
       IN in_School_ID INT,
       IN in_Leader_Score INT
   )
   BEGIN
       DECLARE score_category VARCHAR(20);
       START TRANSACTION;

       -- Update Leaders_Score
       UPDATE chicago_public_schools
       SET Leaders_Score = in_Leader_Score
       WHERE School_ID = in_School_ID;

       -- Determine Leaders_Icon
       IF in_Leader_Score BETWEEN 80 AND 99 THEN
           SET score_category = 'Very strong';
       ELSEIF in_Leader_Score BETWEEN 60 AND 79 THEN
           SET score_category = 'Strong';
       ELSEIF in_Leader_Score BETWEEN 40 AND 59 THEN
           SET score_category = 'Average';
       ELSEIF in_Leader_Score BETWEEN 20 AND 39 THEN
           SET score_category = 'Weak';
       ELSEIF in_Leader_Score BETWEEN 0 AND 19 THEN
           SET score_category = 'Very weak';
       ELSE
           SET score_category = 'Unknown';
       END IF;

       IF score_category = 'Unknown' THEN
           ROLLBACK;
       ELSE
           -- Update Leaders_Icon
           UPDATE chicago_public_schools
           SET Leaders_Icon = score_category
           WHERE School_ID = in_School_ID;
           COMMIT;
       END IF;
   END //
   DELIMITER ;
   ```

## Conclusion
This project demonstrates SQL skills in data analysis and manipulation, using various concepts such as joins, views, stored procedures, and transactions to gain insights from the Chicago Crime and Public Schools data.
