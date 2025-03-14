USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[UpdateBookingApproval]    Script Date: 3/13/2025 7:50:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateBookingApproval]
    @OrderNumber INT,
    @RoleId INT,
    @UserCode NVARCHAR(50),
    @IsApproved BIT,   -- 1 for approval, 0 for rejection
    @RejectionReasonId INT = NULL,  -- Null for approval, required for rejection
    @CustomerCode NVARCHAR(50)  -- Added parameter to track customer balance updates
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RowsAffected INT = 0;
    DECLARE @UserName NVARCHAR(100);
    DECLARE @LatestTotalAvailableBalance DECIMAL(18,2);
    DECLARE @RefundAmount DECIMAL(18,2) = 0;

    -- Fetch User's Name from Users table
    SELECT @UserName = Name 
    FROM Users 
    WHERE UserCode = @UserCode;

    -- Fetch the latest TotalAvailableBalance for the customer
    SELECT TOP 1 @LatestTotalAvailableBalance = COALESCE(TotalAvailableBalance, 0)
    FROM TB_CustomerTransaction
    WHERE CustomerCode = @CustomerCode
    ORDER BY LastUpdated DESC;

    -- If no record exists, assume 0 balance
    IF @LatestTotalAvailableBalance IS NULL
        SET @LatestTotalAvailableBalance = 0;

    -- Calculate the refund amount based on PriceCardType
    SELECT @RefundAmount = SUM(
        CASE 
            WHEN PriceCardType = 'Single' THEN BookingAmount
            WHEN PriceCardType = 'Combo' THEN BookingAmount + SecondaryBookingAmount
            ELSE 0 
        END
    )
    FROM DealerOrderMHZPC
    WHERE OrderNumber = @OrderNumber;

    -- If approved, update approval status
    IF @IsApproved = 1
    BEGIN
        -- TM Approval
        IF @RoleId = 2
        BEGIN
            UPDATE DealerOrderMHZPC
            SET TMApproval = 'Approved',
                TMApproval_Date = GETDATE(),
                TMUserCode = @UserCode,
                TMName = @UserName,
                TMRejectionReasonId = NULL
            WHERE OrderNumber = @OrderNumber;
        END
        -- HA Approval
        ELSE IF @RoleId > 2
        BEGIN
            UPDATE DealerOrderMHZPC
            SET HAApproval = 'Approved',
                HAApproval_Date = GETDATE(),
                HAUserCode = @UserCode,
                HAName = @UserName,
                HARejectionReasonId = NULL
            WHERE OrderNumber = @OrderNumber;
        END
    END
    ELSE  -- If rejected, update rejection status and process refund
    BEGIN
        -- TM Rejection
        IF @RoleId = 2
        BEGIN
            UPDATE DealerOrderMHZPC
            SET TMApproval = 'Rejected',
                TMApproval_Date = GETDATE(),
                TMUserCode = @UserCode,
                TMName = @UserName,
                TMRejectionReasonId = @RejectionReasonId
            WHERE OrderNumber = @OrderNumber;
        END
        -- HA Rejection
        ELSE IF @RoleId > 2
        BEGIN
            UPDATE DealerOrderMHZPC
            SET HAApproval = 'Rejected',
                HAApproval_Date = GETDATE(),
                HAUserCode = @UserCode,
                HAName = @UserName,
                HARejectionReasonId = @RejectionReasonId
            WHERE OrderNumber = @OrderNumber;
        END

        -- Insert refund transaction
        INSERT INTO TB_CustomerTransaction (
            CustomerCode, AvailableBalance, DepositedBalance, TotalAvailableBalance,
            TransactionType, LastUpdated, DeductedBalance, DispatchBalance, RefundBalance
        )
        VALUES (
            @CustomerCode,  -- CustomerCode
            @LatestTotalAvailableBalance,  -- Available Balance (Previous TotalAvailableBalance)
            0,  -- Deposited Balance
            @LatestTotalAvailableBalance + @RefundAmount,  -- New TotalAvailableBalance
            'Refund',  -- Transaction Type
            GETDATE(),  -- LastUpdated
            0,  -- DeductedBalance
            0,  -- DispatchBalance
            @RefundAmount  -- RefundBalance
        );
    END

    -- Return rows affected
    SET @RowsAffected = @@ROWCOUNT;
    SELECT @RowsAffected AS RowsAffected;
END;

GO
