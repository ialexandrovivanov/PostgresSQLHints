CREATE DATABASE School

CREATE TABLE Students(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	MiddleName NVARCHAR(30),
	LastName NVARCHAR(30) NOT NULL,
	Age INT CHECK(Age BETWEEN 5 AND 100),
	[Address] NVARCHAR(50),
	Phone CHAR(10)
)

CREATE TABLE Subjects(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	Lessons INT CHECK(Lessons > 0) NOT NULL
)

CREATE TABLE StudentsSubjects(
	Id INT PRIMARY KEY IDENTITY,
	StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
	SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL,
	Grade DECIMAL(15, 2) CHECK(Grade BETWEEN 2 AND 6) NOT NULL
)

CREATE TABLE Exams(
	Id INT PRIMARY KEY IDENTITY,
	[Date] DATETIME,
	SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL,
)

CREATE TABLE StudentsExams(
	StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
	ExamId INT FOREIGN KEY REFERENCES Exams(Id) NOT NULL,
	Grade DECIMAL(15, 2) CHECK(Grade BETWEEN 2 AND 6) NOT NULL
	PRIMARY KEY (StudentId, ExamId)
)

CREATE TABLE Teachers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	[Address] NVARCHAR(20) NOT NULL,
	Phone CHAR(10),
	SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)

CREATE TABLE StudentsTeachers(
	StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
	TeacherId INT FOREIGN KEY REFERENCES Teachers(Id) NOT NULL
	PRIMARY KEY (StudentId, TeacherId)
)

INSERT INTO Teachers
VALUES('Ruthanne',	'Bamb',	'84948 Mesta Junction',	3105500146,	6),
('Gerrard',	'Lowin',	'370 Talisman Plaza',	3324874824,	2),
('Merrile',	'Lambdin',	'81 Dahle Plaza',	4373065154,	5),
('Bert',	'Ivie',	'2 Gateway Circle',	4409584510,	4)

INSERT INTO Subjects
VALUES ('Geometry',	12),
('Health',	10),
('Drama',	7),
('Sports',	9)

--3. Update
--Make all grades 6.00, where the subject id is 1 or 2, if the grade is above or equal to 5.50

UPDATE StudentsSubjects
   SET Grade = 6
 WHERE SubjectId IN (1, 2) AND Grade >= 5.50

-- 4. Delete
--Delete all teachers, whose phone number contains ‘72’.
DELETE FROM StudentsTeachers WHERE TeacherId IN (SELECT Id FROM Teachers WHERE Phone LIKE '%72%')
DELETE FROM Teachers WHERE Phone LIKE '%72%'

--5. Teen Students
--Select all students who are teenagers (their age is above or equal to 12). Order them by first name (alphabetically), then by last name (alphabetically). Select their first name, last name and their age.

SELECT FirstName, LastName, Age
  FROM Students
 WHERE Age >= 12
 ORDER BY FirstName, LastName

--6. Cool Addresses
--Select all full names from students, whose address text contains ‘road’.
--Order them by first name (alphabetically), then by last name (alphabetically), then by address text (alphabetically).

SELECT FirstName + ' ' + MiddleName + ' ' +  LastName AS FULLNAME, Address
  FROM Students
 WHERE [Address] LIKE '%road%'
 ORDER BY FirstName, LastName, [Address]

--7. 42 Phones
--Select students with middle names whose phones starts with 42. Select their first name, address and phone number. Order them by first name alphabetically.

SELECT FirstName, Address, Phone
  FROM Students
 WHERE MiddleName IS NOT NULL AND Phone LIKE '42%'
 ORDER BY FirstName

-- 8. Students Teachers
--Select all students and the count of teachers each one has. 

SELECT S.FirstName, S.LastName, COUNT(T.Id)
  FROM Students AS S
  JOIN StudentsTeachers AS ST ON ST.StudentId = S.Id
  JOIN Teachers AS T ON T.Id = ST.TeacherId
 GROUP BY S.FirstName, S.LastName

-- 9. Subjects with Students
--Select all teachers’ full names and the subjects they teach with the count of lessons in each. Finally select the count of students each teacher has. Order them by students count descending.

SELECT T.FirstName + ' ' + T.LastName AS NAME, S.Name + '-' + CONVERT(VARCHAR, S.Lessons) AS SUBJECTS, COUNT(ST.StudentId) AS COUNT
  FROM Teachers AS T
  JOIN Subjects AS S ON S.Id = T.SubjectId
  JOIN StudentsTeachers AS ST ON ST.TeacherId = T.Id
 GROUP BY T.FirstName, T.LastName, S.Name, S.Lessons
 ORDER BY COUNT DESC, NAME, SUBJECTS

