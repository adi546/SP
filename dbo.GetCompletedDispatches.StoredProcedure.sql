USE [mazuagricusmssql01-db-db]
GO
/****** Object:  StoredProcedure [dbo].[GetCompletedDispatches]    Script Date: 3/25/2025 6:20:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetCompletedDispatches]
    @UserCode NVARCHAR(50),
    @CustomerCode NVARCHAR(50) = NULL
AS
BEGIN
  DECLARE @RoleId INT;

    -- Get the RoleId of the logged-in user
    SELECT @RoleId = UM.RoleId
    FROM Users UM
    WHERE UM.UserCode = @UserCode;

    -- CTE to find all TMs under the given higher authority
    WITH UserHierarchy AS (
        SELECT UserCode FROM Users WHERE UserCode = @UserCode
        UNION ALL
        SELECT U.UserCode FROM Users U 
        INNER JOIN UserHierarchy UH ON U.RepManCode = UH.UserCode
    )
    SELECT 
        DR.*, 
		DO.SoNumber,
        IH.BillingDocument AS InvoiceNumber
		
    FROM DispatchRequests DR
    INNER JOIN DealerOrderMHZPC DO ON DR.OrderNumber = DO.OrderNumber 
                                     AND DR.ProductId = DO.ProductId
    INNER JOIN TB_InvoiceHeader IH ON DO.SoNumber = IH.SalesOrderNo AND SalesOrganisation = 'MZ01'
    WHERE DR.DispatchStatus = 'Complete'
	AND (
            -- Case 1: Customers (RoleId = 1) can only see their own dispatches
            (@RoleId = 1 AND DR.CustomerCode = @UserCode)

            -- Case 2: Territory Manager (TM) (RoleId = 2)
            OR (@RoleId = 2 AND 
                (
                    (@CustomerCode IS NOT NULL AND DR.CustomerCode = @CustomerCode)
                    OR (@CustomerCode IS NULL AND DR.CustomerCode IN 
                        (SELECT CustomerCode FROM TB_CustomerMaster WHERE TM = @UserCode AND CompanyCode = '1054'))
                )
            )

            -- Case 3: Higher Authorities (RoleId > 2)
            OR (@RoleId > 2 AND 
                (
                    -- Fetch specific customer if provided
                    (@CustomerCode IS NOT NULL AND DR.CustomerCode = @CustomerCode)

                    -- Fetch all customers under this authority if no specific customer is provided
                    OR (@CustomerCode IS NULL AND DR.CustomerCode IN 
                        (SELECT CustomerCode FROM TB_CustomerMaster 
                         WHERE TM IN (SELECT UserCode FROM UserHierarchy)
                        )
                    )
                )
            )
        );
END
GO
