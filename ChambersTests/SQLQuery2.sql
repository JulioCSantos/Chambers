EXEC [dbo].[spDriverExcursionsPointsForDate] @ForDate = '2022-11-01';
SELECT * FROM dbo.ExcursionPoints;
SELECT * FROM dbo.PointsStepsLog;