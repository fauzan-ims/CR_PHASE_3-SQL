CREATE TABLE [dbo].[DOCUMENT_MAIN] (
    [CODE]                   NVARCHAR (50)  NOT NULL,
    [BRANCH_CODE]            NVARCHAR (50)  NOT NULL,
    [BRANCH_NAME]            NVARCHAR (250) NOT NULL,
    [CUSTODY_BRANCH_CODE]    NVARCHAR (50)  NULL,
    [CUSTODY_BRANCH_NAME]    NVARCHAR (250) NULL,
    [DOCUMENT_TYPE]          NVARCHAR (20)  NOT NULL,
    [ASSET_NO]               NVARCHAR (50)  NULL,
    [ASSET_NAME]             NVARCHAR (250) NULL,
    [LOCKER_POSITION]        NVARCHAR (10)  CONSTRAINT [DF_DOCUMENT_MAIN_LOCKER_POSITION] DEFAULT (N'OUT LOCKER') NOT NULL,
    [LOCKER_CODE]            NVARCHAR (50)  NULL,
    [DRAWER_CODE]            NVARCHAR (50)  NULL,
    [ROW_CODE]               NVARCHAR (50)  NULL,
    [DOCUMENT_STATUS]        NVARCHAR (20)  CONSTRAINT [DF_DOCUMENT_MAIN_LOCKER_POSITION1] DEFAULT (N'OUT LOCKER') NOT NULL,
    [MUTATION_TYPE]          NVARCHAR (20)  CONSTRAINT [DF_DOCUMENT_MAIN_DOCUMENT_STATUS1] DEFAULT (N'OUT LOCKER') NULL,
    [MUTATION_LOCATION]      NVARCHAR (20)  CONSTRAINT [DF_DOCUMENT_MAIN_DOCUMENT_MUTATION_STATUS1] DEFAULT (N'OUT LOCKER') NULL,
    [MUTATION_FROM]          NVARCHAR (50)  CONSTRAINT [DF_DOCUMENT_MAIN_MUTATION_LOCATION1] DEFAULT (N'OUT LOCKER') NULL,
    [MUTATION_TO]            NVARCHAR (50)  CONSTRAINT [DF_DOCUMENT_MAIN_MUTATION_FROM1] DEFAULT (N'OUT LOCKER') NULL,
    [MUTATION_BY]            NVARCHAR (250) CONSTRAINT [DF_DOCUMENT_MAIN_MUTATION_TO1] DEFAULT (N'OUT LOCKER') NULL,
    [MUTATION_DATE]          DATETIME       NULL,
    [MUTATION_RETURN_DATE]   DATETIME       NULL,
    [LAST_MUTATION_TYPE]     NVARCHAR (20)  CONSTRAINT [DF_DOCUMENT_MAIN_MUTATION_TYPE1] DEFAULT (N'OUT LOCKER') NULL,
    [LAST_MUTATION_DATE]     DATETIME       NULL,
    [LAST_LOCKER_POSITION]   NVARCHAR (10)  CONSTRAINT [DF_DOCUMENT_MAIN_LOCKER_POSITION1_1] DEFAULT (N'OUT LOCKER') NULL,
    [LAST_LOCKER_CODE]       NVARCHAR (50)  NULL,
    [LAST_DRAWER_CODE]       NVARCHAR (50)  NULL,
    [LAST_ROW_CODE]          NVARCHAR (50)  NULL,
    [BORROW_THIRDPARTY_TYPE] NVARCHAR (50)  NULL,
    [FIRST_RECEIVE_DATE]     DATETIME       NULL,
    [RELEASE_CUSTOMER_DATE]  DATETIME       NULL,
    [SOLD_DATE]              DATETIME       NULL,
    [IS_SOLD]                NVARCHAR (1)   NULL,
    [ESTIMATE_RETURN_DATE]   DATETIME       NULL,
    [FLAG_BORROW]            NVARCHAR (15)  NULL,
    [CRE_DATE]               DATETIME       NOT NULL,
    [CRE_BY]                 NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)  NOT NULL,
    [MOD_DATE]               DATETIME       NOT NULL,
    [MOD_BY]                 NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_DOCUMENT_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_DOCUMENT_MAIN_MASTER_DRAWER] FOREIGN KEY ([DRAWER_CODE]) REFERENCES [dbo].[MASTER_DRAWER] ([CODE]),
    CONSTRAINT [FK_DOCUMENT_MAIN_MASTER_DRAWER_LAST] FOREIGN KEY ([LAST_DRAWER_CODE]) REFERENCES [dbo].[MASTER_DRAWER] ([CODE]),
    CONSTRAINT [FK_DOCUMENT_MAIN_MASTER_LOCKER] FOREIGN KEY ([LOCKER_CODE]) REFERENCES [dbo].[MASTER_LOCKER] ([CODE]),
    CONSTRAINT [FK_DOCUMENT_MAIN_MASTER_LOCKER_LAST] FOREIGN KEY ([LAST_LOCKER_CODE]) REFERENCES [dbo].[MASTER_LOCKER] ([CODE]),
    CONSTRAINT [FK_DOCUMENT_MAIN_MASTER_ROW] FOREIGN KEY ([ROW_CODE]) REFERENCES [dbo].[MASTER_ROW] ([CODE]),
    CONSTRAINT [FK_DOCUMENT_MAIN_MASTER_ROW_LAST] FOREIGN KEY ([LAST_ROW_CODE]) REFERENCES [dbo].[MASTER_ROW] ([CODE])
);


