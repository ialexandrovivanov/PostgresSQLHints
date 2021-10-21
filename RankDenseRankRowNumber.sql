GO

CREATE TABLE Employee(  
    [EMPID] VARCHAR(30),  
    [Name] VARCHAR(150),  
    [Salary] DECIMAL(15, 2) 
)   

INSERT INTO [Employee] ([EMPID], [Name], [Salary]) VALUES ('EMP101', 'Vishal', 15000)  
INSERT INTO [Employee] ([EMPID], [Name], [Salary]) VALUES ('EMP102', 'Sam', 20000)  
INSERT INTO [Employee] ([EMPID], [Name], [Salary]) VALUES ('EMP105', 'Ravi', 10000)  
INSERT INTO [Employee] ([EMPID], [Name], [Salary]) VALUES ('EMP106', 'Mahesh', 18000)  
INSERT [dbo].[Employee] ([EMPID], [Name], [Salary]) VALUES ('EMP108', 'Rahul', 20000)  
INSERT [dbo].[Employee] ([EMPID], [Name], [Salary]) VALUES ('EMP109', 'menaka', 15000)  
INSERT [dbo].[Employee] ([EMPID], [Name], [Salary]) VALUES ('EMP111', 'akshay', 20000) 

UPDATE Employee SET Salary=20000 WHERE EMPID='EMP105'  

SELECT EMPID, Name, Salary,  
RANK() OVER(ORDER BY SALARY DESC) AS [Rank],  
DENSE_RANK () OVER(ORDER BY Salary DESC) AS DenseRank ,  
ROW_NUMBER() OVER(ORDER BY Salary DESC) AS RowNumber FROM Employee  

-------------------------------------------------------------------
RANK, DENSE_RANK

SELECT *, RANK() OVER(ORDER BY TYPE) RANK, 
          DENSE_RANK() OVER(ORDER BY TYPE) DENSE
  FROM Printer

CODE    MODEL   COLOR   TYPE    PRICE	RANK    DENSE
2	1433	y	Jet	270.00	1	1
3	1434	y	Jet	290.00	1	1
1	1276	n	Laser	400.00	3	2
6	1288	n	Laser	400.00	3	2
4	1401	n	Matrix	150.00	5	3
5	1408	n	Matrix	270.00	5	3

-------------------------------------------------------------------
ROW_NUMBER, RANK

SELECT *, ROW_NUMBER() OVER(ORDER BY type) num, 
RANK() OVER(ORDER BY type) rnk 
FROM Printer


code	model	color	type	price	num	rnk
2	1433	y	Jet	270.00	1	1
3	1434	y	Jet	290.00	2	1
1	1276	n	Laser	400.00	3	3
6	1288	n	Laser	400.00	4	3
4	1401	n	Matrix	150.00	5	5
5	1408	n	Matrix	270.00	6	5




