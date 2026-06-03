CREATE DATABASE ApexAUTO;
GO
USE ApexAUTO;
GO

CREATE TABLE Segments(
    Segment_ID INT PRIMARY KEY IDENTITY(1,1),
    Segment_Name NVARCHAR(20) UNIQUE NOT NULL,
    Daily_Base_Price DECIMAL(10,2) CHECK (Daily_Base_Price > 0),
    Min_Licence_Age INT DEFAULT 20 
);
GO

CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY IDENTITY(1,1),
    TC_No CHAR(11) UNIQUE NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    Surname NVARCHAR(50) NOT NULL,
    Phone_No VARCHAR(10),
    Email NVARCHAR(100) UNIQUE,
    Licence_No VARCHAR(20) UNIQUE NOT NULL,
    Registration_Date DATETIME DEFAULT GETDATE(),
    CONSTRAINT CHK_TC_No_Length CHECK (LEN(TC_No) = 11)
);
GO

CREATE TABLE Branches(
    Branch_ID INT PRIMARY KEY IDENTITY(1,1),
    Branch_Name NVARCHAR(50) NOT NULL,
    Branch_City NVARCHAR(20) NOT NULL,
    Branch_Address NVARCHAR(250) NOT NULL
);
GO

CREATE TABLE Insurance(
    Insurance_ID INT PRIMARY KEY IDENTITY(1,1),
    Insurance_Type NVARCHAR(50) NOT NULL,
    Daily_Fee DECIMAL (10,2) CHECK (Daily_Fee >= 0),
    Collateral_Limit DECIMAL(15,2)
);
GO

CREATE TABLE Extra_Services(
    Service_ID INT PRIMARY KEY IDENTITY (1,1),
    Service_Name NVARCHAR(50) NOT NULL,
    Service_Fee DECIMAL (10,2) CHECK (Service_Fee >=0)
);
GO

CREATE TABLE Cars (
    Car_ID INT PRIMARY KEY IDENTITY(1,1),
    Car_Brand NVARCHAR(50) NOT NULL,
    Car_Model NVARCHAR(50) NOT NULL,
    Car_Plate VARCHAR(15) UNIQUE NOT NULL,
    Car_Year INT NOT NULL,
    Car_State NVARCHAR(20) DEFAULT 'Available',
    Daily_Fee DECIMAL(10,2) NOT NULL,
    Segment_ID INT,
    CONSTRAINT CHK_Daily_Fee CHECK (Daily_Fee > 0),
    CONSTRAINT CHK_Car_State CHECK (Car_State IN ('Available','Rented','Maintenance')),
    CONSTRAINT FK_Cars_Segments FOREIGN KEY (Segment_ID) REFERENCES Segments(Segment_ID)
);
GO

CREATE TABLE Rental(
    Rent_ID INT PRIMARY KEY IDENTITY(1,1),
    Customer_ID INT FOREIGN KEY REFERENCES Customers(Customer_ID),
    CAR_ID INT FOREIGN KEY REFERENCES Cars(Car_ID),
    Branch_ID INT FOREIGN KEY REFERENCES Branches(Branch_ID),
    Insurance_ID INT FOREIGN KEY REFERENCES Insurance(Insurance_ID),
    Rent_Start_Date DATETIME NOT NULL,
    Rent_Finish_Date DATETIME NOT NULL,
    CONSTRAINT CHK_Dates CHECK (Rent_Finish_Date > Rent_Start_Date)
);
GO

CREATE TABLE Rental_Services(
    Rent_ID INT FOREIGN KEY REFERENCES Rental(Rent_ID),
    Service_ID INT FOREIGN KEY REFERENCES Extra_Services(Service_ID),
    PRIMARY KEY (Rent_ID, Service_ID)
);
GO

