USE [DSEFACTORY];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[Dashboard_HumanResourceDashboard_Interview2]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MonthStart DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    DECLARE @MonthEnd   DATE = DATEADD(MONTH, 1, @MonthStart);

    /* ============================================================
       1) Template temp table
       ============================================================ */
    IF OBJECT_ID('tempdb..#HRStatus') IS NOT NULL DROP TABLE #HRStatus;

    CREATE TABLE #HRStatus
    (
        DivisionID           INT            NOT NULL,
        DivisionName         NVARCHAR(200)  NOT NULL,

        DepartmentID         INT            NOT NULL,
        DepartmentName       NVARCHAR(200)  NOT NULL,

        FormattedDate        NVARCHAR(20)   NOT NULL,  -- yyyy-MM
        InsertDate           DATE           NOT NULL,  -- MonthStart

        InterviewStatusID    INT            NOT NULL,
        InterviewStatusName  NVARCHAR(100)  NOT NULL,

        Cnt                  INT            NOT NULL,

        AggInsertDate        DATETIME       NOT NULL
    );

    /* ============================================================
       2) Ensure target table exists & matches schema
       ============================================================ */
    DECLARE @DBName SYSNAME = 'DSEFACTORY_AGG';
    DECLARE @SchemaName SYSNAME = 'dbo';
    DECLARE @TableName SYSNAME = 'HumanResourceDashboard_Interview2';
    DECLARE @TableData SYSNAME = '#HRStatus';

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
    TRUNCATE TABLE DSEFACTORY_AGG.dbo.HumanResourceDashboard_Interview2;

    /* ============================================================
       4) Build org grid + aggregate by status (1–7 only)
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
        JOIN DSEFACTORY_ORI.DSEFACTORY.dbo.HumanResourcesDivision dv ON dv.ID = vm.DivisionID
        JOIN DSEFACTORY_ORI.DSEFACTORY.dbo.HumanResourcesDepartment dp ON dp.ID = vm.DepartmentID
    ),
    StatusDim AS
    (
        SELECT 1 AS InterviewStatusID, N'Interview Pending'   AS InterviewStatusName UNION ALL
        SELECT 2, N'Offer Pending'                             UNION ALL
        SELECT 3, N'Hired'                                     UNION ALL
        SELECT 4, N'Rejected'                                  UNION ALL
        SELECT 5, N'Offer Rejected'                            UNION ALL
        SELECT 6, N'KIV'                                       UNION ALL
        SELECT 7, N'No Show / Withdrawn'
    ),
    BaseGrid AS
    (
        SELECT
            bo.DivisionID,
            bo.DivisionName,
            bo.DepartmentID,
            bo.DepartmentName,
            sd.InterviewStatusID,
            sd.InterviewStatusName
        FROM BaseOrg bo
        CROSS JOIN StatusDim sd
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
            StatusKey AS InterviewStatusID,
            COUNT(*) AS Cnt
        FROM Normalized
        GROUP BY DivisionID, DepartmentID, StatusKey
    )
    INSERT INTO DSEFACTORY_AGG.dbo.HumanResourceDashboard_Interview2
    (
        DivisionID, DivisionName,
        DepartmentID, DepartmentName,
        FormattedDate, InsertDate,
        InterviewStatusID, InterviewStatusName,
        Cnt,
        AggInsertDate
    )
    SELECT
        bg.DivisionID,
        bg.DivisionName,
        bg.DepartmentID,
        bg.DepartmentName,
        FORMAT(@MonthStart, 'yyyy-MM'),
        @MonthStart,
        bg.InterviewStatusID,
        bg.InterviewStatusName,
        ISNULL(a.Cnt, 0),
        GETDATE()
    FROM BaseGrid bg
    LEFT JOIN Agg a
      ON a.DivisionID = bg.DivisionID
     AND a.DepartmentID = bg.DepartmentID
     AND a.InterviewStatusID = bg.InterviewStatusID
    ORDER BY
        bg.InterviewStatusID,
        bg.DivisionID,
        bg.DepartmentID;

    /* Return ordered result set */
    SELECT *
    FROM DSEFACTORY_AGG.dbo.HumanResourceDashboard_Interview2
    ORDER BY InterviewStatusID, DivisionID, DepartmentID;
END
GO
