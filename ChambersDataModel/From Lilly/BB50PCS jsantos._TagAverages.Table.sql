/****** Object:  Table [BB50PCS\jsantos].[_TagAverages]    Script Date: 03/07/2023 00:12:30 ******/
DROP TABLE [BB50PCS\jsantos].[_TagAverages]
GO
/****** Object:  Table [BB50PCS\jsantos].[_TagAverages]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BB50PCS\jsantos].[_TagAverages](
	[Tag] [nvarchar](4000) NOT NULL,
	[Average] [float] NULL,
	[Date] [datetime] NULL,
	[MinValue]  AS ([average]-([average]*(20.0))/(100)),
	[MaxValue]  AS ([average]+([average]*(200.0))/(100))
) ON [PRIMARY]
GO
