DROP DATABASE Supermarket
CREATE DATABASE Supermarket
USE Supermarket

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL
)

CREATE TABLE Items(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30)NOT NULL,
	Price DECIMAL(15, 2) NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Phone CHAR(12) NOT NULL,
	Salary DECIMAL(15, 2) NOT NULL
)

CREATE TABLE Orders(
	Id INT PRIMARY KEY IDENTITY,
	[DateTime] DATETIME NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
)

CREATE TABLE OrderItems(
	OrderId INT FOREIGN KEY REFERENCES Orders(Id) NOT NULL,
	ItemId INT FOREIGN KEY REFERENCES Items(Id) NOT NULL,
	Quantity INT NOT NULL CHECK(Quantity >= 1)  
	CONSTRAINT PK_OrderItems PRIMARY KEY(OrderId, ItemId)
)

CREATE TABLE Shifts(
	Id INT IDENTITY NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
	CheckIn DATETIME NOT NULL,
	CheckOut DATETIME NOT NULL
	CONSTRAINT PK_Shifts PRIMARY KEY(Id, EmployeeId)
)

ALTER TABLE Shifts
ADD CONSTRAINT CHK_INOUT CHECK(CheckIn < CheckOut)


INSERT INTO Employees
VALUES('Stoyan', 'Petrov', '888-785-8573', 500.25),
('Stamat',  'Nikolov', '789-613-1122', 999995.25),
('Evgeni', 'Petkov', '645-369-9517', 1234.51),
('Krasimir', 'Vidolov', '321-471-9982', 50.25)

INSERT INTO Items
VALUES ('Tesla battery', 154.25, 8),
('Chess', 30.25, 8),
('Juice', 5.32, 1),
('Glasses',	10,	8),
('Bottle of water',	1, 1)

--3. Update
--Make all items’ prices 27% more expensive where the category ID is either 1, 2 or 3.

UPDATE Items
   SET Price *= 1.27
 WHERE CategoryId IN (1, 2, 3)

--4. Delete
--Delete all order items where the order id is 48 (be careful with the relationships)

DELETE FROM OrderItems WHERE OrderId = 48
DELETE FROM Orders WHERE Id = 48


--5. Richest People
--Select all employees who have a salary above 6500. Order them by first name, then by employee id.

SELECT Id, FirstName FROM Employees WHERE Salary > 6500 ORDER BY FirstName, Id

--6. Cool Phone Numbers
--Select all full names from employees, whose phone number start with ‘3’.
--Order them by first name (ascending), then by phone number (ascending).

SELECT FirstName + ' ' + LastName AS [Full Name], Phone FROM Employees WHERE PHONE LIKE '3%' ORDER BY FirstName 

--7. Employee Statistics
--Select all employees who have orders with the total count of the orders they processed. Order them by their orders count (descending), then by first name. Select their first name, last name and total count of orders.

SELECT FirstName, LastName, COUNT(O.Id) AS [count]
  FROM Employees AS E
  JOIN Orders AS O ON O.EmployeeId = E.Id
 GROUP BY FirstName, LastName
 ORDER BY COUNT(O.Id) DESC, FirstName

-- 8. Hard Workers Club
--Select all employees whose workday is over 7 hours long on average, based on their check in/check out times. Select their first, last name and average work hours.
--Order them by work hours (descending), then by employee ID.

SELECT E.FirstName, E.LastName, AVG(DATEDIFF(HOUR, S.CheckIn, S.CheckOut))[Work hours]
  FROM Employees AS E
  JOIN Shifts AS S ON S.EmployeeId = E.Id
 GROUP BY E.FirstName, E.LastName, E.Id
 HAVING AVG(DATEDIFF(HOUR, S.CheckIn, S.CheckOut)) > 7
 ORDER BY [Work hours] DESC, E.Id


