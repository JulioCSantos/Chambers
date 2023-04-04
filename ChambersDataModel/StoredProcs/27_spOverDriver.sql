CREATE PROCEDURE [dbo].[spOverDriver] 
 @StageDatesArgs varchar(max) NULL
, @FromDate datetime NULL
, @ToDate datetime NULL
AS
BEGIN
--30 --7 --210
	SET NOCOUNT ON;
	IF (@StageDatesArgs IS NULL ) SELECT @StageDatesArgs = CONCAT('1-',CAST(COUNT(*) as varchar(16))) FROM dbo.StagesDates;
	IF (@FromDate IS NULL) SET @FromDate =  DATEADD(Day,-2,GetDate());
	IF (@ToDate IS NULL) SET @ToDate = GetDate();

	SET NOCOUNT ON;

	DECLARE @is_primary_server [bit];

	EXEC SP_check_primary_server @is_primary_server OUTPUT;

	IF @is_primary_server = 1
	BEGIN
		DECLARE @StartStageDateId int, @EndStageDateId int, @ix int, @maxIx int, @currStageDateId int;
		DECLARE @StageDatesTbl as TABLE (id int primary key identity(1,1) ,StageDateId varchar(16))
			IF (CHARINDEX(',',@StageDatesArgs,1) > 0)
			BEGIN
				INSERT INTO @StageDatesTbl
				SELECT * FROM string_split(@StageDatesArgs,',');
				SET @ix = 1;
				SELECT @maxIx = COUNT(*) FROM @StageDatesTbl;
				WHILE @ix <= @maxIx
				BEGIN
					SELECT @currStageDateId = CAST(StageDateId as varchar(16)) from @StageDatesTbl WHERE id = @ix;
					--PRINT CONCAT(@currStageDateId,' @FromDate:',@FromDate,' @ToDate:',@ToDate);
					EXEC [dbo].[spDriverExcursionsPointsForDate] @FromDate, @ToDate, @currStageDateId;

					SET @ix = @ix + 1;
				END
			END
			ELSE
			BEGIN
				IF (CHARINDEX('-', @StageDatesArgs) > 0)
				BEGIN
					INSERT INTO @StageDatesTbl
					SELECT * FROM string_split(@StageDatesArgs,'-');
					SELECT top 1 @StartStageDateId = StageDateId from @StageDatesTbl;
					DELETE FROM @StageDatesTbl WHERE StageDateId = @StartStageDateId;
					SELECT top 1 @EndStageDateId = ISNULL(StageDateId,@StartStageDateId) from @StageDatesTbl;
					DELETE FROM @StageDatesTbl WHERE StageDateId = @EndStageDateId;
				END
				ELSE
				BEGIN
					SET @StartStageDateId = @StageDatesArgs;
					SET @EndStageDateId = @StageDatesArgs;
				END
				SET @ix = CAST(@StartStageDateId as int);
				SET @maxIx = CAST(@EndStageDateId as int);
				WHILE @ix <= @maxIx
				BEGIN
					SELECT @currStageDateId = CAST(@ix as varchar(16));
					--PRINT CONCAT(@currStageDateId,' @FromDate:',@FromDate,' @ToDate:',@ToDate);
					EXEC [dbo].[spDriverExcursionsPointsForDate] @FromDate, @ToDate, @currStageDateId;

					SET @ix = @ix + 1;
				END
			-- syntax
			--spOverDriver '3-7', DATEADD(Day,-2,GetDate()), GetDate();
			--spOverDriver '3-7', NULL, NULL;
			--spOverDriver '3,5,7', DATEADD(Day,-2,GetDate()), GetDate();
			END
	END
	ELSE
	BEGIN
		PRINT 'This is not the primary sever';
	END
END