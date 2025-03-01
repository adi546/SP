USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetOrderConfirmationMHZPC]    Script Date: 2/26/2025 5:29:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetOrderConfirmationMHZPC] 
	@CustomerCode NVARCHAR(50)
AS
BEGIN
	 SELECT OrderNumber, DateOfPurchase, ShippingAddress
    FROM DealerOrderMHZPC
    WHERE CustomerCode = @CustomerCode
    ORDER BY DateOfPurchase DESC;
END
GO
