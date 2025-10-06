CREATE TABLE [dbo].[xxSYS_EOD_TASK_LIST_LOG] (
    [ID]             INT             IDENTITY (1, 1) NOT NULL,
    [EOD_CODE]       NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [EOD_DATE]       DATETIME        NOT NULL,
    [START_TIME]     DATETIME        NOT NULL,
    [END_TIME]       DATETIME        NOT NULL,
    [STATUS]         NVARCHAR (10)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [REASON]         NVARCHAR (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [FK_SYS_EOD_TASK_LIST_LOG_SYS_EOD_TASK_LIST] FOREIGN KEY ([EOD_CODE]) REFERENCES [dbo].[xxSYS_EOD_TASK_LIST] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto Generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_EOD_TASK_LIST_LOG', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode EOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_EOD_TASK_LIST_LOG', @level2type = N'COLUMN', @level2name = N'EOD_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya EOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_EOD_TASK_LIST_LOG', @level2type = N'COLUMN', @level2name = N'EOD_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Waktu dimulainya proses EOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_EOD_TASK_LIST_LOG', @level2type = N'COLUMN', @level2name = N'START_TIME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Waktu berakhirnya proses EOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_EOD_TASK_LIST_LOG', @level2type = N'COLUMN', @level2name = N'END_TIME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data EOD tasklist tersebut, apakah data EOD tersebut ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_EOD_TASK_LIST_LOG', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Reason atas log tasklist EOD tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_EOD_TASK_LIST_LOG', @level2type = N'COLUMN', @level2name = N'REASON';

