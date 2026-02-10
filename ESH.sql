USE [DSEFACTORY]
GO
/****** Object:  Table [dbo].[HumanResourcesESH]    Script Date: 2/10/2026 4:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HumanResourcesESH](
	[No.] [int] IDENTITY(1,1) NOT NULL,
	[Reported Staff ID] [int] NOT NULL,
	[Location] [nvarchar](255) NULL,
	[Date of Incident] [datetime] NULL,
	[Incident Type] [int] NOT NULL,
	[Description] [nvarchar](255) NULL,
	[Status] [int] NOT NULL,
	[ESH Action] [int] NULL,
	[Department] [int] NULL,
	[Responsible by] [int] NULL,
	[Follow Up Date] [datetime] NULL,
	[Remarks] [nvarchar](max) NULL,
	[InsertDate] [datetime] NOT NULL,
	[InsertUserId] [int] NOT NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserId] [int] NULL,
	[DeleteDate] [datetime] NULL,
	[DeleteUserId] [int] NULL,
	[IsActive] [int] NOT NULL,
 CONSTRAINT [PK_HumanResourcesESH] PRIMARY KEY CLUSTERED 
(
	[No.] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HumanResourcesIncidentAction]    Script Date: 2/10/2026 4:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HumanResourcesIncidentAction](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Incident Action] [nvarchar](100) NOT NULL,
	[IsActive] [smallint] NOT NULL,
	[InsertDate] [datetime] NOT NULL,
	[InsertUserId] [int] NOT NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserId] [int] NULL,
	[DeleteDate] [datetime] NULL,
	[DeleteUserId] [int] NULL,
 CONSTRAINT [PK_HumanResourcesIncidentAction] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HumanResourcesIncidentStatus]    Script Date: 2/10/2026 4:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HumanResourcesIncidentStatus](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Incident Status] [nvarchar](100) NOT NULL,
	[IsActive] [smallint] NOT NULL,
	[InsertDate] [datetime] NOT NULL,
	[InsertUserId] [int] NOT NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserId] [int] NULL,
	[DeleteDate] [datetime] NULL,
	[DeleteUserId] [int] NULL,
 CONSTRAINT [PK_HumanResourcesIncidentStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HumanResourcesIncidentType]    Script Date: 2/10/2026 4:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HumanResourcesIncidentType](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Incident Type] [nvarchar](100) NOT NULL,
	[IsActive] [smallint] NOT NULL,
	[InsertDate] [datetime] NOT NULL,
	[InsertUserId] [int] NOT NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserId] [int] NULL,
	[DeleteDate] [datetime] NULL,
	[DeleteUserId] [int] NULL,
 CONSTRAINT [PK_HumanResourcesIncidentType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[HumanResourcesESH] ON 

INSERT [dbo].[HumanResourcesESH] ([No.], [Reported Staff ID], [Location], [Date of Incident], [Incident Type], [Description], [Status], [ESH Action], [Department], [Responsible by], [Follow Up Date], [Remarks], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (1, 75, N'office', CAST(N'2025-12-21T00:00:00.000' AS DateTime), 2, N'testing', 5, 4, 14, 75, CAST(N'2025-12-26T00:00:00.000' AS DateTime), N'nothing', CAST(N'2026-02-10T15:25:47.020' AS DateTime), 1, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[HumanResourcesESH] ([No.], [Reported Staff ID], [Location], [Date of Incident], [Incident Type], [Description], [Status], [ESH Action], [Department], [Responsible by], [Follow Up Date], [Remarks], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (2, 75, N'office', CAST(N'2025-12-21T00:00:00.000' AS DateTime), 2, N'testing', 4, 4, 14, 75, CAST(N'2025-12-23T00:00:00.000' AS DateTime), N'nothing', CAST(N'2026-02-10T15:25:47.020' AS DateTime), 1, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[HumanResourcesESH] ([No.], [Reported Staff ID], [Location], [Date of Incident], [Incident Type], [Description], [Status], [ESH Action], [Department], [Responsible by], [Follow Up Date], [Remarks], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (3, 2, N'office', CAST(N'2026-02-10T00:00:00.000' AS DateTime), 2, N'testing', 2, 1, 14, 1, CAST(N'2025-12-26T00:00:00.000' AS DateTime), N'nothing', CAST(N'2026-02-10T16:07:52.913' AS DateTime), 1, NULL, NULL, NULL, NULL, 1)
SET IDENTITY_INSERT [dbo].[HumanResourcesESH] OFF
GO
SET IDENTITY_INSERT [dbo].[HumanResourcesIncidentAction] ON 

INSERT [dbo].[HumanResourcesIncidentAction] ([ID], [Incident Action], [IsActive], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId]) VALUES (1, N'First Aid', 1, CAST(N'2026-02-10T15:25:47.027' AS DateTime), 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[HumanResourcesIncidentAction] ([ID], [Incident Action], [IsActive], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId]) VALUES (2, N'Warning Issued', 1, CAST(N'2026-02-10T15:25:47.027' AS DateTime), 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[HumanResourcesIncidentAction] ([ID], [Incident Action], [IsActive], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId]) VALUES (3, N'Training Provided', 1, CAST(N'2026-02-10T15:25:47.027' AS DateTime), 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[HumanResourcesIncidentAction] ([ID], [Incident Action], [IsActive], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId]) VALUES (4, N'No Action Needed', 1, CAST(N'2026-02-10T15:25:47.027' AS DateTime), 1, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[HumanResourcesIncidentAction] OFF
GO
SET IDENTITY_INSERT [dbo].[HumanResourcesIncidentStatus] ON 

INSERT [dbo].[HumanResourcesIncidentStatus] ([ID], [Incident Status], [IsActive], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId]) VALUES (1, N'Pending', 1, CAST(N'2026-02-10T15:25:47.030' AS DateTime), 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[HumanResourcesIncidentStatus] ([ID], [Incident Status], [IsActive], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId]) VALUES (2, N'In Progress', 1, CAST(N'2026-02-10T15:25:47.030' AS DateTime), 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[HumanResourcesIncidentStatus] ([ID], [Incident Status], [IsActive], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId]) VALUES (3, N'On Hold', 1, CAST(N'2026-02-10T15:25:47.030' AS DateTime), 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[HumanResourcesIncidentStatus] ([ID], [Incident Status], [IsActive], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId]) VALUES (4, N'Completed', 1, CAST(N'2026-02-10T15:25:47.030' AS DateTime), 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[HumanResourcesIncidentStatus] ([ID], [Incident Status], [IsActive], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId]) VALUES (5, N'Cancelled', 1, CAST(N'2026-02-10T15:25:47.030' AS DateTime), 1, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[HumanResourcesIncidentStatus] OFF
GO
SET IDENTITY_INSERT [dbo].[HumanResourcesIncidentType] ON 

INSERT [dbo].[HumanResourcesIncidentType] ([ID], [Incident Type], [IsActive], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId]) VALUES (1, N'Incident', 1, CAST(N'2026-02-10T15:25:47.033' AS DateTime), 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[HumanResourcesIncidentType] ([ID], [Incident Type], [IsActive], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId]) VALUES (2, N'Near Miss', 1, CAST(N'2026-02-10T15:25:47.033' AS DateTime), 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[HumanResourcesIncidentType] ([ID], [Incident Type], [IsActive], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId]) VALUES (3, N'On Hold', 1, CAST(N'2026-02-10T15:25:47.033' AS DateTime), 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[HumanResourcesIncidentType] ([ID], [Incident Type], [IsActive], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId]) VALUES (4, N'Safety Inspection', 1, CAST(N'2026-02-10T15:25:47.033' AS DateTime), 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[HumanResourcesIncidentType] ([ID], [Incident Type], [IsActive], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId]) VALUES (5, N'Training', 1, CAST(N'2026-02-10T15:25:47.033' AS DateTime), 1, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[HumanResourcesIncidentType] OFF
GO
ALTER TABLE [dbo].[HumanResourcesESH] ADD  DEFAULT (getdate()) FOR [InsertDate]
GO
ALTER TABLE [dbo].[HumanResourcesESH] ADD  DEFAULT ((1)) FOR [InsertUserId]
GO
ALTER TABLE [dbo].[HumanResourcesESH] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[HumanResourcesIncidentAction] ADD  DEFAULT (getdate()) FOR [InsertDate]
GO
ALTER TABLE [dbo].[HumanResourcesIncidentAction] ADD  DEFAULT ((1)) FOR [InsertUserId]
GO
ALTER TABLE [dbo].[HumanResourcesIncidentStatus] ADD  DEFAULT (getdate()) FOR [InsertDate]
GO
ALTER TABLE [dbo].[HumanResourcesIncidentStatus] ADD  DEFAULT ((1)) FOR [InsertUserId]
GO
ALTER TABLE [dbo].[HumanResourcesIncidentType] ADD  DEFAULT (getdate()) FOR [InsertDate]
GO
ALTER TABLE [dbo].[HumanResourcesIncidentType] ADD  DEFAULT ((1)) FOR [InsertUserId]
GO
ALTER TABLE [dbo].[HumanResourcesESH]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesESH_Action] FOREIGN KEY([ESH Action])
REFERENCES [dbo].[HumanResourcesIncidentAction] ([ID])
GO
ALTER TABLE [dbo].[HumanResourcesESH] CHECK CONSTRAINT [FK_HumanResourcesESH_Action]
GO
ALTER TABLE [dbo].[HumanResourcesESH]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesESH_Department] FOREIGN KEY([Department])
REFERENCES [dbo].[HumanResourcesDepartment] ([ID])
GO
ALTER TABLE [dbo].[HumanResourcesESH] CHECK CONSTRAINT [FK_HumanResourcesESH_Department]
GO
ALTER TABLE [dbo].[HumanResourcesESH]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesESH_Employee] FOREIGN KEY([Reported Staff ID])
REFERENCES [dbo].[HumanResourcesEmployee] ([ID])
GO
ALTER TABLE [dbo].[HumanResourcesESH] CHECK CONSTRAINT [FK_HumanResourcesESH_Employee]
GO
ALTER TABLE [dbo].[HumanResourcesESH]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesESH_IncidentType] FOREIGN KEY([Incident Type])
REFERENCES [dbo].[HumanResourcesIncidentType] ([ID])
GO
ALTER TABLE [dbo].[HumanResourcesESH] CHECK CONSTRAINT [FK_HumanResourcesESH_IncidentType]
GO
ALTER TABLE [dbo].[HumanResourcesESH]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesESH_ResponsibleBy] FOREIGN KEY([Responsible by])
REFERENCES [dbo].[HumanResourcesEmployee] ([ID])
GO
ALTER TABLE [dbo].[HumanResourcesESH] CHECK CONSTRAINT [FK_HumanResourcesESH_ResponsibleBy]
GO
ALTER TABLE [dbo].[HumanResourcesESH]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesESH_Status] FOREIGN KEY([Status])
REFERENCES [dbo].[HumanResourcesIncidentStatus] ([ID])
GO
ALTER TABLE [dbo].[HumanResourcesESH] CHECK CONSTRAINT [FK_HumanResourcesESH_Status]
GO
