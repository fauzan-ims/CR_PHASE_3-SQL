CREATE TABLE [dbo].[WRITE_OFF_RECOVERY] (
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]           NVARCHAR (250)  NOT NULL,
    [RECOVERY_STATUS]       NVARCHAR (10)   NOT NULL,
    [RECOVERY_DATE]         DATETIME        NOT NULL,
    [WO_AMOUNT]             DECIMAL (18, 2) NOT NULL,
    [WO_RECOVERY_AMOUNT]    DECIMAL (18, 2) NOT NULL,
    [RECOVERY_AMOUNT]       DECIMAL (18, 2) NOT NULL,
    [RECOVERY_REMARKS]      NVARCHAR (4000) CONSTRAINT [DF_WRITE_OFF_RECOVERY_RECOVERY_REMARKS] DEFAULT ((0)) NOT NULL,
    [AGREEMENT_NO]          NVARCHAR (50)   NOT NULL,
    [RECEIVED_REQUEST_CODE] NVARCHAR (50)   NULL,
    [RECEIVED_VOUCHER_NO]   NVARCHAR (50)   NULL,
    [RECEIVED_VOUCHER_DATE] DATETIME        NULL,
    [PROCESS_REFF_NO]       NVARCHAR (50)   NULL,
    [PROCESS_REFF_NAME]     NVARCHAR (250)  NULL,
    [PROCESS_DATE]          DATETIME        NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_WRITE_OFF_RECOVERY] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_WRITE_OFF_RECOVERY_AGREEMENT_MAIN] FOREIGN KEY ([AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses recovery write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_RECOVERY', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses recovery write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_RECOVERY', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses recovery write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_RECOVERY', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses recovery pada proses recovery write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_RECOVERY', @level2type = N'COLUMN', @level2name = N'RECOVERY_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai recovery pada proses recovery write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_RECOVERY', @level2type = N'COLUMN', @level2name = N'RECOVERY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses recovery write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_RECOVERY', @level2type = N'COLUMN', @level2name = N'RECOVERY_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada proses recovery write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_RECOVERY', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode received request pada proses recovery write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_RECOVERY', @level2type = N'COLUMN', @level2name = N'RECEIVED_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor received voucher pada proses recovery write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_RECOVERY', @level2type = N'COLUMN', @level2name = N'RECEIVED_VOUCHER_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal received voucher pada proses recovery write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_RECOVERY', @level2type = N'COLUMN', @level2name = N'RECEIVED_VOUCHER_DATE';

