CREATE TABLE [dbo].[ENDORSEMENT_DETAIL] (
    [ID]                       BIGINT          IDENTITY (1, 1) NOT NULL,
    [ENDORSEMENT_CODE]         NVARCHAR (50)   NOT NULL,
    [OLD_OR_NEW]               NVARCHAR (3)    NOT NULL,
    [OCCUPATION_CODE]          NVARCHAR (50)   NULL,
    [REGION_CODE]              NVARCHAR (50)   NULL,
    [COLLATERAL_CATEGORY_CODE] NVARCHAR (50)   NULL,
    [OBJECT_NAME]              NVARCHAR (4000) NOT NULL,
    [INSURED_NAME]             NVARCHAR (250)  NOT NULL,
    [INSURED_QQ_NAME]          NVARCHAR (250)  NOT NULL,
    [EFF_DATE]                 DATETIME        NOT NULL,
    [EXP_DATE]                 DATETIME        NOT NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_ENDORSEMENT_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode endorsement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'ENDORSEMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mengfinformasikan apakah data tersebut merupakan data asuransi sebelum atau sesudah dilakukan proses endorsement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'OLD_OR_NEW';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode occupation pada proses endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'OCCUPATION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode wilayah asuransi pada proses endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'REGION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kategori collateral pada proses endorsement tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'COLLATERAL_CATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama objek yang diasuransikan ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'OBJECT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama yang dicover oleh maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'INSURED_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama pihak yang dibebankan pada asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'INSURED_QQ_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal mulai berlakunya asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'EFF_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kadaluwarsa asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENDORSEMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'EXP_DATE';

