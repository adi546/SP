USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[AddCartItem]    Script Date: 2/26/2025 5:29:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddCartItem]
	@CartId INT,
    @PriceCardType NVARCHAR(50),
    @ProductName NVARCHAR(255),
    @ConditionAmount DECIMAL(18,2),
    @BookingPrice DECIMAL(18,2),
    @OrderQuantity INT,
    @OrderAmount DECIMAL(18,2),
    @BookingAmount DECIMAL(18,2),
    @SecondaryProductName NVARCHAR(255) = NULL,
    @SecondaryConditionAmount DECIMAL(18,2) = NULL,
    @SecondaryBookingPrice DECIMAL(18,2) = NULL,
    @SecondaryOrderQuantity INT = NULL,
    @SecondaryOrderAmount DECIMAL(18,2) = NULL,
    @SecondaryBookingAmount DECIMAL(18,2) = NULL

AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO TB_CartItemsMHZPC 
    (CartId, PriceCardType, ProductName, Condition_Amount, BookingPrice, OrderQuantity, OrderAmount, BookingAmount, 
     SecondaryProductName, SecondaryCondition_Amount, SecondaryBookingPrice, SecondaryOrderQuantity, SecondaryOrderAmount, SecondaryBookingAmount) 
    VALUES 
    (@CartId, @PriceCardType, @ProductName, @ConditionAmount, @BookingPrice, @OrderQuantity, @OrderAmount, @BookingAmount,
     @SecondaryProductName, @SecondaryConditionAmount, @SecondaryBookingPrice, @SecondaryOrderQuantity, @SecondaryOrderAmount, @SecondaryBookingAmount);
END;
GO
