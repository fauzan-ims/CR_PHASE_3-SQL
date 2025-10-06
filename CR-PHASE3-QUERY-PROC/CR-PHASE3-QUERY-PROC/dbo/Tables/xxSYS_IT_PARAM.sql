CREATE TABLE [dbo].[xxSYS_IT_PARAM] (
    [SYSTEM_DATE]              DATETIME      NOT NULL,
    [DB_MAIL_PROFILE]          NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [USER_AUTO_INACTIVE]       INT           NOT NULL,
    [PASSWORD_MAX_REPEAT_TIME] INT           NOT NULL,
    [PASSWORD_MAX_LOGIN_TRY]   INT           NOT NULL,
    [PASSWORD_NEXT_CHANGE]     INT           NOT NULL,
    [PASSWORD_MIN_CHAR]        INT           NOT NULL,
    [PASSWORD_MAX_CHAR]        INT           NOT NULL,
    [PASSWORD_REGEX]           NVARCHAR (1)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [PASSWORD_USE_UPPERCASE]   NVARCHAR (1)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [PASSWORD_USE_LOWERCASE]   NVARCHAR (1)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [PASSWORD_CONTAIN_NUMBER]  NVARCHAR (1)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [IS_EOD_RUNNING]           NVARCHAR (1)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [EOD_MANUAL_FLAG]          NVARCHAR (1)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [SUBSCRIPTION_TYPE_CODE]   NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_SYS_IT_PARAM_SUBSCRIPTION_TYPE_CODE] DEFAULT ('') NOT NULL,
    [MAX_USER]                 INT           CONSTRAINT [DF_SYS_IT_PARAM_MAX_USER] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]                 DATETIME      NOT NULL,
    [CRE_BY]                   NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]                 DATETIME      NOT NULL,
    [MOD_BY]                   NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dari sistem tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'SYSTEM_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Settingan server email pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'DB_MAIL_PROFILE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah hari yang dibutuhkan untuk membuat user otomatis menjadi tidak aktif', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'USER_AUTO_INACTIVE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Waktu yang dibutuhkan (dalam bulan) untuk diperbolehkan menggunakan password yang sama', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_MAX_REPEAT_TIME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah (berapa kali) percobaan gagal login yang diperbolehkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_MAX_LOGIN_TRY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Waktu (dalam bulan) perubahan password login berikutnya', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_NEXT_CHANGE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah karakter minimal atas password tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_MIN_CHAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah karakter maksimal atas password tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_MAX_CHAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah password diharuskan mengandung special karakter?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_REGEX';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah password diharuskan mengandung huruf kapital?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_USE_UPPERCASE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah password diharuskan mengandung huruf kecil?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_USE_LOWERCASE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah password diharuskan mengandung angka?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_CONTAIN_NUMBER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah EOD sedang berjalan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'IS_EOD_RUNNING';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag untuk proses request melakukan proses manual EOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'xxSYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'EOD_MANUAL_FLAG';

