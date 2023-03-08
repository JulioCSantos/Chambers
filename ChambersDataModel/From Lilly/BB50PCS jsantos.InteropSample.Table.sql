/****** Object:  Table [BB50PCS\jsantos].[InteropSample]    Script Date: 03/07/2023 00:12:30 ******/
DROP TABLE [BB50PCS\jsantos].[InteropSample]
GO
/****** Object:  Table [BB50PCS\jsantos].[InteropSample]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BB50PCS\jsantos].[InteropSample](
	[tag] [nvarchar](4000) NOT NULL,
	[time] [datetime2](7) NOT NULL,
	[value] [float] NULL,
	[svalue] [nvarchar](4000) NULL,
	[status] [int] NOT NULL,
	[timestep] [time](0) NULL
) ON [PRIMARY]
GO
