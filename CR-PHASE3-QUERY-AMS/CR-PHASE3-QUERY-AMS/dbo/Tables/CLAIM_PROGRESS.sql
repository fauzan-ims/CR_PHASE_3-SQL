CREATE TABLE [dbo].[CLAIM_PROGRESS] (
    [ID]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [CLAIM_CODE]             NVARCHAR (50)   NOT NULL,
    [CLAIM_PROGRESS_CODE]    NVARCHAR (50)   NOT NULL,
    [CLAIM_PROGRESS_DATE]    DATETIME        NOT NULL,
    [CLAIM_PROGRESS_REMARKS] NVARCHAR (4000) NOT NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_INSURANCE_CLAIM_PROGRESS] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_CLAIM_PROGRESS_CLAIM_MAIN] FOREIGN KEY ([CLAIM_CODE]) REFERENCES [dbo].[CLAIM_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_PROGRESS', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode claim pada progress claim tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_PROGRESS', @level2type = N'COLUMN', @level2name = N'CLAIM_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode  pada progress claim tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_PROGRESS', @level2type = N'COLUMN', @level2name = N'CLAIM_PROGRESS_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal progress pada proses claim tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_PROGRESS', @level2type = N'COLUMN', @level2name = N'CLAIM_PROGRESS_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada progress claim tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLAIM_PROGRESS', @level2type = N'COLUMN', @level2name = N'CLAIM_PROGRESS_REMARKS';

