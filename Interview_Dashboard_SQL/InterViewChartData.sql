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

    DECLARE @MonthStart DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    DECLARE @MonthEnd   DATE = DATEADD(MONTH, 1, @MonthStart);

    /* ============================================================
       1) Template temp table for schema
       ============================================================ */
    IF OBJECT_ID('tempdb..#HRModule') IS NOT NULL DROP TABLE #HRModule;

    CREATE TABLE #HRModule
    (
        DivisionID       INT            NOT NULL,
        DivisionName     NVARCHAR(200)  NOT NULL,

        DepartmentID     INT            NOT NULL,
        DepartmentName   NVARCHAR(200)  NOT NULL,

        FormattedDate    NVARCHAR(20)   NOT NULL,   -- yyyy-MM
        InsertDate       DATE           NOT NULL,   -- MonthStart

        TotalInterview   INT            NOT NULL,

        InterviewPending INT            NOT NULL,
        OfferPending     INT            NOT NULL,
        Hired            INT            NOT NULL,
        Rejected         INT            NOT NULL,
        OfferRejected    INT            NOT NULL,
        KIV              INT            NOT NULL,
        NoShowWithdrawn  INT            NOT NULL,

        SuccessRatePct   DECIMAL(9,2)   NOT NULL,
        AggInsertDate    DATETIME       NOT NULL
    );

    /* ============================================================
       2) Ensure target table exists & structure matches template
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
    Normalized AS
    (
        SELECT
            i.DivisionID,
            i.DepartmentID,
            COALESCE(i.HrStatus, i.InterviewStatusID) AS StatusKey
        FROM DSEFACTORY_ORI.DSEFACTORY.dbo.HumanResourcesInterview i
        INNER JOIN ValidMap vm
            ON vm.DivisionID   = i.DivisionID
           AND vm.DepartmentID = i.DepartmentID
        WHERE i.IsActive = 1
          AND i.InterviewDate >= @MonthStart
          AND i.InterviewDate <  @MonthEnd
          AND COALESCE(i.HrStatus, i.InterviewStatusID) IN (1,2,3,4,5,6,7)
    ),
    Agg AS
    (
        SELECT
            DivisionID,
            DepartmentID,
            COUNT(*) AS TotalInterview,
            SUM(CASE WHEN StatusKey = 1 THEN 1 ELSE 0 END) AS InterviewPending,
            SUM(CASE WHEN StatusKey = 2 THEN 1 ELSE 0 END) AS OfferPending,
            SUM(CASE WHEN StatusKey = 3 THEN 1 ELSE 0 END) AS Hired,
            SUM(CASE WHEN StatusKey = 4 THEN 1 ELSE 0 END) AS Rejected,
            SUM(CASE WHEN StatusKey = 5 THEN 1 ELSE 0 END) AS OfferRejected,
            SUM(CASE WHEN StatusKey = 6 THEN 1 ELSE 0 END) AS KIV,
            SUM(CASE WHEN StatusKey = 7 THEN 1 ELSE 0 END) AS NoShowWithdrawn
        FROM Normalized
        GROUP BY DivisionID, DepartmentID
    )
    INSERT INTO DSEFACTORY_AGG.dbo.HumanResourceDashboard_Interview
    (
        DivisionID, DivisionName,
        DepartmentID, DepartmentName,
        FormattedDate, InsertDate,
        TotalInterview,
        InterviewPending, OfferPending, Hired, Rejected,
        OfferRejected, KIV, NoShowWithdrawn,
        SuccessRatePct,
        AggInsertDate
    )
    SELECT
        bo.DivisionID,
        bo.DivisionName,
        bo.DepartmentID,
        bo.DepartmentName,
        FORMAT(@MonthStart, 'yyyy-MM'),
        @MonthStart,
        ISNULL(a.TotalInterview, 0),
        ISNULL(a.InterviewPending, 0),
        ISNULL(a.OfferPending, 0),
        ISNULL(a.Hired, 0),
        ISNULL(a.Rejected, 0),
        ISNULL(a.OfferRejected, 0),
        ISNULL(a.KIV, 0),
        ISNULL(a.NoShowWithdrawn, 0),
        CASE
            WHEN ISNULL(a.TotalInterview, 0) > 0
                THEN ROUND(ISNULL(a.Hired, 0) * 100.0 / a.TotalInterview, 2)
            ELSE 0
        END AS SuccessRatePct,
        GETDATE() AS AggInsertDate
    FROM BaseOrg bo
    LEFT JOIN Agg a
      ON a.DivisionID   = bo.DivisionID
     AND a.DepartmentID = bo.DepartmentID
    ORDER BY
        bo.DivisionID,
        bo.DepartmentID;
END
GO
