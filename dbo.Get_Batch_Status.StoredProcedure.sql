USE [agriuatbackup6May2025]
GO
/****** Object:  StoredProcedure [dbo].[Get_Batch_Status]    Script Date: 5/15/2025 4:00:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Get_Batch_Status]
	 @BatchId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        @BatchId AS BatchId,
        COUNT(*) AS TotalRecords,
        SUM(CASE WHEN ProcessingStatus = 1 THEN 1 ELSE 0 END) AS ProcessedRecords,
        SUM(CASE WHEN ProcessingStatus = 2 THEN 1 ELSE 0 END) AS ErrorRecords,
        CASE 
            WHEN COUNT(*) = SUM(CASE WHEN ProcessingStatus = 1 THEN 1 ELSE 0 END) THEN 'Completed'
            WHEN SUM(CASE WHEN ProcessingStatus = 0 THEN 1 ELSE 0 END) > 0 THEN 'Processing'
            WHEN SUM(CASE WHEN ProcessingStatus = 2 THEN 1 ELSE 0 END) > 0 THEN 'Partially Completed with Errors'
            ELSE 'Unknown'
        END AS Status,
        MIN(ProcessingStarted) AS ProcessingStarted,
        MAX(ProcessingCompleted) AS ProcessingCompleted
    FROM TB_StockDetails_Staging
    WHERE BatchId = @BatchId;
END
GO
