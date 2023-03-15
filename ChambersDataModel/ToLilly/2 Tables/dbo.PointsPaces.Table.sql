/****** Object:  Table [dbo].[PointsPaces]    Script Date: 3/14/2023 11:42:10 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PointsPaces] ADD  DEFAULT ((2)) FOR [StepSizeDays]
GO
ALTER TABLE [dbo].[PointsPaces]  WITH CHECK ADD  CONSTRAINT [fkPointsPacesStageDateId_StagesDatesStageDateId] FOREIGN KEY([StageDateId])
REFERENCES [dbo].[StagesDates] ([StageDateId])
GO
ALTER TABLE [dbo].[PointsPaces] CHECK CONSTRAINT [fkPointsPacesStageDateId_StagesDatesStageDateId]
GO
