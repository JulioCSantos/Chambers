CREATE PROCEDURE [dbo].[spRunTagStep] 
	-- Add the parameters for the stored procedure here
	@Tag varchar(255) , 
	@StageDateId int,
	@AsOfDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @Tag, @StageDateId, @AsOfDate
END