CREATE TABLE Pays(
    Pay_ID INT PRIMARY KEY IDENTITY(1,1),
    Rent_ID INT FOREIGN KEY REFERENCES Rental(Rent_ID),
    Amount DECIMAL(10,2) NOT NULL,
    Pay_Method NVARCHAR(30),
    Pay_Date DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Comments(
    Comment_ID INT PRIMARY KEY IDENTITY (1,1),
    Customer_ID INT FOREIGN KEY REFERENCES Customers(Customer_ID),
    Car_ID INT FOREIGN KEY REFERENCES Cars(Car_ID),
    Comment_Point INT CHECK (Comment_Point BETWEEN 1 AND 5),
    Comment_Date DATETIME DEFAULT GETDATE()
);
GO

-- VERİ EKLEME (INSERT) İŞLEMLERİ --

INSERT INTO Segments (Segment_Name, Daily_Base_Price, Min_Licence_Age) VALUES 
('Economy', 1000.00, 21),('Comfort', 1200.00, 23),('Business', 1500.00, 25),
('Luxury', 3400.00, 27),('SUV', 1400.00, 20),('Minivan',1000.00, 23),
('Sport',4320.00,25),('Electric',1800.00,20),('Pick-Up',1550.00,24),
('Premium SUV',2200.00,25);

INSERT INTO Insurance (Insurance_Type, Daily_Fee, Collateral_Limit) VALUES
('Standart',0.00,50000.00),('Mini Damage', 150.00,100000.00), ('Full Kasko', 400.00, 500000.00),
('Tire-Glass-Light', 100.00, 20000.00), ('Personal Accident', 80.00, 30000.00),
('Exemption-Free', 600.00, 1000000.00), ('Legal Support', 50.00, 15000.00),
('Theft Protection', 120.00, 40000.00), ('Roadside Assistance+', 70.00, 10000.00),
('All-In-One', 850.00, 2000000.00);

INSERT INTO Extra_Services (Service_Name, Service_Fee) VALUES 
('Child Seat', 100.00), ('Navigation/GPS', 50.00), ('Additional Driver', 150.00),
('Pocket Wi-Fi', 80.00), ('Snow Chains', 200.00), ('Roof Box', 250.00),
('Valet Service', 120.00), ('HGS Pass', 40.00), ('Full-to-Full Fuel', 0.00),
('Drop-off Different Branch', 500.00);

INSERT INTO Branches (Branch_Name, Branch_City, Branch_Address) VALUES 
('Umuttepe Main', 'Kocaeli', 'Kocaeli Uni. Umuttepe Yerleskesi'), ('Izmit Center', 'Kocaeli', 'Belen Mevkii'),
('Sabiha Gokcen AP', 'Istanbul', 'Pendik Havalimani'), ('Istanbul Airport', 'Istanbul', 'Arnavutkoy'),
('Kadikoy Port', 'Istanbul', 'Rihtim Cad.'), ('Gebze Technopark', 'Kocaeli', 'GOSB Teknopark'),
('Besiktas Square', 'Istanbul', 'Besiktas Meydan'), ('Bursa Center', 'Bursa', 'Nilufer'),
('Sakarya Serdivan', 'Sakarya', 'Mavi Durak'), ('Ankara Esenboga', 'Ankara', 'Akyurt');

INSERT INTO Customers (Name, Surname, TC_NO, Phone_No, Email, Licence_No) VALUES 
('Kevser', 'Yucedag', '12345678901', '5551112233', 'kevser@gmail.com','ABC123'), 
('Ahmet', 'Yilmaz', '98765432109', '5442223344',  'ahmet@gmail.com', 'XYZ987'),
('Havvanur', 'Bayramoğlu', '45612378905', '5334445566', 'havvanur@gmail.com','LMN456'), 
('Mehmet', 'Kaya', '78945612307','5056667788', 'mehmet@gmail.com', 'PRT789'),
('Zeynep', 'Öztürk', '32165498703','5328889900',  'zeynep@gmail.com', 'KJH321'), 
('Hüseyin', 'Mercimek', '65498732101', '5410001122','hüseyin@gmail.com', 'TYU654'),
('Elif', 'Aydin', '15975345685',  '5523334455', 'elif@gmail.com', 'BVC159'), 
('Burak', 'Bozkurt', '75315985241', '5067778899', 'burak@gmail.com', 'NMQ753'),
('Derya', 'Koç', '85296374125', '5371112233',  'derya@gmail.com', 'PLK852'), 
('Emre', 'Arslan', '96385274102',  '5454445566', 'emre@gmail.com', 'ZXC963');

INSERT INTO Cars (Car_Brand, Car_Model, Car_Plate, Car_Year, Car_State, Daily_Fee, Segment_ID) VALUES 
('Fiat', 'Egea', '34 ABC 123', 2023, 'Available', 600.00, 1),
('Renault', 'Megane', '41 KOÜ 001', 2024, 'Available', 900.00, 2),
('BMW', '520d', '34 BMW 520', 2022, 'Rented', 3500.00, 4),
('Volkswagen', 'Tiguan', '34 VW 789', 2023, 'Available', 1300.00, 5),
('Tesla', 'Model 3', '34 TS 003', 2024, 'Available', 1100.00, 8),
('Mercedes', 'C200', '06 MER 200', 2023, 'Available', 2800.00, 4),
('Toyota', 'Corolla', '34 TYT 111', 2023, 'Available', 750.00, 1),
('Porsche', 'Taycan', '34 POR 911', 2024, 'Maintenance', 5000.00, 7),
('Ford', 'Ranger', '41 FRD 041', 2022, 'Available', 1400.00, 9),
('Audi', 'Q7', '34 AUD 007', 2023, 'Available', 2700.00, 10);
GO

INSERT INTO Rental (Customer_ID, CAR_ID, Branch_ID, Insurance_ID, Rent_Start_Date, Rent_Finish_Date) VALUES 
(1, 1, 1, 3, '2026-05-10', '2026-05-15'), (2, 2, 2, 2, '2026-05-12', '2026-05-14'),
(3, 3, 3, 6, '2026-05-01', '2026-05-20'), (4, 4, 4, 1, '2026-05-14', '2026-05-16'),
(5, 5, 5, 10, '2026-05-15', '2026-05-18'), (6, 6, 6, 3, '2026-05-10', '2026-05-12'),
(7, 7, 1, 1, '2026-05-11', '2026-05-13'), (8, 9, 2, 5, '2026-05-14', '2026-05-15'),
(9, 10, 3, 3, '2026-05-12', '2026-05-14'), (10, 2, 4, 2, '2026-05-08', '2026-05-10');
GO

INSERT INTO Rental_Services(Rent_ID, Service_ID) VALUES 
(1, 1), (1, 2), 
(2, 3), (3, 4), (3, 5), (5, 7), (6, 8), (7, 2), (9, 10), (10, 3);
GO

INSERT INTO Pays (Rent_ID, Amount, Pay_Method, Pay_Date) VALUES 
(1, 3500.00, 'Credit Card', '2026-05-10'), (2, 1900.00, 'Cash', '2026-05-12'),
(3, 72000.00, 'Credit Card', '2026-05-01'), (4, 2600.00, 'Credit Card', '2026-05-14'),
(5, 5850.00, 'Cash', '2026-05-15'), (6, 6400.00, 'Credit Card', '2026-05-10'),
(7, 1500.00, 'Cash', '2026-05-11'), (8, 1480.00, 'Credit Card', '2026-05-14'),
(9, 6200.00, 'Credit Card', '2026-05-12'), (10, 2100.00, 'Cash', '2026-05-08');
GO

INSERT INTO Comments (Customer_ID, Car_ID, Comment_Point, Comment_Date) VALUES 
(1, 1, 5, '2026-05-15'), (2, 2, 4, '2026-05-14'),
(3, 3, 5, '2026-05-20'), (4, 4, 2, '2026-05-16'),
(5, 5, 5, '2026-05-18'), (6, 6, 3, '2026-05-12'),
(7, 7, 4, '2026-05-13'), (8, 9, 5, '2026-05-15'),
(9, 10, 4, '2026-05-14'), (10, 2, 1, '2026-05-10');
GO

SELECT * FROM Customers
SELECT * FROM Segments
SELECT * FROM Branches
SELECT * FROM Insurance
SELECT * FROM Extra_Services
SELECT * FROM Cars
SELECT * FROM Rental
SELECT * FROM Rental_Services
SELECT * FROM Pays
SELECT * FROM Comments
