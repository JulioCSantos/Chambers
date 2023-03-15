/****** Object:  Table [dbo].[PointsStepsLog]    Script Date: 3/14/2023 11:42:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PointsStepsLog](
	[StepLogId] [int] IDENTITY(1,1) NOT NULL,
	[StageDateId] [int] NOT NULL,
	[StageName] [nvarchar](255) NOT NULL,
	[TagId] [int] NOT NULL,
	[TagName] [varchar](255) NOT NULL,
	[StageStartDate] [datetime] NOT NULL,
	[StageEndDate] [datetime] NULL,
	[MinThreshold] [float] NOT NULL,
	[MaxThreshold] [float] NOT NULL,
	[PaceId] [int] NOT NULL,
	[PaceStartDate] [datetime] NOT NULL,
	[PaceEndDate] [datetime] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[ThresholdDuration] [int] NULL,
	[SetPoint] [float] NULL,
 CONSTRAINT [pkPointsStepsLogPaceLogId] PRIMARY KEY CLUSTERED 
(
	[StepLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
