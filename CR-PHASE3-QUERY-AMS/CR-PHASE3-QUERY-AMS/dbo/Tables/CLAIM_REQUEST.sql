CREATE TABLE [dbo].[CLAIM_REQUEST] (
    [CODE]           NVARCHAR (50)  NOT NULL,
    [BRANCH_CODE]    NVARCHAR (50)  NOT NULL,
    [BRANCH_NAME]    NVARCHAR (250) NOT NULL,
    [POLICY_CODE]    NVARCHAR (50)  NOT NULL,
    [REQUEST_STATUS] NVARCHAR (10)  NOT NULL,
    [REQUEST_DATE]   DATETIME       NOT NULL,
    [CLAIM_CODE]     NVARCHAR (50)  NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_CLAIM_REQUEST] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_CLAIM_REQUEST_INSURANCE_POLICY_MAIN] FOREIGN KEY ([POLICY_CODE]) REFERENCES [dbo].[INSURANCE_POLICY_MAIN] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data claim request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_REQUEST', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada data claim request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada data claim request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode polis asuransi pada data claim request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_REQUEST', @level2type = N'COLUMN', @level2name = N'POLICY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada data claim request tersebut - HOLD, menginformasikan bahwa data claim request tersebut belum diproses  - POST, menginformasikan bahwa data claim request tersebut sudah diposting - CANCEL, menginformasikan bahwa data claim request tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses request pada data claim request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode claim pada data claim request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_REQUEST', @level2type = N'COLUMN', @level2name = N'CLAIM_CODE';

