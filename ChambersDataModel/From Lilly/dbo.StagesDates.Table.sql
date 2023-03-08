ALTER TABLE [dbo].[StagesDates] DROP CONSTRAINT [FkStagesStageId_StageId]
GO
ALTER TABLE [dbo].[StagesDates] DROP CONSTRAINT [DF__StagesDat__EndDa__43D61337]
GO
/****** Object:  Index [IxStagesDatesTagIdStartDate]    Script Date: 03/07/2023 00:12:30 ******/
DROP INDEX [IxStagesDatesTagIdStartDate] ON [dbo].[StagesDates]
GO
/****** Object:  Table [dbo].[StagesDates]    Script Date: 03/07/2023 00:12:30 ******/
DROP TABLE [dbo].[StagesDates]
GO
/****** Object:  Table [dbo].[StagesDates]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StagesDates](
	[StageDateId] [int] IDENTITY(1,1) NOT NULL,
	[StageId] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[DeprecatedDate] [datetime] NULL,
 CONSTRAINT [pkStagesDatesStageDateId] PRIMARY KEY CLUSTERED 
(
	[StageDateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IxStagesDatesTagIdStartDate]    Script Date: 03/07/2023 00:12:31 ******/
CREATE NONCLUSTERED INDEX [IxStagesDatesTagIdStartDate] ON [dbo].[StagesDates]
(
	[StageId] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StagesDates] ADD  DEFAULT ('9999-12-31 11:11:59') FOR [EndDate]
GO
ALTER TABLE [dbo].[StagesDates]  WITH CHECK ADD  CONSTRAINT [FkStagesStageId_StageId] FOREIGN KEY([StageId])
REFERENCES [dbo].[Stages] ([StageId])
GO
ALTER TABLE [dbo].[StagesDates] CHECK CONSTRAINT [FkStagesStageId_StageId]
GO
