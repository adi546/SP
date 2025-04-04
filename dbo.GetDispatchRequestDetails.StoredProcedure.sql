USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetDispatchRequestDetails]    Script Date: 4/1/2025 6:49:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetDispatchRequestDetails] 
    @CustomerCode NVARCHAR(50), 
    @OrderNumber INT, 
    @PriceCardType NVARCHAR(10), -- 'Single' or 'Combo' 
    @ProductId INT, 
    @ItemId INT = NULL, 
    @PricePerKg DECIMAL(18,2), 
    @BookingPrice DECIMAL(18,2), 
    @BookedQty INT, 
    @BookingAmtPaid DECIMAL(18,2), 
    @BalanceAmtToPay DECIMAL(18,2), 
    @RequestForQtyMT DECIMAL(18,2), 
    @ErrorMessage NVARCHAR(500) OUTPUT 
AS 
BEGIN 
    SET NOCOUNT ON; 
    SET @ErrorMessage = NULL;

    DECLARE @LatestPrimaryBookingAmtPaid DECIMAL(18,2); 
    DECLARE @AvailableBalance DECIMAL(18,2); 
    DECLARE @AmountRequiredToDispatch DECIMAL(18,2); 
    DECLARE @BookingAmountForRequest DECIMAL(18,2); 
    DECLARE @BalanceAmount DECIMAL(18,2); 
    DECLARE @TotalBalanceAmount DECIMAL(18,2);
    

    -- Determine ItemId logic based on PriceCardType
    DECLARE @CurrentItemId INT = CASE 
        WHEN @PriceCardType = 'Single' THEN 0 
        ELSE @ItemId 
    END;

   

    -- Fetch latest BookingAmtPaid 
    SELECT TOP 1 @LatestPrimaryBookingAmtPaid = BookingAmtPaid
    FROM DispatchRequests 
    WHERE OrderNumber = @OrderNumber  
        AND ProductId = @ProductId  
        AND PriceCardType = @PriceCardType  
        AND (@PriceCardType = 'Single' OR ItemId = @CurrentItemId)
    ORDER BY CreatedOn DESC; 

	 -- Default values if no records found
    IF @LatestPrimaryBookingAmtPaid IS NULL
    SET @LatestPrimaryBookingAmtPaid = @BookingAmtPaid;

    -- Fetch Available Balance 
    SELECT TOP 1 @AvailableBalance = TotalAvailableBalance  
    FROM TB_CustomerTransaction  
    WHERE CustomerCode = @CustomerCode  
    ORDER BY LastUpdated DESC; 

    -- Validate request quantity against remaining quantity
    IF @RequestForQtyMT > @BookedQty
    BEGIN 
        SET @ErrorMessage = 'Error: Requested quantity exceeds remaining quantity.'; 
        RETURN; 
    END

    -- **Primary Product Calculations** 
    SET @AmountRequiredToDispatch = (@RequestForQtyMT * @PricePerKg * 1000); 
    SET @BookingAmountForRequest = (@RequestForQtyMT * @BookingPrice * 1000); 
    SET @BalanceAmount = @AmountRequiredToDispatch - @BookingAmountForRequest; 

    -- **Validation Checks** 
    IF @BookingAmountForRequest > @LatestPrimaryBookingAmtPaid 
    BEGIN 
        SET @ErrorMessage = 'Error: Primary Booking Amount for Request exceeds Booking Amount Paid.'; 
        RETURN; 
    END 

    SET @TotalBalanceAmount = @BalanceAmount;
    
    -- **Final Output**
    SELECT 
        -- Balance Quantity
        (@BookedQty - @RequestForQtyMT) AS BalanceQuantity,
        
       -- Dispatch Status
        CAST(
            CASE 
                WHEN @RequestForQtyMT = @BookedQty THEN 'Complete'
                ELSE 'Partial'
            END AS NVARCHAR(50)
        ) AS DispatchStatus,


        -- Requested Quantity 
        @RequestForQtyMT AS RequestForQuantity, 
        
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

        @TotalBalanceAmount AS TotalBalanceAmount 
END;
GO
