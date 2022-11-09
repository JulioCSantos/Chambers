USE [master]
GO
/****** Object:  Database [ELChambers]    Script Date: 11/9/2022 4:56:19 PM ******/
CREATE DATABASE [ELChambers]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ELChambers', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ELChambers.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'ELChambers_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ELChambers_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [ELChambers] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ELChambers].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ELChambers] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ELChambers] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ELChambers] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ELChambers] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ELChambers] SET ARITHABORT OFF 
GO
ALTER DATABASE [ELChambers] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ELChambers] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ELChambers] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ELChambers] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ELChambers] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ELChambers] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ELChambers] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ELChambers] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ELChambers] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ELChambers] SET  ENABLE_BROKER 
GO
ALTER DATABASE [ELChambers] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ELChambers] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ELChambers] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ELChambers] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ELChambers] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ELChambers] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [ELChambers] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ELChambers] SET RECOVERY FULL 
GO
ALTER DATABASE [ELChambers] SET  MULTI_USER 
GO
ALTER DATABASE [ELChambers] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ELChambers] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ELChambers] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ELChambers] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [ELChambers] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [ELChambers] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'ELChambers', N'ON'
GO
ALTER DATABASE [ELChambers] SET QUERY_STORE = OFF
GO
USE [ELChambers]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetOverlappingDates]    Script Date: 11/9/2022 4:56:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnGetOverlappingDates] 
(	
	-- Add the parameters for the function here
	@StartDate1 DateTime 
	, @endDate1 DateTime
	, @StartDate2 DateTime 
	, @endDate2 DateTime
)
RETURNS @OverlappingSates TABLE ( StartDate DateTime NULL, EndDate DateTime NULL )
AS
BEGIN
	DECLARE @StartDate DateTime , @EndDate DateTime ;
	
	SELECT 
		@StartDate = 
			CASE
				WHEN @StartDate1 > @EndDate2 THEN NULL
				WHEN @StartDate1 < @StartDate2 THEN @StartDate2
				ELSE @StartDate1
			END,
		@EndDate = 
			CASE
				WHEN @EndDate1 < @StartDate2 THEN NULL
				WHEN @EndDate1 > @EndDate2 THEN @EndDate2
				ELSE @EndDate1
			END;
	IF @StartDate IS NULL OR @EndDate IS NULL
		BEGIN INSERT @OverlappingSates SELECT NULL, NULL END
	ELSE 
		BEGIN INSERT @OverlappingSates SELECT @StartDate, @EndDate END

	RETURN;
END;
GO
/****** Object:  Table [dbo].[ExcursionPoints]    Script Date: 11/9/2022 4:56:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExcursionPoints](
	[PointNbr] [int] IDENTITY(1,1) NOT NULL,
	[TagId] [int] NOT NULL,
	[TagName] [varchar](255) NOT NULL,
	[ValueDate] [datetime] NOT NULL,
	[Value] [float] NOT NULL,
	[ExcNbr] [int] NOT NULL,
	[ExcType] [varchar](16) NOT NULL,
	[StepLogId] [int] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixExcursionPointsTagNameValueDate]    Script Date: 11/9/2022 4:56:19 PM ******/
CREATE CLUSTERED INDEX [ixExcursionPointsTagNameValueDate] ON [dbo].[ExcursionPoints]
(
	[TagName] ASC,
	[ValueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Excursions]    Script Date: 11/9/2022 4:56:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Excursions]
AS
SELECT RI.TagId, RI.TagName, RI.ExcNbr, RI.ValueDate AS RampInDate, RI.PointNbr AS RampInPointNbr
, RO.ValueDate AS RampOutDate, RO.PointNbr AS RampOutPointNbr
FROM  dbo.ExcursionPoints AS RI JOIN
         dbo.ExcursionPoints AS RO ON RI.TagId = RO.TagId AND RI.ExcNbr = RO.ExcNbr AND RI.PointNbr != RO.PointNbr
		 WHERE RI.ExcType = 'RampIn' AND RO.ExcType = 'RampOut'
UNION ALL
SELECT RI.TagId, RI.TagName, RI.ExcNbr, RI.ValueDate AS RampInDate, RI.PointNbr AS RampInPointNbr
, RO.ValueDate AS RampOutDate, RO.PointNbr AS RampOutPointNbr
FROM  dbo.ExcursionPoints AS RI LEFT JOIN
         dbo.ExcursionPoints AS RO ON RI.TagId = RO.TagId AND RI.ExcNbr = RO.ExcNbr AND RI.PointNbr != RO.PointNbr
		 WHERE RI.ExcType = 'RampIn' AND RO.PointNbr IS NULL
