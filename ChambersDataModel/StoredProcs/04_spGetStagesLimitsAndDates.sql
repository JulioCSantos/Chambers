CREATE PROCEDURE [dbo].[spGetStagesLimitsAndDates]
	@TagId int,
	@DateTime DateTime
AS
	SELECT * FROM StagesLimitsAndDates
	WHERE TagId = @TagId AND @DateTime BETWEEN [StartDate] AND [EndDate]
