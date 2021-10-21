--Problem 14. Create Table Logs
--Create a table – Logs (LogId, AccountId, OldSum, NewSum). Add a trigger to the Accounts table that enters a new entry into the Logs table every time the sum on an account changes. Submit only the query that creates the trigger.

USE Bank
DROP TABLE Logs

CREATE TABLE Logs(
	LogId INT PRIMARY KEY IDENTITY,
	AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
	OldSum DECIMAL(15, 2) NOT NULL,
	NewSum DECIMAL(15, 2) NOT NULL)

GO
CREATE TRIGGER TR_OnUpdate 
    ON Accounts FOR UPDATE
    AS 
		BEGIN
		   INSERT Logs(AccountId, OldSum, NewSum)
		   SELECT inserted.Id, deleted.Balance, inserted.Balance
			 FROM deleted, inserted
		END

GO
--Problem 15. Create Table Emails
--Create another table – NotificationEmails(Id, Recipient, Subject, Body). Add a trigger to logs table and create new email whenever new record is inserted in logs table. The following data is required to be filled for each email:
--•	Recipient – AccountId
--•	Subject – “Balance change for account: {AccountId}”
--•	Body - “On {date} your balance was changed from {old} to {new}.”

DROP TABLE NotificationEmails

CREATE TABLE NotificationEmails(
	Id INT PRIMARY KEY IDENTITY,
	Recipient VARCHAR(50) NOT NULL,
	[Subject] VARCHAR(100),
	Body VARCHAR(MAX)
)

GO
CREATE TRIGGER TR_OnInsert
    ON Logs AFTER INSERT
	AS
	  BEGIN
		INSERT NotificationEmails(Recipient, [Subject], Body)
		SELECT inserted.AccountId, 
			   CONCAT('Balance change for account: ', inserted.AccountId),
			   CONCAT('On', GETDATE(),' your balance was changed from ', inserted.OldSum, ' to ',inserted.NewSum, '.')
			   FROM inserted
	  END
GO

UPDATE Accounts
   SET Balance = 123.12
 WHERE Id = 1

 SELECT * FROM NotificationEmails

--Problem 16. Deposit Money
--Add stored procedure usp_DepositMoney (AccountId, MoneyAmount) that deposits money to an existing account. Make sure to guarantee valid positive MoneyAmount with precision up to fourth sign after decimal point. The procedure should produce exact results working with the specified precision.

GO
CREATE OR ALTER PROCEDURE usp_DepositMoney(@AccountId INT, @MoneyAmount DECIMAL(15, 4))
AS BEGIN TRAN
		   IF(@MoneyAmount > 0)
			BEGIN
			 UPDATE Accounts
			    SET Balance += @MoneyAmount
			  WHERE Id = @AccountId
		    END
	    COMMIT
	  END	
GO

--Problem 17. Withdraw Money
--Add stored procedure usp_WithdrawMoney (AccountId, MoneyAmount) that withdraws money from an existing account. Make sure to guarantee valid positive MoneyAmount with precision up to fourth sign after decimal point. The procedure should produce exact results working with the specified precision.

GO
CREATE OR ALTER PROCEDURE usp_WithdrawMoney(@AccountId INT, @MoneyAmount DECIMAL(15, 4))
AS BEGIN TRAN
		   IF(@MoneyAmount > 0 )
			BEGIN
			  UPDATE Accounts	
			     SET Balance -= @MoneyAmount
			   WHERE Id = @AccountId
			END
		   IF((SELECT Balance FROM Accounts WHERE Id = @AccountId) < 0) ROLLBACK 
		   ELSE COMMIT 
     END
GO
			
--Write stored procedure usp_TransferMoney(SenderId, ReceiverId, Amount) that transfers money from one account to another. Make sure to guarantee valid positive MoneyAmount with precision up to fourth sign after decimal point. Make sure that the whole procedure passes without errors and if error occurs make no change in the database. You can use both: “usp_DepositMoney”, “usp_WithdrawMoney” (look at previous two problems about those procedures). 

GO
CREATE OR ALTER PROCEDURE usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount DECIMAL(15, 4)) 
AS BEGIN 
      BEGIN TRAN
			IF(@Amount < 0 OR ((SELECT Balance FROM Accounts WHERE Id = @SenderId) - @Amount) < 0) ROLLBACK
			ELSE
			  BEGIN
			    UPDATE Accounts
			       SET Balance -=@Amount
				 WHERE Id = @SenderId
			    UPDATE Accounts	
			       SET Balance += @Amount
			     WHERE Id = @ReceiverId
			    COMMIT
			  END
	      END
