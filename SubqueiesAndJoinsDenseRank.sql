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
 GROUP BY C.CountryName, R.RiverName
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

SELECT top (5) A.CountryName, ISNULL(A.PeakName, '(no highest peak)') AS [Highest Peak Name],
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






