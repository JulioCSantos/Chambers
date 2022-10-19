CREATE TABLE [dbo].[StagesDates] (
    [StageDateId] INT      IDENTITY (1, 1) NOT NULL,
    [StageId]     INT      NOT NULL,
    [StartDate]   DATETIME NOT NULL,
    [EndDate]     DATETIME CONSTRAINT [DF_StagesDates_EndDate] DEFAULT ('9999-12-31 11:11:59') NULL,
    PRIMARY KEY CLUSTERED ([StageDateId] ASC),
    CONSTRAINT [FkStagesStageId_StageId] FOREIGN KEY ([StageId]) REFERENCES [dbo].[Stages] ([StageId])
);


GO
CREATE NONCLUSTERED INDEX [IxStagesDatesTagIdStartDate]
    ON [dbo].[StagesDates]([StageId] ASC, [StartDate] ASC);

