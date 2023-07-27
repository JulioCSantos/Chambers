CREATE PROCEDURE [dbo].[spDriverExcursionsPointsForDate] 
       @FromDate datetime, -- Processing Start date
       @ToDate datetime, -- Processing ENd date
       @StageDateIds nvarchar(max) = null

AS
BEGIN
PRINT CONCAT('>>> spDriverExcursionsPointsForDate @FromDate:', Format(@FromDate,'yyyy-MM-dd')
              ,' @ToDate:', Format(@ToDate,'yyyy-MM-dd'),' @StageDateIds:',@StageDateIds);

       SET NOCOUNT ON;
       
       -- Processing StageDates
       DECLARE @StageDateIdsTable TABLE (StageDateId int);
       IF (@StageDateIds IS NOT NULL) BEGIN
              INSERT INTO @StageDateIdsTable
              SELECT value from STRING_SPLIT(@StageDateIds, ',')
       END;

       -- Processing Tag details
       DECLARE @StagesLimitsAndDatesCore TABLE (
              RowID int not null primary key identity(1,1)
              , TagId int, TagName nvarchar(255), DecommissionedDate datetime, StageDateId int, StageName nvarchar(255) NULL
              , MinThreshold float, MaxThreshold float, StartDate datetime, EndDate datetime
              , TimeStep float null, StageId int, ThresholdDuration int NULL, SetPoint float NULL
              , StageDeprecatedDate datetime NULL, StageDateDeprecatedDate datetime NULL
              , ProductionDate datetime NULL, DeprecatedDate datetime, IsDeprecated bit
              , PaceId int, NextStepStartDate datetime, NextStepEndDate datetime
              , ProcessedDate datetime NULL, StepSizeDays int
       )

       --PRINT 'Get PointPaces for all StagesDatesId. If PointsPaces doesnt exist for a StageDate manufacture one.'
       --PRINT 'If StagesDatesId list not informed use all StagesDates configured'
       INSERT INTO @StagesLimitsAndDatesCore
       SELECT TagId, TagName, DecommissionedDate, sldc.StageDateId, StageName 
              , MinThreshold, MaxThreshold, StartDate, EndDate
              , TimeStep, StageId, ThresholdDuration, SetPoint 
              , StageDeprecatedDate, StageDateDeprecatedDate 
              , ProductionDate, DeprecatedDate, IsDeprecated
              , ISNULL(pp.PaceId,-1) as PaceId
              , ISNULL(pp.NextStepStartDate,@FromDate) as NextStepStartDate, pp.NextStepEndDate
              , pp.ProcessedDate, ISNULL(PP.StepSizeDays,1) as StepSizeDays
              FROM [dbo].[StagesLimitsAndDatesCore] as sldc left join 
              (                     SELECT P1.PaceId, P1.StageDateId, P1.NextStepStartDate, P1.NextStepEndDate, P1.ProcessedDate, P1.StepSizeDays 
                             FROM PointsPaces as P1 WHERE P1.ProcessedDate IS NULL 
              ) as PP 
              ON sldc.StageDateId = PP.StageDateId OR PP.PaceId = -1
              WHERE (@StageDateIds IS NULL OR sldc.StageDateId in (SELECT StageDateId From @StageDateIdsTable));


       DECLARE @ExcPoints as TABLE ( RowID int not null primary key identity(1,1), NewRowId int
       , CycleId int, TagId int NULL
       , TagName varchar(255), TagExcNbr int NULL
       , StepLogId int NULL, StageDateId int NULL
       , RampInDate DateTime NULL, RampInValue float NULL, FirstExcDate DateTime NULL, FirstExcValue float NULL
       , LastExcDate DateTime NULL, LastExcValue float NULL, RampOutDate DateTime NULL, RampOutValue float NULL
       , HiPointsCt int NULL, LowPointsCt int NULL, MinThreshold float NULL, MaxThreshold float NULL
       , MinValue float, MaxValue float, AvergValue float, StdDevValue float
       , DeprecatedDate datetime, DecommissionedDate datetime, ThresholdDuration int, SetPoint float);

       DECLARE @ExcPointsWIP as TABLE ( RowID int NULL
       , CycleId int, TagId int NULL
       , TagName varchar(255), TagExcNbr int NULL
       , StepLogId int NULL, StageDateId int NULL
       , RampInDate DateTime NULL, RampInValue float NULL, FirstExcDate DateTime NULL, FirstExcValue float NULL
       , LastExcDate DateTime NULL, LastExcValue float NULL, RampOutDate DateTime NULL, RampOutValue float NULL
       , HiPointsCt int NULL, LowPointsCt int NULL, MinThreshold float NULL, MaxThreshold float NULL
       , MinValue float, MaxValue float, AvergValue float, StdDevValue float
       , DeprecatedDate datetime, DecommissionedDate datetime, ThresholdDuration int, SetPoint float);

       DECLARE @ExcPointsOutput as TABLE ( RowID int NULL, NewRowId int
       , CycleId int, TagId int NULL
       , TagName varchar(255), TagExcNbr int NULL
       , StepLogId int NULL, StageDateId int NULL
       , RampInDate DateTime NULL, RampInValue float NULL, FirstExcDate DateTime NULL, FirstExcValue float NULL
       , LastExcDate DateTime NULL, LastExcValue float NULL, RampOutDate DateTime NULL, RampOutValue float NULL
       , HiPointsCt int NULL, LowPointsCt int NULL, MinThreshold float NULL, MaxThreshold float NULL
       , MinValue float, MaxValue float, AvergValue float, StdDevValue float
       , DeprecatedDate datetime, DecommissionedDate datetime, ThresholdDuration int, SetPoint float);

       -- If no Tag details found abort (details are not configured).
       IF (NOT EXISTS(SELECT * FROM @StagesLimitsAndDatesCore)) BEGIN
              PRINT '<<< spDriverExcursionsPointsForDate aborted';
              SELECT * FROM @ExcPoints;
              RETURN -1;
       END;
