SELECT * FROM dbo.PointsPaces;
EXEC [dbo].[spDriverExcursionsPointsForDate] @ForDate = '2022-11-03';
SELECT * FROM dbo.PointsStepsLog;
SELECT * FROM dbo.ExcursionPoints;
SELECT * FROM dbo.PointsPaces;