-- 9. The Most Expensive Order
--Find the most expensive order. Select its id and total item price. Consider the item quantity when calculating the price.

  SELECT TOP 1 O.Id, SUM(I.Price * OI.Quantity) AS [sum]
    FROM Orders AS O
    JOIN OrderItems AS OI ON OI.OrderId = O.Id
    JOIN Items AS I ON I.Id = OI.ItemId
   GROUP BY O.Id
   ORDER BY [sum] DESC
   
--10. Rich Item, Poor Item
--Find the top 10 most expensive and cheapest item in each order.
--Order the results by most expensive item’s price (descending), then by order id (ascending).

SELECT TOP 10 O.Id AS OrderId, MAX(I.Price) AS ExpensivePrice, MIN(I.Price) AS CheapPrice 
  FROM Orders AS O
  JOIN OrderItems AS OI ON OI.OrderId = O.Id
  JOIN Items AS I ON I.Id = OI.ItemId
 GROUP BY O.Id
 ORDER BY ExpensivePrice DESC, O.Id 

-- 11. Cashiers
--Find all employees who have orders. Select their id, first name and last name. Order them by employee id.

SELECT DISTINCT E.Id, FirstName AS [First Name], LastName AS [Last Name]
  FROM Employees AS E
  JOIN Orders AS O ON O.EmployeeId = E.Id
 WHERE O.Id IS NOT NULL
 ORDER BY E.Id

--12. Lazy Employees
--Find all employees, who have below 4 work hours per day.
--Order them by employee id.

SELECT DISTINCT E.Id, E.FirstName + ' ' + LastName AS [Full Name] 
  FROM Employees AS E
  JOIN Shifts AS S ON S.EmployeeId = E.Id
 WHERE DATEDIFF(HOUR, S.CheckIn, S.CheckOut) < 4
 ORDER BY E.Id

--13. Sellers
--Find the top 10 employees with their full name, orders’ total price and item count. 
--Count only orders which were ordered before 2018-06-15.
--Order them by total sum (descending), then by item count (descending)


SELECT TOP 10 E.FirstName + ' ' + E.LastName AS [Full Name],
       SUM(OI.Quantity  * I.Price) AS [Total Price],
       SUM(OI.Quantity) AS [Items]
  FROM Employees AS E
  JOIN Orders AS O ON O.EmployeeId = E.Id
  JOIN OrderItems AS OI ON OI.OrderId = O.Id
  JOIN Items AS I ON I.Id = OI.ItemId
 WHERE O.[DateTime] < '2018-06-15'
 GROUP BY E.FirstName + ' ' + E.LastName
 ORDER BY [Total Price] DESC,  [Items] DESC


--14. Tough days
--Find all records of the employees who don’t have orders and who work over 12 hours. 
--Select only their full name and day of the week.
--Order the results by employee id.
--Note: By the American Standards, Sunday is the first day of week.

SELECT A.[Full Name], A.[DayOfWeek] FROM(
   SELECT TOP 1000 E.Id, E.FirstName + ' ' + E.LastName AS [Full Name],
   	      DATENAME(WEEKDAY, S.CheckIn) [DayOfWeek]
     FROM Employees AS E
     LEFT JOIN Orders AS O ON O.EmployeeId = E.Id
     JOIN Shifts AS S ON S.EmployeeId = E.Id
    WHERE DATEDIFF(HOUR, S.CheckIn, S.CheckOut) > 12 AND O.Id IS NULL
    ORDER BY E.Id) AS A

--15. Top Order per Employee
--Find all information of the employees who have orders. Select their full name, duration of the work day (in hours) and total price of all sold products. Find only the top orders (top orders with highest total price).
--Sort them by full name (ascending), work hours (descending) and total price (descending)

