CREATE TABLE [dbo].[ENDORSEMENT_REQUEST] (
    [CODE]                       NVARCHAR (50)  NOT NULL,
    [BRANCH_CODE]                NVARCHAR (50)  NOT NULL,
    [BRANCH_NAME]                NVARCHAR (250) NOT NULL,
    [POLICY_CODE]                NVARCHAR (50)  NOT NULL,
    [ENDORSEMENT_REQUEST_STATUS] NVARCHAR (10)  NOT NULL,
    [ENDORSEMENT_REQUEST_DATE]   DATETIME       NOT NULL,
    [ENDORSEMENT_REQUEST_TYPE]   NVARCHAR (10)  NOT NULL,
    [ENDORSEMENT_CODE]           NVARCHAR (50)  NULL,
    [REQUEST_REFF_NO]            NVARCHAR (50)  NOT NULL,
    [REQUEST_REFF_NAME]          NVARCHAR (250) NOT NULL,
    [CRE_DATE]                   DATETIME       NOT NULL,
    [CRE_BY]                     NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]             NVARCHAR (15)  NOT NULL,
    [MOD_DATE]                   DATETIME       NOT NULL,
    [MOD_BY]                     NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]             NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_INSURANCE_ENDORSEMENT_REQUEST] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses request endorsement asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses request endorsement asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses request endorsement asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode polis asuransi pada proses request endorsement asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'POLICY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses request endorsement asuransi tersebut - HOLD. menginformasikan bahwa proses request endorsement tersebut belum di proses - POST, menginformasikan bahwa proses request endorsement tersebut sudah dilakukan proses posting - CANCEL, menginformasikan bahwa proses request endorsement tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'ENDORSEMENT_REQUEST_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukan proses request endorsement asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'ENDORSEMENT_REQUEST_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe endorsement pada proses request endorsement asuransi tersebut - FINANCIAL, menginformasikan bahwa proses endorsement tersebut berhubungan dengan nominal / uang - NON FINANCIAL, menginformasikan bahwa data proses endorsement tersebut tidak berhubungan dengan nominal / uang', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'ENDORSEMENT_REQUEST_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode endorsement pada proses request endorsement asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'ENDORSEMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor referensi pada proses request endorsement asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_REFF_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama referensi pada proses request endorsement asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_REFF_NAME';

