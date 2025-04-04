USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[InsertPriceCard]    Script Date: 4/1/2025 6:49:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[InsertPriceCard]
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
    @SecondaryVariety NVARCHAR(100) = NULL,
    @SecondaryProduct NVARCHAR(100) = NULL,
    @SecondaryGeneration NVARCHAR(50) = NULL,
    @SecondaryGrade NVARCHAR(50) = NULL,
    @SecondaryBookingPrice DECIMAL(18,2) = NULL,
    @SecondaryRatio BIGINT = NULL
	
AS
BEGIN

BEGIN TRY
 INSERT INTO TB_PriceCard (
        PriceCardType, Variety, Product, Generation, Grade, BookingPrice,State,
        PrimaryRatio, SecondaryVariety, SecondaryProduct, SecondaryGeneration, 
        SecondaryGrade, SecondaryBookingPrice, SecondaryRatio, CreatedOn
    )
    VALUES (
        @PriceCardType, @Variety, @Product, @Generation, @Grade, @BookingPrice,@State,
        @PrimaryRatio, @SecondaryVariety, @SecondaryProduct, @SecondaryGeneration,
        @SecondaryGrade, @SecondaryBookingPrice, @SecondaryRatio, GETDATE()
    );
	 RETURN 1  -- Indicating success
    END TRY
    BEGIN CATCH
        RETURN 0  -- Indicating failure
    END CATCH
 
END
GO
