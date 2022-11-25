EXEC [dbo].[spPivotExcursionPoints] @TagName = 'chamber_report_tag_1', @StartDate = '2022-11-01', @EndDate = '2022-11-03'
		, @LowThreashold = 100, @HiThreashold = 200, @TagId = 111, @StepLogId = 222;
--DELETE FROM [dbo].ExcursionPoints;