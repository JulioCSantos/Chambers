CREATE TABLE [dbo].[Stages] (
    [StageId]   INT            IDENTITY (1, 1) NOT NULL,
    [TagId]     INT            NOT NULL,
    [StageName] NVARCHAR (255) NULL,
    [MinValue]  FLOAT (53)     CONSTRAINT [DF_Stages_MinValue] DEFAULT ((0)) NOT NULL,
    [MaxValue]  FLOAT (53)     CONSTRAINT [DF_Stages_MaxValue] DEFAULT ((3.4000000000000000e+038)) NOT NULL,
    PRIMARY KEY CLUSTERED ([StageId] ASC),
    CONSTRAINT [TagsTagId2StagesTagId] FOREIGN KEY ([TagId]) REFERENCES [dbo].[Tags] ([TagId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IxTagStageName]
    ON [dbo].[Stages]([TagId] ASC, [StageName] ASC);

