USE [DSEFACTORY]

/****** Object:  Table [dbo].[HumanResourcesInterviewStatus]    Script Date: 11/29/2025 9:54:53 AM ******/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE [dbo].[HumanResourcesInterviewStatus] --master table
(
    [ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[InterviewStatus] [NVARCHAR](200) NULL,
	[InsertDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[DeleteDate] [datetime] NULL,
	[IsActive] [smallint] NOT NULL,
	[InsertUserId] [int] NULL,
	[DeleteUserId] [int] NULL,
	[UpdateUserId] [int] NULL,

 CONSTRAINT [PK_HumanResourcesInterviewStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[HumanResourcesInterview]    Script Date: 11/29/2025 10:00:53 AM ******/

CREATE TABLE [dbo].[HumanResourcesInterview]
(
    [ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CandidateName] [nvarchar](256)NULL,
	[NRIC] [NVARCHAR](50)NULL,
	[Age] [INT]NULL,
	[Email][NVARCHAR](256)NULL,
	[TEL][NVARCHAR](50)NULL,
	[Education][NVARCHAR](256)NULL,
	[RaceID][INT]NULL,
	[SexID][INT]NULL,
	--[NationalityID][INT]NULL,
	[Address][NVARCHAR](256)NULL,
	[DivisionID][INT]NULL,
	[DepartmentID][INT]NULL,
	[OccupationID][INT]NULL,
	[AppliedDate][DATETIME]NULL,
	[InterviewDate][DATETIME]NULL,
	[InterviewerID][INT]NULL,
	[ExpectedSalary][DECIMAL]NULL,
	[InterviewStatusID][INT]NULL,
	[Comment][NVARCHAR](max)NULL,
	[OfferDate][DATETIME]NULL,
	[StartDate][DATETIME]NULL,
	[Remarks][NVARCHAR](max)NULL,
	[DocumentUpload][NVARCHAR](max)NULL,
	[DecisionMakerID][INT]NULL,
	[DecisionMadeDate][DATETIME]NULL,
	[RejectedBy][INT]NULL,
	[HrStatus] [int] NULL,
	[HrUpdated] [int] NULL,
	[HrRejectReason] [nvarchar](max) NULL,
	[InsertDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[DeleteDate] [datetime] NULL,
	[IsActive] [int] NULL,
	[InsertUserId] [int] NULL,
	[DeleteUserId] [int] NULL,
	[UpdateUserId] [int] NULL,




	CONSTRAINT [PK_HumanResourcesInterview] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO















	





