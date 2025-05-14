USE [agriuatbackup6May2025]
GO

/****** Updated Schema with Batch Management ******/

-- Add BatchId column to the staging table if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.columns 
          WHERE Name = N'BatchId'
          AND Object_ID = Object_ID(N'TB_StockDetails_Staging'))
BEGIN
    ALTER TABLE TB_StockDetails_Staging
    ADD BatchId INT NOT NULL DEFAULT 0
END

-- Add ProcessingStarted and ProcessingCompleted columns if they don't exist
IF NOT EXISTS (SELECT 1 FROM sys.columns 
          WHERE Name = N'ProcessingStarted'
          AND Object_ID = Object_ID(N'TB_StockDetails_Staging'))
BEGIN
    ALTER TABLE TB_StockDetails_Staging
    ADD ProcessingStarted DATETIME NULL
END

IF NOT EXISTS (SELECT 1 FROM sys.columns 
          WHERE Name = N'ProcessingCompleted'
          AND Object_ID = Object_ID(N'TB_StockDetails_Staging'))
BEGIN
    ALTER TABLE TB_StockDetails_Staging
    ADD ProcessingCompleted DATETIME NULL
END

-- Create index on BatchId for better performance
IF NOT EXISTS (SELECT 1 FROM sys.indexes 
          WHERE Name = N'IX_TB_StockDetails_Staging_BatchId'
          AND Object_ID = Object_ID(N'TB_StockDetails_Staging'))
BEGIN
    CREATE INDEX IX_TB_StockDetails_Staging_BatchId
    ON TB_StockDetails_Staging(BatchId)
END