USE [DSEFACTORY];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[Dashboard_HumanResourceDashboard_Interview_Get_ChartData2]
    @Filter     NVARCHAR(MAX) = NULL,
    @Structure  INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql         NVARCHAR(MAX) = N'';
    DECLARE @finalFilter NVARCHAR(MAX) = N'';
    DECLARE @orderBy     NVARCHAR(MAX) = N'';
    DECLARE @debugSQL    NVARCHAR(MAX);

    -- Source table (Interview2 dashboard AGG)
    DECLARE @sourceTableName NVARCHAR(256) =
        N'[DSEFACTORY_AGG].dbo.[HumanResourceDashboard_Interview2]';

    -- Parsed filter conditions from your TVF
    DECLARE @ParsedConditions TABLE
    (
        ColumnName  NVARCHAR(100),
        Operator    NVARCHAR(100),
        ColumnValue NVARCHAR(100)
    );

    -- For @Structure=2 and for validating columns + building ORDER BY
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
        SET @debugSQL = N'SELECT TOP 1 * FROM ' + @sourceTableName + N';';
        EXEC sp_executesql @debugSQL;
        RETURN;
    END
    ELSE IF @Structure = 2
    BEGIN
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
       3) @Structure = 0 (normal output)
       - Build ORDER BY based on date/datetime columns (same pattern)
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
        SET @orderBy = N'';

    /* ============================================================
       4) Build final WHERE clause from parsed conditions
       ============================================================ */
    IF @Filter IS NULL OR LTRIM(RTRIM(@Filter)) = ''
    BEGIN
        SET @sql = N'SELECT * FROM ' + @sourceTableName + @orderBy + N';';
    END
    ELSE
    BEGIN
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
