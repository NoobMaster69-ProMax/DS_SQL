USE [DSEFACTORY];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[Dashboard_HumanResourceDashboard_Interview]
AS
BEGIN
    SET NOCOUNT ON;

    /* ============================================================
       0) Current month window (by InterviewDate)
       ============================================================ */
    DECLARE @MonthStart DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    DECLARE @MonthEnd   DATE = DATEADD(MONTH, 1, @MonthStart);

    /* ============================================================
       1) Template temp table for schema
          - NEW: InterviewDate column
       ============================================================ */
    IF OBJECT_ID('tempdb..#HRModule') IS NOT NULL DROP TABLE #HRModule;

    CREATE TABLE #HRModule
    (
        DivisionID          INT            NULL,
        DivisionName        NVARCHAR(200)  NULL,

        DepartmentID        INT            NULL,
        DepartmentName      NVARCHAR(200)  NULL,

        InterviewDate       DATE           NULL,   -- NEW (actual date bucket)

        FormattedDate       NVARCHAR(20)   NULL,   -- yyyy-MM (month label)
        InsertDate          DATE           NULL,   -- for sorting/filtering (uses InterviewDate; monthstart for null)

        TotalInterview      INT            NOT NULL,

        InterviewPending    INT            NOT NULL,
        OfferPending        INT            NOT NULL,
        Hired               INT            NOT NULL,
        Rejected            INT            NOT NULL,
        OfferRejected       INT            NOT NULL,
        KIV                 INT            NOT NULL,
        NoShowWithdrawn     INT            NOT NULL,

        InterviewStatusNull INT            NOT NULL,

        SuccessRatePct      DECIMAL(9,2)   NOT NULL,
        AggInsertDate       DATETIME       NOT NULL
    );

    /* ============================================================
       2) Ensure target table exists & structure matches
       ============================================================ */
    DECLARE @DBName SYSNAME = 'DSEFACTORY_AGG';
    DECLARE @SchemaName SYSNAME = 'dbo';
    DECLARE @TableName SYSNAME = 'HumanResourceDashboard_Interview';
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
    TRUNCATE TABLE DSEFACTORY_AGG.dbo.HumanResourceDashboard_Interview;

    /* ============================================================
       4) Staging
       ============================================================ */
    DECLARE @temp TABLE
    (
        DivisionID          INT            NULL,
        DivisionName        NVARCHAR(200)  NULL,

        DepartmentID        INT            NULL,
        DepartmentName      NVARCHAR(200)  NULL,

        InterviewDate       DATE           NULL,

        FormattedDate       NVARCHAR(20)   NULL,
        InsertDate          DATE           NULL,

        TotalInterview      INT            NOT NULL,

        InterviewPending    INT            NOT NULL,
        OfferPending        INT            NOT NULL,
        Hired               INT            NOT NULL,
        Rejected            INT            NOT NULL,
        OfferRejected       INT            NOT NULL,
        KIV                 INT            NOT NULL,
        NoShowWithdrawn     INT            NOT NULL,

        InterviewStatusNull INT            NOT NULL,

        SuccessRatePct      DECIMAL(9,2)   NOT NULL,
        AggInsertDate       DATETIME       NOT NULL
    );

    /* ============================================================
       5) Build Valid Division-Department map from org structure
       ============================================================ */
    ;WITH OrgStart AS
    (
        SELECT
            eh.EmployeeRowId,
            eh.HierarchyId AS DepartmentID,
            eh.ParentRowID
        FROM DSEFACTORY_ORI.DSEFACTORY.dbo.HumanResourcesSplitOrganisationStructure eh
        WHERE eh.HierarchyLevel = 2
          AND eh.HierarchyId IS NOT NULL
    ),
    RecursiveUp AS
    (
        SELECT
            os.EmployeeRowId,
            os.DepartmentID,
            os.ParentRowID,
            NULL AS DivisionID
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
        SELECT DISTINCT
            DivisionID,
            DepartmentID
        FROM RecursiveUp
        WHERE DivisionID IS NOT NULL
          AND DepartmentID IS NOT NULL
    ),

    /* ============================================================
       6) Date grid (all InterviewDate days in current month + one NULL date)
       ============================================================ */
    DateGrid AS
    (
        SELECT DISTINCT CAST(i.InterviewDate AS date) AS InterviewDate
        FROM DSEFACTORY_ORI.DSEFACTORY.dbo.HumanResourcesInterview i
        WHERE i.IsActive = 1
          AND i.InterviewDate >= @MonthStart
          AND i.InterviewDate <  @MonthEnd

        UNION ALL
        SELECT CAST(NULL AS date)
    ),

    /* ============================================================
       7) BaseGrid = (Date x ValidMap) + (Date x NULL ORG) + (Date x MISMATCH)
       ============================================================ */
    BaseGrid AS
    (
        SELECT
            dg.InterviewDate,
            vm.DivisionID,
            dv.Name AS DivisionName,
            vm.DepartmentID,
            dp.Name AS DepartmentName
        FROM DateGrid dg
        CROSS JOIN ValidMap vm
        JOIN DSEFACTORY_ORI.DSEFACTORY.dbo.HumanResourcesDivision   dv ON dv.ID = vm.DivisionID
        JOIN DSEFACTORY_ORI.DSEFACTORY.dbo.HumanResourcesDepartment dp ON dp.ID = vm.DepartmentID

        UNION ALL
        SELECT dg.InterviewDate, NULL, N'(NULL ORG)', NULL, N'(NULL ORG)'
        FROM DateGrid dg

        UNION ALL
        SELECT dg.InterviewDate, -1, N'(MISMATCH ORG)', -1, N'(MISMATCH ORG)'
        FROM DateGrid dg
    ),

    /* ============================================================
       8) Normalize each interview row into bucket keys (NO subquery in GROUP BY)
          Rule you requested:
            - If InterviewDate IS NULL => Division/Department forced to NULL ORG bucket
       ============================================================ */
    Normalized AS
    (
        SELECT
            CAST(i.InterviewDate AS date) AS InterviewDateKey,

            i.DivisionID   AS RawDivisionID,
            i.DepartmentID AS RawDepartmentID,

            CASE WHEN vm.DivisionID IS NULL THEN 0 ELSE 1 END AS IsValidPair,

            COALESCE(i.HrStatus, i.InterviewStatusID) AS StatusKey,
            CASE WHEN i.HrStatus IS NULL AND i.InterviewStatusID IS NULL THEN 1 ELSE 0 END AS StatusIsNull
        FROM DSEFACTORY_ORI.DSEFACTORY.dbo.HumanResourcesInterview i
        LEFT JOIN ValidMap vm
               ON vm.DivisionID = i.DivisionID
              AND vm.DepartmentID = i.DepartmentID
        WHERE i.IsActive = 1
          AND (
                (i.InterviewDate >= @MonthStart AND i.InterviewDate < @MonthEnd)
                OR i.InterviewDate IS NULL
              )
          AND (
                COALESCE(i.HrStatus, i.InterviewStatusID) IN (1,2,3,4,5,6,7)
                OR (i.HrStatus IS NULL AND i.InterviewStatusID IS NULL)
              )
    ),
    Agg AS
    (
        SELECT
            /* InterviewDate bucket */
            InterviewDateKey AS InterviewDate,

            /* Division bucket */
            CASE
                WHEN InterviewDateKey IS NULL THEN NULL
                WHEN RawDivisionID IS NULL OR RawDepartmentID IS NULL THEN NULL
                WHEN IsValidPair = 0 THEN -1
                ELSE RawDivisionID
            END AS DivisionID,

            /* Department bucket */
            CASE
                WHEN InterviewDateKey IS NULL THEN NULL
                WHEN RawDivisionID IS NULL OR RawDepartmentID IS NULL THEN NULL
                WHEN IsValidPair = 0 THEN -1
                ELSE RawDepartmentID
            END AS DepartmentID,

            COUNT(*) AS TotalInterview,

            SUM(CASE WHEN StatusKey = 1 THEN 1 ELSE 0 END) AS InterviewPending,
            SUM(CASE WHEN StatusKey = 2 THEN 1 ELSE 0 END) AS OfferPending,
            SUM(CASE WHEN StatusKey = 3 THEN 1 ELSE 0 END) AS Hired,
            SUM(CASE WHEN StatusKey = 4 THEN 1 ELSE 0 END) AS Rejected,
            SUM(CASE WHEN StatusKey = 5 THEN 1 ELSE 0 END) AS OfferRejected,
            SUM(CASE WHEN StatusKey = 6 THEN 1 ELSE 0 END) AS KIV,
            SUM(CASE WHEN StatusKey = 7 THEN 1 ELSE 0 END) AS NoShowWithdrawn,

            SUM(StatusIsNull) AS InterviewStatusNull
        FROM Normalized
        GROUP BY
            InterviewDateKey,
            CASE
                WHEN InterviewDateKey IS NULL THEN NULL
                WHEN RawDivisionID IS NULL OR RawDepartmentID IS NULL THEN NULL
                WHEN IsValidPair = 0 THEN -1
                ELSE RawDivisionID
            END,
            CASE
                WHEN InterviewDateKey IS NULL THEN NULL
                WHEN RawDivisionID IS NULL OR RawDepartmentID IS NULL THEN NULL
                WHEN IsValidPair = 0 THEN -1
                ELSE RawDepartmentID
            END
    )

    /* ============================================================
       9) Insert into staging using NULL-safe join
       ============================================================ */
    INSERT INTO @temp
    (
        DivisionID, DivisionName,
        DepartmentID, DepartmentName,
        InterviewDate,
        FormattedDate, InsertDate,
        TotalInterview,
        InterviewPending, OfferPending, Hired, Rejected, OfferRejected, KIV, NoShowWithdrawn,
        InterviewStatusNull,
        SuccessRatePct,
        AggInsertDate
    )
    SELECT
        bg.DivisionID,
        bg.DivisionName,
        bg.DepartmentID,
        bg.DepartmentName,

        bg.InterviewDate,

        FORMAT(@MonthStart, 'yyyy-MM') AS FormattedDate,
        ISNULL(bg.InterviewDate, @MonthStart) AS InsertDate,

        ISNULL(a.TotalInterview, 0) AS TotalInterview,
        ISNULL(a.InterviewPending, 0),
        ISNULL(a.OfferPending, 0),
        ISNULL(a.Hired, 0),
        ISNULL(a.Rejected, 0),
        ISNULL(a.OfferRejected, 0),
        ISNULL(a.KIV, 0),
        ISNULL(a.NoShowWithdrawn, 0),

        ISNULL(a.InterviewStatusNull, 0),

        CASE
            WHEN ISNULL(a.TotalInterview, 0) > 0
                THEN ROUND(ISNULL(a.Hired, 0) * 100.0 / ISNULL(a.TotalInterview, 0), 2)
            ELSE 0
        END AS SuccessRatePct,

        GETDATE() AS AggInsertDate
    FROM BaseGrid bg
    LEFT JOIN Agg a
      ON ( (a.InterviewDate = bg.InterviewDate) OR (a.InterviewDate IS NULL AND bg.InterviewDate IS NULL) )
     AND ( (a.DivisionID   = bg.DivisionID)   OR (a.DivisionID   IS NULL AND bg.DivisionID   IS NULL) )
     AND ( (a.DepartmentID = bg.DepartmentID) OR (a.DepartmentID IS NULL AND bg.DepartmentID IS NULL) );

    /* ============================================================
       10) Add TOTAL row per InterviewDate (including NULL InterviewDate)
       ============================================================ */
    INSERT INTO @temp
    (
        DivisionID, DivisionName,
        DepartmentID, DepartmentName,
        InterviewDate,
        FormattedDate, InsertDate,
        TotalInterview,
        InterviewPending, OfferPending, Hired, Rejected, OfferRejected, KIV, NoShowWithdrawn,
        InterviewStatusNull,
        SuccessRatePct,
        AggInsertDate
    )
    SELECT
        NULL, N'TOTAL',
        NULL, N'TOTAL',
        InterviewDate,
        FORMAT(@MonthStart, 'yyyy-MM'),
        ISNULL(InterviewDate, @MonthStart),

        SUM(TotalInterview),
        SUM(InterviewPending),
        SUM(OfferPending),
        SUM(Hired),
        SUM(Rejected),
        SUM(OfferRejected),
        SUM(KIV),
        SUM(NoShowWithdrawn),
        SUM(InterviewStatusNull),

        CASE
            WHEN SUM(TotalInterview) > 0 THEN ROUND(SUM(Hired) * 100.0 / SUM(TotalInterview), 2)
            ELSE 0
        END,
        GETDATE()
    FROM @temp
    WHERE NOT (DivisionName = N'TOTAL' AND DepartmentName = N'TOTAL')
    GROUP BY InterviewDate;

    /* ============================================================
       11) Final insert into AGG table
       ============================================================ */
    INSERT INTO DSEFACTORY_AGG.dbo.HumanResourceDashboard_Interview
    (
        DivisionID, DivisionName,
        DepartmentID, DepartmentName,
        InterviewDate,
        FormattedDate, InsertDate,
        TotalInterview,
        InterviewPending, OfferPending, Hired, Rejected, OfferRejected, KIV, NoShowWithdrawn,
        InterviewStatusNull,
        SuccessRatePct,
        AggInsertDate
    )
    SELECT
        DivisionID, DivisionName,
        DepartmentID, DepartmentName,
        InterviewDate,
        FormattedDate, InsertDate,
        TotalInterview,
        InterviewPending, OfferPending, Hired, Rejected, OfferRejected, KIV, NoShowWithdrawn,
        InterviewStatusNull,
        SuccessRatePct,
        AggInsertDate
    FROM @temp
    ORDER BY
        CASE WHEN InterviewDate IS NULL THEN 1 ELSE 0 END,
        InterviewDate,
        CASE
            WHEN DivisionName = 'TOTAL' AND DepartmentName = 'TOTAL' THEN 0
            WHEN DivisionName = '(NULL ORG)' AND DepartmentName = '(NULL ORG)' THEN 1
            WHEN DivisionName = '(MISMATCH ORG)' AND DepartmentName = '(MISMATCH ORG)' THEN 2
            ELSE 3
        END,
        ISNULL(DivisionID, 999999),
        ISNULL(DepartmentID, 999999);
END
GO
