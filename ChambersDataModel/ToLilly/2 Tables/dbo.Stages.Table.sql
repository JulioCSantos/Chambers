/****** Object:  Table [dbo].[Stages]    Script Date: 3/14/2023 11:42:10 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Stages] ADD  DEFAULT ((3.4000000000000000e+038)) FOR [MaxThreshold]
GO
ALTER TABLE [dbo].[Stages]  WITH CHECK ADD  CONSTRAINT [TagsTagId2StagesTagId] FOREIGN KEY([TagId])
REFERENCES [dbo].[Tags] ([TagId])
GO
ALTER TABLE [dbo].[Stages] CHECK CONSTRAINT [TagsTagId2StagesTagId]
GO
