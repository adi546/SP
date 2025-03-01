USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[Get_PriceCard]    Script Date: 2/26/2025 5:29:08 AM ******/
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
        pc.SecondaryState,
        pc.Status
    FROM TB_PriceCard pc
    LEFT JOIN TB_GradeSize gs ON pc.Grade = gs.Grade
    LEFT JOIN TB_GradeSize gs2 ON pc.SecondaryGrade = gs2.Grade
    WHERE 
        (@Status = 1 OR pc.Status = @Status)
        AND (@PriceCardType IS NULL OR pc.PriceCardType = @PriceCardType)
        AND (@Variety IS NULL OR pc.Variety = @Variety);
END;
GO