--*****************************************************************************************
       PRINT ' >>> GET new excursions in date range'

       DECLARE @StgDtCount int, @CurrStgDtIx int = 1;
       SELECT @StgDtCount = count(*) from @StagesLimitsAndDatesCore;
       --PRINT 'Process every StageDate'
       WHILE @CurrStgDtIx <= @StgDtCount BEGIN
              DECLARE @CurrStageDateId int, @StageId int, @TagId int, @TagName varchar(255)
              , @ProductionDate datetime, @DeprecatedDate datetime, @DecommissionedDate datetime
              , @StageStartDate datetime, @StageEndDate datetime
              , @CurrStepStartDate datetime, @CurrStepEndDate datetime, @StepSizedays int
              , @MinThreshold float, @MaxThreshold float, @ThresholdDuration float, @SetPoint float
              , @PaceId int, @IsDeprecated bit;
              SELECT @CurrStageDateId = StageDateId, @StageId = StageId, @TagId = TagId, @TagName = TagName
              , @ProductionDate = ProductionDate, @DeprecatedDate = DeprecatedDate, @DecommissionedDate = DecommissionedDate
              , @StageStartDate = StartDate, @StageEndDate = EndDate
              , @CurrStepStartDate = NextStepStartDate, @CurrStepEndDate = NextStepEndDate, @StepSizedays = StepSizedays
              , @MinThreshold = MinThreshold, @MaxThreshold = MaxThreshold
              , @ThresholdDuration = ThresholdDuration, @SetPoint = SetPoint
              , @PaceId = PaceId, @IsDeprecated = IsDeprecated
              FROM @StagesLimitsAndDatesCore WHERE RowID = @CurrStgDtIx;
              --PRINT CONCAT('@StagesLimitsAndDatesCore @ProductionDate:', Format(@ProductionDate,'yyyy-MM-dd'),' @DeprecatedDate:', FORMAT(@DeprecatedDate, 'yyyy-MM-dd'));


              if (@CurrStepStartDate < @ProductionDate) BEGIN
                      SET @CurrStepStartDate = @ProductionDate;
              END
              SET @CurrStepEndDate = DateAdd(day, @StepSizedays, @CurrStepStartDate);

			  IF (@DeprecatedDate IS NOT NULL) BEGIN 
				IF (@DeprecatedDate >= @CurrStepStartDate AND @DeprecatedDate <= @CurrStepEndDate) BEGIN
                        PRINT CONCAT('Stage ', @CurrStageDateId, ' deprecated as of ',@DeprecatedDate);
                        Set @CurrStepEndDate = @DeprecatedDate;
                        IF (@CurrStepEndDate <= @CurrStepStartDate) 
                        GOTO NextStageDate;
				END
              End
                        
              PRINT CONCAT('Processing StageDateId:', @CurrStageDateId,' TagName:', @TagName, ' for ...');
              --Get processing date region

              DECLARE @ProcStartDate as datetime, @ProcEndDate as datetime;
              SELECT @ProcStartDate = StartDate,  @ProcEndDate = EndDate 
                      FROM [dbo].[fnGetOverlappingDates](@ProductionDate, @DeprecatedDate, @FromDate, @ToDate);
              PRINT CONCAT('...- Processing Start date:', Format(@ProcStartDate,'yyyy-MM-dd'),' and End date:', FORMAT(@ProcEndDate, 'yyyy-MM-dd'));
              IF (@ProcStartDate is NULL) BEGIN 
                      --PRINT CONCAT('valid processing dates not found for StageDateId', @CurrStageDateId);
                      SET @CurrStgDtIx=@CurrStgDtIx+1;
                      CONTINUE; 
              END;

              DECLARE @ProcNextStepStartDate datetime, @ProcNextStepEndDate datetime
              SELECT @ProcNextStepStartDate = StartDate,  @ProcNextStepEndDate = EndDate 
                      FROM [dbo].[fnGetOverlappingDates](@ProcStartDate, @ProcEndDate
                      , @CurrStepStartDate, ISNULL(@CurrStepEndDate, DATEADD(day,@StepSizedays,@CurrStepStartDate)));

              IF (@DeprecatedDate IS NOT NULL) SELECT @ProcNextStepStartDate = StartDate,  @ProcNextStepEndDate = EndDate 
                                    FROM [dbo].[fnGetOverlappingDates](@ProcNextStepStartDate, @ProcNextStepEndDate, NULL, @DeprecatedDate);

              --PRINT 'processing first Step using...'; 
              --PRINT CONCAT(' @ProcNextStepStartDate:', FORMAT(@ProcNextStepStartDate,'yyyy-MM-dd'),' @ProcNextStepEndDate:', FORMAT(@ProcNextStepEndDate, 'yyyy-MM-dd'));
                      
              --BEGIN TRAN;
              --PRINT 'Process one day'
              WHILE @ProcNextStepEndDate <= @ProcEndDate BEGIN

                --PRINT CONCAT('EXECUTE [dbo].[spPivotExcursionPoints] ''', @TagName, ''', ''', ' StageDateId:', @CurrStageDateId); 
                --PRINT CONCAT(FORMAT(@ProcNextStepStartDate, 'yyyy-MM-dd'), ''', ''', FORMAT(@ProcNextStepEndDate, 'yyyy-MM-dd'), ''', ');
                --PRINT CONCAT(CONVERT(varchar(255), @MinThreshold), ', ', CONVERT(varchar(255), @MaxThreshold), ', ')
                --PRINT CONCAT(Convert(varchar(16), @TagId), ', '); 
                --PRINT CONCAT(Convert(varchar(16), @ThresholdDuration), ', ', Convert(varchar(16), @SetPoint));

                -- Update or insert PointsPaces row
                DECLARE @currPaceId int = null;
                IF (@PaceId <= 0) BEGIN
                        INSERT INTO [dbo].[PointsPaces] ([StageDateId],[NextStepStartDate],[StepSizeDays],[ProcessedDate])
                                    VALUES (@CurrStageDateId, @ProcNextStepStartDate, @StepSizedays , GetDate() ); 
                        SET @currPaceId = SCOPE_IDENTITY();
                END
                ELSE BEGIN
                        UPDATE [dbo].[PointsPaces] SET ProcessedDate = GetDate()
                        WHERE PaceId = @PaceId;
                        SET @currPaceId = @PaceId;
                        SET @PaceId = -1; --subsequent PointsPaces should be inserted after the first update
                END
                      
                -- Insert Log
                DECLARE @StepLogId int;
				INSERT INTO [dbo].[PointsStepsLog] (
									[StageDateId], [StageId], [TagId], [TagName]
								,[StageStartDate], [StageEndDate], [DeprecatedDate], [DecommissionedDate]
								,[MinThreshold], [MaxThreshold]
								,[PaceId], [PaceStartDate]
								,[StartDate], [EndDate]
								,[ThresholdDuration], [SetPoint]
							)
						VALUES (
									@CurrStageDateId, @StageId, @TagId, @TagName
								,@StageStartDate, @StageEndDate, @DeprecatedDate, @DecommissionedDate
								,@MinThreshold, @MaxThreshold
								,@currPaceId, @ProcNextStepStartDate
								,@ProcNextStepStartDate, @ProcNextStepEndDate
								,@ThresholdDuration, @SetPoint
							)
				SET @StepLogId = SCOPE_IDENTITY();

                --PRINT 'Find Excursions in date range'
                DECLARE @pivotReturnValue int = 0;
                INSERT INTO @ExcPoints (
                        [CycleId], [StageDateId], [TagId], [TagName], [TagExcNbr]
                , [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
                , [LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue]
                , [HiPointsCt], [LowPointsCt], [MinThreshold], [MaxThreshold]
                , [MinValue], [MaxValue], [AvergValue], [StdDevValue]
                , [ThresholdDuration], [SetPoint]
                )
                EXECUTE @pivotReturnValue = [dbo].[spPivotExcursionPoints] @CurrStageDateId, @ProcNextStepStartDate
                        , @ProcNextStepEndDate, @MinThreshold, @MaxThreshold, '00:00:01';
                             UPDATE @ExcPoints SET StepLogId = @StepLogId WHERE StepLogId IS NULL;

                DECLARE @dbgExcsFound int, @dbgFirstExcDate datetime;
                SELECT @dbgExcsFound = count(*) from @ExcPoints;
                SELECT top 1 @dbgFirstExcDate = FirstExcDate from @ExcPoints;
                --PRINT CONCAT('DEBUG: @dbgExcsFound:',@dbgExcsFound,'@dbgFirstExcDate:',@dbgFirstExcDate);

                SET @ProcNextStepStartDate = @ProcNextStepEndDate; 
                SET @ProcNextStepEndDate = DateAdd(day, @StepSizedays, @ProcNextStepStartDate);
                --PRINT 'processing next Step using...'; 
                --PRINT CONCAT(' @ProcNextStepStartDate:', FORMAT(@ProcNextStepStartDate,'yyyy-MM-dd'),' @ProcNextStepEndDate:', FORMAT(@ProcNextStepEndDate, 'yyyy-MM-dd'));

              END -- Next day in date Range

              --SELECT @dbgExcsFound = count(*) from @ExcPoints;
              --SELECT top 1 @dbgFirstExcDate = FirstExcDate from @ExcPoints;
              --PRINT CONCAT(' <<< GET new excursions in date range: @dbgExcsFound:',@dbgExcsFound,' @dbgFirstExcDate:',@dbgFirstExcDate);

              PRINT ' <<< GET new excursions in date range ENDED'
--*****************************************************************************************
              PRINT ' >>> Compress lengthy excursions'
             
              --PRINT 'UPDATE ThresholdDuration, SetPoint... in the new excursions found through spPivot'
              UPDATE @ExcPoints SET ThresholdDuration = @ThresholdDuration
                        , SetPoint = @SetPoint, DeprecatedDate = @DeprecatedDate, DecommissionedDate = @DecommissionedDate, NewRowId = RowId;

     --         DECLARE @dbgUpdateCnt int, @dbgInsertCnt int;
     --         SELECT @dbgUpdateCnt = count(*) from @ExcPoints WHERE CycleId > 0;
     --         SELECT @dbgInsertCnt = count(*) from @ExcPoints WHERE CycleId < 0;
                        --PRINT CONCAT('Compress :excursions: @dbgUpdateCnt:', @dbgUpdateCnt,' @dbgInsertCnt:', @dbgInsertCnt);


              DECLARE @CycleId int,@FirstExcDate datetime, @FirstExcValue float, @LastExcDate datetime, @LastExcValue float
                        , @RampOutDate datetime, @RampOutValue float, @HiPointsCt int, @LowPointsCt int
              , @MinValue float, @MaxValue float, @AvergValue float, @StdDevValue float;

              DECLARE @pvtExcCount int, @pvtExcIx int, @prevPvtExcId int, @adjPvtExcId int;
              SELECT @pvtExcIx = count(*) from @ExcPoints;
              WHILE @pvtExcIx > 1 BEGIN
                      --PRINT CONCAT('check if pointed excursion #',@pvtExcIx,' can be compressed')
                      DECLARE @pointedRampInDate datetime;
                      SELECT @pointedRampInDate = RampInDate FROM @ExcPoints WHERE NewRowId = @pvtExcIx;
                      IF (@pointedRampInDate IS NOT NULL) BEGIN 
                             --PRINT CONCAT('pointed excursion #',@pvtExcIx,' can NOT be compressed. Move forward')
                             GOTO SetNextExcursion;
                      END

                      --PRINT CONCAT('check if previous excursion #',@pvtExcIx - 1,' can accept compression')
                      SET @prevPvtExcId = @pvtExcIx - 1;
                      DECLARE @previousRampOutDate datetime;
                     SELECT @previousRampOutDate = RampOutDate FROM @ExcPoints WHERE NewRowId = @prevPvtExcId;
                      IF (@previousRampOutDate IS NOT NULL) BEGIN 
                             --PRINT CONCAT('previous excursion #',@prevPvtExcId,' DOESNT accept compression. Move forward')
                             GOTO SetNextExcursion;
                      END

                      --PRINT CONCAT('       compress pointed excursion #',@pvtExcIx,'. Prepare to update previous excursion');
                             SELECT @CycleId = CycleId
                             , @LastExcDate = LastExcDate, @LastExcValue = LastExcValue, @RampOutDate = RampOutDate, @RampOutValue = RampOutValue
                             , @HiPointsCt = HiPointsCt, @LowPointsCt = LowPointsCt
                             , @MinValue = MinValue, @MaxValue = MaxValue, @AvergValue = AvergValue, @StdDevValue = StdDevValue
                             FROM @ExcPoints where NewRowId = @pvtExcIx;
                      --PRINT '              update previous excursion with pointed excursion'
                             UPDATE @ExcPoints
                             SET LastExcDate = @LastExcDate, LastExcValue = @LastExcValue, RampOutDate = @RampOutDate, RampOutValue = @RampOutValue
                                    , HiPointsCt = HiPointsCt + @HiPointsCt, LowPointsCt = LowPointsCt + @LowPointsCt
                                    , StepLogId = @StepLogId
                                    , MinValue = @MinValue, MaxValue = @MaxValue, AvergValue = @AvergValue, StdDevValue = @StdDevValue
                             WHERE  NewRowId = @prevPvtExcId;
                      --PRINT '          delete pointed excursion'
                             DELETE FROM @ExcPoints where NewRowId = @pvtExcIx;
                      --PRINT CONCAT('         excursion #',@pvtExcIx,' compressed')
                                                  -- Adjust subsequent rows NewRowId
                                                  UPDATE @ExcPoints SET NewRowId = NewRowId - 1 WHERE NewRowId > @pvtExcIx;

SetNextExcursion:
                      SET @pvtExcIx = @pvtExcIx - 1;
                      --PRINT CONCAT('previous excursion #',@pvtExcIx,' is now the POINTED excursion and is ready to be processed');
              END
              
              SELECT @dbgExcsFound = count(*) from @ExcPoints;
              SELECT top 1 @dbgFirstExcDate = FirstExcDate from @ExcPoints ORDER BY NewRowId Desc;
              --PRINT CONCAT(' <<< Compress lengthy excursions: @dbgExcsFound:',@dbgExcsFound,'  @dbgFirstExcDate: ',@dbgFirstExcDate);

              PRINT ' <<< Compress lengthy excursions ENDED'
--*****************************************************************************************
            PRINT ' >>> Compute statistics '

            SELECT @pvtExcCount = count(*) from @ExcPoints;
                  SET @pvtExcIx = 1
                  --PRINT CONCAT(' Compute aggregates for every one of the ',@pvtExcCount ,' Excursions in @ExcPoints')
                  WHILE @pvtExcIx <= @pvtExcCount BEGIN
                          SELECT @FirstExcDate = FirstExcDate, @FirstExcValue = FirstExcValue, @LastExcDate = LastExcDate
                    , @LowPointsCt = LowPointsCt, @HiPointsCt = HiPointsCt 
                                 , @MinThreshold = MinThreshold, @MaxThreshold = MaxThreshold
                          FROM @ExcPoints WHERE NewRowId = @pvtExcIx
                      IF (@FirstExcDate IS NOT NULL AND @LastExcDate IS NOT NULL) BEGIN
                    PRINT CONCAT(' STATS: @TagName:',@TagName,' @FirstExcDate:', FORMAT(@FirstExcDate,'yyyy-MM-dd'),' @LastExcDate:', FORMAT(@LastExcDate,'yyyy-MM-dd'));
                                    DECLARE @OExcPointsCount int, @OMinValue float, @OMaxValue float, @OAvergValue float, @OStdDevValue float;
                    EXECUTE dbo.spGetStats @TagName, @FirstExcDate, @LastExcDate
                            , @ExcPointsCount = @OExcPointsCount OUTPUT, @MinValue = @OMinValue OUTPUT, @MaxValue = @OMaxValue OUTPUT
                            , @AvergValue = @OAvergValue OUTPUT, @StdDevValue = @OStdDevValue OUTPUT;
                    UPDATE @ExcPoints SET MinValue = @OMinValue, MaxValue = @OMaxValue
                                    , AvergValue = @OAvergValue, StdDevValue = @OStdDevValue
                                 WHERE NewRowId = @pvtExcIx;
                    IF (@FirstExcValue >= @MaxThreshold) Update @ExcPoints Set HiPointsCt = @OExcPointsCount WHERE NewRowId = @pvtExcIx;
                    ELSE Update @ExcPoints Set LowPointsCt = @OExcPointsCount WHERE NewRowId = @pvtExcIx;
                    --PRINT 'aggregated values updated'
                END

                          SET @pvtExcIx = @pvtExcIx + 1;
                  END
              
            PRINT ' <<< Compute statistics ENDED'
--*****************************************************************************************
              PRINT ' >>> Merge with ExcursionPoints table'
              --SELECT @dbgUpdateCnt = count(*) from @ExcPoints WHERE CycleId > 0;
              --SELECT @dbgInsertCnt = count(*) from @ExcPoints WHERE CycleId < 0;

              --PRINT 'Determine if first Excursion from spPivot proc can be merged with ExcursionPoints table''s last excursion'
              DECLARE @fstExcRampInDate datetime;
              SELECT @fstExcRampInDate = RampInDate FROM @ExcPoints WHERE NewRowId = 1;
              IF (@fstExcRampInDate IS NULL) BEGIN
                  --PRINT ' GET Latest Excursion row from [ExcursionPoints] table and save it in @ExcPointsWIP '
                DELETE FROM @ExcPointsWIP;
                INSERT INTO @ExcPointsWIP (CycleId, StageDateId, TagName, TagExcNbr
                    , RampInDate, RampInValue, FirstExcDate, FirstExcValue
                    , LastExcDate, LastExcValue, RampOutDate, RampOutValue
                    , HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
                    , MinValue, MaxValue, AvergValue, StdDevValue
                    , ThresholdDuration, SetPoint)
                    SELECT TOP 1 CycleId, StageDateId, TagName, TagExcNbr
                    , RampInDate, RampInValue, FirstExcDate, FirstExcValue
                    , LastExcDate, LastExcValue, RampOutDate, RampOutValue
                    , HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
                    , MinValue, MaxValue, AvergValue, StdDevValue
                    , ThresholdDuration, SetPoint
                      FROM [dbo].[ExcursionPoints] 
                WHERE StageDateId = @CurrStageDateId 
                ORDER BY TagExcNbr Desc
                     --PRINT '  IF ExcursionPoints table last entry is open for a merge ...  '
                      IF (EXISTS(SELECT * FROM @ExcPointsWIP)) BEGIN 
                             DECLARE @tblRampOutDate datetime;
                             SELECT TOP 1 @tblRampOutDate = RampOutDate from @ExcPointsWIP;
                             IF (@tblRampOutDate IS NULL) BEGIN
                                    --PRINT ' ...Update excursion in @ExcPoints using the entry from ExcursionsTable ';
                                    SELECT @CycleId = CycleId
                                    --, @LastExcDate = LastExcDate, @LastExcValue = LastExcValue, @RampOutDate = RampOutDate, @RampOutValue = RampOutValue
                                    , @HiPointsCt = HiPointsCt, @LowPointsCt = LowPointsCt
                                    , @MinValue = MinValue, @MaxValue = MaxValue, @AvergValue = AvergValue, @StdDevValue = StdDevValue
                                    FROM @ExcPointsWIP;
                                    UPDATE @ExcPoints SET CycleId = @CycleId,  HiPointsCt = HiPointsCt + @HiPointsCt
                                    , LowPointsCt = LowPointsCt + @LowPointsCt
                                                                 --, LastExcDate = @LastExcDate, LastExcValue = @LastExcValue
         --                           , RampOutDate = @RampOutDate, RampOutValue = @RampOutValue
                                    where NewRowId = 1;
                             END
                      END
                             END

              --SELECT @dbgExcsFound = count(*) from @ExcPoints;
              --SELECT top 1 @dbgFirstExcDate = FirstExcDate from @ExcPoints;
              --PRINT CONCAT(' <<< Merge with ExcursionPoints table: @dbgExcsFound:',@dbgExcsFound,'@dbgFirstExcDate:',@dbgFirstExcDate);

              PRINT ' <<< Merge with ExcursionPoints table ENDED'
--*****************************************************************************************
              PRINT ' >>> Persist excursions to table'

              --SELECT @dbgUpdateCnt = count(*) from @ExcPoints WHERE CycleId > 0;
              --SELECT @dbgInsertCnt = count(*) from @ExcPoints WHERE CycleId < 0;

              INSERT INTO @ExcPointsOutput
              SELECT * FROM @ExcPoints;

              UPDATE ExcursionPoints 
              SET HiPointsCt = ep.HiPointsCt, LowPointsCt = ep.LowPointsCt, LastExcDate = ep.LastExcDate, LastExcValue = ep.LastExcValue
              , RampOutDate = ep.RampOutDate, RampOutValue = ep.RampOutValue
              FROM @ExcPoints as ep
              WHERE ep.CycleId > 0 AND ExcursionPoints.CycleId = ep.CycleId

              DELETE FROM @ExcPoints WHERE CycleId > 0;

              DECLARE @HighestTagExcNbr int;
              SELECT TOP 1 @HighestTagExcNbr = TagExcNbr from [dbo].[ExcursionPoints] WHERE StageDateId = @CurrStageDateId ORDER BY TagExcNbr Desc;
              if (@HighestTagExcNbr IS NULL) SET @HighestTagExcNbr = 0;

              --PRINT 'Resquence TagExcNbr of excursions that will be inserted'
              UPDATE exp SET TagExcNbr = NewSeq
              FROM @ExcPoints as exp 
              inner join 
              (SELECT FirstExcDate,  (@HighestTagExcNbr + Row_number()OVER(ORDER BY FirstExcDate ) ) as NewSeq 
                             FROM @ExcPoints ) as rsq
              ON exp.FirstExcDate = rsq.FirstExcDate
              WHERE exp.CycleId < 0;

              --DECLARE @dbgDuplicatedTag int, @dbgDuplicatedExcNbrCount int;
              --SElECT TOP 1 @dbgDuplicatedTag = TagExcNbr, @dbgDuplicatedExcNbrCount = count(*) 
              --FROM @ExcPoints      Group by TagExcNbr Having count(*) > 1;
              --PRINT CONCAT(' @dbgDuplicatedTag:',@dbgDuplicatedTag,' @dbgDuplicatedExcNbrCount:',@dbgDuplicatedExcNbrCount);

              --PRINT 'Insert new Excursions to ExcursionPoints Table'
              Insert into ExcursionPoints ( 
                      TagId, TagName, TagExcNbr, StageDateId, StepLogId
                      , RampInDate, RampInValue, FirstExcDate, FirstExcValue
                      , LastExcDate, LastExcValue, RampOutDate, RampOutValue
                      , HiPointsCt, LowPointsCt, MinThreshold,MaxThreshold
                      , MinValue, MaxValue, AvergValue, StdDevValue
                      , DeprecatedDate, DecommissionedDate, ThresholdDuration, SetPoint
                      )
              SELECT 
                      --TagId, TagName, IsNull(TagExcNbr,0), StageDateId, @StepLogId as StepLogId
                      TagId, TagName, IsNull(TagExcNbr,0), StageDateId, StepLogId
                      , RampInDate, RampInValue, FirstExcDate, FirstExcValue
                      , LastExcDate, LastExcValue, RampOutDate, RampOutValue
                      , HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
                      , MinValue, MaxValue, AvergValue, StdDevValue
                      , DeprecatedDate, DecommissionedDate, ThresholdDuration, SetPoint
                      FROM @ExcPoints

              --SELECT @dbgExcsFound = count(*) from @ExcPoints;
              --SELECT top 1 @dbgFirstExcDate = FirstExcDate from @ExcPoints;
              --PRINT CONCAT(' <<< Persist excursions to table: @dbgExcsFound:',@dbgExcsFound,' @dbgFirstExcDate:',@dbgFirstExcDate);

              PRINT ' <<< Persist excursions to table ENDED'
--*****************************************************************************************
              -- Insert PointsPaces' next process row if Tag was not deprecated in the next PointsPace time interval
              if (@DeprecatedDate IS NULL OR @DeprecatedDate > DateAdd(day,@StepSizeDays,@ProcNextStepStartDate))
              INSERT INTO [dbo].[PointsPaces] ([StageDateId],[NextStepStartDate],[StepSizeDays],[ProcessedDate])
                      VALUES (@CurrStageDateId, @ProcNextStepStartDate, @StepSizedays, NULL );

NextStageDate:
              SET @CurrStgDtIx=@CurrStgDtIx+1;
       END; -- Next stageDate


spDriverExit:

SELECT * FROM @ExcPointsOutput;

--SELECT @dbgExcsFound = count(*) from @ExcPointsOutput;
--SELECT top 1 @dbgFirstExcDate = FirstExcDate from @ExcPointsOutput;
--PRINT CONCAT(' <<< spDriverExcursionsPointsForDate: @dbgExcsFound:',@dbgExcsFound,'@dbgFirstExcDate:',@dbgFirstExcDate);


PRINT '  <<< spDriverExcursionsPointsForDate ENDED'

--RETURN @pivotReturnValue;
RETURN 0;;

--UNIT TESTS
--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', NULL
--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', '15,14'
--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', '12341234'

END;
