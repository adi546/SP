USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetCartDetails]    Script Date: 4/19/2025 4:15:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetCartDetails]
	@CustomerCode NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @BookingAmountSum DECIMAL(18,2);

    -- Calculate the total sum of booking amounts
    SELECT @BookingAmountSum = SUM(
        CASE 
            WHEN ci.PriceCardType = 'Single' THEN ci.BookingAmount
            WHEN ci.PriceCardType = 'Combo' THEN ci.BookingAmount + ISNULL(ci.SecondaryBookingAmount, 0)
            ELSE 0
        END
    )
    FROM TB_CartMHZPC c
    INNER JOIN TB_CartItemsMHZPC ci ON c.Id = ci.CartId
    WHERE c.CustomerCode = @CustomerCode;

    SELECT 
	    
        c.Id AS CartId,
		ci.Id,
        ci.PriceCardType,
        ci.ProductName,
        ci.Condition_Amount AS ConditionAmount,
        ci.BookingPrice,
        ci.OrderQuantity,
        ci.OrderAmount,
        ci.BookingAmount,
		ci.Generation,
		ci.Grade,
        ci.BalanceAmountToPay,
        ci.SecondaryProductName,
        ci.SecondaryCondition_Amount AS SecondaryConditionAmount,
        ci.SecondaryBookingPrice,
        ci.SecondaryOrderQuantity,
        ci.SecondaryOrderAmount,
        ci.SecondaryBookingAmount,
		ci.SecondaryGeneration,
		ci.SecondaryGrade,
        ci.SecondaryBalanceAmountToPay
    FROM TB_CartMHZPC c
    INNER JOIN TB_CartItemsMHZPC ci ON c.Id = ci.CartId
    WHERE c.CustomerCode = @CustomerCode;

	SELECT @BookingAmountSum AS BookingAmountSum;
END;
GO
