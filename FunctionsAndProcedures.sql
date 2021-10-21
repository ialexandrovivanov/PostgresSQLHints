USE SoftUni

SELECT TOP 5 E.EmployeeID, E.JobTitle, A.AddressID, A.AddressText	
  FROM Employees AS E
  JOIN Addresses AS A ON E.AddressID = A.AddressID 
ORDER BY A.AddressID

--•	FirstName
--•	LastName
--•	Town
--•	AddressText

SELECT TOP 50 E.FirstName, E.LastName, T.[Name], A.AddressText
  FROM Employees AS E
  JOIN Addresses AS A ON E.AddressID = A.AddressID
  JOIN Towns AS T ON A.TownID = T.TownID
ORDER BY E.FirstName, E.LastName


--•	EmployeeID
--•	FirstName
--•	LastName
--•	DepartmentName

SELECT  E.EmployeeID, E.FirstName, E.LastName, D.[Name] AS [DepartmentName]
  FROM Employees AS E
  JOIN Departments AS D ON E.DepartmentID = D.DepartmentID
 WHERE D.[Name] = 'Sales' 
ORDER BY E.EmployeeID


--•	EmployeeID
--•	FirstName
--•	Salary
--•	DepartmentName

SELECT TOP 5 E.EmployeeID, E.FirstName, E.Salary, D.[Name] 
  FROM Employees AS E
  JOIN Departments AS D ON E.DepartmentID = D.DepartmentID
  WHERE E.Salary > 15000
ORDER BY D.DepartmentID


--•	EmployeeID
--•	FirstName
--Filter only employees without a project. Return the first 3 rows sorted by EmployeeID in ascending order.

   SELECT TOP 3 E.EmployeeID, E.FirstName
     FROM Employees AS E
LEFT JOIN EmployeesProjects AS EP ON E.EmployeeID = EP.EmployeeID
    WHERE EP.EmployeeID IS NULL
 ORDER BY E.EmployeeID

--•	FirstName
--•	LastName
--•	HireDate
--•	DeptName
--Filter only employees hired after 1.1.1999 and are from either "Sales" or "Finance" departments, sorted by HireDate (ascending).


SELECT E.FirstName, E.LastName, E.HireDate, D.[Name] 
  FROM Employees AS E
  JOIN Departments AS D ON E.DepartmentID = D.DepartmentID
 WHERE E.HireDate > '1999-01-01' AND D.[Name] IN ('Sales', 'Finance')


--• EmployeeID
--•	FirstName
--•	ProjectName
--  Filter only employees with a project which has started after 13.08.2002 and it is still ongoing
-- (no end date). Return the first 5 rows sorted by EmployeeID in ascending order.

SELECT TOP 5 E.EmployeeID, E.FirstName, P.[Name] AS[ProjectName]
  FROM Employees AS E
  JOIN EmployeesProjects AS EP ON E.EmployeeID = EP.EmployeeID
  JOIN Projects AS P ON EP.ProjectID = P.ProjectID
 WHERE P.StartDate > '2002-08-13' AND P.EndDate IS NULL
ORDER BY E.EmployeeID


--•	EmployeeID
--•	FirstName
--•	ProjectName
--Filter all the projects of employee with Id 24. If the project has started during or after 2005 the returned value should be NULL.

SELECT E.EmployeeID, E.FirstName,
   CASE 
      WHEN P.StartDate > '2005-01-01' THEN NULL 
      ELSE P.[Name] 
   END AS [ProjectName]
  FROM Employees AS E
  JOIN EmployeesProjects AS EP ON E.EmployeeID = EP.EmployeeID
  JOIN Projects AS P ON EP.ProjectID = P.ProjectID
 WHERE E.EmployeeID = 24
 

--•EmployeeID			
--•	FirstName
--•	ManagerID
--•	ManagerName		                        	JOIN SELF REFERENCING
--Filter all employees with a manager who has ID equals to 3 or 7. Return all the rows, sorted by EmployeeID in ascending order.

SELECT EM.EmployeeID, EM.FirstName, EM.ManagerID, E.FirstName
  FROM Employees AS E
  JOIN Employees AS EM ON E.EmployeeID = EM.ManagerID
  WHERE E.EmployeeID IN (3,7)
ORDER BY EM.EmployeeID

--•	EmployeeID
--•	EmployeeName
--•	ManagerName
--•	DepartmentName
--Show first 50 employees with their managers and the departments they are in (show the departments of the employees). Order by EmployeeID.

