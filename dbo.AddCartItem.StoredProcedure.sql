USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[AddCartItem]    Script Date: 4/11/2025 2:42:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddCartItem]
	@CartId INT,
    @PriceCardType NVARCHAR(50),
    @ProductName NVARCHAR(255),
	@Generation NVARCHAR(50),
	@Grade NVARCHAR(50),
    @ConditionAmount DECIMAL(18,2),
    @BookingPrice DECIMAL(18,2),
    @OrderQuantity FLOAT,
    @OrderAmount DECIMAL(18,2),
    @BookingAmount DECIMAL(18,2),
	@BalanceAmountToPay DECIMAL(18,2),
    @SecondaryProductName NVARCHAR(255) = NULL,
	@SecondaryGeneration NVARCHAR(50) = NULL,
	@SecondaryGrade NVARCHAR(50) = NULL,
    @SecondaryConditionAmount DECIMAL(18,2) = NULL,
    @SecondaryBookingPrice DECIMAL(18,2) = NULL,
    @SecondaryOrderQuantity FLOAT = NULL,
    @SecondaryOrderAmount DECIMAL(18,2) = NULL,
    @SecondaryBookingAmount DECIMAL(18,2) = NULL,
	@SecondaryBalanceAmountToPay DECIMAL(18,2) = NULL,
	@PrimaryRatio BIGINT = NULL,
    @SecondaryRatio BIGINT = NULL

AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO TB_CartItemsMHZPC 
    (CartId, PriceCardType, ProductName,Generation,Grade, Condition_Amount, BookingPrice, OrderQuantity, OrderAmount, BookingAmount, BalanceAmountToPay,
     SecondaryProductName,SecondaryGeneration,SecondaryGrade, SecondaryCondition_Amount, SecondaryBookingPrice, SecondaryOrderQuantity, SecondaryOrderAmount, SecondaryBookingAmount, SecondaryBalanceAmountToPay, PrimaryRatio,SecondaryRatio ) 
    VALUES 
    (@CartId, @PriceCardType, @ProductName, @Generation,@Grade, @ConditionAmount, @BookingPrice, @OrderQuantity, @OrderAmount, @BookingAmount, @BalanceAmountToPay,
     @SecondaryProductName,@SecondaryGeneration,@SecondaryGrade, @SecondaryConditionAmount, @SecondaryBookingPrice, @SecondaryOrderQuantity, @SecondaryOrderAmount, @SecondaryBookingAmount,@SecondaryBalanceAmountToPay, @PrimaryRatio, @SecondaryRatio );
END;
GO
