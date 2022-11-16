EXEC	[dbo].[spPivotExcursionPoints]
		@TagName = N'chamber_report_tag_1',
		@StartDate = N'2022-11-01 08:00:00',
		@EndDate = N'2022-11-10 08:00:00',
		@LowThreashold = 100,
		@HiThreashold = 200