CREATE VIEW dbo.Excursions
AS
SELECT RI.TagId, RI.TagName, RI.ExcNbr, RI.ValueDate AS RampInDater, RO.ValueDate AS RampOutDate
, RI.PointNbr AS RampInPointNb, RO.PointNbr AS RampOutPointNbr
FROM  dbo.ExcursionPoints AS RI INNER JOIN dbo.ExcursionPoints AS RO 
	ON RI.TagId = RI.TagId AND RI.ExcNbr = RI.ExcNbr