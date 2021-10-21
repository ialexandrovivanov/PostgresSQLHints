USE SoftUni

SELECT FirstName
FROM Employees
WHERE DepartmentID IN(3,10) AND HireDate BETWEEN '01-01-1995'AND '12-31-2005'

SELECT FirstName, LastName
FROM Employees
WHERE JobTitle NOT LIKE ('%engineer%')

SELECT [Name] FROM Towns
WHERE LEN([Name]) IN (5, 6) 
ORDER BY [Name]

SELECT * FROM Towns
WHERE [Name] LIKE '[MKBE]%'
ORDER BY [Name]

SELECT * FROM Towns
WHERE [Name] LIKE '[^RBD]%'
ORDER BY [Name]

GO
CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName
FROM Employees
WHERE HireDate > '01-01-2001'
GO
SELECT * FROM V_EmployeesHiredAfter2000

SELECT FirstName, LastName FROM Employees
WHERE LEN(LastName) = 5

SELECT * FROM(
   SELECT EmployeeID, FirstName, LastName, Salary,
       DENSE_RANK() OVER(
       PARTITION BY Salary
	ORDER BY EmployeeID) AS [Rank]
   FROM Employees) AS E
 WHERE E.Salary BETWEEN 10000 AND 50000 AND E.[Rank] = 2
 ORDER BY E.Salary DESC 

 USE [Geography]

 SELECT CountryName AS [Country Name], IsoCode AS [ISO Code] FROM Countries
 WHERE CountryName LIKE '%a%a%a%'
 ORDER BY IsoCode

 SELECT PeakName, RiverName, LOWER(SUBSTRING(PeakName,1, LEN(PeakName)-1)+ RiverName) AS [Mix] 
 FROM Peaks, Rivers
 WHERE RIGHT(PeakName, 1) = LEFT(RiverName,1)
 ORDER BY [Mix]

 USE Diablo

 SELECT TOP 50 [Name], FORMAT([Start], 'yyyy-MM-dd') AS [Start]
 FROM Games
 WHERE [Start] > '01-01-2011' AND [Start] < '12-31-2012'
 ORDER BY [Start]

 SELECT Username, SUBSTRING(Email, CHARINDEX('@', Email, 1) + 1, LEN(Email)) AS [Email Provider]
 FROM Users
 ORDER BY [Email Provider], Username

 SELECT Username, IpAddress FROM Users
 WHERE IpAddress LIKE '___.1%._%.___'
 ORDER BY Username

 SELECT * FROM Games

 USE ORDERS

SELECT ProductName,
   OrderDate, 
   DATEADD(DAY, 3, OrderDate) AS [Pay Due],
    DATEADD(MONTH, 1, OrderDate) AS [Deliver Due]
FROM Orders


USE Diablo

SELECT [Name],
	CASE
		WHEN DATEPART(HOUR, [Start]) >= 0 AND DATEPART(HOUR, [Start]) < 12 THEN 'Morning'
		WHEN DATEPART(HOUR, [Start]) >= 12 AND DATEPART(HOUR, [Start]) < 18 THEN 'Afternoon'
		ELSE 'Evning'
	END AS [Part of the Day],
	CASE 
		WHEN Duration <= 3 THEN 'Extra Short'
		WHEN Duration BETWEEN 4 AND 6 THEN 'Short'
		WHEN Duration > 6 THEN 'Long'
		ELSE 'Extra Long'
	END AS [Duration]
FROM Games
ORDER BY [Name], Duration
SELECT IIF(IsFinished = 1, 'Finished', 'Not Finished') FROM Games



