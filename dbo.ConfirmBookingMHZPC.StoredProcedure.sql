USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[ConfirmBookingMHZPC]    Script Date: 3/10/2025 4:32:54 AM ******/
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
    @BookingAmountSum DECIMAL(18,2), 
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

    DECLARE @OrderNumber INT;
    DECLARE @PreviousBalance DECIMAL(18,2);
    DECLARE @NewTotalAvailableBalance DECIMAL(18,2);

    -- Get the previous balance
    SELECT TOP 1 @PreviousBalance = TotalAvailableBalance
    FROM TB_CustomerTransaction
    WHERE CustomerCode = @CustomerCode
    ORDER BY LastUpdated DESC;

    -- Calculate the new TotalAvailableBalance after deduction
    SET @NewTotalAvailableBalance = @PreviousBalance - @BookingAmountSum;

    -- Insert into OrdersMHZPC to create a new order record
    INSERT INTO OrdersMHZPC (CustomerCode, BillingAddress, ShippingAddress, ContactPersonName, ContactPersonNumber, OrderDate)
    VALUES (@CustomerCode, @BillingAddress, @ShippingAddress, @ContactPersonName, @ContactPersonNumber, GETDATE());

    -- Retrieve the newly created OrderNumber
    SET @OrderNumber = SCOPE_IDENTITY();

    -- Insert all cart items into DealerOrderMHZPC with ProductId starting from 1 for each order
    INSERT INTO DealerOrderMHZPC (
        OrderNumber, ProductId, CartId, PriceCardType, ProductName, Condition_Amount, BookingPrice, OrderQuantity,
        OrderAmount, BookingAmount, BalanceAmountToPay, SecondaryProductName, SecondaryCondition_Amount, 
        SecondaryBookingPrice, SecondaryOrderQuantity, SecondaryOrderAmount, SecondaryBookingAmount, 
        SecondaryBalanceAmountToPay, DispatchStatus, TMApproval, SoNumber, DateOfPurchase, TMApproval_Date, 
        HAApproval, HAApproval_Date, PrimaryRatio, SecondaryRatio, TMNAME, TMUserCode, HAName, HAUserCode
    )
    SELECT 
        @OrderNumber,
        ROW_NUMBER() OVER (ORDER BY CartId) AS ProductId,  -- Generate ProductId starting from 1
        CartId, PriceCardType, ProductName, Condition_Amount, BookingPrice, OrderQuantity,
        OrderAmount, BookingAmount, BalanceAmountToPay, SecondaryProductName, SecondaryCondition_Amount, 
        SecondaryBookingPrice, SecondaryOrderQuantity, SecondaryOrderAmount, SecondaryBookingAmount, 
        SecondaryBalanceAmountToPay, 'Pending', 'Pending', NULL, GETDATE(), NULL, 'Pending', NULL, PrimaryRatio, SecondaryRatio, NULL, NULL, NULL, NULL
    FROM TB_CartItemsMHZPC 
    WHERE CartId IN (SELECT Id FROM TB_CartMHZPC WHERE CustomerCode = @CustomerCode);

    -- Insert transaction record for customer balance update
    INSERT INTO TB_CustomerTransaction (
        CustomerCode, AvailableBalance, DepositedBalance, DeductedBalance, TotalAvailableBalance, TransactionType, LastUpdated
    )
    VALUES (
        @CustomerCode, @PreviousBalance, 0, @BookingAmountSum, @NewTotalAvailableBalance, 'Deduct', GETDATE()
    );

    -- Delete Cart Items after order confirmation
    DELETE FROM TB_CartItemsMHZPC WHERE CartId IN (SELECT Id FROM TB_CartMHZPC WHERE CustomerCode = @CustomerCode);

    -- Delete Cart Header
    DELETE FROM TB_CartMHZPC WHERE CustomerCode = @CustomerCode;

    -- Return success
    SET @ReturnValue = 1;
END;
GO
