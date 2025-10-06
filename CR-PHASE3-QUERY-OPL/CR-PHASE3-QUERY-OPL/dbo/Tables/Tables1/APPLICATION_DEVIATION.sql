CREATE TABLE [dbo].[APPLICATION_DEVIATION] (
    [ID]             BIGINT          IDENTITY (1, 1) NOT NULL,
    [APPLICATION_NO] NVARCHAR (50)   NOT NULL,
    [DEVIATION_CODE] NVARCHAR (50)   NOT NULL,
    [REMARKS]        NVARCHAR (4000) NOT NULL,
    [POSITION_CODE]  NVARCHAR (50)   NULL,
    [POSITION_NAME]  NVARCHAR (250)  NULL,
    [IS_MANUAL]      NVARCHAR (1)    CONSTRAINT [DF_APPLICATION_DEVIATION_IS_AUTO] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_APPLICATION_DEVIATION] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_APPLICATION_DEVIATION_APPLICATION_MAIN] FOREIGN KEY ([APPLICATION_NO]) REFERENCES [dbo].[APPLICATION_MAIN] ([APPLICATION_NO]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode posisi yang dapat menyetujui atas deviation tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_DEVIATION', @level2type = N'COLUMN', @level2name = N'POSITION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Posisi jabatan yang dapat menyetujui atas deviation tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_DEVIATION', @level2type = N'COLUMN', @level2name = N'POSITION_NAME';

