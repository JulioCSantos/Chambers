/****** Object:  Table [BB50PCS\jsantos].[CompressedPoints]    Script Date: 03/07/2023 00:12:30 ******/
DROP TABLE [BB50PCS\jsantos].[CompressedPoints]
GO
/****** Object:  Table [BB50PCS\jsantos].[CompressedPoints]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BB50PCS\jsantos].[CompressedPoints](
	[tag] [varchar](255) NOT NULL,
	[time] [datetime] NOT NULL,
	[value] [float] NOT NULL
) ON [PRIMARY]
GO
