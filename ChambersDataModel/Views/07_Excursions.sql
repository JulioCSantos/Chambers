CREATE VIEW [dbo].[Excursions]
AS
SELECT ISNULL(RI.TagId, RO.TagID) as TagId, ISNULL(RI.TagName, RO.TagName) as TagName, ISNULL(RI.ExcNbr, RO.ExcNbr) as ExcNbr
    , RI.ValueDate AS RampInDate, RI.PointNbr AS RampInPointNbr
    , RO.ValueDate AS RampOutDate, RO.PointNbr AS RampOutPointNbr
    FROM  dbo.ExcursionPoints AS RI FULL OUTER JOIN dbo.ExcursionPoints AS RO 
        ON RI.TagId = RO.TagId AND RI.ExcNbr = RO.ExcNbr AND RI.PointNbr != RO.PointNbr
WHERE (RI.ExcType = 'RampIn' AND RO.ExcType = 'RampOut')
OR (RI.ExcType = 'RampIn' AND RO.ExcType IS NULL)
OR (RI.ExcType IS NULL AND RO.ExcType = 'RampOut')