USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetDealerOrderDetails]    Script Date: 4/11/2025 1:03:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetDealerOrderDetails]
@OrderNumber INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT 
        CartId, 
        ProductName, 
        Condition_Amount, 
        OrderQuantity,
        SecondaryProductName, 
        SecondaryCondition_Amount, 
        SecondaryOrderQuantity,
        PriceCardType, 
        ProductId,
		TMApproval,
		HAApproval
    FROM 
        DealerOrderMHZPC
    WHERE 
        OrderNumber = @OrderNumber
    ORDER BY 
        ProductId;
END
GO
