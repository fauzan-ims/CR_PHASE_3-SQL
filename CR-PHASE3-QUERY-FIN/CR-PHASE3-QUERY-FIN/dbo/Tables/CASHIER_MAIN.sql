CREATE TABLE [dbo].[CASHIER_MAIN] (
    [CODE]                    NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]             NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]             NVARCHAR (250)  NOT NULL,
    [CASHIER_STATUS]          NVARCHAR (10)   NOT NULL,
    [CASHIER_OPEN_DATE]       DATETIME        NOT NULL,
    [CASHIER_CLOSE_DATE]      DATETIME        NULL,
    [CASHIER_INNITIAL_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_MAIN_CASHIER_OPEN_AMOUNT1_2] DEFAULT (N'0') NOT NULL,
    [CASHIER_OPEN_AMOUNT]     DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_MAIN_CASHIER_AMOUNT] DEFAULT (N'0') NOT NULL,
    [CASHIER_DB_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_MAIN_CASHIER_OPEN_AMOUNT1] DEFAULT (N'0') NOT NULL,
    [CASHIER_CR_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_MAIN_CASHIER_DB_AMOUNT1] DEFAULT (N'0') NOT NULL,
    [CASHIER_CLOSE_AMOUNT]    DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_MAIN_CASHIER_OPEN_AMOUNT1_1] DEFAULT (N'0') NOT NULL,
    [EMPLOYEE_CODE]           NVARCHAR (50)   NOT NULL,
    [EMPLOYEE_NAME]           NVARCHAR (250)  NOT NULL,
    [CRE_DATE]                DATETIME        NOT NULL,
    [CRE_BY]                  NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]          NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                DATETIME        NOT NULL,
    [MOD_BY]                  NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]          NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_CASHIER_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_MAIN', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada data cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada data cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data cashier tersebut - OPEN, menginformasikan bahwa cashier tersebut sedang di open - CLOSE, menginformasikan bahwa cashier tersebut sudah di close', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_MAIN', @level2type = N'COLUMN', @level2name = N'CASHIER_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kasir tersebut dilakukan proses open cashier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_MAIN', @level2type = N'COLUMN', @level2name = N'CASHIER_OPEN_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal cashier tersebut dilakukan proses close cashier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_MAIN', @level2type = N'COLUMN', @level2name = N'CASHIER_CLOSE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pada cashier saat dilakukan proses open cashier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_MAIN', @level2type = N'COLUMN', @level2name = N'CASHIER_INNITIAL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pada cashier saat dilakukan proses open cashier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_MAIN', @level2type = N'COLUMN', @level2name = N'CASHIER_OPEN_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah nilai debet pada cashier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_MAIN', @level2type = N'COLUMN', @level2name = N'CASHIER_DB_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah nilai credit pada cashier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_MAIN', @level2type = N'COLUMN', @level2name = N'CASHIER_CR_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pada cashier saat dilakukan proses close cashier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_MAIN', @level2type = N'COLUMN', @level2name = N'CASHIER_CLOSE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode karyawan pada data cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_MAIN', @level2type = N'COLUMN', @level2name = N'EMPLOYEE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama karyawan pada data cashier tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_MAIN', @level2type = N'COLUMN', @level2name = N'EMPLOYEE_NAME';

