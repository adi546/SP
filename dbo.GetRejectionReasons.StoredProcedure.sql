USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetRejectionReasons]    Script Date: 3/13/2025 7:50:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetRejectionReasons]
	
AS
BEGIN
 SELECT Id, Reason FROM RejectionReasons
END
GO
