USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetCartDetails]    Script Date: 2/26/2025 5:29:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetCartDetails]
	@CustomerCode NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.Id AS CartId,
        ci.PriceCardType,
        ci.ProductName,
        ci.Condition_Amount AS ConditionAmount,
        ci.BookingPrice,
        ci.OrderQuantity,
        ci.OrderAmount,
        ci.BookingAmount,
        (ci.OrderAmount - ci.BookingAmount) AS BalanceAmountToPay,
        ci.SecondaryProductName,
        ci.SecondaryCondition_Amount AS SecondaryConditionAmount,
        ci.SecondaryBookingPrice,
        ci.SecondaryOrderQuantity,
        ci.SecondaryOrderAmount,
        ci.SecondaryBookingAmount,
        (ci.SecondaryOrderAmount - ci.SecondaryBookingAmount) AS SecondaryBalanceAmountToPay
    FROM TB_CartMHZPC c
    INNER JOIN TB_CartItemsMHZPC ci ON c.Id = ci.CartId
    WHERE c.CustomerCode = @CustomerCode;
END;
GO
