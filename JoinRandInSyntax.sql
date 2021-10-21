CREATE DATABASE Instagram
CREATE TABLE Users(
	Id INT PRIMARY KEY IDENTITY,
	UserName VARCHAR(30) NOT NULL UNIQUE,
	[Password] BINARY(26) NOT NULL,
	ProfilePicture VARBINARY(MAX),
	LastLoginTime DATETIME,
	IsDeleted BIT NOT NULL
)

INSERT INTO Users(UserName, [Password], ProfilePicture, LastLoginTime, IsDeleted) 
VALUES
('Stamat', HASHBYTES('SHA1', '123'), NULL, CONVERT(datetime, '22-05-2018', 103), 0),
('Doncho', HASHBYTES('SHA1', '321'), NULL, CONVERT(datetime, '11-03-2018', 103), 0),
('Pesho', HASHBYTES('SHA1', '111'), NULL, CONVERT(datetime, '02-05-2018', 103), 0),
('Gosho', HASHBYTES('SHA1', '222'), NULL, CONVERT(datetime, '12-11-2018', 103), 0),
('Ivan', HASHBYTES('SHA1', '333'), NULL, CONVERT(datetime, '02-01-2018', 103), 0)

ALTER TABLE Users
ADD CONSTRAINT CHK_ProfilePicture CHECK(DATALENGTH(ProfilePicture) <= 900 * 1024)

ALTER TABLE Users
DROP CONSTRAINT PK__Users__3214EC07D4368478

ALTER TABLE Users
ADD CONSTRAINT PK_Users PRIMARY KEY(Id, UserName)

ALTER TABLE Users
ADD DEFAULT GETDATE() FOR LastLoginTime

INSERT INTO Users(UserName, [Password], ProfilePicture, IsDeleted) 
VALUES('Primat', HASHBYTES('SHA1', '123'), NULL, 0)

ALTER TABLE Users
ADD CONSTRAINT CHK_UserNameLength CHECK(LEN(UserName) >= 3)

CREATE TABLE Addresses(
	Id INT PRIMARY KEY IDENTITY,
	AddressId INT FOREIGN KEY REFERENCES Users(Id)	NOT NULL,
	AddressText NVARCHAR(50) NOT NULL
)

INSERT INTO Addresses(AddressId, AddressText)
VALUES (3, 'Sofia, bul. Carigradsko Shose 331')

SELECT UserName, Addresses.AddressText
  FROM Users
  JOIN  Addresses
    ON Users.Id = Addresses.Id

SELECT UserName + ' - ' + CONVERT(VARCHAR, LastLoginTime) AS [Last User Activity]
 FROM Users
ORDER BY LastLoginTime DESC

SELECT UserName
 FROM Users
WHERE NOT (Id = 1 OR Id = 4)  --not working

SELECT UserName
  FROM Users
 WHERE Id IN (1,2,3)

SELECT U.UserName, A.AddressText
  FROM Users AS U
  JOIN Addresses AS A
    ON A.AddressId = U.Id

SELECT FLOOR((RAND() * 100))