SELECT TOP (50) EM.EmployeeID, CONCAT(EM.FirstName, ' ', EM.LastName) AS [EmployeeName], 
       CONCAT(E.FirstName, ' ', E.LastName) AS [ManagerName], D.[Name] AS [DepartmentName]
  FROM Employees AS E
  JOIN Employees AS EM ON E.EmployeeID = EM.ManagerID
  JOIN Departments AS D ON EM.DepartmentID = D.DepartmentID
ORDER BY EM.EmployeeID


--Write a query that returns the value of the lowest average salary of all departments.

SELECT TOP (1) AVG(Salary) AS [MinAverageSalary]
  FROM Employees
 GROUP BY DepartmentID
 ORDER BY AVG(Salary) 



USE Geography

--• CountryCode
--•	MountainRange
--•	PeakName
--•	Elevation
--Filter all peaks in Bulgaria with elevation over 2835. Return all the rows sorted by elevation in descending order.

SELECT C.CountryCode, M.MountainRange, P.PeakName, P.Elevation
  FROM Countries AS C
  JOIN MountainsCountries AS MC ON C.CountryCode = MC.CountryCode
  JOIN Mountains AS M ON MC.MountainId = M.Id
  JOIN Peaks AS P ON M.Id = P.MountainId
 WHERE P.Elevation > 2835 AND C.CountryCode = 'BG'
 ORDER BY P.Elevation DESC


--• CountryCode
--•	MountainRanges
--Filter the count of the mountain ranges in the United States, Russia and Bulgaria.

SELECT C.CountryCode, COUNT(M.Id) AS [MountainRanges]
  FROM Countries AS C
  JOIN MountainsCountries AS MC ON C.CountryCode = MC.CountryCode
  JOIN Mountains AS M ON MC.MountainId = M.Id
 WHERE C.CountryCode IN ('US','RU','BG')
 GROUP BY C.CountryCode

--•	CountryName
--•	RiverName
--Find the first 5 countries with or without rivers in Africa. Sort them by CountryName in ascending order.

SELECT TOP (5) C.CountryName, R.RiverName 
  FROM Countries AS C
  LEFT JOIN CountriesRivers AS CR ON C.CountryCode = CR.CountryCode
  LEFT JOIN Rivers AS R ON CR.RiverId = R.Id
 WHERE C.ContinentCode = 'AF'
 ORDER BY C.CountryName


--•	ContinentCode
--•	CurrencyCode
--•	CurrencyUsage
-- Find all continents and their most used currency.
-- Filter any currency that is used in only one country. Sort your results by ContinentCode.


SELECT A.ContinentCode, A.CurrencyCode, A.[Count] AS [CurrencyUsage] FROM (
  SELECT C.ContinentCode, C.CurrencyCode, COUNT(C.CurrencyCode) AS [Count],
   DENSE_RANK() OVER (PARTITION BY C.ContinentCode ORDER BY COUNT(C.CurrencyCode) DESC) AS [Rank] 
    FROM Countries AS C
   GROUP BY c.ContinentCode, c.CurrencyCode) AS A
WHERE A.[Rank] = 1 AND A.[Count] <> 1


-- Write a query that selects CountryCode. Find all the count of all countries, which don’t have a mountain.

SELECT COUNT(C.CountryCode) AS [CountryCode]
  FROM Countries AS C
  LEFT JOIN MountainsCountries AS MC ON C.CountryCode = MC.CountryCode
 WHERE MC.MountainId IS NULL
  

-- For each country, find the elevation of the highest peak and the length of the longest river, sorted by the highest peak elevation
-- (from highest to lowest), then by the longest river length 
-- (from longest to smallest), then by country name
-- (alphabetically). 
-- Display NULL when no data is available in some of the columns. Limit only the first 5 rows.

