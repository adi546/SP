USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetAllStates]    Script Date: 2/26/2025 5:29:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetAllStates] 
	
AS
BEGIN
	 SELECT Id, StateName FROM TB_States ORDER BY StateName;
END
GO
