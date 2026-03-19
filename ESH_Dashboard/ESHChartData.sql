USE [DSEFACTORY];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[Dashboard_HumanResourceDashboard_ESH]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentYear INT = YEAR(GETDATE());

    IF OBJECT_ID('tempdb..#HRModule') IS NOT NULL DROP TABLE #HRModule;

    CREATE TABLE #HRModule
    (
        DivisionID         INT            NOT NULL,
        DivisionName       NVARCHAR(200)  NOT NULL,
        DepartmentID       INT            NOT NULL,
        DepartmentName     NVARCHAR(200)  NOT NULL,
        [Month]            INT            NOT NULL,
        FormattedDate      NVARCHAR(20)   NOT NULL,
        InsertDate         DATE           NOT NULL,
        TotalIncidents     INT            NOT NULL,
        AggInsertDate      DATETIME       NOT NULL
    );

    DECLARE @DBName SYSNAME = 'DSEFACTORY_AGG';
    DECLARE @SchemaName SYSNAME = 'dbo';
    DECLARE @TableName SYSNAME = 'HumanResourceDashboard_ESH';
    DECLARE @TableData SYSNAME = '#HRModule';

    DECLARE @FullTable NVARCHAR(MAX) =
        QUOTENAME(@DBName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName);

    IF OBJECT_ID(@FullTable, 'U') IS NULL
    BEGIN
        EXEC('SELECT * INTO ' + @FullTable + ' FROM ' + @TableData + ' WHERE 1 = 0;');
    END
    ELSE
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM (
                SELECT COLUMN_NAME, DATA_TYPE
                FROM tempdb.INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME LIKE @TableData + '%'
            ) AS temp
            FULL OUTER JOIN (
                SELECT COLUMN_NAME, DATA_TYPE
                FROM [DSEFACTORY_AGG].INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME = @TableName AND TABLE_SCHEMA = @SchemaName
            ) AS real
              ON temp.COLUMN_NAME = real.COLUMN_NAME
             AND temp.DATA_TYPE   = real.DATA_TYPE
            WHERE temp.COLUMN_NAME IS NULL OR real.COLUMN_NAME IS NULL
        )
        BEGIN
            EXEC('DROP TABLE ' + @FullTable + ';');
            EXEC('SELECT * INTO ' + @FullTable + ' FROM ' + @TableData + ' WHERE 1 = 0;');
        END
    END

    TRUNCATE TABLE DSEFACTORY_AGG.dbo.HumanResourceDashboard_ESH;

    ;WITH OrgStart AS
    (
        SELECT eh.EmployeeRowId, eh.HierarchyId AS DepartmentID, eh.ParentRowID
        FROM DSEFACTORY_ORI.DSEFACTORY.dbo.HumanResourcesSplitOrganisationStructure eh
        WHERE eh.HierarchyLevel = 2
          AND eh.HierarchyId IS NOT NULL
    ),
    RecursiveUp AS
    (
        SELECT os.EmployeeRowId, os.DepartmentID, os.ParentRowID, NULL AS DivisionID
        FROM OrgStart os

        UNION ALL

        SELECT
            ru.EmployeeRowId,
            ru.DepartmentID,
            p.ParentRowID,
            CASE WHEN p.HierarchyLevel = 1 THEN p.HierarchyId ELSE ru.DivisionID END
        FROM DSEFACTORY_ORI.DSEFACTORY.dbo.HumanResourcesSplitOrganisationStructure p
        JOIN RecursiveUp ru ON p.ID = ru.ParentRowID
        WHERE p.IsActive = 1
    ),
    ValidMap AS
    (
        SELECT DISTINCT DivisionID, DepartmentID
        FROM RecursiveUp
        WHERE DivisionID IS NOT NULL
          AND DepartmentID IS NOT NULL
    ),
    BaseOrg AS
    (
        SELECT
            vm.DivisionID,
            dv.Name AS DivisionName,
            vm.DepartmentID,
            dp.Name AS DepartmentName
        FROM ValidMap vm
        JOIN DSEFACTORY_ORI.DSEFACTORY.dbo.HumanResourcesDivision dv
            ON dv.ID = vm.DivisionID
        JOIN DSEFACTORY_ORI.DSEFACTORY.dbo.HumanResourcesDepartment dp
            ON dp.ID = vm.DepartmentID
    ),
    Months AS
    (
        SELECT 1 AS [Month]
        UNION ALL SELECT 2
        UNION ALL SELECT 3
        UNION ALL SELECT 4
        UNION ALL SELECT 5
        UNION ALL SELECT 6
        UNION ALL SELECT 7
        UNION ALL SELECT 8
        UNION ALL SELECT 9
        UNION ALL SELECT 10
        UNION ALL SELECT 11
        UNION ALL SELECT 12
    ),
    OrgMonth AS
    (
        SELECT
            bo.DivisionID,
            bo.DivisionName,
            bo.DepartmentID,
            bo.DepartmentName,
            m.[Month],
            DATEFROMPARTS(@CurrentYear, m.[Month], 1) AS MonthStart
        FROM BaseOrg bo
        CROSS JOIN Months m
    ),
    NormalizedIncidents AS
    (
        SELECT
            e.DivisionID,
            e.DepartmentID,
            MONTH(esh.[Date of Incident]) AS [Month]
        FROM dbo.HumanResourcesESH esh
        INNER JOIN dbo.HumanResourcesEmployee e
            ON esh.[Reported Staff ID] = e.ID
        INNER JOIN ValidMap vm
            ON vm.DivisionID = e.DivisionID
           AND vm.DepartmentID = e.DepartmentID
        WHERE esh.IsActive = 1
          AND esh.[Date of Incident] IS NOT NULL
          AND YEAR(esh.[Date of Incident]) = @CurrentYear
    ),
    AggIncidents AS
    (
        SELECT
            DivisionID,
            DepartmentID,
            [Month],
            COUNT(*) AS TotalIncidents
        FROM NormalizedIncidents
        GROUP BY DivisionID, DepartmentID, [Month]
    )
    INSERT INTO DSEFACTORY_AGG.dbo.HumanResourceDashboard_ESH
    (
        DivisionID,
        DivisionName,
        DepartmentID,
        DepartmentName,
        [Month],
        FormattedDate,
        InsertDate,
        TotalIncidents,
        AggInsertDate
    )
    SELECT
        om.DivisionID,
        om.DivisionName,
        om.DepartmentID,
        om.DepartmentName,
        om.[Month],
        CONVERT(VARCHAR(7), om.MonthStart, 120) AS FormattedDate,
        om.MonthStart AS InsertDate,
        ISNULL(ai.TotalIncidents, 0) AS TotalIncidents,
        GETDATE() AS AggInsertDate
    FROM OrgMonth om
    LEFT JOIN AggIncidents ai
        ON ai.DivisionID = om.DivisionID
       AND ai.DepartmentID = om.DepartmentID
       AND ai.[Month] = om.[Month]
    ORDER BY
        om.DivisionID,
        om.DepartmentID,
        om.[Month];
END
GO