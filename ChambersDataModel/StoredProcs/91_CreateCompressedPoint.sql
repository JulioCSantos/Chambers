CREATE PROCEDURE [BB50PCSjsantos].CreateCompressedPoint 
	-- Add the parameters for the stored procedure here
	@CurveName varchar(32) = 'HiExcursion', 
	@tagName varchar(256) ,
	@offsetDays int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (@CurveName = 'HiExcursion') BEGIN
			select @TagName as tag, DateAdd(Day,@OffsetDays,XdateStr) as time, CVal as value 
				from [ELChambers].[BB50PCSjsantos].[HiExcursion]
		END
		ELSE IF (@CurveName = 'LowExcursion') BEGIN
			select @TagName as tag, DateAdd(Day,@OffsetDays,XdateStr) as time, CVal as value 
				from [ELChambers].[BB50PCSjsantos].LowExcursion
		END
		ELSE IF (@CurveName = 'OneHiOneLowOneDay') BEGIN
			select @TagName as tag, DateAdd(Day,@OffsetDays,XdateStr) as time, CVal as value 
				from [ELChambers].[BB50PCSjsantos].OneHiOneLowOneDay
		END
		ELSE IF (@CurveName = 'OneHiOneLowTwoDays') BEGIN
			select @TagName as tag, DateAdd(Day,@OffsetDays,XdateStr) as time, CVal as value 
				from [ELChambers].[BB50PCSjsantos].OneHiOneLowTwoDays
		END
		--EXEC [BB50PCSjsantos].CreateCompressedPoint 'HiExcursion', 'my tag', 130
		--EXEC [BB50PCSjsantos].CreateCompressedPoint 'LowExcursion', 'my tag', 150
		--EXEC [BB50PCSjsantos].CreateCompressedPoint 'OneHiOneLowOneDay', 'my tag', 140
		--EXEC [BB50PCSjsantos].CreateCompressedPoint 'OneHiOneLowTwoDays', 'my tag', 160

END