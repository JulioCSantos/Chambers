/****** Object:  StoredProcedure [BB50PCS\jsantos].[spGetPIInterop]    Script Date: 03/07/2023 00:12:30 ******/
DROP PROCEDURE [BB50PCS\jsantos].[spGetPIInterop]
GO
/****** Object:  StoredProcedure [BB50PCS\jsantos].[spGetPIInterop]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [BB50PCS\jsantos].[spGetPIInterop]
	 @PTagName nvarchar(255) = 'chamber_report_tag_1', @PStartDate DateTime = '2022-11-01', @PEndDate DateTime = '2022-11-10'
	, @PLowThreashold float = 100, @PHiThreashold float = 200 
AS
    -- Insert statements for procedure here
	DECLARE @Sql nvarchar(max) = '
	SELECT Top 10 * FROM OPENQUERY(PI,
	'' 
		SELECT *
		FROM piarchive..piinterp2
		WHERE tag = ''''' + @PTagName + '''''
		AND time BETWEEN ''''' + @PStartDate + ''''' AND ''''' + @PEndDate + '''''
	'')
	';
	
		--	AND time BETWEEN ''' + @PStartDate + ''' AND ''' + @PEndDate + '''
		--AND (value >= ''' + @PHiThreashold + ''' OR value < ''' + @PLowThreashold + ''')
		--AND TimeStep=''''5s''''

	PRINT @Sql

	DECLARE @Tbl Table ([tag] nvarchar(4000) NOT  NULL, [Time] datetime2(7) NOT  NULL,
	[Value] nvarchar(4000)  NULL, [Status] int NOT  NULL, [TimeStep] time(0)  NULL);
	Insert @Tbl exec(@Sql);
	SELECT * FROM @Tbl;

--select * [tag], [time], [value] from  [dbo].[CompressedPoints]
--		WHERE tag = @TagName AND time >= @StartDate AND time < @EndDate 
--		AND (value >= @HiThreashold OR value < @LowThreashold)
--		ORDER BY time;
GO
