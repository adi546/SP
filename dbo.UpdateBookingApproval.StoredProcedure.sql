USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[UpdateBookingApproval]    Script Date: 2/28/2025 8:00:07 AM ******/
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

    -- TM Approval (Only RoleId = 2 can approve as TM)
    IF @RoleId = 2
    BEGIN
        UPDATE DealerOrderMHZPC
        SET TMApproval = 'Approved',
            TMApproval_Date = GETDATE()
            
        WHERE OrderNumber = @OrderNumber;

	    SET @RowsAffected = @@ROWCOUNT; 

    END

    -- Higher Authority Approval (Only RoleId > 2 can approve)
    ELSE IF @RoleId > 2
    BEGIN
        UPDATE DealerOrderMHZPC
        SET HAApproval = 'Approved',
            HAApproval_Date = GETDATE()
         
        WHERE OrderNumber = @OrderNumber;

		SET @RowsAffected = @@ROWCOUNT; 
    END

    SELECT @RowsAffected AS RowsAffected;
    
END;
GO
