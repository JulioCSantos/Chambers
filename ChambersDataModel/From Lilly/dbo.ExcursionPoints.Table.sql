/****** Object:  Index [ixExcursionPointsRampoutDateTagNameTagExcNbr]    Script Date: 03/07/2023 00:12:30 ******/
DROP INDEX [ixExcursionPointsRampoutDateTagNameTagExcNbr] ON [dbo].[ExcursionPoints]
GO
/****** Object:  Index [ixExcursionPointsRampInDateTagNameTagExcNbr]    Script Date: 03/07/2023 00:12:30 ******/
DROP INDEX [ixExcursionPointsRampInDateTagNameTagExcNbr] ON [dbo].[ExcursionPoints] WITH ( ONLINE = OFF )
GO
/****** Object:  Table [dbo].[ExcursionPoints]    Script Date: 03/07/2023 00:12:30 ******/
DROP TABLE [dbo].[ExcursionPoints]
GO
/****** Object:  Table [dbo].[ExcursionPoints]    Script Date: 03/07/2023 00:12:31 ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixExcursionPointsRampInDateTagNameTagExcNbr]    Script Date: 03/07/2023 00:12:31 ******/
CREATE UNIQUE CLUSTERED INDEX [ixExcursionPointsRampInDateTagNameTagExcNbr] ON [dbo].[ExcursionPoints]
(
	[TagName] ASC,
	[TagExcNbr] ASC,
	[RampInDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixExcursionPointsRampoutDateTagNameTagExcNbr]    Script Date: 03/07/2023 00:12:31 ******/
CREATE NONCLUSTERED INDEX [ixExcursionPointsRampoutDateTagNameTagExcNbr] ON [dbo].[ExcursionPoints]
(
	[TagName] ASC,
	[TagExcNbr] ASC,
	[RampOutDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
