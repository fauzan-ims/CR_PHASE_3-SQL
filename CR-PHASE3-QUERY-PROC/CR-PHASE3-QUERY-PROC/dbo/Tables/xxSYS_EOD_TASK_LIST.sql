CREATE TABLE [dbo].[xxSYS_EOD_TASK_LIST] (
    [CODE]           NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [NAME]           NVARCHAR (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [SP_NAME]        NVARCHAR (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ORDER_NO]       INT            NOT NULL,
    [IS_DONE]        NVARCHAR (1)   COLLATE SQL_Latin1_General_CP1_CI_AS DEFAULT ((0)) NOT NULL,
    [IS_ACTIVE]      NVARCHAR (1)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_SYS_EOD_TASK_LIST] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode tasklist EOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_EOD_TASK_LIST', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama Tasklist EOD tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_EOD_TASK_LIST', @level2type = N'COLUMN', @level2name = N'NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama SP atas tasklist EOD tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_EOD_TASK_LIST', @level2type = N'COLUMN', @level2name = N'SP_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor urut dari tasklist EOD tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_EOD_TASK_LIST', @level2type = N'COLUMN', @level2name = N'ORDER_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data Status pengerjaan dari tasklist EOD tersebut, apakah data tasklist EOD tersebut sudah selesai dikerjakan atau belum?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_EOD_TASK_LIST', @level2type = N'COLUMN', @level2name = N'IS_DONE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari tasklist EOD tersebut, apakah data tasklist EOD tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_EOD_TASK_LIST', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