SELECT TOP (5) A.CountryName, A.MaxElevation AS [HighestPeakElevation], A.[MaxLength] AS LongestRiverLength  
  FROM (
   SELECT C.CountryName, P.PeakName, MAX(P.Elevation) AS [MaxElevation], MAX(R.[Length]) AS [MaxLength],
     DENSE_RANK() OVER (PARTITION BY C.CountryName ORDER BY P.Elevation DESC) AS [PeakRank],
     DENSE_RANK() OVER (PARTITION BY C.CountryName ORDER BY R.[Length] DESC) AS [RiverRank]
     FROM Countries AS C
     JOIN MountainsCountries AS MC ON C.CountryCode = MC.CountryCode
     JOIN Mountains AS M ON MC.MountainId = M.Id
     JOIN Peaks AS P ON M.Id = P.MountainId
     JOIN CountriesRivers AS CR ON C.CountryCode = CR.CountryCode
     JOIN Rivers AS R ON CR.RiverId = R.Id
    GROUP BY C.CountryName, P.PeakName, P.Elevation, R.[Length]) AS A
 WHERE A.[PeakRank] = 1 AND A.RiverRank = 1
 ORDER BY A.MaxElevation DESC, A.[MaxLength] DESC


 --For each country, find the name and elevation of the highest peak, along with its mountain. 
 --When no peaks are available in some country, display elevation 0, "(no highest peak)" as peak name and "(no mountain)" as mountain name.
 --When multiple peaks in some country have the same elevation, display all of them. Sort the results by country name alphabetically, 
 --then by highest peak name alphabetically. Limit only the first 5 rows.

SELECT TOP 5 A.CountryName, ISNULL(A.PeakName, '(no highest peak)') AS [Highest Peak Name],
	 ISNULL(A.MaxElevation, 0) AS [Highest Peak Elevation], ISNULL(A.MountainRange,'(no mountain)') AS [Mountain]
  FROM(
   SELECT C.CountryName, P.PeakName, MAX(P.Elevation) AS MaxElevation, M.MountainRange,
    DENSE_RANK() OVER (PARTITION BY C.CountryName ORDER BY P.Elevation DESC) AS [PeakRank]
     FROM Countries AS C
     LEFT JOIN MountainsCountries AS MC ON C.CountryCode = MC.CountryCode
     LEFT JOIN Mountains AS M ON MC.MountainId = M.Id
     LEFT JOIN Peaks AS P ON M.Id = P.MountainId
    GROUP BY C.CountryName, P.PeakName, M.MountainRange, P.Elevation) AS A
    WHERE A.PeakRank = 1
	ORDER BY A.CountryName, A.PeakName




--			HOMEWORK Functions And Procedures


USE SoftUni

-- Create stored procedure usp_GetEmployeesSalaryAbove35000 that returns all employees’
-- first and last names for whose salary is above 35000. 
GO
CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000 AS
	SELECT E.FirstName AS[First Name], E.LastName AS [Last Name]  
	  FROM Employees AS E		
	 WHERE E.Salary > 35000
GO;
EXEC usp_GetEmployeesSalaryAbove35000

 --Create stored procedure usp_GetEmployeesSalaryAboveNumber that accept a number (of type DECIMAL(18,4))
 --as parameter and returns all employees’ first and last names whose salary is above or equal to the given number. 

GO
CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber @Number DECIMAL(18, 4) AS
	SELECT E.FirstName AS[First Name], E.LastName AS [Last Name]  
	  FROM Employees AS E		
	 WHERE E.Salary >= @Number
GO;

-- Write a stored procedure usp_GetTownsStartingWith that accept string as parameter and returns all town names 
-- starting with that string. 

USE SoftUni

GO
CREATE PROCEDURE usp_GetTownsStartingWith @String VARCHAR(50) AS
	SELECT T.[Name] 
	  FROM Towns AS T
	 WHERE T.[Name] LIKE @String + '%'
GO

-- Write a stored procedure usp_GetEmployeesFromTown that accepts town name as parameter and return
-- the employees’ first and last name that live in the given town. 

GO
CREATE PROCEDURE usp_GetEmployeesFromTown @Town VARCHAR(50) AS
	SELECT FirstName AS [First Name], LastName AS [Last Name] 
	  FROM Employees AS E
	  JOIN Addresses AS A ON E.AddressID = A.AddressID
	  JOIN Towns AS T ON A.TownID = T.TownID
	 WHERE T.[Name] = @Town
GO

--  Write a function ufn_GetSalaryLevel(@salary DECIMAL(18,4)) that receives salary of an employee and returns the level of the salary.
--•	If salary is < 30000 return “Low”
--•	If salary is between 30000 and 50000 (inclusive) return “Average”
--•	If salary is > 50000 return “High”


GO
CREATE FUNCTION ufn_GetSalaryLevel (@Salary DECIMAL(15, 2)) 
RETURNS VARCHAR(20) 
AS BEGIN
   DECLARE @Result VARCHAR(20)
       SET @Result = (
		   CASE 
		     WHEN @Salary < 30000 THEN 'Low'
		     WHEN @Salary BETWEEN 30000 AND 50000 THEN 'Average'
		     ELSE 'High'
		   END)
   RETURN @Result
  END
GO

