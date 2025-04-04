USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[Get_PriceCard]    Script Date: 4/1/2025 6:49:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Get_PriceCard]
    @CompanyCode BIGINT,
    @Status BIT = 1,
    @PriceCardType NVARCHAR(10) = NULL,
    @Variety NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Condition Table Priority Order
    DECLARE @ConditionTablePriority TABLE (PriorityOrder INT, ConditionTable NVARCHAR(5));
    INSERT INTO @ConditionTablePriority (PriorityOrder, ConditionTable)
    VALUES (1, 'A860'), (2, 'A935'), (3, 'A933'), (4, 'A862'), (5, 'A559');

    SELECT 
        pc.Id, 
        pc.PriceCardType, 
        pc.Variety, 
        pc.Product, 
        pc.Generation, 
        pc.Grade, 
        gs.Size AS Size,  
        pc.BookingPrice,
        pc.State,
        pc.PrimaryRatio,
        pc.SecondaryVariety,
        pc.SecondaryProduct,
        pc.SecondaryGeneration,
        pc.SecondaryGrade,
        gs2.Size AS SecondarySize,  
        pc.SecondaryBookingPrice,
        pc.SecondaryRatio,
        pc.CreatedOn,
        pc.Status,
        COALESCE(primary_cond.Condition_Amount, 0) AS condition_amount,
        COALESCE(secondary_cond.Condition_Amount, 0) AS secondaryCondition_amount

    FROM TB_PriceCard pc
    LEFT JOIN TB_GradeSize gs ON pc.Grade = gs.Grade
    LEFT JOIN TB_GradeSize gs2 ON pc.SecondaryGrade = gs2.Grade

    -- Fetch Primary Condition Amount
    OUTER APPLY (
        SELECT TOP 1 
            pm.Condition_Amount
        FROM TB_PriceMaster pm WITH (INDEX(IDX_TB_PriceMaster_Search))
        JOIN @ConditionTablePriority ctp ON pm.Condition_Table = ctp.ConditionTable
        WHERE pm.CompanyCode = @CompanyCode
          AND pm.Condition_Type = 'ZB01'
          AND pm.Material_Description LIKE '%' + pc.Variety + '%'
          AND pm.Material_Description LIKE '%' + pc.Product + '%'
          AND pm.Material_Description LIKE '%' + pc.Generation + '%'
          AND pm.Material_Description LIKE '%' + pc.Grade + '%'
        ORDER BY ctp.PriorityOrder
    ) AS primary_cond

    -- Fetch Secondary Condition Amount
    OUTER APPLY (
        SELECT TOP 1 
            pm.Condition_Amount
        FROM TB_PriceMaster pm WITH (INDEX(IDX_TB_PriceMaster_Search))
        JOIN @ConditionTablePriority ctp ON pm.Condition_Table = ctp.ConditionTable
        WHERE pm.CompanyCode = @CompanyCode
          AND pm.Condition_Type = 'ZB01'
          AND pm.Material_Description LIKE '%' + pc.SecondaryVariety + '%'
          AND pm.Material_Description LIKE '%' + pc.SecondaryProduct + '%'
          AND pm.Material_Description LIKE '%' + pc.SecondaryGeneration + '%'
          AND pm.Material_Description LIKE '%' + pc.SecondaryGrade + '%'
        ORDER BY ctp.PriorityOrder
    ) AS secondary_cond;
END;
GO
