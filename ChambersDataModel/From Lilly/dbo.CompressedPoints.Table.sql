/****** Object:  Table [dbo].[CompressedPoints]    Script Date: 03/07/2023 00:12:30 ******/
DROP TABLE [dbo].[CompressedPoints]
GO
/****** Object:  Table [dbo].[CompressedPoints]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompressedPoints](
	[tag] [varchar](255) NOT NULL,
	[time] [datetime] NOT NULL,
	[value] [float] NOT NULL,
 CONSTRAINT [pkCompressedPoints] PRIMARY KEY CLUSTERED 
(
	[tag] ASC,
	[time] ASC,
	[value] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
