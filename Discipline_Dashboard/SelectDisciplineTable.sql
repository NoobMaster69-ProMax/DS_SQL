USE [DSEFACTORY]
GO

-- 1. Main Transactional Tables
SELECT * FROM [dbo].[HumanResourcesDiscipline];
SELECT * FROM [dbo].[HumanResourcesDisciplineAction];

-- 2. Lookup / Reference Tables
SELECT * FROM [dbo].[HumanResourcesDisciplineActionTaken];
SELECT * FROM [dbo].[HumanResourcesDisciplineCategory];
SELECT * FROM [dbo].[HumanResourcesDisciplineStatus];
SELECT * FROM [dbo].[HumanResourcesDisciplineSubCategory];
SELECT * FROM [dbo].[HumanResourcesDisciplineWarning];