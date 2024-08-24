SELECT * FROM chicago_crime limit 1 ;
SELECT * FROM chicago_socioeconomic_data limit 1 ;
SELECT * FROM chicago_public_schools limit 1 ;

-- Exercise 1: Using Joins

-- Write and execute a SQL query to list all crimes that took place at a school. Include case number, crime type and community name.Write and execute a SQL query to list all crimes that took place at a school. Include case number, crime type and community name.Write and execute a SQL query to list the school names, community names and average attendance for communities with a hardship index of 98.

select cp.NAME_OF_SCHOOL , cp.COMMUNITY_AREA_NAME , cp.AVERAGE_STUDENT_ATTENDANCE
from chicago_public_schools as cp
left join chicago_socioeconomic_data as cs 
on cp.COMMUNITY_AREA_NUMBER = cs.COMMUNITY_AREA_NUMBER
where cs.HARDSHIP_INDEX = 98

-- Write and execute a SQL query to list all crimes that took place at a school. Include case number, crime type and community name.

select cc.CASE_NUMBER ,	cc.PRIMARY_TYPE , cs.COMMUNITY_AREA_NAME
from chicago_crime as cc
left join chicago_socioeconomic_data as cs 
on cc.COMMUNITY_AREA_NUMBER = cs.COMMUNITY_AREA_NUMBER ;

-- Exercise 2: Creating a View

 -- Write and execute a SQL statement to create a view showing the columns listed in the following table, with new column names as shown in the second column.
 
 create view new_table AS
select NAME_OF_SCHOOL as School_Name , Safety_Icon as Safety_Rating , Family_Involvement_Icon	as  Family_Rating ,Environment_Icon  as  Environment_Rating , Instruction_Icon as Instruction_Rating , Leaders_Icon as Leaders_Rating , Teachers_Icon  as  Teachers_Rating
from chicago_public_schools ;

-- Write and execute a SQL statement that returns all of the columns from the view.

select * from new_table ;

-- Write and execute a SQL statement that returns just the school name and leaders rating from the view.

select School_Name , Leaders_Rating from new_table ;

-- Exercise 3: Creating a Stored Procedure

-- Write the structure of a query to create or replace a stored procedure called UPDATE_LEADERS_SCORE that takes a in_School_ID parameter as an integer and a in_Leader_Score parameter as an integer.
-- Inside your stored procedure, write a SQL statement to update the Leaders_Score field in the CHICAGO_PUBLIC_SCHOOLS table for the school identified by in_School_ID to the value in the in_Leader_Score parameter.
-- Inside your stored procedure, write a SQL IF statement to update the Leaders_Icon field in the CHICAGO_PUBLIC_SCHOOLS table for the school identified by in_School_ID using the following information.
-- Score lower limit	Score upper limit	Icon
-- 80	99	Very strong
-- 60	79	Strong
-- 40	59	Average
-- 20	39	Weak
-- 0	19	Very weak

Delimiter //
create PROCEDURE UPDATE_LEADERS_SCORE ( in in_School_ID int , in in_Leader_Score int ) 
begin 
 UPDATE chicago_public_schools
    SET Leader_Score = in_Leader_Score
    WHERE School_ID = in_School_ID ;
    
    UPDATE chicago_public_schools
    SET Leaders_Icon = CASE
        WHEN in_Leader_Score BETWEEN 80 AND 99 THEN 'Very strong'
        WHEN in_Leader_Score BETWEEN 60 AND 79 THEN 'Strong'
        WHEN in_Leader_Score BETWEEN 40 AND 59 THEN 'Average'
        WHEN in_Leader_Score BETWEEN 20 AND 39 THEN 'Weak'
        WHEN in_Leader_Score BETWEEN 0 AND 19 THEN 'Very weak'
        ELSE 'Unknown' -- In case the score is out of the expected range
    END
    WHERE School_ID = in_School_ID ;
    
 END //

DELIMITER ;


-- Write a query to call the stored procedure, passing a valid school ID and a leader score of 50, to check that the procedure works as expected.
 
 Call UPDATE_LEADERS_SCORE( 609993 , 65 );
 
 -- Update your stored procedure definition. Add a generic ELSE clause to the IF statement that rolls back the current work if the score did not fit any of the preceding categories.
 --         Update your stored procedure definition again. Add a statement to commit the current unit of work at the end of the procedure.

DELIMITER //

CREATE PROCEDURE UPDATE_LEADERS_SCORE(
    IN in_School_ID INT,
    IN in_Leader_Score INT
)
BEGIN
    DECLARE score_category VARCHAR(20);

    -- Start a transaction
    START TRANSACTION;

    -- Update the Leaders_Score field
    UPDATE CHICAGO_PUBLIC_SCHOOLS
    SET Leaders_Score = in_Leader_Score
    WHERE School_ID = in_School_ID;

    -- Determine the Leaders_Icon based on the Leader Score using IF statements
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
        SET score_category = 'Unknown'; -- Handles scores not fitting the predefined categories
    END IF;

    -- Decide whether to commit or rollback based on the score_category
    IF score_category = 'Unknown' THEN
        -- Rollback the transaction if the category is 'Unknown'
        ROLLBACK;
    ELSE
        -- Update the Leaders_Icon field
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET Leaders_Icon = score_category
        WHERE School_ID = in_School_ID;

        -- Commit the transaction if the category is valid
        COMMIT;
    END IF;
END //

DELIMITER ;
 
 