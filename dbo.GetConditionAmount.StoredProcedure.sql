USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetConditionAmount]    Script Date: 4/1/2025 6:49:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetConditionAmount]
    @CompanyCode VARCHAR(10),
    @Variety VARCHAR(50),
    @Product VARCHAR(100),
    @Generation VARCHAR(10),
    @Grade VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @FinalConditionAmount DECIMAL(18,2);
    
    -- Define the priority sequence for Condition_Table
    DECLARE @ConditionTablePriority TABLE (PriorityOrder INT, ConditionTable NVARCHAR(5));
    INSERT INTO @ConditionTablePriority (PriorityOrder, ConditionTable)
    VALUES 
        (1, 'A860'), 
        (2, 'A935'), 
        (3, 'A933'), 
        (4, 'A862'), 
        (5, 'A559');
        
    -- Logic for CompanyCode = 1049
    IF @CompanyCode = '1049'
    BEGIN
        -- Get the highest priority condition record with both condition types in one query
        SELECT TOP 1 @FinalConditionAmount = 
            CASE 
                WHEN bag.Condition_Amount IS NOT NULL AND dis.Condition_Amount IS NOT NULL 
                THEN bag.Condition_Amount - (bag.Condition_Amount * dis.Condition_Amount / 100)
                ELSE bag.Condition_Amount
            END
        FROM @ConditionTablePriority ctp
        JOIN TB_PriceMaster bag WITH (INDEX(IDX_TB_PriceMaster_Search))
            ON bag.Condition_Table = ctp.ConditionTable
            AND bag.CompanyCode = @CompanyCode
            AND bag.Condition_Type = 'ZBAG'
            AND bag.Material_Description LIKE '%' + @Variety + '%'
            AND bag.Material_Description LIKE '%' + @Product + '%'
            AND bag.Material_Description LIKE '%' + @Generation + '%'
            AND bag.Material_Description LIKE '%' + @Grade + '%'
        LEFT JOIN TB_PriceMaster dis WITH (INDEX(IDX_TB_PriceMaster_Search))
            ON dis.Material_Number = bag.Material_Number
            AND dis.Condition_Table = bag.Condition_Table
            AND dis.Condition_Type = 'ZDIS'
        ORDER BY ctp.PriorityOrder;
    END
    -- Logic for CompanyCode = 1054
    ELSE IF @CompanyCode = '1054'
    BEGIN
        -- Get the highest priority ZB01 record directly
        SELECT TOP 1 @FinalConditionAmount = pm.Condition_Amount
        FROM @ConditionTablePriority ctp
        JOIN TB_PriceMaster pm WITH (INDEX(IDX_TB_PriceMaster_Search))
            ON pm.Condition_Table = ctp.ConditionTable
            AND pm.CompanyCode = @CompanyCode
            AND pm.Condition_Type = 'ZB01'
            AND pm.Material_Description LIKE '%' + @Variety + '%'
            AND pm.Material_Description LIKE '%' + @Product + '%'
            AND pm.Material_Description LIKE '%' + @Generation + '%'
            AND pm.Material_Description LIKE '%' + @Grade + '%'
        ORDER BY ctp.PriorityOrder;
    END
    
    -- Return the final result
    SELECT ISNULL(@FinalConditionAmount, 0) AS FinalConditionAmount;
END;
GO
