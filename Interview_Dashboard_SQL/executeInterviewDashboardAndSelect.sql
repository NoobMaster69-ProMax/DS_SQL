USE [DSEFACTORY]
GO

DECLARE @RC int

-- TODO: Set parameter values here.

EXECUTE @RC = [dbo].[Dashboard_HumanResourceDashboard_Interview] 
GO

SELECT *
FROM DSEFACTORY_AGG.dbo.HumanResourceDashboard_Interview
order by DivisionID, DepartmentID