UNION ALL
SELECT RO.TagId, RO.TagName, RO.ExcNbr, RI.ValueDate AS RampInDate, RI.PointNbr AS RampInPointNbr
, RO.ValueDate AS RampOutDate, RO.PointNbr AS RampOutPointNbr
FROM  dbo.ExcursionPoints AS RI RIGHT JOIN
         dbo.ExcursionPoints AS RO ON RI.TagId = RO.TagId AND RI.ExcNbr = RO.ExcNbr AND RI.PointNbr != RO.PointNbr
		 WHERE Ro.ExcType = 'RampOut' AND RI.PointNbr IS NULL
GO
/****** Object:  Table [dbo].[PointsPaces]    Script Date: 11/9/2022 4:56:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PointsPaces](
	[PaceId] [int] IDENTITY(1,1) NOT NULL,
	[TagId] [int] NOT NULL,
	[NextStepStartDate] [datetime] NOT NULL,
	[StepSizeDays] [int] NOT NULL,
	[NextStepEndDate]  AS (dateadd(day,[StepSizeDays],[NextStepStartDate])),
 CONSTRAINT [pkPointsPacesPointId] PRIMARY KEY CLUSTERED 
(
	[PaceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Stages]    Script Date: 11/9/2022 4:56:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Stages](
	[StageId] [int] IDENTITY(1,1) NOT NULL,
	[TagId] [int] NOT NULL,
	[StageName] [nvarchar](255) NULL,
	[MinValue] [float] NOT NULL,
	[MaxValue] [float] NOT NULL,
 CONSTRAINT [PK_Stages] PRIMARY KEY CLUSTERED 
(
	[StageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StagesDates]    Script Date: 11/9/2022 4:56:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StagesDates](
	[StageDateId] [int] IDENTITY(1,1) NOT NULL,
	[StageId] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
 CONSTRAINT [pkStagesDatesStageDateId] PRIMARY KEY CLUSTERED 
(
	[StageDateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[StagesLimitsAndDates]    Script Date: 11/9/2022 4:56:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[StagesLimitsAndDates]
AS
SELECT dbo.StagesDates.StageDateId, dbo.Stages.TagId, dbo.Stages.StageName
	, dbo.Stages.MinValue, dbo.Stages.MaxValue
	, dbo.StagesDates.StartDate, dbo.StagesDates.EndDate
FROM  dbo.Stages INNER JOIN
         dbo.StagesDates ON dbo.Stages.StageId = dbo.StagesDates.StageId
GO
/****** Object:  View [dbo].[DefaultPointsPaces]    Script Date: 11/9/2022 4:56:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DefaultPointsPaces]
AS
SELECT SLDs.TagId, DATEADD(year, - 1, GETDATE()) AS NextStepStartDate
FROM  dbo.StagesLimitsAndDates AS SLDs LEFT OUTER JOIN
         dbo.PointsPaces AS PPs ON SLDs.TagId = PPs.TagId
WHERE (PPs.PaceId IS NULL)
GO
/****** Object:  Table [dbo].[Tags]    Script Date: 11/9/2022 4:56:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tags](
	[TagId] [int] NOT NULL,
	[TagName] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_Tags] PRIMARY KEY CLUSTERED 
(
	[TagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[PointsStepsLogNextValues]    Script Date: 11/9/2022 4:56:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PointsStepsLogNextValues]
AS
SELECT T.TagId, T.TagName
, sld.StageDateId, sld.StageName, sld.StartDate AS StageStartDate, sld.EndDate AS StageEndDate
, sld.MinValue, sld.MaxValue
, pp.PaceId, pp.NextStepStartDate as PaceStartDate, pp.NextStepEndDate as PaceEndDate
, ods.StartDate, ods.EndDate
FROM 
Tags as t
INNER JOIN 
dbo.StagesLimitsAndDates AS sld ON t.TagId = sld.TagId
INNER JOIN
dbo.PointsPaces AS pp ON sld.TagId = pp.TagId 
CROSS APPLY
[dbo].[fnGetOverlappingDates](sld.StartDate, sld.EndDate, pp.NextStepStartDate, pp.NextStepEndDate) AS ods
WHERE 
t.TagName IS NOT NULL AND
ods.StartDate IS NOT NULL AND
ods.EndDate IS NOT NULL
GO
/****** Object:  Table [dbo].[CompressedPoints]    Script Date: 11/9/2022 4:56:19 PM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExcursionsViewMock]    Script Date: 11/9/2022 4:56:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExcursionsViewMock](
	[TagId] [int] NOT NULL,
	[TagName] [varchar](256) NULL,
	[ExcursionNbr] [int] IDENTITY(1,1) NOT NULL,
	[RampInDateTime] [datetime] NOT NULL,
	[RampOutDateTime] [datetime] NOT NULL,
	[RampInPointId] [int] NULL,
	[RampOutPointId] [int] NULL,
 CONSTRAINT [PK_Excursions] PRIMARY KEY CLUSTERED 
(
	[TagId] ASC,
	[ExcursionNbr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExcursionTypes]    Script Date: 11/9/2022 4:56:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExcursionTypes](
	[ExcType] [varchar](16) NOT NULL,
	[Predicate] [nvarchar](255) NULL,
	[ExcDescription] [nvarchar](255) NULL,
 CONSTRAINT [pkExcursionType] PRIMARY KEY CLUSTERED 
(
	[ExcType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PointsStepsLog]    Script Date: 11/9/2022 4:56:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PointsStepsLog](
	[StepLogId] [int] IDENTITY(1,1) NOT NULL,
	[StageDateId] [int] NOT NULL,
	[TagId] [int] NOT NULL,
	[StageName] [nvarchar](255) NOT NULL,
	[StageStartDate] [datetime] NOT NULL,
	[StageEndDate] [datetime] NULL,
	[MinValue] [float] NOT NULL,
	[MaxValue] [float] NOT NULL,
	[PaceId] [int] NOT NULL,
	[PaceStartDate] [datetime] NOT NULL,
	[PaceEndDate] [datetime] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[TagName] [varchar](255) NOT NULL,
 CONSTRAINT [pkPointsStepsLogPaceLogId] PRIMARY KEY CLUSTERED 
(
	[StepLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_LowExcursionTest', CAST(N'2022-01-08T00:00:00.000' AS DateTime), 150)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_LowExcursionTest', CAST(N'2022-01-09T00:00:00.000' AS DateTime), 110)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_LowExcursionTest', CAST(N'2022-01-10T00:00:00.000' AS DateTime), 50)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_LowExcursionTest', CAST(N'2022-01-12T00:00:00.000' AS DateTime), 60)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_LowExcursionTest', CAST(N'2022-01-20T00:00:00.000' AS DateTime), 120)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_LowExcursionTest', CAST(N'2022-01-21T00:00:00.000' AS DateTime), 130)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_TwoCyclesTest', CAST(N'2022-01-08T00:00:00.000' AS DateTime), 140)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_TwoCyclesTest', CAST(N'2022-01-09T00:00:00.000' AS DateTime), 150)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_TwoCyclesTest', CAST(N'2022-01-10T00:00:00.000' AS DateTime), 210)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_TwoCyclesTest', CAST(N'2022-01-12T00:00:00.000' AS DateTime), 220)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_TwoCyclesTest', CAST(N'2022-01-20T00:00:00.000' AS DateTime), 170)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_TwoCyclesTest', CAST(N'2022-01-21T00:00:00.000' AS DateTime), 160)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_TwoCyclesTest', CAST(N'2022-02-08T00:00:00.000' AS DateTime), 141)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_TwoCyclesTest', CAST(N'2022-02-09T00:00:00.000' AS DateTime), 151)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_TwoCyclesTest', CAST(N'2022-02-10T00:00:00.000' AS DateTime), 211)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_TwoCyclesTest', CAST(N'2022-02-12T00:00:00.000' AS DateTime), 221)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_TwoCyclesTest', CAST(N'2022-02-20T00:00:00.000' AS DateTime), 171)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'SpGetCompressedPointsTests_TwoCyclesTest', CAST(N'2022-02-21T00:00:00.000' AS DateTime), 161)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T2', CAST(N'2022-01-08T00:00:00.000' AS DateTime), 140)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T2', CAST(N'2022-01-09T00:00:00.000' AS DateTime), 150)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T2', CAST(N'2022-01-10T00:00:00.000' AS DateTime), 210)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T2', CAST(N'2022-01-12T00:00:00.000' AS DateTime), 220)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T2', CAST(N'2022-01-20T00:00:00.000' AS DateTime), 170)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T2', CAST(N'2022-01-21T00:00:00.000' AS DateTime), 160)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T2', CAST(N'2022-02-08T00:00:00.000' AS DateTime), 141)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T2', CAST(N'2022-02-09T00:00:00.000' AS DateTime), 151)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T2', CAST(N'2022-02-10T00:00:00.000' AS DateTime), 211)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T2', CAST(N'2022-02-12T00:00:00.000' AS DateTime), 221)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T2', CAST(N'2022-02-20T00:00:00.000' AS DateTime), 171)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T2', CAST(N'2022-02-21T00:00:00.000' AS DateTime), 161)
GO
SET IDENTITY_INSERT [dbo].[ExcursionPoints] ON 

INSERT [dbo].[ExcursionPoints] ([PointNbr], [TagId], [TagName], [ValueDate], [Value], [ExcNbr], [ExcType], [StepLogId]) VALUES (1, 1, N'Tag1', CAST(N'2021-01-01T00:00:00.000' AS DateTime), 11.11, 10, N'RampIn', 0)
INSERT [dbo].[ExcursionPoints] ([PointNbr], [TagId], [TagName], [ValueDate], [Value], [ExcNbr], [ExcType], [StepLogId]) VALUES (3, 1, N'tag1', CAST(N'2021-01-02T00:00:00.000' AS DateTime), 22.22, 10, N'RampOut', 0)
INSERT [dbo].[ExcursionPoints] ([PointNbr], [TagId], [TagName], [ValueDate], [Value], [ExcNbr], [ExcType], [StepLogId]) VALUES (4, 2, N'Tag2', CAST(N'2021-01-03T00:00:00.000' AS DateTime), 33.33, 11, N'RampIn', 0)
INSERT [dbo].[ExcursionPoints] ([PointNbr], [TagId], [TagName], [ValueDate], [Value], [ExcNbr], [ExcType], [StepLogId]) VALUES (5, 3, N'Tag3', CAST(N'2021-01-04T00:00:00.000' AS DateTime), 44.44, 12, N'RampOut', 0)
SET IDENTITY_INSERT [dbo].[ExcursionPoints] OFF
GO
INSERT [dbo].[ExcursionTypes] ([ExcType], [Predicate], [ExcDescription]) VALUES (N'HiExcursion', N'', N'value > &HiThreshold')
INSERT [dbo].[ExcursionTypes] ([ExcType], [Predicate], [ExcDescription]) VALUES (N'lowExcursion', N'', N'value < &LowThreshold')
INSERT [dbo].[ExcursionTypes] ([ExcType], [Predicate], [ExcDescription]) VALUES (N'RampIn', N'', N'time < Excursion.Time AND (value < @HiThreshold OR value >= @LowThreshold )')
INSERT [dbo].[ExcursionTypes] ([ExcType], [Predicate], [ExcDescription]) VALUES (N'RampOut', N'', N'time > Excursion.Time AND (value < @HiThreshold OR value >= @LowThreshold )')
GO
INSERT [dbo].[Tags] ([TagId], [TagName]) VALUES (1001, N'TagTests_InsertTest')
GO
/****** Object:  Index [pkExcursionPointsPointNbr]    Script Date: 11/9/2022 4:56:20 PM ******/
ALTER TABLE [dbo].[ExcursionPoints] ADD  CONSTRAINT [pkExcursionPointsPointNbr] PRIMARY KEY NONCLUSTERED 
(
	[PointNbr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixExcursionPointsTagNameExcNbrValueDate]    Script Date: 11/9/2022 4:56:20 PM ******/
CREATE NONCLUSTERED INDEX [ixExcursionPointsTagNameExcNbrValueDate] ON [dbo].[ExcursionPoints]
(
	[TagName] ASC,
	[ExcNbr] ASC,
	[ValueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_CollectionPointsPace_TagId]    Script Date: 11/9/2022 4:56:20 PM ******/
CREATE NONCLUSTERED INDEX [IX_CollectionPointsPace_TagId] ON [dbo].[PointsPaces]
(
	[TagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IxTagStageName]    Script Date: 11/9/2022 4:56:20 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IxTagStageName] ON [dbo].[Stages]
(
	[TagId] ASC,
	[StageName] ASC
)
WHERE ([StageName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IxStagesDatesTagIdStartDate]    Script Date: 11/9/2022 4:56:20 PM ******/
CREATE NONCLUSTERED INDEX [IxStagesDatesTagIdStartDate] ON [dbo].[StagesDates]
(
	[StageId] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixTagsTagName]    Script Date: 11/9/2022 4:56:20 PM ******/
CREATE NONCLUSTERED INDEX [ixTagsTagName] ON [dbo].[Tags]
(
	[TagName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Stages] ADD  DEFAULT ((3.4000000000000000e+038)) FOR [MaxValue]
GO
ALTER TABLE [dbo].[StagesDates] ADD  DEFAULT ('9999-12-31 11:11:59') FOR [EndDate]
GO
ALTER TABLE [dbo].[ExcursionPoints]  WITH CHECK ADD  CONSTRAINT [fkExcursionTypesExcType_ExcursionPointsExcType] FOREIGN KEY([ExcType])
REFERENCES [dbo].[ExcursionTypes] ([ExcType])
GO
ALTER TABLE [dbo].[ExcursionPoints] CHECK CONSTRAINT [fkExcursionTypesExcType_ExcursionPointsExcType]
GO
ALTER TABLE [dbo].[PointsPaces]  WITH CHECK ADD  CONSTRAINT [fkTagsTagId_PointsPacesTagId] FOREIGN KEY([TagId])
REFERENCES [dbo].[Tags] ([TagId])
GO
ALTER TABLE [dbo].[PointsPaces] CHECK CONSTRAINT [fkTagsTagId_PointsPacesTagId]
GO
ALTER TABLE [dbo].[Stages]  WITH CHECK ADD  CONSTRAINT [TagsTagId2StagesTagId] FOREIGN KEY([TagId])
REFERENCES [dbo].[Tags] ([TagId])
GO
ALTER TABLE [dbo].[Stages] CHECK CONSTRAINT [TagsTagId2StagesTagId]
GO
ALTER TABLE [dbo].[StagesDates]  WITH CHECK ADD  CONSTRAINT [FkStagesStageId_StageId] FOREIGN KEY([StageId])
REFERENCES [dbo].[Stages] ([StageId])
GO
ALTER TABLE [dbo].[StagesDates] CHECK CONSTRAINT [FkStagesStageId_StageId]
GO
/****** Object:  StoredProcedure [dbo].[spGetCompressedPoints]    Script Date: 11/9/2022 4:56:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetCompressedPoints] 
(	
	-- Add the parameters for the function here
	  @TagName varchar(255)
	, @StartDate DateTime 
	, @EndDate DateTime
	, @LowThreashold float
	, @HiThreashold float 
)
AS
BEGIN
DECLARE @ExcNbr int = 0
, @RampOut varchar(16) = 'RampOut' 
, @RampIn varchar(16) = 'RampIn' ;

DECLARE @FullExcCycle as TABLE ( ExcNbr int Not Null, tag varchar(255) NOT NULL, time DateTime NOT NULL
, value float NOT NULL, excType varchar(16) NOT NULL );

DECLARE @ExcPoints as TABLE ( ExcNbr int Not Null, tag varchar(255) NOT NULL, time DateTime NOT NULL
, value float NOT NULL, excType varchar(16) NOT NULL );
DECLARE @RampOutPoints as TABLE ( ExcNbr int Not Null,  tag varchar(255) NOT NULL, time DateTime NOT NULL
, value float NOT NULL, excType varchar(16) NOT NULL );
DECLARE @RampInPoints as TABLE ( ExcNbr int Not Null,  tag varchar(255) NOT NULL, time DateTime NOT NULL
, value float NOT NULL, excType varchar(16) NOT NULL );

DECLARE  @tag varchar(255), @time DateTime, @value float;
DECLARE  @ROtime DateTime, @HiOrLow varchar(16);

	DECLARE CPoint CURSOR
		FOR SELECT [tag], [time], [value] from  [dbo].[CompressedPoints]
		WHERE tag = @TagName AND time >= @StartDate AND time < @EndDate 
		AND (value >= @HiThreashold OR value < @LowThreashold)
		ORDER BY time;

		SET @ExcNbr = @ExcNbr + 1;
		OPEN CPoint;
		PRINT 'Fetch first Excursion point'
		FETCH NEXT FROM CPoint INTO @tag, @time, @value;

		PRINT 'Determine if it is a HiExcursion or a LowExcursion'
		if (@value >=  @HiThreashold) SET @HiOrLow = 'HiExcursion'
		ELSE SET @HiOrLow = 'LowExcursion';

		PRINT 'Loop through Excursion points in the time period if any'
		WHILE @@FETCH_STATUS = 0  
		BEGIN

			PRINT 'IF RampOut exists ..'
			IF EXISTS (SELECT * FROM @RampOutPoints) BEGIN 
				PRINT '..If current Excursion Time greater than RampOut Time (next Excursion cycle) ..'
				IF (@time > @ROtime) BEGIN
					PRINT '.. save current full Excursion in @FullExcCycle tmpTbl, and  ..'
					INSERT INTO @FullExcCycle
					SELECT * FROM @RampInPoints UNION ALL SELECT * FROM @ExcPoints UNION SELECT * FROM @RampOutPoints;
					PRINT '.. prepare for next Excursion by clearing Temp tables and incrementing ExcNbr'
					DELETE @ExcPoints;
					DELETE @RampInPoints;
					DELETE @RampOutPoints;
					SET @ExcNbr = @ExcNbr + 1;
					--UPDATE @ExcPoints Set ExcNbr = @ExcNbr;
				END
			END
			
			PRINT 'Save Excursion point in Temp table'
			INSERT INTO @ExcPoints VALUES (@ExcNbr, @tag, @time, @value, @HiOrLow);

			PRINT 'Create Ramp points if they don''t exist for this Excursion cycle'
			IF NOT EXISTS (SELECT * FROM @RampOutPoints) BEGIN
				PRINT 'RampIn being created' 
				INSERT INTO @RampInPoints 
				SELECT TOP 1 @ExcNbr as 'ExcNbr', [tag], [time], [value], @RampIn as 'ExcType' 
					from  [dbo].[CompressedPoints]
				WHERE tag = @tag AND time < @time AND 
				(@HiOrLow = 'HiExcursion' AND value < @HiThreashold OR @HiOrLow = 'LowExcursion' AND value >= @LowThreashold)
				ORDER BY [time] DESC; 

				PRINT 'RampOut being created' 
				INSERT INTO @RampOutPoints
				SELECT TOP 1 @ExcNbr as 'ExcNbr', [tag], [time], [value], @RampOut as 'ExcType' 
					from  [dbo].[CompressedPoints]
				WHERE tag = @tag AND time >= @time AND 
				(@HiOrLow = 'HiExcursion' AND value < @HiThreashold OR @HiOrLow = 'LowExcursion' AND value >= @LowThreashold)
				ORDER BY [time] ASC; 
				PRINT 'Save RampOut point''s time'
				SELECT Top 1 @ROtime = time from @RampOutPoints;
			END

			PRINT 'Fetch next High Excursion point'
			FETCH NEXT FROM CPoint INTO @tag, @time, @value;  
		END;

		PRINT 'if Excursion point exists ..'
		IF EXISTS (SELECT TOP 1 * FROM @ExcPoints) BEGIN
			PRINT '..save final points as last Full Excursion Cycle'
			INSERT INTO @FullExcCycle
			SELECT * FROM @RampInPoints UNION ALL SELECT * FROM @ExcPoints UNION SELECT * FROM @RampOutPoints;

		END

	CLOSE CPoint;
	DEALLOCATE CPoint;

	PRINT 'RETURN ALL Full Excursion Cycles'
	SELECT * FROM @FullExcCycle;

END
GO
/****** Object:  StoredProcedure [dbo].[spGetStagesLimitsAndDates]    Script Date: 11/9/2022 4:56:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetStagesLimitsAndDates]
	@TagId int,
	@DateTime DateTime
AS
	SELECT * FROM StagesLimitsAndDates
	WHERE TagId = @TagId AND @DateTime BETWEEN [StartDate] AND [EndDate]
RETURN 0
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "SLDs"
            Begin Extent = 
               Top = 15
               Left = 96
               Bottom = 324
               Right = 424
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PPs"
            Begin Extent = 
               Top = 15
               Left = 520
               Bottom = 324
               Right = 896
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'DefaultPointsPaces'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'DefaultPointsPaces'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[29] 2[11] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "RI"
            Begin Extent = 
               Top = 37
               Left = 212
               Bottom = 537
               Right = 633
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RO"
            Begin Extent = 
               Top = 15
               Left = 729
               Bottom = 503
               Right = 1274
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 600
         Width = 600
         Width = 600
         Width = 600
         Width = 600
         Width = 600
         Width = 600
         Width = 600
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 2436
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Excursions'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Excursions'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 600
         Width = 600
         Width = 600
         Width = 600
         Width = 600
         Width = 600
         Width = 600
         Width = 600
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PointsStepsLogNextValues'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PointsStepsLogNextValues'
GO
USE [master]
GO
ALTER DATABASE [ELChambers] SET  READ_WRITE 
GO
