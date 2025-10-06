CREATE TABLE [dbo].[RPT_KEUNTUNGAN_KERUGIAN_PENJUALAN_ASET_LIST_SUMMARY] (
    [USER_ID]              NVARCHAR (50)   NULL,
    [DESKRIPSI]            NVARCHAR (250)  NULL,
    [BIAYA_PEROLEHAN]      DECIMAL (18, 2) NULL,
    [AKUMULASI_PENYUSUTAN] DECIMAL (18, 2) NULL,
    [NILAI_BUKU_NETO]      DECIMAL (18, 2) NULL,
    [HARGA_JUAL]           DECIMAL (18, 2) NULL,
    [KEUNTUNGAN_KERUGIAN]  DECIMAL (18, 2) NULL,
    [TOTAL]                DECIMAL (18, 2) NULL,
    [CRE_DATE]             DATETIME        NULL,
    [CRE_BY]               NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NULL,
    [MOD_DATE]             DATETIME        NULL,
    [MOD_BY]               NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NULL
);

