USE [agriuatbackup6May2025]
GO
/****** Object:  StoredProcedure [dbo].[Process_StockDetails_FromStaging]    Script Date: 5/15/2025 4:00:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Fix the Process_StockDetails_FromStaging stored procedure
CREATE PROCEDURE [dbo].[Process_StockDetails_FromStaging]
    @BatchId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @BatchSize INT = 2500; -- Smaller batch size for better transaction management
    DECLARE @ProcessedCount INT = 0;
    
    -- Mark the batch as started processing
    UPDATE TB_StockDetails_Staging
    SET ProcessingStarted = GETDATE()
    WHERE BatchId = @BatchId AND ProcessingStatus = 0;
    
    -- Process records in smaller batches
    WHILE EXISTS (SELECT 1 FROM TB_StockDetails_Staging WHERE BatchId = @BatchId AND ProcessingStatus = 0)
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;
            
            -- Get batch of records to process
            -- Explicitly select only the columns we need for the merge
            WITH StagingBatch AS (
                SELECT TOP (@BatchSize) 
                    ID,
                    CompanyCode, 
                    Plant, 
                    Storage_Location, 
                    Description_of_Storage_Location, 
                    Material,
                    Material_Description,
                    Batch, 
                    Base_Unit_of_Measure, 
                    Unrestricted_Kgs, 
                    Stock_in_Transit
                FROM TB_StockDetails_Staging
                WHERE BatchId = @BatchId AND ProcessingStatus = 0
                ORDER BY ID
            )
            
            -- Process each record using MERGE for efficient upsert
            MERGE TB_StockDetails AS target
            USING StagingBatch AS source
            ON (
                target.CompanyCode = source.CompanyCode
                AND target.Plant = source.Plant
                AND target.Storage_Location = source.Storage_Location
                AND target.Material = source.Material
                AND target.Batch = source.Batch
            )
            WHEN MATCHED THEN
                UPDATE SET
                    target.Description_of_Storage_Location = source.Description_of_Storage_Location,
                    target.Material_Description = source.Material_Description,
                    target.Base_Unit_of_Measure = source.Base_Unit_of_Measure,
                    target.Unrestricted_Kgs = source.Unrestricted_Kgs,
                    target.Stock_in_Transit = source.Stock_in_Transit
            WHEN NOT MATCHED THEN
                INSERT (
                    CompanyCode, Plant, Storage_Location, Description_of_Storage_Location,
                    Material, Material_Description, Batch, Base_Unit_of_Measure,
                    Unrestricted_Kgs, Stock_in_Transit
                )
                VALUES (
                    source.CompanyCode, source.Plant, source.Storage_Location,
                    source.Description_of_Storage_Location, source.Material,
                    source.Material_Description, source.Batch, source.Base_Unit_of_Measure,
                    source.Unrestricted_Kgs, source.Stock_in_Transit
                );
            
            -- Mark processed records
            UPDATE TB_StockDetails_Staging
            SET 
                ProcessingStatus = 1,
                ProcessingCompleted = GETDATE()
            WHERE ID IN (
                SELECT TOP (@BatchSize) ID
                FROM TB_StockDetails_Staging
                WHERE BatchId = @BatchId AND ProcessingStatus = 0
                ORDER BY ID
            );
            
            SET @ProcessedCount = @ProcessedCount + @@ROWCOUNT;
            
            COMMIT TRANSACTION;
            
            -- Add a small delay to prevent database overload
            WAITFOR DELAY '00:00:00.010'; -- 100ms delay
            
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
                
            -- Mark failed records
            UPDATE TB_StockDetails_Staging
            SET 
                ProcessingStatus = 2,
                ErrorMessage = ERROR_MESSAGE()
            WHERE BatchId = @BatchId AND ProcessingStatus = 0
            AND ID IN (
                SELECT TOP (@BatchSize) ID
                FROM TB_StockDetails_Staging
                WHERE BatchId = @BatchId AND ProcessingStatus = 0
                ORDER BY ID
            );
        END CATCH
    END
    
    -- Return number of processed records
    SELECT @ProcessedCount AS ProcessedCount;
END
GO
