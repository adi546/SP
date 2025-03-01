USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetConditionAmount]    Script Date: 2/26/2025 5:29:08 AM ******/
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

    DECLARE @MaterialNumber VARCHAR(50);
    DECLARE @ConditionTable INT;
    DECLARE @ZBAG DECIMAL(18,2);
    DECLARE @ZDIS DECIMAL(5,2);

    -- Define the priority sequence for Condition_Table
    DECLARE @ConditionTablePriority TABLE (PriorityOrder INT, ConditionTable INT);
    INSERT INTO @ConditionTablePriority (PriorityOrder, ConditionTable)
    VALUES 
        (1, 860), 
        (2, 935), 
        (3, 933), 
        (4, 862), 
        (5, 559);

    -- Use index hint in the query
    ;WITH MaterialCTE AS (
        SELECT 
            pm.Material_Number, 
            pm.Condition_Table,
            ROW_NUMBER() OVER (PARTITION BY pm.Material_Number 
                               ORDER BY ctp.PriorityOrder) AS RowNum
        FROM TB_PriceMaster pm WITH (INDEX(IDX_TB_PriceMaster_Search))  -- 💡 Force this stored procedure to use this index
        JOIN @ConditionTablePriority ctp ON pm.Condition_Table = ctp.ConditionTable
        WHERE pm.CompanyCode = @CompanyCode
          AND pm.Material_Description LIKE '%' + @Variety + '%'
          AND pm.Material_Description LIKE '%' + @Product + '%'
          AND pm.Material_Description LIKE '%' + @Generation + '%'
          AND pm.Material_Description LIKE '%' + @Grade + '%'
    )
    SELECT TOP 1 
        @MaterialNumber = Material_Number,
        @ConditionTable = Condition_Table
    FROM MaterialCTE
    WHERE RowNum = 1;

    -- Fetch prices using the forced index
    IF @MaterialNumber IS NOT NULL
    BEGIN
        -- Fetch ZBAG price (Basic Price)
        SELECT @ZBAG = Condition_Amount
        FROM TB_PriceMaster WITH (INDEX(IDX_TB_PriceMaster_Search))  -- 💡 Force the index
        WHERE Material_Number = @MaterialNumber
          AND Condition_Type = 'ZBAG'
          AND Condition_Table = @ConditionTable;

        -- Fetch ZDIS price (Discount %)
        SELECT @ZDIS = Condition_Amount
        FROM TB_PriceMaster WITH (INDEX(IDX_TB_PriceMaster_Search))  -- 💡 Force the index
        WHERE Material_Number = @MaterialNumber
          AND Condition_Type = 'ZDIS'
          AND Condition_Table = @ConditionTable;

        -- Calculate final price
        IF @ZBAG IS NOT NULL AND @ZDIS IS NOT NULL
        BEGIN
            SELECT @ZBAG - (@ZBAG * @ZDIS / 100) AS FinalConditionAmount;
        END
        ELSE
        BEGIN
            SELECT @ZBAG AS FinalConditionAmount;
        END
    END
    ELSE
    BEGIN
        SELECT NULL AS FinalConditionAmount;
    END
END;

GO
