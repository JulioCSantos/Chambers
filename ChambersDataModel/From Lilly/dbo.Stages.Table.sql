ALTER TABLE [dbo].[Stages] DROP CONSTRAINT [TagsTagId2StagesTagId]
GO
ALTER TABLE [dbo].[Stages] DROP CONSTRAINT [DF_Stages_ProductionDate]
GO
ALTER TABLE [dbo].[Stages] DROP CONSTRAINT [DF__Stages__MaxThres__42E1EEFE]
GO
/****** Object:  Index [IxTagStageName]    Script Date: 03/07/2023 00:12:30 ******/
DROP INDEX [IxTagStageName] ON [dbo].[Stages]
GO
/****** Object:  Table [dbo].[Stages]    Script Date: 03/07/2023 00:12:30 ******/
DROP TABLE [dbo].[Stages]
GO
/****** Object:  Table [dbo].[Stages]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Stages](
	[StageId] [int] IDENTITY(1,1) NOT NULL,
	[TagId] [int] NOT NULL,
	[StageName] [nvarchar](255) NULL,
	[MinThreshold] [float] NOT NULL,
	[MaxThreshold] [float] NOT NULL,
	[TimeStep] [float] NULL,
	[ProductionDate] [datetime] NULL,
	[DeprecatedDate] [datetime] NULL,
	[ThresholdDuration] [int] NULL,
	[SetPoint] [float] NULL,
 CONSTRAINT [PK_Stages] PRIMARY KEY CLUSTERED 
(
	[StageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IxTagStageName]    Script Date: 03/07/2023 00:12:31 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IxTagStageName] ON [dbo].[Stages]
(
	[TagId] ASC,
	[StageName] ASC
)
WHERE ([StageName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Stages] ADD  DEFAULT ((3.4000000000000000e+038)) FOR [MaxThreshold]
GO
ALTER TABLE [dbo].[Stages] ADD  CONSTRAINT [DF_Stages_ProductionDate]  DEFAULT (getdate()) FOR [ProductionDate]
GO
ALTER TABLE [dbo].[Stages]  WITH CHECK ADD  CONSTRAINT [TagsTagId2StagesTagId] FOREIGN KEY([TagId])
REFERENCES [dbo].[Tags] ([TagId])
GO
ALTER TABLE [dbo].[Stages] CHECK CONSTRAINT [TagsTagId2StagesTagId]
GO
