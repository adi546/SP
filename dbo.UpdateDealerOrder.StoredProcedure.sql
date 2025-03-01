USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[UpdateDealerOrder]    Script Date: 2/28/2025 8:00:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateDealerOrder]
    @OrderNumber INT,
    @PriceCardType NVARCHAR(50),
    @OrderQuantity INT,
    @OrderAmount DECIMAL(18,2),
    @BookingAmount DECIMAL(18,2),
    @BalanceAmountToPay DECIMAL(18,2),
    @SecondaryOrderQuantity INT = NULL,
    @SecondaryOrderAmount DECIMAL(18,2) = NULL,
    @SecondaryBookingAmount DECIMAL(18,2) = NULL,
    @SecondaryBalanceAmountToPay DECIMAL(18,2) = NULL,
    @RowsAffected INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @PriceCardType = 'Single'
    BEGIN
        UPDATE DealerOrderMHZPC
        SET 
            OrderQuantity = @OrderQuantity,
            OrderAmount = @OrderAmount,
            BookingAmount = @BookingAmount,
            BalanceAmountToPay = @BalanceAmountToPay
        WHERE OrderNumber = @OrderNumber;

        SET @RowsAffected = @@ROWCOUNT;
    END
    ELSE IF @PriceCardType = 'Combo'
    BEGIN
        UPDATE DealerOrderMHZPC
        SET 
            OrderQuantity = @OrderQuantity,
            OrderAmount = @OrderAmount,
            BookingAmount = @BookingAmount,
            BalanceAmountToPay = @BalanceAmountToPay,
            SecondaryOrderQuantity = @SecondaryOrderQuantity,
            SecondaryOrderAmount = @SecondaryOrderAmount,
            SecondaryBookingAmount = @SecondaryBookingAmount,
            SecondaryBalanceAmountToPay = @SecondaryBalanceAmountToPay
        WHERE OrderNumber = @OrderNumber;

        SET @RowsAffected = @@ROWCOUNT;
    END
END;
GO