SELECT E.Salary, dbo.ufn_GetSalaryLevel(E.Salary) AS 'SalaryLevel'
  FROM Employees AS E


-- Write a stored procedure usp_EmployeesBySalaryLevel that receive as parameter level of salary
-- (low, average or high) and print the names of all employees that have given level of salary. You should use the function 
-- - “dbo.ufn_GetSalaryLevel(@Salary)”, which was part of the previous task, inside your “CREATE PROCEDURE …” query.

GO
CREATE PROCEDURE usp_EmployeesBySalaryLevel @Temp VARCHAR(20) AS
	SELECT E.FirstName, E.LastName
	  FROM Employees AS E
	 WHERE dbo.ufn_GetSalaryLevel(E.Salary) = @Temp
GO
EXEC usp_EmployeesBySalaryLevel @Temp = 'Low'


GO
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(50), @word VARCHAR(50)) 
RETURNS BIT
	AS BEGIN
	 DECLARE @Index INT, @Total INT, @Result BIT
	 SET @Index = 1
	 SET @Total = LEN(@word)
	  WHILE @Index <= @Total
		BEGIN
		  IF (CHARINDEX(SUBSTRING(@word, @Index, 1), @setOfLetters) >= 1)
		    BEGIN
		  	 SET @Result = 1
		    END
		  ELSE 
		    BEGIN
		  	 SET @Result = 0
			 RETURN  @Result
		    END
		  SET @Index += 1
		END
	  RETURN @Result
	END
GO

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'halves') AS [Result]


-- Write a procedure with the name usp_DeleteEmployeesFromDepartment (@departmentId INT) which deletes all Employees from a given department.
-- Delete these departments from the Departments table too. Finally SELECT the number of employees from the given department. 
-- If the delete statements are correct the select query should return 0.
-- After completing that exercise restore your database to revert all changes.
GO

BEGIN TRANSACTION
 GO
 CREATE PROCEDURE usp_DeleteEmployeesFromDepartment (@department INT) 
 AS BEGIN
	 DECLARE @departmentId INT 
	 SET  @departmentId = 2

	 DECLARE @delTargets TABLE(
              [Id]    INT,
              [Name]  VARCHAR(50),
              [DepartmentID] INT
			 )
 
	 INSERT INTO @delTargets
     SELECT e.[EmployeeID], d.[Name], d.[DepartmentID]
       FROM Employees AS E
       JOIN [Departments] AS D ON E.[DepartmentID] = D.[DepartmentID]
      WHERE D.DepartmentID = @departmentId
	  
      ALTER TABLE  Departments
      ALTER COLUMN [ManagerID] INT NULL
       
      DELETE FROM EmployeesProjects
      WHERE [EmployeeID] IN (SELECT [Id] FROM @delTargets)
                           
      UPDATE Employees SET [ManagerID] = NULL
       WHERE [ManagerID] IN (SELECT [Id] FROM @delTargets)
       
      UPDATE Departments SET [ManagerID] = NULL
       WHERE [ManagerID] IN (SELECT [Id] FROM @delTargets)
       
      DELETE FROM Employees
       WHERE [DepartmentID] IN (SELECT [DepartmentID] FROM @delTargets)
       
      DELETE FROM Departments
       WHERE [Name] IN (SELECT [Name] FROM @delTargets)

	  SELECT COUNT(E.DepartmentID) FROM Employees AS E WHERE DepartmentID = 2
END

EXEC  dbo.usp_DeleteEmployeesFromDepartment 2 
  
SELECT COUNT(Employees.DepartmentID) 
    FROM Employees 
   WHERE DepartmentID = 2

ROLLBACK

GO
 
 
 
USE SoftUni

GO
CREATE PROCEDURE usp_DeleteEmployeesFromDepartment (@departmentId INT) AS
	ALTER TABLE Employees
	DROP CONSTRAINT FK_Employees_Departments
	ALTER TABLE Employees
	DROP CONSTRAINT FK_Employees_Employees
	ALTER TABLE EmployeesProjects
	DROP CONSTRAINT FK_EmployeesProjects_Employees
	ALTER TABLE Departments
	DROP CONSTRAINT FK_Departments_Employees
	ALTER TABLE Employees
	ALTER COLUMN ManagerID INT
	DELETE FROM Departments  WHERE DepartmentID = @departmentId
	DELETE FROM Employees  WHERE DepartmentID = @departmentId
GO

SELECT * FROM Employees WHERE DepartmentID = 2

EXEC dbo.usp_DeleteEmployeesFromDepartment 2


