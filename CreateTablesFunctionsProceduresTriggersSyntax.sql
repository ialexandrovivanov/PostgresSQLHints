CREATE TABLE AccountTypes(
  Id INT PRIMARY KEY IDENTITY,
  [Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Account (
  Id INT PRIMARY KEY IDENTITY,
  AccountTypeId INT FOREIGN KEY REFERENCES AccountTypes(Id),
  Balance DECIMAL(15, 2) NOT NULL Default(0),
  ClientId INT FOREIGN KEY REFERENCES Clients(Id)
)

INSERT INTO Clients (FirstName, LastName) VALUES ('Dancho', 'Geshev'), ('Gosho', 'Goshev'), ('Ivan', 'Petkov')  
SELECT * FROM Clients
SELECT FirstName, Id FROM Clients

INSERT INTO Clients (FirstName, LastName) VALUES ('Dancho', 'Ivanov')

SELECT DISTINCT FirstName FROM Clients

sp_rename 'PK__Clients__3214EC07E30FBBA0', 'PK__Clients'                              			     Rename PK
GO
sp_rename 'PK__AccountT__3214EC070F614275', 'PK__Account'

INSERT INTO AccountTypes([Name]) VALUES('Saving')
INSERT INTO AccountTypes([Name]) VALUES('Paying')

SELECT * FROM Account

INSERT INTO Account (AccountTypeId, ClientId) VALUES(2, 4)

EXEC sp_fkeys 'Account'
EXEC sp_help  'Account'
ALTER TABLE [Account] ALTER COLUMN [AccountTypeId] INT NOT NULL FOREIGN KEY REFERENCES AccountTypes(Id) 
EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"

ALTER TABLE Account ALTER COLUMN AccountTypeId NOT NULL
UPDATE Account SET AccountTypeId = 0 WHERE AccountTypeId IS NULL
SELECT * FROM Accounts

CREATE TABLE Accounts(
	Id INT PRIMARY KEY IDENTITY,
	AccountTypeId INT NOT NULL FOREIGN KEY REFERENCES Account(Id),
	Balance DECIMAL(15, 2) NOT NULL DEFAULT(0),
	ClientId INT FOREIGN KEY REFERENCES Clients(Id) NOT NULL,
)

CREATE TABLE Accounts(
	Id PRIMARY KEY IDENTITY,
	Balance DECIMAL(15, 2) DEFAULT(0) NOT NULL,
	ClientId INT FOREIGN KEY REFERENCES Clients(Id) NOT NULL,
	AccountTypeId INT FOREIGN KEY REFERENCES AccountTypes(Id) NOT NULL
)

CREATE DATABASE Bank
CREATE TABLE Clients(
	Id INT IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	SecondName NVARCHAR(50) NOT NULL,
	CONSTRAINT PK_ClientId PRIMARY KEY (Id) 
)

SELECT * FROM Clients
INSERT INTO Clients(FirstName, SecondName) VALUES('Tosho', 'Geshev')

CREATE TABLE Accounts(
	Id INT IDENTITY,
	Balance DECIMAL(15, 2) NOT NULL DEFAULT(0),
	ClientId INT NOT NULL FOREIGN KEY REFERENCES Clients(Id),
	AccTypeId INT NOT NULL FOREIGN KEY REFERENCES AccountTypes(Id),
	CONSTRAINT PK_AccTypeId PRIMARY KEY (Id)
)

INSERT INTO AccountTypes([Type]) VALUES('Saving'), ('Paying')
INSERT INTO Accounts(Balance, ClientId, AccTypeId) VALUES(1670.63, 3, 2)
SELECT * FROM Accounts

GO 												Procedure
CREATE PROCEDURE P_AddAccount @Balance DECIMAL(15, 2), @ClientId INT, @AccTypeId INT AS
INSERT INTO Accounts(Balance, ClientId, AccTypeId)
VALUES (@Balance, @ClientId, @AccTypeId)

P_AddAccount 350.20, 4, 1									Using Procedure

GO												Function
CREATE FUNCTION f_CalculateTotalBalance(@ClientId INT)
RETURNS DECIMAL(15, 2)
BEGIN
	DECLARE @result AS DECIMAL(15, 2) = (
		SELECT SUM(Balance)
		FROM Accounts
		WHERE ClientId = @ClientId
	)
	RETURN @result
END

SELECT [dbo].f_CalculateTotalBalance(2) AS TotalBalance						Using Function 

GO
CREATE PROCEDURE p_DepositToAccount(@AccountId INT, @Amount DECIMAL(15, 2)) AS                  Procedure For Deposit
UPDATE Accounts
SET Balance += @Amount
WHERE Id = @AccountId

p_DepositToAccount 2, 280.00

CREATE PROC p_WithdrawFromAccount(@AccountId INT, @Amount DECIMAL(15, 2)) AS                    Procedure For Withdraw Conditional
BEGIN
DECLARE @OldBalance DECIMAL(15, 2)
SELECT @OldBalance = Balance FROM Accounts WHERE Id = @AccountId
IF(@OldBalance - @Amount >= 0)
	BEGIN
		UPDATE Accounts
		SET Balance -= @Amount
		WHERE Id = @AccountId
	END
ELSE
	BEGIN
		RAISERROR('Insuficient funds', 10, 1)
	END
END

p_WithdrawFromAccount 3, 274.00									Using Withdraw Procedure

CREATE TRIGGER tr_Transaction ON Accounts							Trriger For Any Changes ON TABLE Accounts
AFTER UPDATE
AS
	INSERT INTO Transactions(OldBalance, NewBalance, [DateTime])
	SELECT deleted.Balance, inserted.Balance, GETDATE() FROM inserted
	JOIN deleted ON inserted.Id = deleted.Id

p_DepositToAccount 4, 280.00
SELECT * FROM Transactions

-- Balance DECIMAL(15, 2) NOT NULL CHECK(Balance >= 0)						Check Constraint When Initializing TABLE