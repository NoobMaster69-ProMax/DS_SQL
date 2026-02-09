USE [DSEFACTORY];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[Dashboard_HumanResourceDashboard_Interview_Get_ChartData]
    @Filter     NVARCHAR(MAX) = NULL,
    @Structure  INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql         NVARCHAR(MAX) = N'';
    DECLARE @finalFilter NVARCHAR(MAX) = N'';
    DECLARE @orderBy     NVARCHAR(MAX) = N'';

    -- Source table (Interview dashboard AGG)
    DECLARE @sourceTableName NVARCHAR(256) =
        N'[DSEFACTORY_AGG].dbo.[HumanResourceDashboard_Interview]';

    DECLARE @debugSQL NVARCHAR(MAX);

    -- Parsed filter conditions from your TVF
    DECLARE @ParsedConditions TABLE
    (
        ColumnName  NVARCHAR(100),
        Operator    NVARCHAR(100),
        ColumnValue NVARCHAR(100)
    );

    -- Used for @Structure=2 and building ORDER BY for @Structure=0
    DECLARE @StructureTable TABLE
    (
        name NVARCHAR(MAX),
        type NVARCHAR(MAX)
    );

    /* ============================================================
       1) Parse filter string (if provided)
       ============================================================ */
    IF @Filter IS NOT NULL AND LTRIM(RTRIM(@Filter)) <> ''
    BEGIN
        INSERT INTO @ParsedConditions
        SELECT *
        FROM dbo.Dashboard_ColumnNameValue_TVF(@Filter);
    END

    /* ============================================================
       2) Structure modes
       ============================================================ */
    IF @Structure = 1
    BEGIN
        -- Debug: show one row
        SET @debugSQL = N'SELECT TOP 1 * FROM ' + @sourceTableName + N';';
        EXEC sp_executesql @debugSQL;
        RETURN;
    END
    ELSE IF @Structure = 2
    BEGIN
        -- Return column structure: "col type,col type,..."
        INSERT INTO @StructureTable (name, type)
        SELECT
            name,
            system_type_name
        FROM sys.dm_exec_describe_first_result_set(
            N'SELECT TOP 1 * FROM ' + @sourceTableName,
            NULL,
            0
        );

        SELECT STRING_AGG(name + N' ' + type, N',')
        FROM @StructureTable;

        RETURN;
    END

    /* ============================================================
       3) @Structure = 0 (normal data output)
       - Build ORDER BY based on date/datetime columns
       ============================================================ */
    INSERT INTO @StructureTable (name, type)
    SELECT
        name,
        system_type_name
    FROM sys.dm_exec_describe_first_result_set(
        N'SELECT TOP 1 * FROM ' + @sourceTableName,
        NULL,
        0
    );

    -- order by date/datetime columns (like your reference proc)
    -- NOTE: dm_exec_describe_first_result_set returns system_type_name like 'date', 'datetime', 'datetime2(7)' etc.
    SET @orderBy =
    (
        SELECT STRING_AGG(QUOTENAME(name) + N' ASC', N',')
        FROM @StructureTable
        WHERE type LIKE 'date%'
           OR type LIKE 'datetime%'
    );

    IF @orderBy IS NOT NULL AND @orderBy <> ''
        SET @orderBy = N' ORDER BY ' + @orderBy;
    ELSE
        SET @orderBy = N''; -- no ordering if no date/datetime col

    /* ============================================================
       4) Build final WHERE clause (safe-ish dynamic filter)
       ============================================================ */
    IF @Filter IS NULL OR LTRIM(RTRIM(@Filter)) = ''
    BEGIN
        SET @sql = N'SELECT * FROM ' + @sourceTableName + @orderBy + N';';
    END
    ELSE
    BEGIN
        /*
          Build: [ColumnName] Operator 'Value' AND ...
          - Only allow common operators
          - Optional: validate column exists in result-set (kept ON here)
        */
        SELECT @finalFilter =
            STRING_AGG(
                QUOTENAME(pc.ColumnName) + N' ' + pc.Operator + N' ' + QUOTENAME(pc.ColumnValue, ''''),
                N' AND '
            )
        FROM @ParsedConditions pc
        WHERE pc.Operator IN (N'=', N'>', N'<', N'>=', N'<=', N'<>', N'LIKE')
          AND EXISTS
          (
              SELECT 1
              FROM @StructureTable st
              WHERE st.name = pc.ColumnName
          );

        IF @finalFilter IS NULL OR LTRIM(RTRIM(@finalFilter)) = ''
        BEGIN
            -- If parsing produced nothing valid, fail clearly
            RAISERROR('Filter provided but no valid parsed conditions were produced (or columns/operators invalid).', 16, 1);
            RETURN;
        END

        SET @sql = N'SELECT * FROM ' + @sourceTableName + N' WHERE ' + @finalFilter + @orderBy + N';';
    END

    /* ============================================================
       5) Execute
       ============================================================ */
    BEGIN TRY
        EXEC sp_executesql @sql;
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
        PRINT 'SQL: ' + @sql;
    END CATCH
END
GO


/* ===========================
   Example tests (Serenity)
   =========================== */

-- 1) normal data
-- EXEC dbo.Dashboard_HumanResourceDashboard_Interview_Get_ChartData;

-- 2) debug top 1
-- EXEC dbo.Dashboard_HumanResourceDashboard_Interview_Get_ChartData @Structure = 1;

-- 3) show structure
-- EXEC dbo.Dashboard_HumanResourceDashboard_Interview_Get_ChartData @Structure = 2;

-- 4) filtered example (depends on your TVF format)
-- EXEC dbo.Dashboard_HumanResourceDashboard_Interview_Get_ChartData
--     @Filter = N'DivisionID=1 AND FormattedDate=2026-01',
--     @Structure = 0;

-- 5) filter by InsertDate (date) and DepartmentID
-- EXEC dbo.Dashboard_HumanResourceDashboard_Interview_Get_ChartData
--     @Filter = N'InsertDate>=2026-01-01 AND DepartmentID=5',
--     @Structure = 0;
