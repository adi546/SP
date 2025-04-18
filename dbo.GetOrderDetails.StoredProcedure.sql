USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetOrderDetails]    Script Date: 4/11/2025 1:03:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetOrderDetails]
	 @OrderNumber INT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
        CustomerCode, 
        OrderDate 
    FROM 
        OrdersMHZPC 
    WHERE 
       OrderNumber = @OrderNumber;
END
GO