SELECT E.FirstName + ' ' + E.LastName AS FullName,
	   DATEDIFF(HOUR, S.CheckIn, S.CheckOut) AS WorkHours,
	   A.TotalAmount	
  FROM (SELECT O.EmployeeId AS EMPID,
               O.DateTime AS [DATETIME],
  	           SUM(OI.Quantity  * I.Price) AS TotalAmount,
  	           ROW_NUMBER() OVER (PARTITION BY O.EmployeeId ORDER BY O.EmployeeId, SUM(OI.Quantity  * I.Price) DESC) AS ROWNUM
          FROM Orders AS O                          --START FROM ORDERS BECAUSE IT CONTAINS ONLY EMP ID WHO HAVE ORDERS
          JOIN OrderItems AS OI ON OI.OrderId = O.Id
          JOIN Items AS I ON I.Id = OI.ItemId
         GROUP BY O.EmployeeId, O.Id, O.[DateTime]) AS A
  JOIN Employees AS E ON E.Id = A.EMPID 
  JOIN Shifts AS S ON S.EmployeeId = A.EMPID
 WHERE A.ROWNUM = 1 AND A.DATETIME BETWEEN S.CheckIn AND S.CheckOut
 ORDER BY FullName, WorkHours DESC, TotalAmount DESC
 
-- 16. Average Profit per Day
--Find the average profit for each day. Select the day of month and average daily profit of sold products.
--Sort them by day of month (ascending) and format the profit to the second digit after the decimal point.

SELECT DATEPART(DAY, O.[DateTime]) AS [Day], FORMAT(AVG((OI.Quantity  * I.Price)),'N2') AS Average
  FROM OrderItems AS OI
  JOIN Orders AS O ON O.Id = OI.OrderId
  JOIN Items AS I ON I.Id = OI.ItemId
 GROUP BY DATEPART(DAY, O.[DateTime])
 ORDER BY [Day]

--Find information about all products. Select their name, category, how many of them were sold and the total profit they produced.
--Sort them by total profit (descending) and their count (descending)

    SELECT I.Name, C.Name, SUM(Quantity) ItemsSold, SUM(OI.Quantity  * I.Price) AS TotalAmount
      FROM OrderItems AS OI
 FULL JOIN Items AS I ON I.Id = OI.ItemId
 FULL JOIN Categories AS C ON I.CategoryId = C.Id
 FULL JOIN Orders AS O ON O.Id = OI.OrderId
  GROUP BY I.Name, C.Name
  ORDER BY TotalAmount DESC, ItemsSold DESC

--18. Promotion days
--Create a user defined function, named udf_GetPromotedProducts(@CurrentDate, @StartDate, @EndDate, @Discount, @FirstItemId, @SecondItemId, @ThirdItemId), that receives a current date, a start date for the promotion, an end date for the promotion, a discount, a first item id, a second item id and third item id.
--The function should print the discounted price of the items, based on these conditions:
--•	The first, second and third items must exist in the database.
--•	The current date must be between the start date and end date.
--If both conditions are true, you must discount the price and print the following message in the format:
--•	 “{FirstItemName} price: {@FirstItemPrice} <-> {SecondItemName} price: {@SecondItemPrice} <-> {ThirdItemName} price: {@ThirdItemPrice}”
--If one of the items is not in the database, the function should return “One of the items does not exists!”
--If the current date is not between the start date and end date, the function should return “The current date is not within the promotion dates!”
--Note: Do not update any records in the database!

GO
CREATE OR ALTER FUNCTION udf_GetPromotedProducts(@CurrentDate DATETIME, @StartDate DATETIME, @EndDateDATETIME DATETIME,
                                        @Discount DECIMAL(15, 2), @FirstItemId INT, @SecondItemId INT, @ThirdItemId INT)
