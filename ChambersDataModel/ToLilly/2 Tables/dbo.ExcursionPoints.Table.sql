/****** Object:  Table [dbo].[ExcursionPoints]    Script Date: 3/14/2023 11:42:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExcursionPoints](
	[CycleId] [int] IDENTITY(1,1) NOT NULL,
	[TagId] [int] NULL,
	[TagName] [varchar](255) NOT NULL,
	[TagExcNbr] [int] NOT NULL,
	[StepLogId] [int] NULL,
	[RampInDate] [datetime] NULL,
	[RampInValue] [float] NULL,
	[FirstExcDate] [datetime] NULL,
	[FirstExcValue] [float] NULL,
	[LastExcDate] [datetime] NULL,
	[LastExcValue] [float] NULL,
	[RampOutDate] [datetime] NULL,
	[RampOutValue] [float] NULL,
	[HiPointsCt] [int] NOT NULL,
	[LowPointsCt] [int] NOT NULL,
	[MinThreshold] [float] NULL,
	[MaxThreshold] [float] NULL,
	[MinValue] [float] NULL,
	[MaxValue] [float] NULL,
	[AvergValue] [float] NULL,
	[StdDevValue] [float] NULL,
	[Duration]  AS (datediff(second,[FirstExcDate],[LastExcDate])) PERSISTED,
	[ThresholdDuration] [int] NULL,
	[SetPoint] [float] NULL,
 CONSTRAINT [pkExcursionPointsCycleId] PRIMARY KEY NONCLUSTERED 
(
	[CycleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
