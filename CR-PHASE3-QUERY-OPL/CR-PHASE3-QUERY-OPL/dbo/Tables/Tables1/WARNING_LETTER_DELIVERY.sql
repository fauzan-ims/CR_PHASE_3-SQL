CREATE TABLE [dbo].[WARNING_LETTER_DELIVERY] (
    [CODE]                        NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]                 NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]                 NVARCHAR (250)  NOT NULL,
    [DELIVERY_STATUS]             NVARCHAR (10)   NOT NULL,
    [DELIVERY_DATE]               DATETIME        NOT NULL,
    [DELIVERY_COURIER_TYPE]       NVARCHAR (10)   NOT NULL,
    [DELIVERY_COURIER_CODE]       NVARCHAR (50)   NULL,
    [DELIVERY_COLLECTOR_CODE]     NVARCHAR (50)   NULL,
    [DELIVERY_COLLECTOR_NAME]     NVARCHAR (250)  NULL,
    [DELIVERY_REMARKS]            NVARCHAR (4000) NOT NULL,
    [CRE_DATE]                    DATETIME        NOT NULL,
    [CRE_BY]                      NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                    DATETIME        NOT NULL,
    [MOD_BY]                      NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    [CLIENT_NO]                   NVARCHAR (50)   NULL,
    [CLIENT_NAME]                 NVARCHAR (250)  NULL,
    [DELIVERY_ADDRESS]            NVARCHAR (4000) NULL,
    [DELIVERY_TO_NAME]            NVARCHAR (250)  NULL,
    [CLIENT_PHONE_NO]             NVARCHAR (50)   NULL,
    [CLIENT_NPWP]                 NVARCHAR (50)   NULL,
    [CLIENT_EMAIL]                NVARCHAR (50)   NULL,
    [LETTER_DATE]                 DATETIME        NULL,
    [LETTER_TYPE]                 NVARCHAR (50)   NULL,
    [GENERATE_TYPE]               NVARCHAR (50)   NULL,
    [OVERDUE_DAYS]                BIGINT          NULL,
    [TOTAL_OVERDUE_AMOUNT]        DECIMAL (18, 2) NULL,
    [TOTAL_AGREEMENT]             BIGINT          NULL,
    [TOTAL_ASSET]                 BIGINT          NULL,
    [TOTAL_MONTHLY_RENTAL_AMOUNT] DECIMAL (18, 2) NULL,
    [LAST_PRINT_BY]               NVARCHAR (50)   NULL,
    [PRINT_COUNT]                 BIGINT          NULL,
    [RESULT]                      NVARCHAR (50)   NULL,
    [RECEIVED_DATE]               DATETIME        NULL,
    [RECEIVED_BY]                 NVARCHAR (50)   NULL,
    [RESI_NO]                     NVARCHAR (50)   NULL,
    [REJECT_DATE]                 DATETIME        NULL,
    [REASON_CODE]                 NVARCHAR (50)   NULL,
    [REASON_DESC]                 NVARCHAR (50)   NULL,
    [RESULT_REMARK]               NVARCHAR (4000) NULL,
    [FILE_NAME]                   NVARCHAR (250)  NULL,
    [PATH]                        NVARCHAR (250)  NULL,
    [UP_PRINT_SP]                 NVARCHAR (250)  NULL,
    CONSTRAINT [PK_COLLECTION_LETTER_DELIVERY_HEADER] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses pengiriman surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses pengiriman surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses pengiriman surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pengiriman pada proses pengiriman surat peringatan tersebut (Sudah terkirim / Tidak terkirim)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY', @level2type = N'COLUMN', @level2name = N'DELIVERY_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal pengiriman surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY', @level2type = N'COLUMN', @level2name = N'DELIVERY_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe kurir pada proses pengiriman surat peringatan tersebut - INTERNAL, menginformasikan bahwa surat peringatan tersebut dikirim oleh pihak internal multifinance - EXTERNAL, menginformasikan bahwa surat peringatan tersebut dikirim oleh kurir external', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY', @level2type = N'COLUMN', @level2name = N'DELIVERY_COURIER_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kurir pengirim pada proses pengiriman surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY', @level2type = N'COLUMN', @level2name = N'DELIVERY_COURIER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode collector pengirim surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY', @level2type = N'COLUMN', @level2name = N'DELIVERY_COLLECTOR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode collector pengirim surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY', @level2type = N'COLUMN', @level2name = N'DELIVERY_COLLECTOR_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses pengiriman surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY', @level2type = N'COLUMN', @level2name = N'DELIVERY_REMARKS';