GO
CREATE NONCLUSTERED INDEX [IDX_DOCUMENT_MAIN_20231003]
    ON [dbo].[DOCUMENT_MAIN]([DOCUMENT_TYPE] ASC, [DOCUMENT_STATUS] ASC, [FIRST_RECEIVE_DATE] ASC)
    INCLUDE([BRANCH_CODE], [ASSET_NO]);


GO
CREATE NONCLUSTERED INDEX [IDX_DOCUMENT_MAIN_20231004]
    ON [dbo].[DOCUMENT_MAIN]([DOCUMENT_TYPE] ASC, [ASSET_NO] ASC, [DOCUMENT_STATUS] ASC, [FIRST_RECEIVE_DATE] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_DOCUMENT_MAIN_20231004_2]
    ON [dbo].[DOCUMENT_MAIN]([DOCUMENT_TYPE] ASC, [DOCUMENT_STATUS] ASC, [FIRST_RECEIVE_DATE] ASC)
    INCLUDE([BRANCH_NAME], [ASSET_NO], [ASSET_NAME], [LOCKER_POSITION], [LOCKER_CODE], [DRAWER_CODE], [ROW_CODE], [LAST_LOCKER_CODE]);


GO
CREATE NONCLUSTERED INDEX [IDX_DOCUMENT_MAIN_DOCUMENT_STATUS_20250516]
    ON [dbo].[DOCUMENT_MAIN]([DOCUMENT_STATUS] ASC)
    INCLUDE([BRANCH_CODE], [ASSET_NO]);


GO
CREATE NONCLUSTERED INDEX [IDX_DOCUMENT_MAIN_DOCUMENT_TYPE_DOCUMENT_STATUS_20250615]
    ON [dbo].[DOCUMENT_MAIN]([DOCUMENT_TYPE] ASC, [DOCUMENT_STATUS] ASC)
    INCLUDE([ASSET_NO], [FIRST_RECEIVE_DATE], [CRE_DATE]);


