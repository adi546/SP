USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetLatestBalanceQuantity]    Script Date: 3/27/2025 3:31:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetLatestBalanceQuantity]
    @OrderNumber INT,
    @ProductId INT,
    @ItemId INT,
    @PriceCardType NVARCHAR(20), -- 'Single' or 'Combo'
    @LatestBalanceQty INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Try to fetch LatestBalanceQty from DispatchRequests
    SELECT TOP 1 @LatestBalanceQty = BalanceQuantity
    FROM DispatchRequests
    WHERE OrderNumber = @OrderNumber  
          AND ProductId = @ProductId  
          AND PriceCardType = @PriceCardType
          AND (@PriceCardType = 'Single' OR ItemId = @ItemId)
    ORDER BY CreatedOn DESC;

    -- If no record is found in DispatchRequests, fetch from DealerOrderMhzpc
    IF @LatestBalanceQty IS NULL
    BEGIN
        SELECT @LatestBalanceQty = 
            CASE 
                WHEN @PriceCardType = 'Combo' AND @ItemId = 1 THEN OrderQuantity
                WHEN @PriceCardType = 'Combo' AND @ItemId = 2 THEN SecondaryOrderQuantity
                WHEN @PriceCardType = 'Single' THEN OrderQuantity
                ELSE 0 
            END
        FROM DealerOrderMhzpc
        WHERE OrderNumber = @OrderNumber 
              AND ProductId = @ProductId
              AND PriceCardType = @PriceCardType;
    END
END;
GO
