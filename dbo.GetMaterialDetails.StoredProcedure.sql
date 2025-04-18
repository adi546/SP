USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetMaterialDetails]    Script Date: 4/11/2025 1:03:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetMaterialDetails]
 @MaterialDescription NVARCHAR(255)
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT TOP 1 
        [Material_Number] 
    FROM 
        [TB_PriceMaster] 
    WHERE 
        [Material_Description] = @MaterialDescription;
   
END
GO
