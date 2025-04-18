USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetInvoices]    Script Date: 4/15/2025 3:39:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetInvoices]
    @CompanyCode BIGINT,
    @FromDate DATE = NULL,
    @ToDate DATE = NULL,
    @CustomerCodes NVARCHAR(MAX)
AS
BEGIN
    -- Set NOCOUNT to ON to prevent extra result sets
    SET NOCOUNT ON;
    
    -- Fetch records based on the required CompanyCode and optional filters
    SELECT 
        -- Invoice Header Details
        h.BillingDocument,
        h.BillingDate,
        h.BillingType,
        h.BillingCategory,
        h.ODN_No,
        h.Sold_To_Party,
        h.Sold_To_Party_Name,
        h.Ship_To_Party,
        h.Ship_To_Party_Name,
        h.SalesOrganisation,
        h.Dist_Channel,
        h.Division,
        h.SalesOrderNo,
        h.TotalInvoiceValue,
        -- Invoice Item Details
        d.ItemNo,
        d.Material_Code,
        d.Material_Description,
        d.Batch,
        d.BilledQty,
        d.SalesUnit,
        d.NetPrice,
        d.DiscountValue,
        d.CGSTRate,
        d.CGSTAmount,
        d.SGSTRate,
        d.SGSTAmount,
        d.IGSTRate,
        d.IGSTAmount
    FROM 
        TB_InvoiceHeader h
    LEFT JOIN 
        TB_InvoiceItemDetails d 
        ON h.BillingDocument = d.BillingDocument
    LEFT JOIN 
        TB_CompanyMaster cm 
        ON h.SalesOrganisation = cm.SalesOrganisation
    -- Conditional join based on company code
    LEFT JOIN 
        TB_Create_Dealer_Order o1 
        ON h.SalesOrderNo = o1.SONumber AND cm.CompanyCode = 1049
    LEFT JOIN 
        DealerOrderMHZPC o2 
        ON h.SalesOrderNo = o2.SoNumber AND cm.CompanyCode = 1054
    LEFT JOIN 
        OrdersMHZPC o3 
        ON o2.OrderNumber = o3.OrderNumber AND cm.CompanyCode = 1054
    WHERE 
        -- Filter by CompanyCode
        cm.CompanyCode = @CompanyCode
        -- Filter by date range if provided
        AND (@FromDate IS NULL OR h.BillingDate >= @FromDate)
        AND (@ToDate IS NULL OR h.BillingDate <= @ToDate)
        -- Customer code filter - adapted for both tables
        AND (
            @CustomerCodes IS NULL 
            OR EXISTS (
                SELECT 1 FROM STRING_SPLIT(@CustomerCodes, ',') s 
                WHERE (cm.CompanyCode = 1049 AND COALESCE(o1.CustomerCode, '') = COALESCE(s.value, ''))
                   OR (cm.CompanyCode = 1054 AND COALESCE(o3.CustomerCode, '') = COALESCE(s.value, ''))
            )
        );
END;
GO
