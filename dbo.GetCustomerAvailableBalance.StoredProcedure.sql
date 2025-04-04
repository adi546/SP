USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetCustomerAvailableBalance]    Script Date: 4/3/2025 1:47:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetCustomerAvailableBalance]
	 @CustomerCode NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT TOP 1 TotalAvailableBalance
    FROM TB_CustomerTransaction
    WHERE CustomerCode = @CustomerCode
    ORDER BY LastUpdated DESC
END
GO
