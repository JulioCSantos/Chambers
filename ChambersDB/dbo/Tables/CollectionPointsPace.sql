CREATE TABLE [dbo].[CollectionPointsPace] (
    [PaceId]            INT      IDENTITY (1, 1) NOT NULL,
    [TagId]             INT      NOT NULL,
    [NextStepStartTime] DATETIME NOT NULL,
    [StepSizeDays]      INT      NOT NULL,
    [NestStepEndTime]   AS       (dateadd(day,[StepSizeDays],[NextStepStartTime])),
    PRIMARY KEY CLUSTERED ([PaceId] ASC),
    FOREIGN KEY ([TagId]) REFERENCES [dbo].[Tags] ([TagId])
);

