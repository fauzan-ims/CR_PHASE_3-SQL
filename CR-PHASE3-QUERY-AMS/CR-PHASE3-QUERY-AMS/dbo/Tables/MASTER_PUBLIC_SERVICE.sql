CREATE TABLE [dbo].[MASTER_PUBLIC_SERVICE] (
    [CODE]                         NVARCHAR (50)  NOT NULL,
    [PUBLIC_SERVICE_NO]            NVARCHAR (50)  NOT NULL,
    [PUBLIC_SERVICE_NAME]          NVARCHAR (250) NOT NULL,
    [CONTACT_PERSON_NAME]          NVARCHAR (250) NOT NULL,
    [CONTACT_PERSON_AREA_PHONE_NO] NVARCHAR (4)   NOT NULL,
    [CONTACT_PERSON_PHONE_NO]      NVARCHAR (15)  NOT NULL,
    [TAX_FILE_TYPE]                NVARCHAR (10)  NOT NULL,
    [TAX_FILE_NO]                  NVARCHAR (50)  NOT NULL,
    [TAX_FILE_NAME]                NVARCHAR (250) NOT NULL,
    [TAX_FILE_ADDRESS]             NVARCHAR (250) NOT NULL,
    [AREA_PHONE_NO]                NVARCHAR (4)   NULL,
    [PHONE_NO]                     NVARCHAR (25)  NULL,
    [AREA_FAX_NO]                  NVARCHAR (4)   NULL,
    [FAX_NO]                       NVARCHAR (25)  NULL,
    [EMAIL]                        NVARCHAR (100) NULL,
    [WEBSITE]                      NVARCHAR (100) NULL,
    [IS_VALIDATE]                  NVARCHAR (1)   NOT NULL,
    [KTP_NO]                       NVARCHAR (20)  NULL,
    [CRE_DATE]                     DATETIME       NOT NULL,
    [CRE_BY]                       NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]               NVARCHAR (15)  NOT NULL,
    [MOD_DATE]                     DATETIME       NOT NULL,
    [MOD_BY]                       NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]               NVARCHAR (15)  NOT NULL,
    [OLD_TAX_FILE_NO]              NVARCHAR (20)  NULL,
    [NITKU]                        NVARCHAR (50)  NULL,
    [NPWP_PUSAT]                   NVARCHAR (50)  NULL,
    CONSTRAINT [PK_MASTER_PUBLIC_SERVICE] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_PUBLIC_SERVICE_Delete_Audit]    
			ON [dbo].[MASTER_PUBLIC_SERVICE]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_PUBLIC_SERVICE]
([CODE],[PUBLIC_SERVICE_NO],[PUBLIC_SERVICE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[KTP_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[PUBLIC_SERVICE_NO],[PUBLIC_SERVICE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[KTP_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_PUBLIC_SERVICE_Update_Audit]      
			ON [dbo].[MASTER_PUBLIC_SERVICE]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([PUBLIC_SERVICE_NO]) THEN '[PUBLIC_SERVICE_NO]-' ELSE '' END + 
CASE WHEN UPDATE([PUBLIC_SERVICE_NAME]) THEN '[PUBLIC_SERVICE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([CONTACT_PERSON_NAME]) THEN '[CONTACT_PERSON_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([CONTACT_PERSON_AREA_PHONE_NO]) THEN '[CONTACT_PERSON_AREA_PHONE_NO]-' ELSE '' END + 
CASE WHEN UPDATE([CONTACT_PERSON_PHONE_NO]) THEN '[CONTACT_PERSON_PHONE_NO]-' ELSE '' END + 
CASE WHEN UPDATE([TAX_FILE_TYPE]) THEN '[TAX_FILE_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([TAX_FILE_NO]) THEN '[TAX_FILE_NO]-' ELSE '' END + 
CASE WHEN UPDATE([TAX_FILE_NAME]) THEN '[TAX_FILE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([TAX_FILE_ADDRESS]) THEN '[TAX_FILE_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([AREA_PHONE_NO]) THEN '[AREA_PHONE_NO]-' ELSE '' END + 
CASE WHEN UPDATE([PHONE_NO]) THEN '[PHONE_NO]-' ELSE '' END + 
CASE WHEN UPDATE([AREA_FAX_NO]) THEN '[AREA_FAX_NO]-' ELSE '' END + 
CASE WHEN UPDATE([FAX_NO]) THEN '[FAX_NO]-' ELSE '' END + 
CASE WHEN UPDATE([EMAIL]) THEN '[EMAIL]-' ELSE '' END + 
CASE WHEN UPDATE([WEBSITE]) THEN '[WEBSITE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_VALIDATE]) THEN '[IS_VALIDATE]-' ELSE '' END + 
CASE WHEN UPDATE([KTP_NO]) THEN '[KTP_NO]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_PUBLIC_SERVICE]
([CODE],[PUBLIC_SERVICE_NO],[PUBLIC_SERVICE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[KTP_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[PUBLIC_SERVICE_NO],[PUBLIC_SERVICE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[KTP_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_PUBLIC_SERVICE]
([CODE],[PUBLIC_SERVICE_NO],[PUBLIC_SERVICE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[KTP_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[PUBLIC_SERVICE_NO],[PUBLIC_SERVICE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[KTP_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_PUBLIC_SERVICE_Insert_Audit] 
			ON [dbo].[MASTER_PUBLIC_SERVICE]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_PUBLIC_SERVICE]
([CODE],[PUBLIC_SERVICE_NO],[PUBLIC_SERVICE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[KTP_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[PUBLIC_SERVICE_NO],[PUBLIC_SERVICE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[KTP_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOMOR BIRO JASA', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'PUBLIC_SERVICE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA BIRO JASA', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'PUBLIC_SERVICE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA KONTAK', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'CONTACT_PERSON_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOMOR AREA', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'CONTACT_PERSON_AREA_PHONE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOMOR HANDPHONE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'CONTACT_PERSON_PHONE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TIPE PAJAK (''N21'' atau ''WITHOUT TAX - PERSONAL'', ''N23'' atau ''WITHOUT TAX - CORPORATE'', ''P21'' atau ''WITH TAX - PERSONAL'', ''P23'' atau ''WITH TAX - CORPORATE'')', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'TAX_FILE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOMOR PAJAK ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'TAX_FILE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA PAJAK', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'TAX_FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ALAMAT PAJAK', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'TAX_FILE_ADDRESS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOMOR AREA', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'AREA_PHONE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOMOR HANDPHONE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'PHONE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOMOR AREA FAX', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'AREA_FAX_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOMOR FAX', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'FAX_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ALAMAT EMAIL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'EMAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'WEBSITE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'WEBSITE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'APAKAH SUDAH TERVALIDASI (''1'', ''0'')', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_PUBLIC_SERVICE', @level2type = N'COLUMN', @level2name = N'IS_VALIDATE';

