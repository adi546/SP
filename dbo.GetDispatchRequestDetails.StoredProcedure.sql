USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetDispatchRequestDetails]    Script Date: 3/10/2025 4:32:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetDispatchRequestDetails]
    @CustomerCode NVARCHAR(50),
    @OrderNumber INT,
    @PriceCardType NVARCHAR(10), -- 'Single' or 'Combo'
    @ProductId INT,
    -- Single PriceCardType Parameters
    @PricePerKg DECIMAL(18,2),
    @BookingPrice DECIMAL(18,2),
    @BookedQty INT,
    @BookingAmtPaid DECIMAL(18,2),
    @BalanceAmtToPay DECIMAL(18,2),
    @RequestForQtyMT DECIMAL(18,2),

    -- Combo PriceCardType Parameters (Secondary Only)
    @SecondaryPricePerKg DECIMAL(18,2) = NULL, 
    @SecondaryBookingPrice DECIMAL(18,2) = NULL,
    @SecondaryBookedQty INT = NULL,
    @SecondaryBookingAmtPaid DECIMAL(18,2) = NULL,
    @SecondaryBalanceAmtToPay DECIMAL(18,2) = NULL,
    @SecondaryRequestForQtyMT DECIMAL(18,2) = NULL,

    @ErrorMessage NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @ErrorMessage = NULL;

    DECLARE @LatestPrimaryBookingAmtPaid DECIMAL(18,2);
    DECLARE @LatestSecondaryBookingAmtPaid DECIMAL(18,2);
    DECLARE @AvailableBalance DECIMAL(18,2);
    
    DECLARE @AmountRequiredToDispatch DECIMAL(18,2);
    DECLARE @BookingAmountForRequest DECIMAL(18,2);
    DECLARE @BalanceAmount DECIMAL(18,2);
    
    DECLARE @SecondaryAmountRequiredToDispatch DECIMAL(18,2);
    DECLARE @SecondaryBookingAmountForRequest DECIMAL(18,2);
    DECLARE @SecondaryBalanceAmount DECIMAL(18,2);
	DECLARE @TotalBalanceAmount DECIMAL(18,2);

    -- Fetch latest BookingAmtPaid based on PriceCardType
    SELECT TOP 1 
        @LatestPrimaryBookingAmtPaid = BookingAmtPaid,
        @LatestSecondaryBookingAmtPaid = CASE WHEN @PriceCardType = 'Combo' THEN SecondaryBookingAmtPaid ELSE NULL END
    FROM DispatchRequests
    WHERE OrderNumber = @OrderNumber AND ProductId = @ProductId
    ORDER BY CreatedOn DESC;

    -- Default values if no records found
    IF @LatestPrimaryBookingAmtPaid IS NULL
    SET @LatestPrimaryBookingAmtPaid = @BookingAmtPaid;

    IF @LatestSecondaryBookingAmtPaid IS NULL
    SET @LatestSecondaryBookingAmtPaid = @SecondaryBookingAmtPaid;


    -- Fetch Available Balance
    SELECT TOP 1 @AvailableBalance = TotalAvailableBalance 
    FROM TB_CustomerTransaction 
    WHERE CustomerCode = @CustomerCode 
    ORDER BY LastUpdated DESC;

    -- **Primary Product Calculations**
    SET @AmountRequiredToDispatch = (@RequestForQtyMT * @PricePerKg * 1000);
    SET @BookingAmountForRequest = (@RequestForQtyMT * @BookingPrice * 1000);
    SET @BalanceAmount = @AmountRequiredToDispatch - @BookingAmountForRequest;

    -- **Combo Product Calculations**
    IF @PriceCardType = 'Combo'
    BEGIN
        SET @SecondaryAmountRequiredToDispatch = (@SecondaryRequestForQtyMT * @SecondaryPricePerKg * 1000);
        SET @SecondaryBookingAmountForRequest = (@SecondaryRequestForQtyMT * @SecondaryBookingPrice * 1000);
        SET @SecondaryBalanceAmount = @SecondaryAmountRequiredToDispatch - @SecondaryBookingAmountForRequest;
    END

    -- **Validation Checks**
    IF @BookingAmountForRequest > @LatestPrimaryBookingAmtPaid
    BEGIN
        SET @ErrorMessage = 'Error: Primary Booking Amount for Request exceeds Booking Amount Paid.';
        RETURN;
    END

    IF @PriceCardType = 'Combo' AND @SecondaryBookingAmountForRequest > @LatestSecondaryBookingAmtPaid
    BEGIN
        SET @ErrorMessage = 'Error: Secondary Booking Amount for Request exceeds Booking Amount Paid.';
        RETURN;
    END

	SET @TotalBalanceAmount = @BalanceAmount + ISNULL(@SecondaryBalanceAmount, 0);


    -- **Final Output**
    SELECT 
        -- Balance Quantity
        (@BookedQty - @RequestForQtyMT) AS BalanceQuantity,
        CASE WHEN @PriceCardType = 'Combo' THEN (@SecondaryBookedQty - @SecondaryRequestForQtyMT) ELSE NULL END AS SecondaryBalanceQuantity,

        -- Dispatch Status
        CAST(
            CASE 
                WHEN @RequestForQtyMT = @BookedQty THEN 'Complete'
                ELSE 'Partial'
            END AS NVARCHAR(50)
        ) AS DispatchStatus,

        CAST(
            CASE 
                WHEN @PriceCardType = 'Combo' AND @SecondaryRequestForQtyMT = @SecondaryBookedQty THEN 'Complete'
                WHEN @PriceCardType = 'Combo' THEN 'Partial'
                ELSE NULL 
            END AS NVARCHAR(50)
        ) AS SecondaryDispatchStatus,

        -- Requested Quantity
        @RequestForQtyMT AS RequestForQuantity,
        CASE WHEN @PriceCardType = 'Combo' THEN @SecondaryRequestForQtyMT ELSE NULL END AS SecondaryRequestForQuantity,

        -- Amount Required To Dispatch
        @AmountRequiredToDispatch AS AmountRequiredToDispatch,

        -- Booking Amount Remaining
        (@LatestPrimaryBookingAmtPaid - @BookingAmountForRequest) AS BookingAmountRemaining,

        -- Booking Amount Received
        @BookingAmountForRequest AS BookingAmountReceived,

        -- Balance Amount Calculation
        @BalanceAmount AS BalanceAmount,

        -- Available Balance
        @AvailableBalance AS AvailableBalance,

	 @TotalBalanceAmount AS TotalBalanceAmount,

        -- Secondary Product Calculations (For Combo Type Only)
        CASE WHEN @PriceCardType = 'Combo' THEN @SecondaryAmountRequiredToDispatch ELSE NULL END AS SecondaryAmountRequiredToDispatch,
        CASE WHEN @PriceCardType = 'Combo' THEN @SecondaryBookingAmountForRequest ELSE NULL END AS SecondaryBookingAmountForRequest,
        CASE WHEN @PriceCardType = 'Combo' THEN @SecondaryBalanceAmount ELSE NULL END AS SecondaryBalanceAmount,
		CASE WHEN @PriceCardType = 'Combo' THEN @LatestSecondaryBookingAmtPaid - @SecondaryBookingAmountForRequest  ELSE NULL END AS SecondaryBookingAmountRemaining;
END;
GO
