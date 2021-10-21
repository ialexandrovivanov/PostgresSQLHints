USE Gringotts

SELECT COUNT(Id) AS	[Count] 
  FROM WizzardDeposits


SELECT MAX(MagicWandSize) AS[LongestMagicWand] FROM WizzardDeposits


SELECT DepositGroup, MAX(MagicWandSize) AS [LongestMagicWand]
  FROM WizzardDeposits
 GROUP BY DepositGroup


 SELECT TOP 2 DepositGroup
 FROM WizzardDeposits
 GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)

SELECT * FROM(
SELECT DepositGroup, SUM(DepositAmount) AS [TotalSum]
 FROM WizzardDeposits
  WHERE MagicWandCreator = 'Ollivander family'
 GROUP BY DepositGroup) AS D
 WHERE D.TotalSum < 150000
 ORDER BY D.TotalSum DESC

 
 SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge)  AS [MinDepositCharge]
  FROM WizzardDeposits
 GROUP BY DepositGroup, MagicWandCreator
 ORDER BY MagicWandCreator, DepositGroup



SELECT A.AgeGroup, COUNT(*) AS [WizardCount] FROM(
 SELECT 
	CASE
	  WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
	  WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
	  WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
	  WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
	  WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
	  WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
	  ELSE '[61+]'
	END AS [AgeGroup]
	FROM WizzardDeposits) AS A
GROUP BY A.AgeGroup


SELECT DISTINCT LEFT(FirstName, 1) FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'


SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest) AS [AverageInterest] 
  FROM WizzardDeposits
 WHERE DepositStartDate >= '01/01/1985'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired


SELECT SUM(A.C) FROM(
SELECT DepositAmount - (SELECT DepositAmount FROM WizzardDeposits WHERE Id = Host.Id + 1 ) AS C
  FROM WizzardDeposits AS Host) AS A

SELECT SUM(A.D) FROM(
SELECT DepositAmount - LEAD(DepositAmount, 1) OVER (ORDER BY Id) AS D 
FROM WizzardDeposits) AS A                    -- THE SAME AS ABOVE, LAG(DepositAmount, 1) takes 1 record behind

USE SoftUni 

SELECT DepartmentID, SUM(Salary) AS [TotalSalary] FROM Employees
GROUP BY DepartmentID

SELECT DepartmentID, MIN(Salary) AS [MinimumSalary]
  FROM Employees
 WHERE HireDate >= '01-01-2000' AND DepartmentID IN (2,5,7)
 GROUP BY DepartmentID
  

SELECT * INTO NewTable 
  FROM Employees	
  WHERE Salary > 30000

DELETE FROM NewTable
 WHERE ManagerID = 42

UPDATE NewTable
   SET Salary += 5000
 WHERE DepartmentID = 1

 SELECT DepartmentID, AVG(Salary) AS [AverageSalary]
   FROM NewTable
  GROUP BY DepartmentID



SELECT * FROM(
SELECT DepartmentID, MAX(Salary) AS [MaxSalary]
  FROM Employees
 GROUP BY DepartmentID) AS A
 WHERE A.MaxSalary NOT BETWEEN 30000 AND 70000
  


SELECT COUNT(*) AS [Count] FROM Employees
 WHERE ManagerID IS NULL



 SELECT DISTINCT DepartmentID, Salary FROM(
 SELECT DepartmentID, Salary, DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS [SalaryRank]
   FROM Employees) AS A
  WHERE A.SalaryRank = 3



 SELECT TOP(10) FirstName, LastName, DepartmentID 
   FROM Employees AS EMP
   WHERE Salary > (SELECT AVG(Salary) 
					 FROM Employees
					 GROUP BY DepartmentID
					 HAVING DepartmentID = EMP.DepartmentID)
ORDER BY DepartmentID


SELECT E.Salary, E.DepartmentID, D.[Name] AS [Department Name]
  FROM Employees AS E, Departments AS D
  JOIN Employees ON Employees.DepartmentID = D.DepartmentID
GROUP BY E.DepartmentID, D.[Name], E.Salary
ORDER BY E.Salary DESC














