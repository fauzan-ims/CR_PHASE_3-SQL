CREATE TABLE [dbo].[DOCUMENT_MOVEMENT] (
    [CODE]                        NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]                 NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]                 NVARCHAR (250)  NOT NULL,
    [MOVEMENT_DATE]               DATETIME        NOT NULL,
    [MOVEMENT_STATUS]             NVARCHAR (20)   NOT NULL,
    [MOVEMENT_TYPE]               NVARCHAR (20)   NOT NULL,
    [MOVEMENT_LOCATION]           NVARCHAR (20)   NULL,
    [MOVEMENT_FROM]               NVARCHAR (50)   NULL,
    [MOVEMENT_TO]                 NVARCHAR (50)   NULL,
    [MOVEMENT_TO_AGREEMENT_NO]    NVARCHAR (50)   NULL,
    [MOVEMENT_TO_CLIENT_NAME]     NVARCHAR (250)  NULL,
    [MOVEMENT_TO_BRANCH_CODE]     NVARCHAR (50)   NULL,
    [MOVEMENT_TO_BRANCH_NAME]     NVARCHAR (250)  NULL,
    [MOVEMENT_FROM_DEPT_CODE]     NVARCHAR (50)   NULL,
    [MOVEMENT_FROM_DEPT_NAME]     NVARCHAR (250)  NULL,
    [MOVEMENT_TO_DEPT_CODE]       NVARCHAR (50)   NULL,
    [MOVEMENT_TO_DEPT_NAME]       NVARCHAR (250)  NULL,
    [MOVEMENT_BY_EMP_CODE]        NVARCHAR (50)   NOT NULL,
    [MOVEMENT_BY_EMP_NAME]        NVARCHAR (250)  NOT NULL,
    [MOVEMENT_TO_THIRDPARTY_TYPE] NVARCHAR (50)   NULL,
    [RECEIVED_BY]                 NVARCHAR (1)    NULL,
    [RECEIVED_ID_NO]              NVARCHAR (50)   NULL,
    [RECEIVED_NAME]               NVARCHAR (250)  NULL,
    [FILE_NAME]                   NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PATHS]                       NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [MOVEMENT_COURIER_CODE]       NVARCHAR (50)   NULL,
    [MOVEMENT_REMARKS]            NVARCHAR (4000) NULL,
    [ESTIMATE_RETURN_DATE]        DATETIME        NULL,
    [RECEIVE_STATUS]              NVARCHAR (20)   NULL,
    [RECEIVE_DATE]                DATETIME        NULL,
    [RECEIVE_REMARK]              NVARCHAR (4000) NULL,
    [FLAG_BORROW]                 NVARCHAR (15)   NULL,
    [CRE_DATE]                    DATETIME        NOT NULL,
    [CRE_BY]                      NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                    DATETIME        NOT NULL,
    [MOD_BY]                      NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_DOCUMENT_BORROW_HEADER] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IDX_DOCUMENT_MOVEMENT_MOVEMENT_STATUS_MOVEMENT_LOCATION_MOVEMENT_DATE_IDX_20250615]
    ON [dbo].[DOCUMENT_MOVEMENT]([MOVEMENT_STATUS] ASC, [MOVEMENT_LOCATION] ASC, [MOVEMENT_DATE] ASC)
    INCLUDE([BRANCH_CODE], [MOVEMENT_TYPE]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses movement document tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses movement document tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses movement document tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal pergerakan dokumen pada proses movement document tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses movement document tersebut - HOLD, menginformasikan bahwa proses movement dokumen tersebut belum diproses - ON PROCESS, menginformasikan bahwa proses movement dokumen tersebut sedang diproses - POST, menginformasikan bahwa proses movement dokumen tersebut sudah diposting - CANCEL, menginformasikan bahwa proses movement dokumen tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe movement pada proses movement dokumen tersebut - BORROW, menginformasikan bahwa tipe movement tersebut merupakan proses peminjaman - RELEASE, menginformasikan bahwa tipe movement tersebut merupakan proses release ke client - ENTRY, menginformasikan bahwa tipe movement tersebut merupakan proses entry - RETRIEVE, menginformasikan bahwa tipe movement tersebut merupakan proses pengeluaran dari loker - RETURN, menginformasikan bahwa tipe movement tersebut merupakan proses pengembalian setelah dilakukan proses peminjaman - STORE, menginformasikan bahwa tipe movement tersebut merupakan proses penyimpanan ke loker - ON TRANSIT BORROW, menginformasikan bahwa movement dokumen tersebut sedang dalam proses pengiriman untuk dilakukan proses pinjam - ON TRANSIT RETURN, menginformasikan bahwa movement dokumen tersebut sedang dalam proses pengiriman untuk dilakukan proses pinjam', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis lokasi terjadinya proses movement document tersebut - THIRDPARTY, menginformasikan bahwa proses movement tersebut lokasinya terjadi di thirdparty - CLIENT, menginformasikan bahwa proses movement tersebut lokasinya terjadi di client - BRANCH, menginformasikan bahwa proses movement tersebut terjadi antar cabang - DEPARTMENT - menginformasikan bahwa proses movement tersebut terjadi antar department', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_LOCATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Asal dari dokumen yang dilakukan proses movement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_FROM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tujuan dokumen yang dilakukan proses movement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_TO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan tujuan proses movement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_TO_AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama client tujuan proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_TO_CLIENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang tujuan proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_TO_BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang tujuan proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_TO_BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode department  asal proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_FROM_DEPT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama department asal proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_FROM_DEPT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode department tujuan proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_TO_DEPT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama department tujuan proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_TO_DEPT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode karyawan yang melakukan proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_BY_EMP_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama karyawan yang melakukan proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_BY_EMP_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe third party tujuan proses movement dokumen tersebut. Data ini diambil dari General Sub Code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_TO_THIRDPARTY_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pihak yang menerima dokumen proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'RECEIVED_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor identitas pihak yang menerima dokumen pada proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'RECEIVED_ID_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama pihak yang menerima dokumen pada proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'RECEIVED_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama file yang diupload pada proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama folder file yang diupload pada proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'PATHS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kurir yang melakukan proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_COURIER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'MOVEMENT_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal perkiraan dokumen yang dilakukan proses movement tersebut dikembalikan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'ESTIMATE_RETURN_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Not Used', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'RECEIVE_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dokumen yang dilakukan proses movement dikembalikan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'RECEIVE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses pengembalian dokumen yang dilakukan proses movement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MOVEMENT', @level2type = N'COLUMN', @level2name = N'RECEIVE_REMARK';

