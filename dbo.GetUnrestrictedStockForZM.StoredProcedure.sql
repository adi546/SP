USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetUnrestrictedStockForZM]    Script Date: 4/12/2025 3:50:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetUnrestrictedStockForZM]
     @ProductName NVARCHAR(255),
     @TM NVARCHAR(50)
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @Plant NVARCHAR(50)
    
    SELECT @Plant = Plant 
    FROM TB_CustomerMaster 
    WHERE TM = @TM
    GROUP BY Plant
    
    -- Get the unrestricted kilograms for the product at that plant
    SELECT 
        SD.Material_Description,
        SD.Unrestricted_Kgs
    FROM 
        TB_StockDetails SD
    WHERE 
        SD.Material_Description LIKE '%' + @ProductName + '%'
        AND SD.Plant = @Plant
   
END
GO
