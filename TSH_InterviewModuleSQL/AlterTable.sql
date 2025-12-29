USE [DSEFACTORY]

ALTER TABLE [dbo].[HumanResourcesInterviewStatus] ADD  DEFAULT ((1)) FOR [IsActive] --IsActive is 1
GO
ALTER TABLE [dbo].[HumanResourcesInterviewStatus] ADD  DEFAULT (getdate()) FOR [InsertDate] --Date for InsertDate in HRINT
GO
ALTER TABLE [dbo].[HumanResourcesInterviewStatus] ADD  DEFAULT (getdate()) FOR [UpdateDate] --Date
GO
ALTER TABLE [dbo].[HumanResourcesInterviewStatus] ADD  DEFAULT (getdate()) FOR [DeleteDate] --Date
GO

--ALTER TABLE [dbo].[HumanResourcesInterviewStatus]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesInterviewStatus_InsertUser] FOREIGN KEY([InsertUserID])
--REFERENCES [dbo].[HumanResourcesEmployee] ([ID])
--GO
--ALTER TABLE [dbo].[HumanResourcesInterviewStatus] CHECK CONSTRAINT [FK_HumanResourcesInterview_InsertUser]
--GO
--ALTER TABLE [dbo].[HumanResourcesInterviewStatus]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesInterviewStatus_UpdateUser] FOREIGN KEY([UpdateUserID])
--REFERENCES [dbo].[HumanResourcesEmployee] ([ID])
--GO
--ALTER TABLE [dbo].[HumanResourcesInterviewStatus] CHECK CONSTRAINT [FK_HumanResourcesInterview_UpdateUser]
--GO
--ALTER TABLE [dbo].[HumanResourcesInterviewStatus]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesInterviewStatus_DeleteUser] FOREIGN KEY([DeleteUserID])
--REFERENCES [dbo].[HumanResourcesEmployee] ([ID])
--GO
--ALTER TABLE [dbo].[HumanResourcesInterviewStatus] CHECK CONSTRAINT [FK_HumanResourcesInterview_DeleteUser]
--GO








ALTER TABLE [dbo].[HumanResourcesInterview] ADD  DEFAULT ((1)) FOR [IsActive] --IsActive is 1
GO
ALTER TABLE [dbo].[HumanResourcesInterview] ADD  DEFAULT (getdate()) FOR [InsertDate] --Date
GO
ALTER TABLE [dbo].[HumanResourcesInterview] ADD  DEFAULT (getdate()) FOR [UpdateDate] --Date
GO
ALTER TABLE [dbo].[HumanResourcesInterview] ADD  DEFAULT (getdate()) FOR [DeleteDate] --Date
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

--ALTER TABLE [dbo].[HumanResourcesInterview]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesInterview_UpdateUser] FOREIGN KEY([UpdateUserID])
--REFERENCES [dbo].[HumanResourcesEmployee] ([ID])
--GO
--ALTER TABLE [dbo].[HumanResourcesInterview] CHECK CONSTRAINT [FK_HumanResourcesInterview_UpdateUser]
--GO
--ALTER TABLE [dbo].[HumanResourcesInterview]  WITH CHECK ADD  CONSTRAINT [FK_HumanResourcesInterview_DeleteUser] FOREIGN KEY([DeleteUserID])
--REFERENCES [dbo].[HumanResourcesEmployee] ([ID])
--GO
--ALTER TABLE [dbo].[HumanResourcesInterview] CHECK CONSTRAINT [FK_HumanResourcesInterview_DeleteUser]
--GO


