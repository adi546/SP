USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[UpdateBookingApproval]    Script Date: 3/10/2025 4:32:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateBookingApproval]
    @OrderNumber INT,
    @RoleId INT,
    @UserCode NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RowsAffected INT = 0;
    DECLARE @UserName NVARCHAR(100); -- Variable to store user's name

    -- Fetch User's Name from Users table
    SELECT @UserName = Name 
    FROM Users 
    WHERE UserCode = @UserCode;

    -- TM Approval (Only RoleId = 2 can approve as TM)
    IF @RoleId = 2
    BEGIN
        UPDATE DealerOrderMHZPC
        SET TMApproval = 'Approved',
            TMApproval_Date = GETDATE(),
            TMUserCode = @UserCode,  -- Storing UserCode
            TMName = @UserName       -- Storing User's Name
        WHERE OrderNumber = @OrderNumber;

        SET @RowsAffected = @@ROWCOUNT;
    END
    -- Higher Authority Approval (Only RoleId > 2 can approve)
    ELSE IF @RoleId > 2
    BEGIN
        UPDATE DealerOrderMHZPC
        SET HAApproval = 'Approved',
            HAApproval_Date = GETDATE(),
            HAUserCode = @UserCode,  -- Storing UserCode
            HAName = @UserName       -- Storing User's Name
        WHERE OrderNumber = @OrderNumber;

        SET @RowsAffected = @@ROWCOUNT;
    END

    -- Return the number of affected rows
    SELECT @RowsAffected AS RowsAffected;
END;

GO
