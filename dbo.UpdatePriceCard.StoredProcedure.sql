USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[UpdatePriceCard]    Script Date: 4/1/2025 6:49:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdatePriceCard]
    @Id INT,
    @PriceCardType NVARCHAR(10),
    
    -- Common Fields
    @Variety NVARCHAR(100),
    @Product NVARCHAR(100),
    @Generation NVARCHAR(50),
    @Grade NVARCHAR(50),
    @BookingPrice DECIMAL(18,2),
	@State NVARCHAR(30),

    -- Fields for Combo (Nullable for Single)
    @PrimaryRatio BIGINT = NULL, 
    @SecondaryVariety NVARCHAR(100)= NULL,
    @SecondaryProduct NVARCHAR(100)= NULL,
    @SecondaryGeneration NVARCHAR(50)= NULL,
    @SecondaryGrade NVARCHAR(50)= NULL,
    @SecondaryBookingPrice DECIMAL(18,2)= NULL,
    @SecondaryRatio BIGINT = NULL
	
AS
BEGIN
	 BEGIN TRY
	 IF EXISTS (SELECT 1 FROM TB_PriceCard WHERE Id = @Id)
        BEGIN
        UPDATE TB_PriceCard
        SET PriceCardType = @PriceCardType,
            Variety = @Variety,
            Product = @Product,
            Generation = @Generation,
            Grade = @Grade,
            BookingPrice = @BookingPrice,
			State = @State,
			PrimaryRatio = @PrimaryRatio,
			SecondaryVariety = @SecondaryVariety,
			SecondaryProduct = @SecondaryProduct,
			SecondaryGeneration = @SecondaryGeneration,
			SecondaryGrade = @SecondaryGrade,
			SecondaryBookingPrice = @SecondaryBookingPrice,
			SecondaryRatio = @SecondaryRatio
			
			
        WHERE Id = @Id;

        RETURN 1; -- Success
    END
        ELSE
        BEGIN
            RETURN 0; -- Not found
        END
    END TRY
    BEGIN CATCH
        RETURN -1; -- Error
    END CATCH
END
GO
