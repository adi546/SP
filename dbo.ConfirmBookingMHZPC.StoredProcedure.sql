USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[ConfirmBookingMHZPC]    Script Date: 2/28/2025 8:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ConfirmBookingMHZPC]
    @CustomerCode NVARCHAR(50),
    @BillingAddress NVARCHAR(255),
    @ShippingAddress NVARCHAR(255),
    @ContactPersonName NVARCHAR(100),
    @ContactPersonNumber NVARCHAR(20),
	@BalanceAmountToPay DECIMAL(18,2),
    @SecondaryBalanceAmountToPay DECIMAL(18,2) = NULL,
    @ReturnValue INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the customer has items in the cart
    IF NOT EXISTS (SELECT 1 FROM TB_CartMHZPC WHERE CustomerCode = @CustomerCode)
    BEGIN
        SET @ReturnValue = 0; -- No cart found
        RETURN;
    END

    -- Insert Cart Items into DealerOrderMHZPC
    INSERT INTO DealerOrderMHZPC (
        CustomerCode, BillingAddress, ShippingAddress, ContactPersonName, ContactPersonNumber,
        CartId, PriceCardType, ProductName, Condition_Amount, BookingPrice, OrderQuantity,
        OrderAmount, BookingAmount, BalanceAmountToPay, SecondaryProductName,
        SecondaryCondition_Amount, SecondaryBookingPrice, SecondaryOrderQuantity, SecondaryOrderAmount,
        SecondaryBookingAmount, SecondaryBalanceAmountToPay, DispatchStatus, TMApproval, SoNumber, DateOfPurchase, TMApproval_Date, HAApproval, HAApproval_Date
    )
    SELECT 
        @CustomerCode, @BillingAddress, @ShippingAddress, @ContactPersonName, @ContactPersonNumber,
        CartId, PriceCardType, ProductName, Condition_Amount, BookingPrice, OrderQuantity,
        OrderAmount, BookingAmount, @BalanceAmountToPay, SecondaryProductName,
        SecondaryCondition_Amount, SecondaryBookingPrice, SecondaryOrderQuantity, SecondaryOrderAmount,
        SecondaryBookingAmount, @SecondaryBalanceAmountToPay, 'Pending', 'Pending', NULL, GETDATE(), NULL, 'Pending', NULL
    FROM TB_CartItemsMHZPC WHERE CartId IN (SELECT Id FROM TB_CartMHZPC WHERE CustomerCode = @CustomerCode);

    -- Delete Cart Items
    DELETE FROM TB_CartItemsMHZPC WHERE CartId IN (SELECT Id FROM TB_CartMHZPC WHERE CustomerCode = @CustomerCode);

    -- Delete Cart Header
    DELETE FROM TB_CartMHZPC WHERE CustomerCode = @CustomerCode;

    -- Return success
    SET @ReturnValue = 1;
END
GO