USE Bank
--Problem 9. Find Full Name
--You are given a database schema with tables AccountHolders(Id (PK), FirstName, LastName, SSN) and Accounts(Id (PK), AccountHolderId (FK), Balance).  Write a stored procedure usp_GetHoldersFullName that selects the full names of all people. 

GO
CREATE OR ALTER PROCEDURE usp_GetHoldersFullName AS
  SELECT CONCAT(FirstName, ' ', LastName) AS [Full Name] 
    FROM AccountHolders

EXEC usp_GetHoldersFullName


--Problem 10. People with Balance Higher Than
--Your task is to create a stored procedure usp_GetHoldersWithBalanceHigherThan that accepts a number as a parameter and returns all people who have more money in total of all their accounts than the supplied number. Order them by first name, then by last name

GO
CREATE OR ALTER PROCEDURE usp_GetHoldersWithBalanceHigherThan(@Number DECIMAL(15, 2)) AS
	SELECT R.FirstName, R.LastName FROM(
	   SELECT AH.Id, AH.FirstName, AH.LastName, SUM(A.Balance) AS [TotalBalance] -- AH.Id for case we have two users with same name
	     FROM AccountHolders AS AH
		 JOIN Accounts AS A ON AH.Id = A.AccountHolderId
		GROUP BY FirstName, LastName, AH.Id) AS R
	   WHERE R.TotalBalance > @Number
	ORDER BY R.FirstName, R.LastName

EXEC usp_GetHoldersWithBalanceHigherThan 1000000.23

--Problem 11. Future Value Function
--Your task is to create a function ufn_CalculateFutureValue that accepts as parameters – sum (decimal), yearly interest rate (float) and number of years(int). It should calculate and return the future value of the initial sum rounded to the fourth digit after the decimal delimiter. Using the following formula:
--FV=I×(〖(1+R)〗^T)
--	I – Initial sum
--	R – Yearly interest rate
--	T – Number of years

GO
CREATE OR ALTER FUNCTION ufn_CalculateFutureValue(@Sum  DECIMAL(15, 4), @YearInterest FLOAT, @NumberYears INT) 
RETURNS DECIMAL(15, 4)
     AS BEGIN
     	DECLARE @Result DECIMAL(15, 4)
     	    SET @Result = @Sum * (POWER((1 + @YearInterest), @NumberYears))
       RETURN @Result
     END
GO

SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)

--Problem 12. Calculating Interest
--Your task is to create a stored procedure usp_CalculateFutureValueForAccount that uses the function from the previous problem to give an interest to a person's account for 5 years, along with information about his/her account id, first name, last name and current balance as it is shown in the example below. It should take the AccountId and the interest rate as parameters. Again you are provided with “dbo.ufn_CalculateFutureValue” function which was part of the previous task.
GO
CREATE PROCEDURE usp_CalculateFutureValueForAccount(@AccId INT, @InterestRate DECIMAL(15, 4)) AS
	SELECT A.Id AS [Account Id], 
		   AH.FirstName AS [First Name], 
		   AH.LastName AS [Last Name], 
		   A.Balance AS [Current Balance],
		   dbo.ufn_CalculateFutureValue(A.Balance, @InterestRate, 5) AS [Balance in 5 years]
	  FROM Accounts AS A
	  JOIN AccountHolders AS AH ON A.AccountHolderId = AH.Id
	 WHERE A.Id = @AccId 

EXEC dbo.usp_CalculateFutureValueForAccount 1, 0.1


GO
USE Diablo
--Problem 13. *Scalar Function: Cash in User Games Odd Rows
--Create a function ufn_CashInUsersGames that sums the cash of odd rows. Rows must be ordered by cash in descending order. The function should take a game name as a parameter and return the result as table. Submit only your function in.

DROP FUNCTION ufn_CashInUsersGames
GO
CREATE OR ALTER FUNCTION ufn_CashInUsersGames(@Input VARCHAR(MAX))
RETURNS TABLE
AS
RETURN
(
SELECT SUM(K.Cash) AS [SumCash]
  FROM
   (SELECT G.Id, UG.Cash, ROW_NUMBER() OVER (PARTITION BY G.Id ORDER BY UG.Cash DESC) AS [RowNumber]
      FROM Games AS G
      JOIN UsersGames AS UG ON G.Id = UG.GameId
      WHERE G.[Name] = @Input) AS K
   WHERE K.RowNumber % 2 <> 0 
)
GO

SELECT * FROM dbo.ufn_CashInUsersGames('Love in a mist')
SELECT * FROM GAMES



