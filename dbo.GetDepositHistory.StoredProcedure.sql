USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetDepositHistory]    Script Date: 4/2/2025 7:32:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetDepositHistory]
   @CustomerCode NVARCHAR(50) = NULL,
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL,
    @Status NVARCHAR(50) = NULL,
    @UserId NVARCHAR(50) = NULL,
    @RoleId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        db.Id,
        db.CustomerCode,
        db.PaymentDate,
        db.AmountPaid,
        db.TransactionReferenceNo,
        db.ReceiptPath,
        db.Status,
        db.CreatedAt,
        db.ApprovedAt
    FROM 
        TB_DepositBalance db
    WHERE 
        (
            -- Allow TM or FI users to see all deposits
            (@RoleId = 2 OR @RoleId = 8)
            -- OR filter by customer code if provided
            OR (@CustomerCode IS NOT NULL AND db.CustomerCode = @CustomerCode)
        )
        -- Additional filters
        AND (@FromDate IS NULL OR db.PaymentDate >= @FromDate)
        AND (@ToDate IS NULL OR db.PaymentDate <= @ToDate)
        AND (@Status IS NULL OR db.Status = @Status)
    ORDER BY 
        db.CreatedAt DESC;
        
END
GO