GO
CREATE NONCLUSTERED INDEX [IDX_DOCUMENT_MAIN_DOCUMENT_TYPE_DOCUMENT_STATUS_20250615_1]
    ON [dbo].[DOCUMENT_MAIN]([DOCUMENT_TYPE] ASC, [DOCUMENT_STATUS] ASC)
    INCLUDE([BRANCH_NAME], [ASSET_NO], [ASSET_NAME], [LOCKER_POSITION], [LOCKER_CODE], [DRAWER_CODE], [ROW_CODE], [LAST_LOCKER_CODE], [FIRST_RECEIVE_DATE], [CRE_DATE]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses document main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses document main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses document main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses document main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'CUSTODY_BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses document main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'CUSTODY_BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe dokumen pada proses document main tersebut - COLLATERAL, menginformasikan bahwa dokumen tersebut merupakan dokumen collateral - LEGAL, menginformasikan bahwa dokumen tersebut merupakan dokumen legal  - INSURANCE, menginformasikan bahwa dokumen tersebut merupakan dokumen asuransi - OTHER, menginformasikan bahwa dokumen tersebut merupakan dokumen lainnya', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'DOCUMENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada proses document main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'ASSET_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor collateral pada proses document main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'ASSET_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Posisi loker atas dokumen pada data document main tersebut - IN LOCKER, menginformasikan bahwa dokumen tersebut sedang berada didalam loker - OUT LOCKER, menginformasikan bahwa dokumen tersebut sedang berada diluar loker', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'LOCKER_POSITION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode loker penyimpanan dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'LOCKER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode drawer penyimpanan dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'DRAWER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode row penyimpanan document tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'ROW_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada data document main tersebut - ON HAND, menginformasikan bahwa dokumen tersebut sedang berada pada multifinance - ON BORROW, menginformasikan bahwa dokumen tersebut sedang dalam proses peminjaman - ON TRANSIT BORROW, menginformasikan bahwa dokumen tersebut sedang dalam proses transit pada proses peminjaman - ON TRANSIT RETURN, menginformasikan bahwa dokumen tersebut sedang dalam proses transit pada proses pengembalian - RELEASE, menginformasikan bahwa dokumen tersebut sedang dalam proses release ke client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'DOCUMENT_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe movement pada data document history tersebut - BORROW, menginformasikan bahwa tipe movement tersebut merupakan proses peminjaman - RELEASE, menginformasikan bahwa tipe movement tersebut merupakan proses release ke client - ENTRY, menginformasikan bahwa tipe movement tersebut merupakan proses entry - RETRIEVE, menginformasikan bahwa tipe movement tersebut merupakan proses pengeluaran dari loker - RETURN, menginformasikan bahwa tipe movement tersebut merupakan proses pengembalian setelah dilakukan proses peminjaman - STORE, menginformasikan bahwa tipe movement tersebut merupakan proses penyimpanan ke loker - ON TRANSIT BORROW, menginformasikan bahwa movement dokumen tersebut sedang dalam proses pengiriman untuk dilakukan proses pinjam - ON TRANSIT RETURN, menginformasikan bahwa movement dokumen tersebut sedang dalam proses pengiriman untuk dilakukan proses pinjam', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'MUTATION_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis lokasi terjadinya proses movement tersebut - THIRDPARTY, menginformasikan bahwa proses movement tersebut lokasinya terjadi di thirdparty - CLIENT, menginformasikan bahwa proses movement tersebut lokasinya terjadi di client - BRANCH, menginformasikan bahwa proses movement tersebut terjadi antar cabang - DEPARTMENT - menginformasikan bahwa proses movement tersebut terjadi antar department', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'MUTATION_LOCATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Asal dokumen pada proses mutasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'MUTATION_FROM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tujuan dokumen pada proses mutasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'MUTATION_TO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pihak yang melakukan proses mutasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'MUTATION_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dokumen tersebut dilakukan proses mutasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'MUTATION_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses return ayas dokumen yang di mutasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'MUTATION_RETURN_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe mutasi terakhir atas dokumen main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'LAST_MUTATION_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal  terakhir kali dilakukan proses mutasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'LAST_MUTATION_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Posisi loker terakhir atas data dokumen tersebut - IN LOCKER, menginformasikan bahwa dokumen tersebut berada pada dalam loker - OUT LOCKER, menginformasikan bahwa dokumen tersebut berada di luar loker', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'LAST_LOCKER_POSITION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode loker tempat penyimpanan terkahir dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'LAST_LOCKER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode drawer tempat penyimpanan terkahir dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'LAST_DRAWER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode baris tempat penyimpanan terkahir dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'LAST_ROW_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe thirdparty pada proses peminjaman dokumen tersebut, data ini diambil dari General Sub Code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'BORROW_THIRDPARTY_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal pertama kali dokumen tersebut diterima', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'FIRST_RECEIVE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dokumen tersebut direlease ke client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_MAIN', @level2type = N'COLUMN', @level2name = N'RELEASE_CUSTOMER_DATE';

