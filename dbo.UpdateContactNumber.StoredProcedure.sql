USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[UpdateContactNumber]    Script Date: 3/15/2025 2:53:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateContactNumber]
    @CompanyCode BIGINT,
    @UserCode NVARCHAR(50),
    @RoleId INT,
    @NewContactNumber NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowsAffected INT = 0;

    IF @RoleId = 1
    BEGIN
        UPDATE TB_CustomerMaster
        SET Telephone = @NewContactNumber
        WHERE CompanyCode = @CompanyCode AND CustomerCode = @UserCode;

        SET @RowsAffected = @@ROWCOUNT;
    END
    ELSE IF @RoleId BETWEEN 2 AND 7
    BEGIN
        UPDATE Users
        SET ContactNumber = @NewContactNumber
        WHERE CompanyCode = @CompanyCode AND UserCode = @UserCode;

        SET @RowsAffected = @@ROWCOUNT;
    END

    SELECT @RowsAffected AS RowsAffected;
END
GO
