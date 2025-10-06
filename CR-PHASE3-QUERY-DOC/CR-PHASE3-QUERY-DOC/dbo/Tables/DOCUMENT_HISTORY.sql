CREATE TABLE [dbo].[DOCUMENT_HISTORY] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [DOCUMENT_CODE]        NVARCHAR (50)   NOT NULL,
    [DOCUMENT_STATUS]      NVARCHAR (20)   CONSTRAINT [DF_DOCUMENT_HISTORY_DOCUMENT_STATUS1] DEFAULT (N'OUT LOCKER') NULL,
    [MOVEMENT_TYPE]        NVARCHAR (20)   CONSTRAINT [DF_DOCUMENT_HISTORY_MUTATION_TYPE] DEFAULT (N'OUT LOCKER') NULL,
    [MOVEMENT_LOCATION]    NVARCHAR (20)   CONSTRAINT [DF_DOCUMENT_HISTORY_MUTATION_LOCATION] DEFAULT (N'OUT LOCKER') NULL,
    [MOVEMENT_FROM]        NVARCHAR (50)   CONSTRAINT [DF_DOCUMENT_HISTORY_MUTATION_FROM] DEFAULT (N'OUT LOCKER') NULL,
    [MOVEMENT_TO]          NVARCHAR (50)   CONSTRAINT [DF_DOCUMENT_HISTORY_MUTATION_TO] DEFAULT (N'OUT LOCKER') NULL,
    [MOVEMENT_BY]          NVARCHAR (250)  CONSTRAINT [DF_DOCUMENT_HISTORY_MUTATION_BY] DEFAULT (N'OUT LOCKER') NULL,
    [MOVEMENT_DATE]        DATETIME        NULL,
    [MOVEMENT_RETURN_DATE] DATETIME        NULL,
    [LOCKER_POSITION]      NVARCHAR (10)   CONSTRAINT [DF_DOCUMENT_HISTORY_LOCKER_POSITION] DEFAULT (N'OUT LOCKER') NOT NULL,
    [LOCKER_CODE]          NVARCHAR (50)   NULL,
    [DRAWER_CODE]          NVARCHAR (50)   NULL,
    [ROW_CODE]             NVARCHAR (50)   NULL,
    [REMARKS]              NVARCHAR (4000) NOT NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_DOCUMENT_HISTORY] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_DOCUMENT_HISTORY_DOCUMENT_MAIN] FOREIGN KEY ([DOCUMENT_CODE]) REFERENCES [dbo].[DOCUMENT_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_DOCUMENT_HISTORY_MASTER_DRAWER] FOREIGN KEY ([DRAWER_CODE]) REFERENCES [dbo].[MASTER_DRAWER] ([CODE]),
    CONSTRAINT [FK_DOCUMENT_HISTORY_MASTER_LOCKER] FOREIGN KEY ([LOCKER_CODE]) REFERENCES [dbo].[MASTER_LOCKER] ([CODE]),
    CONSTRAINT [FK_DOCUMENT_HISTORY_MASTER_ROW] FOREIGN KEY ([ROW_CODE]) REFERENCES [dbo].[MASTER_ROW] ([CODE])
);


GO
CREATE NONCLUSTERED INDEX [IDX_DOCUMENT_HISTORY_DOCUMENT_STATUS_MOD_DATE_20250615]
    ON [dbo].[DOCUMENT_HISTORY]([DOCUMENT_STATUS] ASC, [MOD_DATE] ASC)
    INCLUDE([DOCUMENT_CODE]);


GO
CREATE NONCLUSTERED INDEX [IDX_DOCUMENT_HISTORY_MOVEMENT_TYPE_MOVEMENT_LOCATION_MOVEMENT_DATE_20250615]
    ON [dbo].[DOCUMENT_HISTORY]([MOVEMENT_TYPE] ASC, [MOVEMENT_LOCATION] ASC, [MOVEMENT_DATE] ASC)
    INCLUDE([DOCUMENT_CODE], [MOVEMENT_TO], [MOVEMENT_BY], [MOVEMENT_RETURN_DATE]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data history dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'DOCUMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dokumen pada data document history tersebut - ON HAND, menginformasikan bahwa dokumen tersebut berada pada pihak multifinance - ON BORROW, menginformasikan bahwa dokumen tersebut sedang dipinjam oleh pihak lain - ON CLIENT, menginformasikan bahwa dokumen tersebut sedang berada di client - ON TRANSIT BORROW, menginformasikan bahwa dokumen tersebut sedang dalam proses engiriman untuk dipinjam oleh pihak lain - ON TRANSIT RETURN, menginformasikan bahwa dokumen tersebut  sedang dalam proses pengembalian dari proses peminjaman', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'DOCUMENT_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe movement pada data document history tersebut - BORROW, menginformasikan bahwa tipe movement tersebut merupakan proses peminjaman - RELEASE, menginformasikan bahwa tipe movement tersebut merupakan proses release ke client - ENTRY, menginformasikan bahwa tipe movement tersebut merupakan proses entry - RETRIEVE, menginformasikan bahwa tipe movement tersebut merupakan proses pengeluaran dari loker - RETURN, menginformasikan bahwa tipe movement tersebut merupakan proses pengembalian setelah dilakukan proses peminjaman - STORE, menginformasikan bahwa tipe movement tersebut merupakan proses penyimpanan ke loker - ON TRANSIT BORROW, menginformasikan bahwa movement dokumen tersebut sedang dalam proses pengiriman untuk dilakukan proses pinjam - ON TRANSIT RETURN, menginformasikan bahwa movement dokumen tersebut sedang dalam proses pengiriman untuk dilakukan proses pinjam', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'MOVEMENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis lokasi terjadinya proses movement tersebut - THIRDPARTY, menginformasikan bahwa proses movement tersebut lokasinya terjadi di thirdparty - CLIENT, menginformasikan bahwa proses movement tersebut lokasinya terjadi di client - BRANCH, menginformasikan bahwa proses movement tersebut terjadi antar cabang - DEPARTMENT - menginformasikan bahwa proses movement tersebut terjadi antar department', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'MOVEMENT_LOCATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Asal dari dokumen yang dilakukan proses movement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'MOVEMENT_FROM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tujuan dari dokumen pada proses movement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'MOVEMENT_TO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama pihak yang melakukan proses movement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'MOVEMENT_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dari movement dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'MOVEMENT_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal pengembalian dokumen yang dilakukan proses movement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'MOVEMENT_RETURN_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Posisi dari dokumen tersebut - IN LOCKER, menginformasikan bahwa dokumen tersebut posisinya sedang didalam loket - OUT LOCKER, menginformasikan bahwa dokumen tersebut posisinya sedang berada di luar loker', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'LOCKER_POSITION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode loker tempat penyimpanan dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'LOCKER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode laci tempat penyimpanan dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'DRAWER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode baris tempat penyimpanan dokumen tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'ROW_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada data dokumen history tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_HISTORY', @level2type = N'COLUMN', @level2name = N'REMARKS';

