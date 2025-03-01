USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[DeleteCartItemMHZPC]    Script Date: 2/26/2025 5:29:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DeleteCartItemMHZPC]
 @CustomerCode NVARCHAR(50),
    @CartItemId INT,
    @ReturnValue INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the item exists in the customer's cart
    IF NOT EXISTS (SELECT 1 FROM TB_CartItemsMHZPC WHERE Id = @CartItemId AND CartId IN 
                   (SELECT Id FROM TB_CartMHZPC WHERE CustomerCode = @CustomerCode))
    BEGIN
        SET @ReturnValue = 0; -- Item not found
        RETURN;
    END

    -- Get the CartId associated with the item
    DECLARE @CartId INT;
    SELECT @CartId = CartId FROM TB_CartItemsMHZPC WHERE Id = @CartItemId;

    -- Delete the item from the cart
    DELETE FROM TB_CartItemsMHZPC WHERE Id = @CartItemId;

    -- Check if the cart is now empty
    IF NOT EXISTS (SELECT 1 FROM TB_CartItemsMHZPC WHERE CartId = @CartId)
    BEGIN
        -- If no more items, delete the cart header
        DELETE FROM TB_CartMHZPC WHERE Id = @CartId;
    END

    -- Set return value to 1 for success
    SET @ReturnValue = 1;
END
GO
