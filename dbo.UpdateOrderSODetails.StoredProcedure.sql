USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[UpdateOrderSODetails]    Script Date: 4/16/2025 9:36:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateOrderSODetails]
	 @OrderNumber INT,
     @SONumber NVARCHAR(50)
AS
BEGIN
	
	SET NOCOUNT ON;

     IF @SONumber IS NOT NULL AND LEN(LTRIM(RTRIM(@SONumber))) > 0
    BEGIN
        -- Update SONumber and SODate for all records with the given OrderNumber
        UPDATE DealerOrderMHZPC
        SET SoNumber = @SONumber,
            SODate = GETDATE()
        WHERE OrderNumber = @OrderNumber;
        
        -- Return the number of affected rows
        SELECT @@ROWCOUNT AS RowsAffected;
    END
    ELSE
    BEGIN
        -- Return 0 rows affected if SONumber is null or empty
        SELECT 0 AS RowsAffected;
    END
END
GO
