USE DSEFACTORY
SET IDENTITY_INSERT [dbo].[HumanResourcesInterviewStatus] ON 

INSERT [dbo].[HumanResourcesInterviewStatus] ([ID], [InterviewStatus], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (1, N'Interview Pending', GETDATE(), 1, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[HumanResourcesInterviewStatus] ([ID], [InterviewStatus], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (2, N'Offer Pending', GETDATE(), 1, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[HumanResourcesInterviewStatus] ([ID], [InterviewStatus], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (3, N'Hired', GETDATE(), 1, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[HumanResourcesInterviewStatus] ([ID], [InterviewStatus], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (4, N'Rejected', GETDATE(), 1, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[HumanResourcesInterviewStatus] ([ID], [InterviewStatus], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (5, N'Offer Rejected', GETDATE(), 1, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[HumanResourcesInterviewStatus] ([ID], [InterviewStatus], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (6, N'KIV', GETDATE(), 1, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[HumanResourcesInterviewStatus] ([ID], [InterviewStatus], [InsertDate], [InsertUserId], [UpdateDate], [UpdateUserId], [DeleteDate], [DeleteUserId], [IsActive]) VALUES (7, N'No Show/Withdrawn', GETDATE(), 1, NULL, NULL, NULL, NULL, 1)

SET IDENTITY_INSERT [dbo].[HumanResourcesInterviewStatus] OFF


