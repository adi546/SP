USE [agriuatbackup6May2025]
GO
/****** Object:  StoredProcedure [dbo].[Cleanup_StockDetails_Staging]    Script Date: 5/15/2025 4:00:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Cleanup_StockDetails_Staging]
  @BatchId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Only delete processed records, keep error records for inspection
    DELETE FROM TB_StockDetails_Staging
    WHERE BatchId = @BatchId AND ProcessingStatus = 1;
    
    -- Keep error records for 7 days, then clean them up
    -- You can schedule a job to run this periodically
    DELETE FROM TB_StockDetails_Staging
    WHERE ProcessingStatus = 2 
    AND ProcessingCompleted IS NOT NULL
    AND DATEDIFF(DAY, ProcessingCompleted, GETDATE()) > 7;
END
GO
