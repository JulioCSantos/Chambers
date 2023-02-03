--EXEC [dbo].[spPivotExcursionPoints] @TagName = 'chamber_report_tag_1', @StartDate = '2022-11-01', @EndDate = '2022-11-03'
--		, @LowThreashold = 100, @HiThreashold = 200, @TagId = 111, @StepLogId = 222;

--DELETE FROM [dbo].ExcursionPoints;
--EXEC dbo.spDriverExcursionsPointsForDate @ForDate = '2023-01-30 12:00:00 AM', @StageDateId = 1,
	--@TagName = 'spDriverExcursionsPointsForDateTests_TwoLowExcursionPointsWithRampsTest';
--EXECUTE dbo.spGetStats 'spDriverExcursionsPointsForDateTests_TwoLowExcursionPointsWithRampsTest', NULL;
--EXEC dbo.spPivotExcursionPoints 'spDriverExcursionsPointsForDateTests_ExcursionOnOffDateTest', '2022-01-01', '2022-03-31', 100, 200, null, null;
EXEC dbo.spDriverExcursionsPointsForDate '2023-02-23 12:00:00', 1, 'SpPivotExcursionPointsTests_HiExcursionWithPrevTagExcNbrTest';