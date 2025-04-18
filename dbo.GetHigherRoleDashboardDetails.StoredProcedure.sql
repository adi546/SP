USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetHigherRoleDashboardDetails]    Script Date: 4/13/2025 2:08:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetHigherRoleDashboardDetails]
    @UserCode NVARCHAR(50),
	@SelectedCustomer NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- Get Current Month and Year
    DECLARE @CurrentMonth INT = MONTH(GETDATE());
    DECLARE @CurrentYear INT = YEAR(GETDATE());
    
    -- Get customers under this higher role
    DECLARE @CustomerList TABLE (CustomerCode NVARCHAR(50), CustomerName NVARCHAR(100));
    INSERT INTO @CustomerList
    EXEC GetUserCustomers @UserCode = @UserCode;

	IF @SelectedCustomer IS NOT NULL
BEGIN
    DELETE FROM @CustomerList 
    WHERE CustomerCode <> @SelectedCustomer;
END
    
    -- 1. YTD Sales and Monthly Sales (combined in one result set)
    SELECT 
        -- YTD Sales Value 
        (SELECT ISNULL(SUM(CASE 
                WHEN YEAR(h_inner.BillingDate) = @CurrentYear THEN CONVERT(DECIMAL(18,2), h_inner.TotalInvoiceValue) 
                ELSE 0 
            END), 0)
        FROM (
            SELECT DISTINCT h_distinct.BillingDocument, h_distinct.BillingDate, h_distinct.TotalInvoiceValue
            FROM TB_InvoiceHeader h_distinct
            INNER JOIN DealerOrderMHZPC d_distinct ON h_distinct.SalesOrderNo = d_distinct.SoNumber
            INNER JOIN OrdersMHZPC o_distinct ON d_distinct.OrderNumber = o_distinct.OrderNumber
            WHERE o_distinct.CustomerCode IN (SELECT CustomerCode FROM @CustomerList)
              AND h_distinct.SalesOrganisation = 'MZ01'
        ) h_inner) AS TotalYTDSaleValue,
        
        -- Monthly Sales Value
        (SELECT ISNULL(SUM(CASE 
                WHEN MONTH(h_inner.BillingDate) = @CurrentMonth 
                AND YEAR(h_inner.BillingDate) = @CurrentYear 
                THEN CONVERT(DECIMAL(18,2), h_inner.TotalInvoiceValue) 
                ELSE 0 
            END), 0)
        FROM (
            SELECT DISTINCT h_distinct.BillingDocument, h_distinct.BillingDate, h_distinct.TotalInvoiceValue
            FROM TB_InvoiceHeader h_distinct
            INNER JOIN DealerOrderMHZPC d_distinct ON h_distinct.SalesOrderNo = d_distinct.SoNumber
            INNER JOIN OrdersMHZPC o_distinct ON d_distinct.OrderNumber = o_distinct.OrderNumber
            WHERE o_distinct.CustomerCode IN (SELECT CustomerCode FROM @CustomerList)
              AND h_distinct.SalesOrganisation = 'MZ01'
        ) h_inner) AS TotalCurrentMonthSaleValue;
    
    -- 3. Pending Orders
    SELECT COUNT(OrderNumber) AS PendingOrders
    FROM OrdersMHZPC
    WHERE CustomerCode IN (SELECT CustomerCode FROM @CustomerList)
      AND OrderStatus = 'Pending';
    
    -- 4. Approved Orders
    SELECT COUNT(OrderNumber) AS ApprovedOrders
    FROM OrdersMHZPC
    WHERE CustomerCode IN (SELECT CustomerCode FROM @CustomerList)
      AND OrderStatus = 'Approved';
    
    -- 5. Outstanding Aging
    SELECT
        SUM([0_30_Days] + [31_60_Days] + [61_90_Days]) AS [0_90_Days],
        SUM([91_120_Days]) AS [91_120_Days],
        SUM([121_150_Days] + [151_180_Days]) AS [121_180_Days],
        SUM([181_210_Days] + [210_365_Days]) AS [181_365_Days],
        SUM([Over_365_Days]) AS [Over_365_Days]
    FROM TB_CustomerAgeingReport
    WHERE CustomerCode IN (SELECT CustomerCode FROM @CustomerList)
      AND CompanyCode = '1054';
    
    -- 6. Account Summary
   SELECT 
        SUM(d.BookingAmount) + SUM(ISNULL(d.SecondaryBookingAmount, 0)) AS TotalBookingAdvance,
        SUM(d.BalanceAmountToPay) + SUM(ISNULL(d.SecondaryBalanceAmountToPay, 0)) AS TotalBalanceDue,
        -- Added OrderAmount using the same logic as in TM Dashboard
        ISNULL(SUM(CONVERT(DECIMAL(18,2), d.OrderAmount)) + 
               SUM(ISNULL(CONVERT(DECIMAL(18,2), d.SecondaryOrderAmount), 0)), 0) AS TotalOrderAmount
    FROM DealerOrderMHZPC d
    INNER JOIN OrdersMHZPC o ON d.OrderNumber = o.OrderNumber
    WHERE o.CustomerCode IN (SELECT CustomerCode FROM @CustomerList);
    
    -- 7. Turnover by Financial Year
    SELECT 
        fin_year.FinancialYear,
        ISNULL(SUM(fin_year.TotalValue), 0) AS TotalValue,
        ISNULL(SUM(fin_year.TotalQuantity), 0) AS TotalQuantity
    FROM (
        -- Get financial year and total value (from InvoiceHeader)
        SELECT 
            CASE 
                WHEN MONTH(h_distinct.BillingDate) >= 4 THEN 'FY' + RIGHT(CAST(YEAR(h_distinct.BillingDate) AS VARCHAR), 2)
                ELSE 'FY' + RIGHT(CAST(YEAR(h_distinct.BillingDate) - 1 AS VARCHAR), 2)
            END AS FinancialYear,
            CONVERT(DECIMAL(18,2), h_distinct.TotalInvoiceValue) AS TotalValue,
            0 AS TotalQuantity
        FROM (
            SELECT DISTINCT h_inner.BillingDocument, h_inner.BillingDate, h_inner.TotalInvoiceValue
            FROM TB_InvoiceHeader h_inner
            INNER JOIN DealerOrderMHZPC d_inner ON h_inner.SalesOrderNo = d_inner.SoNumber
            INNER JOIN OrdersMHZPC o_inner ON d_inner.OrderNumber = o_inner.OrderNumber
            WHERE o_inner.CustomerCode IN (SELECT CustomerCode FROM @CustomerList)
              AND h_inner.SalesOrganisation = 'MZ01'
        ) h_distinct

        UNION ALL

        -- Get financial year and total quantity (from InvoiceItemDetails)
        SELECT 
            CASE 
                WHEN MONTH(h.BillingDate) >= 4 THEN 'FY' + RIGHT(CAST(YEAR(h.BillingDate) AS VARCHAR), 2)
                ELSE 'FY' + RIGHT(CAST(YEAR(h.BillingDate) - 1 AS VARCHAR), 2)
            END AS FinancialYear,
            0 AS TotalValue,
            item_qty.BilledQty AS TotalQuantity
        FROM (
            -- First get the relevant BillingDocuments with their dates
            SELECT DISTINCT h.BillingDocument, h.BillingDate
            FROM TB_InvoiceHeader h
            INNER JOIN DealerOrderMHZPC d ON h.SalesOrderNo = d.SoNumber
            INNER JOIN OrdersMHZPC o ON d.OrderNumber = o.OrderNumber
            WHERE o.CustomerCode IN (SELECT CustomerCode FROM @CustomerList)
              AND h.SalesOrganisation = 'MZ01'
        ) h
        -- Then join to items to get quantities
        INNER JOIN TB_InvoiceItemDetails item_qty ON h.BillingDocument = item_qty.BillingDocument
    ) fin_year
    GROUP BY fin_year.FinancialYear
    ORDER BY fin_year.FinancialYear;
END
GO
