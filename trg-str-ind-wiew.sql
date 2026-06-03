USE ApexAUTO;
GO

CREATE VIEW vw_RentalDetails AS
SELECT r.Rent_ID, 
       c.Name + ' ' + c.Surname AS CustomerName, 
       c.Phone_No, 
       cr.Car_Brand + ' ' + cr.Car_Model AS CarInfo, 
       cr.Car_Plate, 
       b.Branch_Name, 
       r.Rent_Start_Date, 
       r.Rent_Finish_Date
FROM Rental r
JOIN Customers c ON r.Customer_ID = c.Customer_ID
JOIN Cars cr ON r.CAR_ID = cr.Car_ID
JOIN Branches b ON r.Branch_ID = b.Branch_ID;
GO

CREATE VIEW vw_CarPricing AS
SELECT c.Car_Brand, 
       c.Car_Model, 
       c.Car_Plate, 
       s.Segment_Name, 
       s.Daily_Base_Price, 
       c.Daily_Fee, 
       c.Car_State
FROM Cars c
JOIN Segments s ON c.Segment_ID = s.Segment_ID;
GO



CREATE PROCEDURE sp_GetAvailableCars
    @SegmentID INT
AS
BEGIN
    SELECT Car_ID, Car_Brand, Car_Model, Car_Plate, Daily_Fee
    FROM Cars
    WHERE Segment_ID = @SegmentID AND Car_State = 'Available';
END;
GO

CREATE PROCEDURE sp_AddRental
    @CustomerID INT,
    @CarID INT,
    @BranchID INT,
    @InsuranceID INT,
    @StartDate DATETIME,
    @FinishDate DATETIME
AS
BEGIN
    INSERT INTO Rental (Customer_ID, CAR_ID, Branch_ID, Insurance_ID, Rent_Start_Date, Rent_Finish_Date)
    VALUES (@CustomerID, @CarID, @BranchID, @InsuranceID, @StartDate, @FinishDate);
END;
GO





CREATE TRIGGER trg_MarkCarAsRented
ON Rental
AFTER INSERT
AS
BEGIN
    UPDATE Cars
    SET Car_State = 'Rented'
    WHERE Car_ID IN (SELECT CAR_ID FROM inserted);
END;
GO


CREATE TRIGGER trg_MarkCarAsAvailable
ON Rental
AFTER DELETE
AS
BEGIN
    UPDATE Cars
    SET Car_State = 'Available'
    WHERE Car_ID IN (SELECT CAR_ID FROM deleted);
END;
GO



CREATE NONCLUSTERED INDEX IX_Customers_TCNo
ON Customers(TC_No);
GO

CREATE NONCLUSTERED INDEX IX_Cars_CarPlate
ON Cars(Car_Plate);
GO