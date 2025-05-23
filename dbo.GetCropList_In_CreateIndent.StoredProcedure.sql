USE [agriuatbackup6May2025]
GO
/****** Object:  StoredProcedure [dbo].[GetCropList_In_CreateIndent]    Script Date: 5/16/2025 10:13:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetCropList_In_CreateIndent]
    @CompanyCode INT
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRY
	DECLARE @CurrentDate DATE = GETDATE();
    SELECT DISTINCT  
        PM.[Crop],
        PM.[PackSize]
   FROM [dbo].[TB_PriceMaster] PM
	 WHERE ((PM.Deletion_Indicator NOT LIKE '%X%') OR (PM.Deletion_Indicator IS NULL))
	 AND (@CurrentDate >= PM.Valid_From OR PM.Valid_From IS NULL)
                AND (@CurrentDate <= PM.Valid_To OR PM.Valid_To IS NULL) 
	;
	END TRY
BEGIN CATCH
    INSERT INTO ErrorLog_dashboard (
        ErrorNumber,
        ErrorSeverity,
        ErrorState,
        ErrorProcedure,
        ErrorLine,
        ErrorMessage,
        ProcedureName
    )
    VALUES (
        ERROR_NUMBER(),
        ERROR_SEVERITY(),
        ERROR_STATE(),
        ERROR_PROCEDURE(),
        ERROR_LINE(),
        ERROR_MESSAGE(),
        'SelectDistinctCropPackSize'
    );

    -- Optionally return the error to the caller
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH

    
END;
GO