--   10. Students to Go
--Find all students, who have not attended an exam. Select their full name (first name + last name).
--Order the results by full name (ascending).

SELECT FirstName + ' ' + LastName AS FULLNAME 
  FROM Students 
 WHERE Id NOT IN(SELECT StudentId FROM StudentsExams)
 ORDER BY FULLNAME

-- 11. Busiest Teachers
--Find top 10 teachers with most students they teach. Select their first name, last name and the amount of students they have. Order them by students count (descending), then by first name (ascending), then by last name (ascending).

SELECT TOP 10 T.FirstName, T.LastName, COUNT(ST.StudentId) AS COUNT
  FROM StudentsTeachers AS ST
  JOIN Students AS S ON S.Id = ST.StudentId
  JOIN Teachers AS T ON T.Id = ST.TeacherId
  GROUP BY T.FirstName, T.LastName
  ORDER BY COUNT DESC, T.FirstName, T.LastName

--  12. Top Students
--Find top 10 students, who have highest average grades from the exams.
--Format the grade, two symbols after the decimal point.
--Order them by grade (descending), then by first name (ascending), then by last name (ascending)

SELECT TOP 10 S.FirstName, S.LastName, FORMAT(AVG(SE.Grade), 'N2') AS GRADE
  FROM StudentsExams AS SE
  JOIN Students AS S ON S.Id = SE.StudentId
  JOIN Exams AS E ON E.Id = SE.ExamId
 GROUP BY S.FirstName, S.LastName
 ORDER BY GRADE DESC, S.FirstName, S.LastName

-- 13. Second Highest Grade
--Find the second highest grade per student from all subjects. Sort them by first name (ascending), then by last name (ascending).

SELECT A.FirstName, A.LastName, A.Grade FROM(
  SELECT TOP 1000 S.FirstName, S.LastName, SS.Grade,
         ROW_NUMBER() OVER (PARTITION BY SS.StudentId ORDER BY SS.GRADE DESC) AS RANK
    FROM StudentsSubjects AS SS
    JOIN Students AS S ON S.Id = SS.StudentId
   ORDER BY SS.Grade DESC) AS A WHERE RANK = 2 ORDER BY A.FirstName, A.LastName

--   14. Not So In The Studying
--Find all students who don’t have any subjects. Select their full name. The full name is combination of first name, middle name and last name. Order the result by full name
--NOTE: If the middle name is null you have to concatenate the first name and last name separated with single space.

 SELECT S.FirstName + ' ' + IIF(S.MiddleName IS NULL, '', S.MiddleName + ' ') + S.LastName AS FULLNAME
   FROM Students AS S
  WHERE S.Id NOT IN (SELECT StudentId FROM StudentsSubjects)
  ORDER BY FULLNAME

--  15. Top Student per Teacher
--Find all teachers with their top students. The top student is the person with highest average grade. Select teacher full name (first name + last name), subject name, student full name (first name + last name) and corresponding grade. The grade must be formatted to the second digit after the decimal point.
--Sort the results by subject name (ascending), then by teacher full name (ascending), then by grade (descending)

SELECT A.TEACHERNAME, A.SUBJECT, A.STUDENTNAME, A.AVGGRADE FROM(
  SELECT CONCAT(T.FirstName,' ', T.LastName) AS TEACHERNAME, SU.Name AS SUBJECT, CONCAT(S.FirstName, ' ', S.LastName) AS STUDENTNAME,
         AVG(SS.Grade) AS AVGGRADE, DENSE_RANK() OVER (PARTITION BY T.FirstName, T.LastName, SU.Name ORDER BY AVG(SS.Grade) DESC) AS RANK
    FROM Students AS S
    JOIN StudentsSubjects AS SS ON SS.StudentId = S.Id
    JOIN Subjects AS SU ON SU.Id = SS.SubjectId
    JOIN StudentsTeachers AS ST ON ST.StudentId = S.Id
    JOIN Teachers AS T ON T.Id = ST.TeacherId
	GROUP BY T.FirstName, T.LastName, SU.Name, S.FirstName, S.LastName) AS A WHERE A.RANK = 1 ORDER BY A.SUBJECT, A.TEACHERNAME, A.AVGGRADE DESC                  -- NOT CORRECT SOLUTION

-- 16. Average Grade per Subject
--Find the average grade for each subject. Select the subject name and the average grade. 
--Sort them by subject id (ascending).

SELECT S.Name, AVG(SS.Grade) AS GRADE
  FROM StudentsSubjects AS SS
  JOIN Subjects AS S ON S.Id = SS.SubjectId
  GROUP BY S.Name, S.Id
  ORDER BY S.Id

