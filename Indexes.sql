CREATE NONCLUSTERED INDEX IX_StockDetails_MergeKey 
ON TB_StockDetails (CompanyCode, Plant, Storage_Location, Material, Batch);

CREATE NONCLUSTERED INDEX IX_StockDetailsStaging_BatchId_Status 
ON TB_StockDetails_Staging (BatchId, ProcessingStatus);
