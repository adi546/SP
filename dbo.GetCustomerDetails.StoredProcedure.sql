USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetCustomerDetails]    Script Date: 4/11/2025 1:03:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetCustomerDetails]
  @CustomerCode NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
        Dist_Channel, 
        Division, 
        Plant 
    FROM 
        TB_CustomerMaster 
    WHERE 
        CustomerCode = @CustomerCode;
END
GO
