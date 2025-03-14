USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetProducts]    Script Date: 3/15/2025 3:44:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetProducts] 
    @CompanyCode BIGINT,
	@VarietyName NVARCHAR(50) = NULL,
    @GenerationName NVARCHAR(50) = NULL,
    @GradeName NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    WITH CleanedData AS (
        SELECT DISTINCT 
            PM.CompanyCode,
            TRIM(REPLACE(REPLACE(Material_Description, '  ', ' '), '  ', ' ')) AS CleanedDescription
        FROM TB_PriceMaster PM
        WHERE PM.CompanyCode = @CompanyCode  
    ),
    SplitData AS (
        SELECT 
            CD.CompanyCode,
            CD.CleanedDescription,
            value AS Word,
            ROW_NUMBER() OVER (PARTITION BY CD.CleanedDescription ORDER BY CHARINDEX(value, CD.CleanedDescription)) AS RowNum
        FROM CleanedData CD
        CROSS APPLY STRING_SPLIT(CD.CleanedDescription, ' ')
    ),
    ProductDetails AS (
        SELECT 
            SD1.CompanyCode,
            SD1.CleanedDescription,

            -- Product Name
            CASE 
                WHEN SD1.Word = 'Potato' AND SD2.Word = 'Jyoti' 
                THEN 'Potato Jyoti'  
                ELSE CONCAT(SD1.Word, ' ', SD2.Word, ' ', SD3.Word)
            END AS ProductName,

            -- Generation Name
            CASE 
                WHEN SD1.Word = 'Potato' AND SD2.Word = 'Jyoti' 
                THEN 'G4'  
                ELSE COALESCE(SD4.Word, '') 
            END AS Generation,

            -- Grade Name
            LTRIM(RTRIM(SD_Last.Word)) AS Grade  -- Trim spaces

        FROM SplitData SD1
        JOIN SplitData SD2 ON SD1.CleanedDescription = SD2.CleanedDescription AND SD2.RowNum = 2
        JOIN SplitData SD3 ON SD1.CleanedDescription = SD3.CleanedDescription AND SD3.RowNum = 3
        LEFT JOIN SplitData SD4 ON SD1.CleanedDescription = SD4.CleanedDescription AND SD4.RowNum = 4
        LEFT JOIN (SELECT CleanedDescription, Word FROM SplitData WHERE RowNum = (SELECT MAX(RowNum) FROM SplitData S3 WHERE S3.CleanedDescription = SplitData.CleanedDescription)) AS SD_Last 
               ON SD1.CleanedDescription = SD_Last.CleanedDescription
        WHERE SD1.RowNum = 1
    )
    SELECT DISTINCT 
        PD.ProductName,
        PD.Generation,
        COALESCE(G.Size, 'Size Not Found') AS Size  -- Fix for missing size
    FROM ProductDetails PD
    LEFT JOIN TB_GradeSize G 
        ON LTRIM(RTRIM(UPPER(PD.Grade))) = LTRIM(RTRIM(UPPER(G.Grade)))
    WHERE 
        (@VarietyName IS NULL OR PD.CleanedDescription LIKE '%' + @VarietyName + '%')
        AND (@GenerationName IS NULL OR PD.Generation = @GenerationName)
        AND (@GradeName IS NULL OR PD.Grade = @GradeName);
END
GO
