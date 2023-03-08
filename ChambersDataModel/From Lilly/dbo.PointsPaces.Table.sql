ALTER TABLE [dbo].[PointsPaces] DROP CONSTRAINT [fkPointsPacesStageDateId_StagesDatesStageDateId]
GO
ALTER TABLE [dbo].[PointsPaces] DROP CONSTRAINT [DF_PointsPaces_StepSizeDays]
GO
/****** Object:  Index [ixPointsPacesStageDateId]    Script Date: 03/07/2023 00:12:30 ******/
DROP INDEX [ixPointsPacesStageDateId] ON [dbo].[PointsPaces] WITH ( ONLINE = OFF )
GO
/****** Object:  Table [dbo].[PointsPaces]    Script Date: 03/07/2023 00:12:30 ******/
DROP TABLE [dbo].[PointsPaces]
GO
/****** Object:  Table [dbo].[PointsPaces]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PointsPaces](
	[PaceId] [int] IDENTITY(1,1) NOT NULL,
	[StageDateId] [int] NOT NULL,
	[NextStepStartDate] [datetime] NOT NULL,
	[StepSizeDays] [int] NOT NULL,
	[NextStepEndDate]  AS (dateadd(day,[StepSizeDays],[NextStepStartDate])),
	[ProcessedDate] [datetime] NULL,
 CONSTRAINT [pcPointsPacesPaceId] PRIMARY KEY NONCLUSTERED 
(
	[PaceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [ixPointsPacesStageDateId]    Script Date: 03/07/2023 00:12:31 ******/
CREATE CLUSTERED INDEX [ixPointsPacesStageDateId] ON [dbo].[PointsPaces]
(
	[StageDateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PointsPaces] ADD  CONSTRAINT [DF_PointsPaces_StepSizeDays]  DEFAULT ((2)) FOR [StepSizeDays]
GO
ALTER TABLE [dbo].[PointsPaces]  WITH CHECK ADD  CONSTRAINT [fkPointsPacesStageDateId_StagesDatesStageDateId] FOREIGN KEY([StageDateId])
REFERENCES [dbo].[StagesDates] ([StageDateId])
GO
ALTER TABLE [dbo].[PointsPaces] CHECK CONSTRAINT [fkPointsPacesStageDateId_StagesDatesStageDateId]
GO
