CREATE TABLE [dbo].[MASTER_AUCTION] (
    [CODE]                         NVARCHAR (50)  NOT NULL,
    [AUCTION_NAME]                 NVARCHAR (250) NOT NULL,
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
    [IS_VALIDATE]                  NVARCHAR (1)   NULL,
    [CRE_DATE]                     DATETIME       NOT NULL,
    [CRE_BY]                       NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]               NVARCHAR (15)  NOT NULL,
    [MOD_DATE]                     DATETIME       NOT NULL,
    [MOD_BY]                       NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]               NVARCHAR (15)  NOT NULL,
    [KTP_NO]                       NVARCHAR (20)  NULL,
    [OLD_TAX_FILE_NO]              NVARCHAR (20)  NULL,
    [NITKU]                        NVARCHAR (50)  NULL,
    [NPWP_HO]                      NVARCHAR (50)  NULL,
    CONSTRAINT [PK_MASTER_AUCTION] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_AUCTION_Delete_Audit]    
			ON [dbo].[MASTER_AUCTION]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION]
([CODE],[AUCTION_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],[KTP_NO],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[AUCTION_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],[KTP_NO],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_AUCTION_Update_Audit]      
			ON [dbo].[MASTER_AUCTION]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([AUCTION_NAME]) THEN '[AUCTION_NAME]-' ELSE '' END + 
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
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([KTP_NO]) THEN '[KTP_NO]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION]
([CODE],[AUCTION_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],[KTP_NO],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[AUCTION_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],[KTP_NO],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION]
([CODE],[AUCTION_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],[KTP_NO],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[AUCTION_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],[KTP_NO],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_AUCTION_Insert_Audit] 
			ON [dbo].[MASTER_AUCTION]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION]
([CODE],[AUCTION_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],[KTP_NO],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[AUCTION_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],[KTP_NO],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data master auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama balai lelang pada data master auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'AUCTION_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama contact person pada data master auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'CONTACT_PERSON_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode operator nomor handphone pada data master auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'CONTACT_PERSON_AREA_PHONE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor handphone pada data master auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'CONTACT_PERSON_PHONE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe NPWP pada data master auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'TAX_FILE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor NPWP pada data master auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'TAX_FILE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama NPWP pada data master auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'TAX_FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alamat NPWP pada data master auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'TAX_FILE_ADDRESS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode area nomor telepon pada data master auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'AREA_PHONE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor telepon pada data master auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'PHONE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode area faksimili pada data master auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'AREA_FAX_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor faksimili pada data master auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'FAX_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alamat email pada data master auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'EMAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alamat website pada data master auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'WEBSITE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data auction tersebut berstatus valid atau tidak?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION', @level2type = N'COLUMN', @level2name = N'IS_VALIDATE';

