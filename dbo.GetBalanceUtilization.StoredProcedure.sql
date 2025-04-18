USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetBalanceUtilization]    Script Date: 4/18/2025 6:43:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetBalanceUtilization]
    @CustomerCode NVARCHAR(50),
    @YearFilter NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- Standardize @YearFilter to match 'YYYY-YYYY' format
    IF @YearFilter IS NOT NULL 
    BEGIN
        DECLARE @StartYear INT = LEFT(@YearFilter, 4);
        SET @YearFilter = CONCAT(@StartYear, '-', @StartYear + 1);
    END

    -- Create a CTE to combine all transactions in a unified format
    ;WITH AllTransactions AS (
        -- Get Deposits
        SELECT 
            LastUpdated AS DateOfTransaction,
            DepositedBalance AS Amount,
            TotalAvailableBalance AS AvailableAmount,
            'Deposit' AS Description,
              CONCAT(
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated)
                    ELSE YEAR(LastUpdated) - 1
                END,
                '-',
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated) + 1
                    ELSE YEAR(LastUpdated)
                END
            ) AS Year,
            Id as TransactionId
        FROM TB_CustomerTransaction
        WHERE CustomerCode = @CustomerCode
        AND DepositedBalance > 0 
        AND TransactionType = 'Deposit' 
        AND (@YearFilter IS NULL OR 
            CONCAT(
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated)
                    ELSE YEAR(LastUpdated) - 1
                END,
                '-',
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated) + 1
                    ELSE YEAR(LastUpdated)
                END
            ) = @YearFilter
        )
        
        UNION ALL
        
        -- Get Deduct Transactions
        SELECT 
            LastUpdated AS DateOfTransaction,
            -DeductedBalance AS Amount,  -- Negative for debit
            TotalAvailableBalance AS AvailableAmount,
            'Booking' AS Description,
            CONCAT(
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated)
                    ELSE YEAR(LastUpdated) - 1
                END,
                '-',
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated) + 1
                    ELSE YEAR(LastUpdated)
                END
            ) AS Year,
            Id as TransactionId
        FROM TB_CustomerTransaction
        WHERE CustomerCode = @CustomerCode
        AND DeductedBalance > 0 
        AND TransactionType = 'Deduct' 
         AND (@YearFilter IS NULL OR 
            CONCAT(
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated)
                    ELSE YEAR(LastUpdated) - 1
                END,
                '-',
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated) + 1
                    ELSE YEAR(LastUpdated)
                END
            ) = @YearFilter
        )
        
        UNION ALL
        
        -- Get Refund Transactions
        SELECT 
            LastUpdated AS DateOfTransaction,
            RefundBalance AS Amount,  -- Positive for credit
            TotalAvailableBalance AS AvailableAmount,
            'Refund' AS Description,
           CONCAT(
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated)
                    ELSE YEAR(LastUpdated) - 1
                END,
                '-',
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated) + 1
                    ELSE YEAR(LastUpdated)
                END
            ) AS Year,
            Id as TransactionId
        FROM TB_CustomerTransaction
        WHERE CustomerCode = @CustomerCode
        AND RefundBalance > 0
        AND TransactionType = 'Refund'
        AND (@YearFilter IS NULL OR 
            CONCAT(
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated)
                    ELSE YEAR(LastUpdated) - 1
                END,
                '-',
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated) + 1
                    ELSE YEAR(LastUpdated)
                END
            ) = @YearFilter
        )
        
        UNION ALL
        
        -- Get Dispatch Transactions
        SELECT 
            LastUpdated AS DateOfTransaction,
            -DispatchBalance AS Amount,  -- Negative for debit
            TotalAvailableBalance AS AvailableAmount,
            'Dispatch' AS Description,
          CONCAT(
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated)
                    ELSE YEAR(LastUpdated) - 1
                END,
                '-',
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated) + 1
                    ELSE YEAR(LastUpdated)
                END
            ) AS Year,
            Id as TransactionId
        FROM TB_CustomerTransaction
        WHERE CustomerCode = @CustomerCode
        AND DispatchBalance > 0
        AND TransactionType = 'Dispatch'
       AND (@YearFilter IS NULL OR 
            CONCAT(
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated)
                    ELSE YEAR(LastUpdated) - 1
                END,
                '-',
                CASE 
                    WHEN MONTH(LastUpdated) >= 4 THEN YEAR(LastUpdated) + 1
                    ELSE YEAR(LastUpdated)
                END
            ) = @YearFilter
        )
    )
    
    
    -- Add joins to get product/quantity information where applicable
    SELECT 
        t.DateOfTransaction, 
        t.Amount, 
        t.AvailableAmount, 
        CASE 
            WHEN t.Description = 'Booking' AND o.OrderNumber IS NOT NULL 
                THEN CONCAT('Booking ', d.ProductName, ' (Qty: ', d.OrderQuantity, 'MT)')
            WHEN t.Description = 'Dispatch' AND dr.ID IS NOT NULL 
                THEN CONCAT('Dispatch Qty: ', dr.RequestForQuantityMT, 'MT')
            ELSE t.Description
        END AS Description, 
        t.Year
    FROM AllTransactions t
    LEFT JOIN TB_CustomerTransaction ct ON t.TransactionId = ct.Id
    -- Try to join with order information for Deduct transactions
    LEFT JOIN OrdersMHZPC o ON o.CustomerCode = @CustomerCode 
        AND t.Description = 'Booking'
        AND ABS(DATEDIFF(SECOND, o.OrderDate, t.DateOfTransaction)) < 10  -- Assuming close timestamps
    LEFT JOIN DealerOrderMHZPC d ON d.OrderNumber = o.OrderNumber
    -- Try to join with dispatch information for Dispatch transactions
    LEFT JOIN DispatchRequests dr ON dr.CustomerCode = @CustomerCode 
        AND t.Description = 'Dispatch'
        AND ABS(DATEDIFF(SECOND, dr.CreatedOn, t.DateOfTransaction)) < 10  -- Assuming close timestamps
    ORDER BY t.DateOfTransaction DESC;
END;
GO
