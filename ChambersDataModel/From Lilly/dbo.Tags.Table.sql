/****** Object:  Index [ixTagsTagName]    Script Date: 03/07/2023 00:12:30 ******/
DROP INDEX [ixTagsTagName] ON [dbo].[Tags]
GO
/****** Object:  Table [dbo].[Tags]    Script Date: 03/07/2023 00:12:30 ******/
DROP TABLE [dbo].[Tags]
GO
/****** Object:  Table [dbo].[Tags]    Script Date: 03/07/2023 00:12:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tags](
	[TagId] [int] NOT NULL,
	[TagName] [nvarchar](255) NOT NULL,
	[Picture] [varbinary](max) NULL,
 CONSTRAINT [PK_Tags] PRIMARY KEY CLUSTERED 
(
	[TagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixTagsTagName]    Script Date: 03/07/2023 00:12:31 ******/
CREATE NONCLUSTERED INDEX [ixTagsTagName] ON [dbo].[Tags]
(
	[TagName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
