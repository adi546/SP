USE [agriuatbackup6May2025]
GO
/****** Object:  StoredProcedure [dbo].[Add_StockDetails_Staging]    Script Date: 5/15/2025 4:00:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Add_StockDetails_Staging]
	@BatchId INT,
    @CompanyCode BIGINT, 
    @Plant NVARCHAR(5), 
    @Storage_Location VARCHAR(10), 
    @Description_of_Storage_Location NVARCHAR(40), 
    @Material NVARCHAR(15), 
    @Material_Description NVARCHAR(120), 
    @Batch NVARCHAR(20), 
    @Base_Unit_of_Measure NVARCHAR(50), 
    @Unrestricted_Kgs DECIMAL(15,3), 
    @Stock_in_Transit BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO TB_StockDetails_Staging(
            BatchId,
            CompanyCode, 
            Plant, 
            Storage_Location, 
            Description_of_Storage_Location, 
            Material,
            Material_Description,
            Batch, 
            Base_Unit_of_Measure, 
            Unrestricted_Kgs, 
            Stock_in_Transit,
            ProcessingStatus)
        VALUES (
            @BatchId,
            @CompanyCode, 
            @Plant, 
            @Storage_Location, 
            @Description_of_Storage_Location, 
            @Material, 
            @Material_Description, 
            @Batch, 
            @Base_Unit_of_Measure, 
            @Unrestricted_Kgs, 
            @Stock_in_Transit,
            0 -- Initial status: Not processed
        )
        RETURN 1; -- Success
    END TRY
    BEGIN CATCH
        RETURN 0; -- Failure
    END CATCH
END
GO
