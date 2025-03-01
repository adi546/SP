USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[Delete_CartItem]    Script Date: 2/26/2025 5:29:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Delete_CartItem]
		@CompanyCode bigint,@CartItemId bigint
AS
BEGIN

	SET NOCOUNT ON;
	IF EXISTS (SELECT 1 FROM TB_Cart_Items WHERE CompanyCode = @CompanyCode and @CartItemId=CartItemId)
    BEGIN
        -- Delete the customer record from the table
        DELETE FROM TB_Cart_Items
        WHERE CompanyCode = @CompanyCode and @CartItemId=CartItemId;

		RETURN 1  -- Indicating success

		END
    ELSE
    BEGIN
        -- If customer does not exist, return a message
        RETURN 0  -- Indicating failure
    END
END
GO
