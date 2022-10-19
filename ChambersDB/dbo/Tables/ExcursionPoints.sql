CREATE TABLE [dbo].[ExcursionPoints] (
    [PointId]       INT        IDENTITY (1, 1) NOT NULL,
    [ValueDate]     DATETIME   NOT NULL,
    [Value]         FLOAT (53) NOT NULL,
    [TagId]         INT        NOT NULL,
    [ExcursionType] INT        NOT NULL,
    [PaceLogId]     INT        NOT NULL,
    [MinValue]      FLOAT (53) NOT NULL,
    [MaxValue]      FLOAT (53) NOT NULL,
    PRIMARY KEY CLUSTERED ([PointId] ASC),
    FOREIGN KEY ([ExcursionType]) REFERENCES [dbo].[ExcursionTypes] ([ExcursionType]),
    FOREIGN KEY ([PaceLogId]) REFERENCES [dbo].[CollectionPointsPaceLog] ([PaceLogId])
);

