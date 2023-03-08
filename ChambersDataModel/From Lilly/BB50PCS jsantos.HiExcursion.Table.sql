/****** Object:  Table [BB50PCS\jsantos].[HiExcursion]    Script Date: 03/07/2023 00:12:30 ******/
DROP TABLE [BB50PCS\jsantos].[HiExcursion]
GO
/****** Object:  Table [BB50PCS\jsantos].[HiExcursion]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BB50PCS\jsantos].[HiExcursion](
	[XdateStr] [datetime2](7) NOT NULL,
	[CVal] [float] NOT NULL,
 CONSTRAINT [PK_HiExcursion] PRIMARY KEY CLUSTERED 
(
	[XdateStr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