GO  


EXEC usp_TransferMoney 1,2,10
EXEC usp_TransferMoney 2,1,10


--Problem 19. Trigger
--1. Users should not be allowed to buy items with higher level than their level. Create a trigger that restricts that. The trigger should prevent inserting items that are above specified level while allowing all others to be inserted.
USE Diablo

DROP TRIGGER TR_ONINSERT
GO
CREATE TRIGGER TR_ONINSERT ON UserGameItems INSTEAD OF INSERT 
AS
  DECLARE @InsertedUserGameId INT = (SELECT UserGameId FROM inserted)
  DECLARE @InsertedItemId INT = (SELECT ItemId FROM inserted)
  DECLARE @ItemLevel INT = (SELECT MinLevel FROM Items WHERE Id = @InsertedItemId)
  DECLARE @UserLevel INT = (SELECT Level FROM UsersGames WHERE Id = @InsertedUserGameId)
 
  IF(@UserLevel > @ItemLevel)
	BEGIN
	   INSERT INTO Test(ItemId, UserGameId)
	   SELECT ItemId, UserGameId FROM inserted
	  END
       

--2. Add bonus cash of 50000 to users: baleremuda, loosenoise, inguinalself, buildingdeltoid, monoxidecos in the game “Bali”.

SELECT Cash FROM UsersGames WHERE UserId IN (SELECT Id 
					FROM Users
				   WHERE Username IN ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos'))
			 AND GameId = 212

UPDATE UsersGames
   SET Cash += 50000
 WHERE UserId IN (SELECT Id 
					FROM Users
				   WHERE Username IN ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos'))
			 AND GameId = 212

--3. There are two groups of items that you must buy for the above users. The first are items with id between 251 and 299 including. Second group are items with id between 501 and 539 including.
GO
DECLARE @ItemIds TABLE( ItemId INT )
INSERT INTO @ItemIds
SELECT Id FROM Items WHERE Id BETWEEN 251 AND 299 OR Id BETWEEN 501 AND 539

DECLARE @UserIds TABLE ( UserId INT )
INSERT INTO @UserIds 
SELECT Id 
  FROM UsersGames 
 WHERE UserId IN (SELECT Id FROM Users WHERE Username IN ('loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
		     AND GameId = (SELECT Id FROM Games WHERE [Name] = 'Bali'))

INSERT INTO UserGameItems(UserGameId, ItemId)
SELECT *                	          --DECART FOREACH USER EACH OF THE ITEMS (UserGameId first, itemId second in SELECT) 
  FROM @UserIds, @ItemIds				    
GO
SELECT COUNT(*) FROM UserGameItems
--Take off cash from each user for the bought items.

UPDATE UsersGames
   SET Cash -= (SELECT SUM(I.Price)
                  FROM Items AS I
			     WHERE UserId IN (SELECT Id 
									FROM Users
								   WHERE Username IN ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')))
WHERE UserId IN (SELECT Id FROM Users WHERE Username IN('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos'))
  AND GameId = 212

--4. Select all users in the current game (“Bali”) with their items. Display username, game name, cash and item name. Sort the result by username alphabetically, then by item name alphabetically. 

SELECT U.Username, G.Name, UG.Cash, I.Name [Item Name]
  FROM UsersGames AS UG
  JOIN Users AS U ON U.Id = UG.UserId
  JOIN Games AS G ON G.Id = UG.GameId
  JOIN UserGameItems AS UGI ON UG.Id = UGI.UserGameId
  JOIN Items AS I ON I.Id = UGI.ItemId
 WHERE GameId = (SELECT Id FROM Games WHERE Name = 'Bali')
 ORDER BY [Username], [Item Name]

-- Problem 20. *Massive Shopping
--1. User Stamat in Safflower game wants to buy some items. He likes all items from Level 11 to 12 as well as all items from Level 19 to 21. As it is a bulk operation you have to use transactions. 
--2. A transaction is the operation of taking out the cash from the user in the current game as well as adding up the items. 
--3. Write transactions for each level range. If anything goes wrong turn back the changes inside of the transaction.
--4. Extract all of Stamat’s item names in the given game sorted by name alphabetically


DECLARE @UserId INT = (SELECT Id FROM Users WHERE Username = 'Stamat')
DECLARE @GameId INT = (SELECT Id FROM Games WHERE Name = 'Safflower')
DECLARE @UserGameId INT = (SELECT Id FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)
BEGIN TRY
BEGIN TRANSACTION 
	UPDATE UsersGames
	   SET Cash -= (SELECT SUM(Price) FROM Items WHERE MinLevel IN(11, 12))
	 WHERE Id = @UserGameId

	 DECLARE @Cash DECIMAL(15, 2) = (SELECT Cash FROM UsersGames WHERE Id = @UserGameId)

	 IF(@Cash < 0) BEGIN ROLLBACK RETURN END

	 INSERT INTO UserGameItems
	 SELECT Id, @UserGameId FROM Items WHERE MinLevel IN(11, 12)
COMMIT
END TRY
BEGIN CATCH
	ROLLBACK 
END CATCH

BEGIN TRY
BEGIN TRANSACTION 
	UPDATE UsersGames
	   SET Cash -= (SELECT SUM(Price) FROM Items WHERE MinLevel IN(19, 20, 21))
	 WHERE Id = @UserGameId

	 SET @Cash = (SELECT Cash FROM UsersGames WHERE Id = @UserGameId)

	 IF(@Cash < 0) BEGIN ROLLBACK RETURN END

	 INSERT INTO UserGameItems
	 SELECT Id, @UserGameId FROM Items WHERE MinLevel IN(19, 20, 21)
COMMIT
END TRY
BEGIN CATCH
	ROLLBACK 
END CATCH
SELECT I.[Name] AS [Item Name] 
  FROM Items AS I
  JOIN UserGameItems AS UGI ON UGI.ItemId = I.Id
 WHERE UserGameId = (SELECT Id FROM UsersGames WHERE UserId = (SELECT Id FROM Users WHERE Username = 'Stamat')
					    AND GameId = (SELECT Id FROM Games WHERE Name = 'Safflower'))
ORDER BY I.Name





USE SoftUni
--Problem 21. Employees with Three Projects
--Create a procedure usp_AssignProject(@emloyeeId, @projectID) that assigns projects to employee. If the employee has more than 3 project throw exception and rollback the changes. The exception message must be: "The employee has too many projects!" with Severity = 16, State = 1.

GO
CREATE PROCEDURE usp_AssignProject (@emloyeeId INT, @projectID INT) 
	AS BEGIN
      BEGIN TRAN
		DECLARE @EmpProjectNum INT = (SELECT A.[Count] FROM (SELECT EmployeeID, COUNT(ProjectID) AS [Count]
										FROM EmployeesProjects
									GROUP BY EmployeeID) AS A WHERE A.EmployeeID = @emloyeeId)

		IF(@EmpProjectNum >= 3)
		 BEGIN 
		   RAISERROR ('The employee has too many projects!', 16, 1)
		   ROLLBACK 
		 END

		INSERT INTO EmployeesProjects
		SELECT @emloyeeId, @projectID

	    COMMIT
      END
GO

EXEC usp_AssignProject 1, 33

--Problem 22. Delete Employees
--Create a table Deleted_Employees(EmployeeId PK, FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary) that will hold information about fired(deleted) employees from the Employees table. Add a trigger to Employees table that inserts the corresponding information about the deleted records in Deleted_Employees.


CREATE TABLE Deleted_Employees(
   EmployeeId INT PRIMARY KEY IDENTITY, 
   FirstName VARCHAR(50), 
   LastName VARCHAR(50), 
   MiddleName VARCHAR(50), 
   JobTitle VARCHAR(50), 
   DepartmentId INT FOREIGN KEY REFERENCES Departments(DepartmentID), 
   Salary DECIMAL(15, 4)
)

GO
CREATE TRIGGER TR_OnDelete ON Employees AFTER DELETE
	AS
	  BEGIN
		INSERT INTO Deleted_Employees
		SELECT FirstName, LastName, MiddleName, JobTitle, DepartmentID, Salary FROM deleted 
	  END

DELETE FROM Employees WHERE EmployeeID = 1
SELECT * FROM Deleted_Employees