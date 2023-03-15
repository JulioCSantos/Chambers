/****** Object:  StoredProcedure [dbo].[spGetInterop2]    Script Date: 3/14/2023 11:46:39 AM ******/
DROP PROCEDURE [dbo].[spGetInterop2]
GO
/****** Object:  StoredProcedure [dbo].[spGetInterop2]    Script Date: 3/14/2023 11:46:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetInterop2] 
	-- Add the parameters for the stored procedure here
	@Tag nvarchar(4000)
	, @StartTime datetime2
	, @EndTime datetime2
	, @TimeStep time = '00:00:05'
AS
BEGIN

	SET NOCOUNT ON;

	--Set @Tag = NULLIF(LTRIM(RTRIM(@Tag)), ''); -- NULL if has blanks or emptry string
	--Set @StartTime = NULLIF(@StartTime, ''); -- NULL if has blanks or emptry string
	--Set @EndTime = NULLIF(@EndTime, ''); -- NULL if has blanks or emptry string
	Set @TimeStep = NULLIF(LTRIM(RTRIM(@TimeStep)), ''); -- NULL if has blanks or emptry string
	
	DECLARE @Sql nvarchar(max) = '';

	--SET @Sql = ' tag = ''''' + @Tag + '''''';
	IF @Tag is NOT NULL AND len(@Tag)>0
		SET @Sql = ' tag in ('+ [dbo].[fn_SplitJoin](@Tag,',','''''','''''',',') + ')'

	PRINT(@Sql);


	SET @Sql = @Sql + ' AND time BETWEEN ''''' + Convert(varchar(20), @StartTime, 20) + ''''' AND ''''' + Convert(varchar(20), @EndTime, 20) + '''''';

	IF (@TimeStep Is Not NULL)		
	SET @Sql = @Sql + ' AND TimeStep=''''' + Convert(varchar(20), @TimeStep, 8) + '''''';

	SET @Sql = '''SELECT * FROM piarchive..piinterp2 WHERE ' + @Sql + '';

	--SELECT @Sql;
	--PRINT(@Sql);
	
	DECLARE @OuterQuery nvarchar(max) = 
	'SELECT * FROM OPENQUERY(PI, ' + @Sql + ' '' )';

	--DECLARE @OuterQuery nvarchar(max) = 
	--'SELECT * FROM OPENQUERY(PI, ''SELECT * FROM piarchive..piinterp2 WHERE ' + @Sql + ''' )';

	--PRINT(@OuterQuery);
	--DECLARE @Tbl Table ([tag] nvarchar(4000) NOT  NULL, [Time] datetime2(7) NOT  NULL,
	--[Value] nvarchar(4000)  NULL, [Status] int NOT  NULL, [TimeStep] time(0)  NULL);
	--Insert @Tbl exec(@OuterQuery);
	--SELECT * FROM @Tbl;

	PRINT(@OuterQuery);
	EXEC SP_ExecuteSql @OuterQuery;
END
GO
