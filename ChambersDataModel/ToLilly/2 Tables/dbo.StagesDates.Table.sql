/****** Object:  Table [dbo].[StagesDates]    Script Date: 3/14/2023 11:42:10 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StagesDates] ADD  DEFAULT ('9999-12-31 11:11:59') FOR [EndDate]
GO
ALTER TABLE [dbo].[StagesDates]  WITH CHECK ADD  CONSTRAINT [FkStagesStageId_StageId] FOREIGN KEY([StageId])
REFERENCES [dbo].[Stages] ([StageId])
GO
ALTER TABLE [dbo].[StagesDates] CHECK CONSTRAINT [FkStagesStageId_StageId]
GO
