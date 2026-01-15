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


SET IDENTITY_INSERT [dbo].[HumanResourcesInterviewStatus] ON 

INSERT [dbo].[HumanResourcesInterviewStatus] ([ID], [InterviewStatus], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (1, N'Interview Pending', GETDATE(), 1, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[HumanResourcesInterviewStatus] ([ID], [InterviewStatus], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (2, N'Offer Pending', GETDATE(), 1, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[HumanResourcesInterviewStatus] ([ID], [InterviewStatus], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (3, N'Hired', GETDATE(), 1, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[HumanResourcesInterviewStatus] ([ID], [InterviewStatus], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (4, N'Rejected', GETDATE(), 1, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[HumanResourcesInterviewStatus] ([ID], [InterviewStatus], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (5, N'Offer Rejected', GETDATE(), 1, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[HumanResourcesInterviewStatus] ([ID], [InterviewStatus], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (6, N'KIV', GETDATE(), 1, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[HumanResourcesInterviewStatus] ([ID], [InterviewStatus], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (7, N'No Show/Withdrawn', GETDATE(), 1, NULL, NULL, NULL, NULL, 1)

SET IDENTITY_INSERT [dbo].[HumanResourcesInterviewStatus] OFF



ALTER TABLE [dbo].[HumanResourcesInterviewStatus] ADD  DEFAULT ((1)) FOR [IsActive] --IsActive is 1
GO
ALTER TABLE [dbo].[HumanResourcesInterviewStatus] ADD  DEFAULT (getdate()) FOR [InsertDate] --Date for InsertDate in HRINT
GO






ALTER TABLE [dbo].[HumanResourcesInterview] ADD  DEFAULT ((1)) FOR [IsActive] --IsActive is 1
GO
ALTER TABLE [dbo].[HumanResourcesInterview] ADD  DEFAULT (getdate()) FOR [InsertDate] --Date
GO

GO
ALTER TABLE [dbo].[HumanResourcesInterview] ADD  DEFAULT (getdate()) FOR [AppliedDate] --Date
GO
ALTER TABLE [dbo].[HumanResourcesInterview] ADD  DEFAULT (getdate()) FOR [InterviewDate] --Date
GO
ALTER TABLE [dbo].[HumanResourcesInterview] ADD  DEFAULT (getdate()) FOR [OfferDate] --Date
GO
ALTER TABLE [dbo].[HumanResourcesInterview] ADD  DEFAULT (getdate()) FOR [StartDate] --Date
GO


GO
ALTER TABLE [dbo].[HumanResourcesInterview]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesInterview_InterviewStatus] FOREIGN KEY([InterviewStatusID])
REFERENCES [dbo].[HumanResourcesInterviewStatus] ([ID])
GO
ALTER TABLE [dbo].[HumanResourcesInterview] CHECK CONSTRAINT [FK_HumanResourcesInterview_InterviewStatus]
GO


ALTER TABLE [dbo].[HumanResourcesInterview]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesInterview_Race] FOREIGN KEY([RaceID])
REFERENCES [dbo].[HumanResourcesRace] ([ID])
GO
ALTER TABLE [dbo].[HumanResourcesInterview] CHECK CONSTRAINT [FK_HumanResourcesInterview_Race]
GO


ALTER TABLE [dbo].[HumanResourcesInterview]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesInterview_Division] FOREIGN KEY([DivisionID])
REFERENCES [dbo].[HumanResourcesDivision] ([ID])
GO
ALTER TABLE [dbo].[HumanResourcesInterview] CHECK CONSTRAINT [FK_HumanResourcesInterview_Division]
GO


ALTER TABLE [dbo].[HumanResourcesInterview]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesInterview_Department] FOREIGN KEY([DepartmentID])
REFERENCES [dbo].[HumanResourcesDepartment] ([ID])
GO
ALTER TABLE [dbo].[HumanResourcesInterview] CHECK CONSTRAINT [FK_HumanResourcesInterview_Department]
GO


ALTER TABLE [dbo].[HumanResourcesInterview]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesInterview_Occupation] FOREIGN KEY([OccupationID])
REFERENCES [dbo].[HumanResourcesOccupation] ([ID])
GO
ALTER TABLE [dbo].[HumanResourcesInterview] CHECK CONSTRAINT [FK_HumanResourcesInterview_Occupation]
GO


ALTER TABLE [dbo].[HumanResourcesInterview]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesInterview_Interviewer] FOREIGN KEY([InterviewerID])
REFERENCES [dbo].[HumanResourcesEmployee] ([ID])
GO
ALTER TABLE [dbo].[HumanResourcesInterview] CHECK CONSTRAINT [FK_HumanResourcesInterview_Interviewer]
GO


ALTER TABLE [dbo].[HumanResourcesInterview]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesInterview_DecisionMaker] FOREIGN KEY([DecisionMakerID])
REFERENCES [dbo].[HumanResourcesEmployee] ([ID])
GO
ALTER TABLE [dbo].[HumanResourcesInterview] CHECK CONSTRAINT [FK_HumanResourcesInterview_DecisionMaker]
GO




	





