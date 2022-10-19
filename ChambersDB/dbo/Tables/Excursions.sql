CREATE TABLE [dbo].[Excursions] (
    [ExcursionId]     INT      IDENTITY (1, 1) NOT NULL,
    [TagId]           INT      NOT NULL,
    [RampInDateTime]  DATETIME NOT NULL,
    [RampOutDateTime] DATETIME NOT NULL,
    [RampinPointId]   INT      NULL,
    [RampOutPointId]  INT      NULL,
    FOREIGN KEY ([RampinPointId]) REFERENCES [dbo].[ExcursionPoints] ([PointId]),
    FOREIGN KEY ([RampOutPointId]) REFERENCES [dbo].[ExcursionPoints] ([PointId])
);

