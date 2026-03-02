USE [DSEFACTORY];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[Dashboard_HumanResourceDashboard_Discipline]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MonthStart DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    DECLARE @MonthEnd   DATE = DATEADD(MONTH, 1, @MonthStart);

    /* ============================================================
       1) Template temp table for schema
       ============================================================ */
    IF OBJECT_ID('tempdb..#HRModule') IS NOT NULL DROP TABLE #HRModule;

    CREATE TABLE #HRModule
    (
        DivisionID         INT            NOT NULL,
        DivisionName       NVARCHAR(200)  NOT NULL,

        DepartmentID       INT            NOT NULL,
        DepartmentName     NVARCHAR(200)  NOT NULL,

        FormattedDate      NVARCHAR(20)   NOT NULL,   -- yyyy-MM
        InsertDate         DATE           NOT NULL,   -- MonthStart

        TotalIncidents     INT            NOT NULL,

        AggInsertDate      DATETIME       NOT NULL
    );

    /* ============================================================
       2) Ensure target table exists & structure matches template
       ============================================================ */
    DECLARE @DBName SYSNAME = 'DSEFACTORY_AGG';
    DECLARE @SchemaName SYSNAME = 'dbo';
    DECLARE @TableName SYSNAME = 'HumanResourceDashboard_Discipline';
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

    /* ============================================================
       3) Refresh target table
       ============================================================ */
    TRUNCATE TABLE DSEFACTORY_AGG.dbo.HumanResourceDashboard_Discipline;

    /* ============================================================
       4) Valid Division–Department mapping + Monthly aggregation
       ============================================================ */
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
    -- Base logic to gather incidents mapping via Employee table
    NormalizedIncidents AS
    (
        SELECT
            e.DivisionID,
            e.DepartmentID
        FROM DSEFACTORY_ORI.DSEFACTORY.dbo.HumanResourcesDiscipline d
        -- Need Employee table to bridge Staff ID to their Department/Division
        INNER JOIN DSEFACTORY_ORI.DSEFACTORY.dbo.HumanResourcesEmployee e 
            ON d.[Staff ID] = e.ID
        INNER JOIN ValidMap vm
            ON vm.DivisionID   = e.DivisionID
           AND vm.DepartmentID = e.DepartmentID
        WHERE d.IsActive = 1
          AND d.[Date of Incident] >= @MonthStart
          AND d.[Date of Incident] <  @MonthEnd
    ),
    AggIncidents AS
    (
        SELECT
            DivisionID,
            DepartmentID,
            COUNT(*) AS TotalIncidents
        FROM NormalizedIncidents
        GROUP BY DivisionID, DepartmentID
    )

    /* ============================================================
       5) Final Insert
       ============================================================ */
    INSERT INTO DSEFACTORY_AGG.dbo.HumanResourceDashboard_Discipline
    (
        DivisionID, DivisionName,
        DepartmentID, DepartmentName,
        FormattedDate, InsertDate,
        TotalIncidents,
        AggInsertDate
    )
    SELECT
        bo.DivisionID,
        bo.DivisionName,
        bo.DepartmentID,
        bo.DepartmentName,
        FORMAT(@MonthStart, 'yyyy-MM'),
        @MonthStart,
        ISNULL(ai.TotalIncidents, 0),
        GETDATE() AS AggInsertDate
    FROM BaseOrg bo
    LEFT JOIN AggIncidents ai
      ON ai.DivisionID   = bo.DivisionID
     AND ai.DepartmentID = bo.DepartmentID
    ORDER BY
        bo.DivisionID,
        bo.DepartmentID;
END
GO