--  17. Exams Information
--Divide the year in 4 quarters using the exam dates. For each quarter get the subject name and the count of students who took the exam with grade more or equal to 4.00. If the date is missing, replace it with “TBA”. Order them by quarter ascending.

SELECT CASE 
		 WHEN DATEPART(QUARTER, E.Date) = 1 THEN 'Q1'
		 WHEN DATEPART(QUARTER, E.Date) = 2 THEN 'Q2'
		 WHEN DATEPART(QUARTER, E.Date) = 3 THEN 'Q3'
		 WHEN DATEPART(QUARTER, E.Date) = 4 THEN 'Q4'
		 ELSE 'TBA'
	   END AS PART, S.Name, COUNT(SE.StudentId) AS COUNT
  FROM Exams AS E
  JOIN Subjects AS S ON S.Id = E.SubjectId
  JOIN StudentsExams AS SE ON SE.ExamId = E.Id
 WHERE SE.Grade >= 4
 GROUP BY CASE 
		 WHEN DATEPART(QUARTER, E.Date) = 1 THEN 'Q1'
		 WHEN DATEPART(QUARTER, E.Date) = 2 THEN 'Q2'
		 WHEN DATEPART(QUARTER, E.Date) = 3 THEN 'Q3'
		 WHEN DATEPART(QUARTER, E.Date) = 4 THEN 'Q4'
		 ELSE 'TBA'
	   END, S.Name
 ORDER BY PART

-- 18. Exam Grades
--Create a user defined function, named udf_ExamGradesToUpdate(@studentId, @grade), that receives a student id and grade.
--The function should return the count of grades, for the student with the given id, which are above the received grade and under the received grade with 0.50 added (example: you are given grade 3.50 and you have to find all grades for the provided student which are between 3.50 and 4.00 inclusive):
--If the condition is true, you must return following message in the format:
--•	 “You have to update {count} grades for the student {student first name}”
--If the provided student id is not in the database the function should return “The student with provided id does not exist in the school!”
--If the provided grade is above 6.00 the function should return “Grade cannot be above 6.00!”
--Note: Do not update any records in the database!

GO
CREATE  FUNCTION udf_ExamGradesToUpdate(@studentId INT, @grade DECIMAL(15, 2))
RETURNS VARCHAR(MAX)
		BEGIN
		 IF(@studentId NOT IN (SELECT StudentId FROM StudentsExams)) RETURN 'The student with provided id does not exist in the school!'
		 IF(@grade > 6) RETURN 'Grade cannot be above 6.00!'
		 DECLARE @Count INT = (SELECT COUNT(SE.Grade) 
							     FROM StudentsExams AS SE
			                     JOIN Students AS S ON S.Id = SE.StudentId
							    WHERE S.Id = @studentId AND SE.Grade BETWEEN @grade AND @GRADE + 0.5)

			RETURN 'You have to update ' + CONVERT(VARCHAR, @Count) + ' grades for the student ' + (SELECT FirstName FROM Students WHERE Id = @studentId)
		END
GO		
SELECT dbo.udf_ExamGradesToUpdate(12, 6.20)
SELECT dbo.udf_ExamGradesToUpdate(12, 5.50)
SELECT dbo.udf_ExamGradesToUpdate(121, 5.50)

--19. Exclude from school
--Create a user defined stored procedure, named usp_ExcludeFromSchool(@StudentId), that receives a student id and attempts to delete the current student. A student will only be deleted if all of these conditions pass:
--•	If the student doesn’t exist, then it cannot be deleted. Raise an error with the message “This school has no student with the provided id!”
--If all the above conditions pass, delete the student and ALL OF HIS REFERENCES!

GO
CREATE OR ALTER PROCEDURE usp_ExcludeFromSchool(@StudentId INT)
AS BEGIN
	IF(@StudentId NOT IN (SELECT Id FROM Students))BEGIN RAISERROR('This school has no student with the provided id!', 16, 1) RETURN END

	DELETE FROM StudentsExams WHERE StudentId = @StudentId
	DELETE FROM StudentsTeachers WHERE StudentId = @StudentId
	DELETE FROM StudentsSubjects WHERE StudentId = @StudentId
	DELETE FROM Students WHERE Id = @StudentId

END
EXEC usp_ExcludeFromSchool 1
SELECT COUNT(*) FROM Students


GO
CREATE TRIGGER TR_ONDELETE ON Students FOR DELETE
AS 
BEGIN 
    INSERT INTO ExcludedStudents
	SELECT Id, FirstName + ' ' + LastName FROM deleted
END