RETURNS VARCHAR(MAX)
	BEGIN
		IF(@FirstItemId NOT IN (SELECT ItemId FROM OrderItems) 
		   OR @SecondItemId NOT IN (SELECT ItemId FROM OrderItems) 
		   OR @ThirdItemId NOT IN (SELECT ItemId FROM OrderItems)) RETURN 'One of the items does not exists!'

	    IF(@CurrentDate NOT BETWEEN @StartDate AND @EndDateDATETIME) RETURN 'The current date is not within the promotion dates!' 

		DECLARE @FirstPrice DECIMAL(15, 2) = (SELECT Price FROM Items WHERE Id = @FirstItemId)
		SET @FirstPrice = @FirstPrice - (@FirstPrice * @Discount / 100)

		DECLARE @SecondPrice DECIMAL(15, 2) = (SELECT Price FROM Items WHERE Id = @SecondItemId)
		SET @SecondPrice = @SecondPrice - (@SecondPrice * @Discount / 100)

		DECLARE @ThirdPrice DECIMAL(15, 2) = (SELECT Price FROM Items WHERE Id = @ThirdItemId)
		SET @ThirdPrice = @ThirdPrice - (@ThirdPrice * @Discount / 100)

		DECLARE @FirstName NVARCHAR(50) = (SELECT [Name] FROM Items WHERE Id = @FirstItemId)
		DECLARE @SecondName NVARCHAR(50) = (SELECT [Name] FROM Items WHERE Id = @SecondItemId)
		DECLARE @ThirdName NVARCHAR(50) = (SELECT [Name] FROM Items WHERE Id = @ThirdItemId)
		DECLARE @Result NVARCHAR(MAX) = @FirstName + ' price: ' + CONVERT(NVARCHAR(MAX), @FirstPrice) + ' <-> ' +
		                                @SecondName + ' price: ' + CONVERT(NVARCHAR(MAX),@SecondPrice) + ' <-> ' +
			                            @ThirdName + ' price: ' + CONVERT(NVARCHAR(MAX), @ThirdPrice)
		RETURN @Result
	END
GO

SELECT dbo.udf_GetPromotedProducts('2018-08-02', '2018-08-01', '2018-08-03',13, 3,4,5)

--19. Cancel order
--Create a user defined stored procedure, named usp_CancelOrder(@OrderId, @CancelDate), that receives an order id and date, and attempts to delete the current order. An order will only be deleted if all of these conditions pass:
--•	If the order doesn’t exists, then it cannot be deleted. Raise an error with the message “The order does not exist!”
--•	If the cancel date is 3 days after the issue date, raise an error with the message “You cannot cancel the order!”
--If all the above conditions pass, delete the order.

GO
CREATE PROCEDURE usp_CancelOrder(@OrderId INT, @CancelDate DATETIME) 
AS
	IF(@OrderId NOT IN (SELECT OrderId FROM OrderItems))
	BEGIN RAISERROR('The order does not exist!', 16, 1) RETURN END
	IF(DATEDIFF(DAY, (SELECT [DateTime] FROM Orders WHERE Id = @OrderId), @CancelDate) > 3)
	BEGIN RAISERROR('You cannot cancel the order!', 16, 2) RETURN END
	
	DELETE FROM OrderItems WHERE OrderId = @OrderId
	DELETE FROM Orders WHERE Id = @OrderId


EXEC usp_CancelOrder 1, '2018-06-02'
SELECT COUNT(*) FROM Orders
SELECT COUNT(*) FROM OrderItems

EXEC usp_CancelOrder 1, '2018-06-15'

EXEC usp_CancelOrder 124231, '2018-06-15'

--20. Deleted Order
--Create a new table “DeletedOrders” with columns (OrderId, ItemId, ItemQuantity). Create a trigger, which fires when order is deleted. After deleting the order, insert all of the data into the new table “DeletedOrders”.

DROP TABLE DeletedOrders
CREATE TABLE DeletedOrders(
	OrderId INT,
    ItemId INT,
    ItemQuantity INT
)

GO
CREATE TRIGGER TR_AFTERDELETE ON OrderItems AFTER DELETE
AS
	INSERT INTO DeletedOrders 
	SELECT OrderId, ItemId, Quantity FROM deleted


