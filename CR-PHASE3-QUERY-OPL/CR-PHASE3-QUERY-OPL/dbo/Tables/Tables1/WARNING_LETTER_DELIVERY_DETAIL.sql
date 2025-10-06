CREATE TABLE [dbo].[WARNING_LETTER_DELIVERY_DETAIL] (
    [ID]               INT             IDENTITY (1, 1) NOT NULL,
    [DELIVERY_CODE]    NVARCHAR (50)   NOT NULL,
    [LETTER_CODE]      NVARCHAR (50)   NOT NULL,
    [RECEIVED_STATUS]  NVARCHAR (20)   NULL,
    [RECEIVED_DATE]    DATETIME        NULL,
    [RECEIVED_BY]      NVARCHAR (250)  NULL,
    [RECEIVED_REMARKS] NVARCHAR (4000) NULL,
    [FILE_NAME]        NVARCHAR (250)  NULL,
    [PATHS]            NVARCHAR (250)  NULL,
    [IS_POST]          NVARCHAR (1)    CONSTRAINT [DF_WARNING_LETTER_DELIVERY_DETAIL_IS_POST] DEFAULT ((0)) NOT NULL,
    [SURAT_NO_SP_1]    NVARCHAR (50)   NULL,
    [SURAT_NO_SP_2]    NVARCHAR (50)   NULL,
    [SURAT_NO_SOMASI]  NVARCHAR (50)   NULL,
    [CRE_DATE]         DATETIME        NOT NULL,
    [CRE_BY]           NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    [MOD_DATE]         DATETIME        NOT NULL,
    [MOD_BY]           NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_COLLECTION_LETTER_DELIVERY_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_WARNING_LETTER_DELIVERY_DETAIL_WARNING_LETTER_DELIVERY] FOREIGN KEY ([DELIVERY_CODE]) REFERENCES [dbo].[WARNING_LETTER_DELIVERY] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode delivery pada proses detail pengiriman surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY_DETAIL', @level2type = N'COLUMN', @level2name = N'DELIVERY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode surat peringatan pada proses detail pengiriman surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY_DETAIL', @level2type = N'COLUMN', @level2name = N'LETTER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY_DETAIL', @level2type = N'COLUMN', @level2name = N'RECEIVED_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tanggal surat peringatan tersebut diterima pada proses detail pengiriman surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY_DETAIL', @level2type = N'COLUMN', @level2name = N'RECEIVED_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pihak yang menerima surat peringatan pada proses detail pengiriman surat peringatan tersebut - CUSTOMER, menginformasikan bahwa surat peringatan tersebut diterima oleh customer langsung - OTHER, menginformasikan bahwa surat peringatan tersebut diterima oleh orang lain', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY_DETAIL', @level2type = N'COLUMN', @level2name = N'RECEIVED_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses detail pengiriman surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY_DETAIL', @level2type = N'COLUMN', @level2name = N'RECEIVED_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama file yang diupload pada proses detail pengiriman surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY_DETAIL', @level2type = N'COLUMN', @level2name = N'FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama folder file yang diupload pada proses detail pengiriman surat peringatan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY_DETAIL', @level2type = N'COLUMN', @level2name = N'PATHS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag menandakan data detailnya apakah sudah diposting atau belum', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WARNING_LETTER_DELIVERY_DETAIL', @level2type = N'COLUMN', @level2name = N'IS_POST';

