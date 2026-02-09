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

    /* ============================================================
       0) Current year window
       ============================================================ */
    DECLARE @YearStart DATE = DATEFROMPARTS(YEAR(GETDATE()), 1, 1);
    DECLARE @NextYear  DATE = DATEADD(YEAR, 1, @YearStart);

    /* ============================================================
       1) Template temp table for schema
       ============================================================ */
    IF OBJECT_ID('tempdb..#ESHModule') IS NOT NULL DROP TABLE #ESHModule;

    CREATE TABLE #ESHModule
    (
        MetricName     NVARCHAR(100) NOT NULL,  -- 'TotalIncident'
        [Year]         INT           NOT NULL,

        [Jan]          INT           NOT NULL,
        [Feb]          INT           NOT NULL,
        [Mar]          INT           NOT NULL,
        [Apr]          INT           NOT NULL,
        [May]          INT           NOT NULL,
        [Jun]          INT           NOT NULL,
        [Jul]          INT           NOT NULL,
        [Aug]          INT           NOT NULL,
        [Sep]          INT           NOT NULL,
        [Oct]          INT           NOT NULL,
        [Nov]          INT           NOT NULL,
        [Dec]          INT           NOT NULL,

        YearTotal      INT           NOT NULL,

        AggInsertDate  DATETIME      NOT NULL
    );

    /* ============================================================
       2) Ensure target table exists & structure matches
       ============================================================ */
    DECLARE @DBName SYSNAME = 'DSEFACTORY_AGG';
    DECLARE @SchemaName SYSNAME = 'dbo';
    DECLARE @TableName SYSNAME = 'HumanResourceDashboard_ESH';
    DECLARE @TableData SYSNAME = '#ESHModule';

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
    TRUNCATE TABLE DSEFACTORY_AGG.dbo.HumanResourceDashboard_ESH;

    /* ============================================================
       4) Insert ONE row with 12 month columns (current year)
          - ISNULL to guarantee 0 instead of NULL
       ============================================================ */
    INSERT INTO DSEFACTORY_AGG.dbo.HumanResourceDashboard_ESH
    (
        MetricName, [Year],
        [Jan],[Feb],[Mar],[Apr],[May],[Jun],[Jul],[Aug],[Sep],[Oct],[Nov],[Dec],
        YearTotal,
        AggInsertDate
    )
    SELECT
        N'TotalIncident' AS MetricName,
        YEAR(@YearStart) AS [Year],

        ISNULL(SUM(CASE WHEN e.[Date of Incident] IS NOT NULL AND MONTH(e.[Date of Incident]) = 1  THEN 1 ELSE 0 END), 0) AS [Jan],
        ISNULL(SUM(CASE WHEN e.[Date of Incident] IS NOT NULL AND MONTH(e.[Date of Incident]) = 2  THEN 1 ELSE 0 END), 0) AS [Feb],
        ISNULL(SUM(CASE WHEN e.[Date of Incident] IS NOT NULL AND MONTH(e.[Date of Incident]) = 3  THEN 1 ELSE 0 END), 0) AS [Mar],
        ISNULL(SUM(CASE WHEN e.[Date of Incident] IS NOT NULL AND MONTH(e.[Date of Incident]) = 4  THEN 1 ELSE 0 END), 0) AS [Apr],
        ISNULL(SUM(CASE WHEN e.[Date of Incident] IS NOT NULL AND MONTH(e.[Date of Incident]) = 5  THEN 1 ELSE 0 END), 0) AS [May],
        ISNULL(SUM(CASE WHEN e.[Date of Incident] IS NOT NULL AND MONTH(e.[Date of Incident]) = 6  THEN 1 ELSE 0 END), 0) AS [Jun],
        ISNULL(SUM(CASE WHEN e.[Date of Incident] IS NOT NULL AND MONTH(e.[Date of Incident]) = 7  THEN 1 ELSE 0 END), 0) AS [Jul],
        ISNULL(SUM(CASE WHEN e.[Date of Incident] IS NOT NULL AND MONTH(e.[Date of Incident]) = 8  THEN 1 ELSE 0 END), 0) AS [Aug],
        ISNULL(SUM(CASE WHEN e.[Date of Incident] IS NOT NULL AND MONTH(e.[Date of Incident]) = 9  THEN 1 ELSE 0 END), 0) AS [Sep],
        ISNULL(SUM(CASE WHEN e.[Date of Incident] IS NOT NULL AND MONTH(e.[Date of Incident]) = 10 THEN 1 ELSE 0 END), 0) AS [Oct],
        ISNULL(SUM(CASE WHEN e.[Date of Incident] IS NOT NULL AND MONTH(e.[Date of Incident]) = 11 THEN 1 ELSE 0 END), 0) AS [Nov],
        ISNULL(SUM(CASE WHEN e.[Date of Incident] IS NOT NULL AND MONTH(e.[Date of Incident]) = 12 THEN 1 ELSE 0 END), 0) AS [Dec],

        ISNULL(COUNT(CASE WHEN e.[Date of Incident] IS NOT NULL THEN 1 END), 0) AS YearTotal,

        GETDATE() AS AggInsertDate
    FROM dbo.HumanResourcesESH e
    WHERE e.[Date of Incident] >= @YearStart
      AND e.[Date of Incident] <  @NextYear;
END
GO
