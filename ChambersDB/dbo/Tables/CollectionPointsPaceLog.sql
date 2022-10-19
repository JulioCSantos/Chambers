CREATE TABLE [dbo].[CollectionPointsPaceLog] (
    [PaceLogId]     INT      IDENTITY (1, 1) NOT NULL,
    [PaceId]        INT      NOT NULL,
    [StageDatesId]  INT      NOT NULL,
    [StepStartTime] DATETIME NOT NULL,
    [StepEndTime]   DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([PaceLogId] ASC),
    FOREIGN KEY ([PaceId]) REFERENCES [dbo].[CollectionPointsPace] ([PaceId]),
    FOREIGN KEY ([StageDatesId]) REFERENCES [dbo].[StagesDates] ([StageDateId])
);

