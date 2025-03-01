USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetSecondaryRatioByPrimary]    Script Date: 2/26/2025 5:29:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetSecondaryRatioByPrimary]
  @PrimaryRatio BIGINT,
    @SecondaryRatio BIGINT OUTPUT,
    @Status INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate range
    IF @PrimaryRatio < 1 OR @PrimaryRatio > 9
    BEGIN
        SET @Status = 0;
        RETURN;
    END

    -- Calculate SecondaryRatio
    SET @SecondaryRatio = 10 - @PrimaryRatio;
    SET @Status = 1;
END;
GO
