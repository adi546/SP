USE [agriuatbackup6May2025]
GO
/****** Object:  StoredProcedure [dbo].[CheckCartItemsDivisions]    Script Date: 5/15/2025 7:27:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CheckCartItemsDivisions]
    @CartId NVARCHAR(50),
    @HasSameDivision BIT OUTPUT,
    @DivisionName NVARCHAR(100) OUTPUT,
    @ErrorMessage NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DivisionCount INT;
    DECLARE @ItemCount INT;

    -- Step 1: Check if cart has any non-deleted items
    SELECT @ItemCount = COUNT(CartItemId)
    FROM TB_Cart_Items
    WHERE CartId = @CartId AND DeletedAt IS NULL;

    IF @ItemCount = 0
    BEGIN
        SET @HasSameDivision = 0;
        SET @DivisionName = NULL;
        SET @ErrorMessage = 'Cart is empty or does not exist.';
        RETURN;
    END

    -- Step 2: Count DISTINCT non-null divisions
    SELECT @DivisionCount = COUNT(DISTINCT Division)
    FROM TB_Cart_Items
    WHERE CartId = @CartId AND DeletedAt IS NULL AND Division IS NOT NULL;

    -- Step 3: Check if all items belong to the same division
    IF @DivisionCount = 1
    BEGIN
        SELECT TOP 1 @DivisionName = Division
        FROM TB_Cart_Items
        WHERE CartId = @CartId AND DeletedAt IS NULL AND Division IS NOT NULL;

        SET @HasSameDivision = 1;
        SET @ErrorMessage = 'All items belong to the same division: ' + @DivisionName;
    END
    ELSE
    BEGIN
        SET @HasSameDivision = 0;
        SET @DivisionName = NULL;
        SET @ErrorMessage = 'Items in cart belong to multiple divisions. All items must be from the same division to proceed.';
    END
END
GO
