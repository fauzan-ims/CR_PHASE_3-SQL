CREATE TABLE [dbo].[MASTER_INSURANCE] (
    [CODE]                         NVARCHAR (50)  NOT NULL,
    [INSURANCE_NO]                 NVARCHAR (50)  NOT NULL,
    [INSURANCE_NAME]               NVARCHAR (250) NOT NULL,
    [CONTACT_PERSON_NAME]          NVARCHAR (250) NOT NULL,
    [CONTACT_PERSON_AREA_PHONE_NO] NVARCHAR (4)   NOT NULL,
    [CONTACT_PERSON_PHONE_NO]      NVARCHAR (15)  NOT NULL,
    [INSURANCE_TYPE]               NVARCHAR (10)  NULL,
    [TAX_FILE_TYPE]                NVARCHAR (10)  NOT NULL,
    [TAX_FILE_NO]                  NVARCHAR (50)  CONSTRAINT [DF_MASTER_INSURANCE_TAX_FILE_NO] DEFAULT (N'') NULL,
    [TAX_FILE_NAME]                NVARCHAR (250) CONSTRAINT [DF_MASTER_INSURANCE_TAX_FILE_NAME] DEFAULT (N'') NULL,
    [TAX_FILE_ADDRESS]             NVARCHAR (250) CONSTRAINT [DF_MASTER_INSURANCE_TAX_FILE_ADDRESS] DEFAULT (N'') NULL,
    [INSURANCE_BUSINESS_UNIT]      NVARCHAR (12)  NOT NULL,
    [AREA_PHONE_NO]                NVARCHAR (4)   NOT NULL,
    [PHONE_NO]                     NVARCHAR (25)  NOT NULL,
    [AREA_FAX_NO]                  NVARCHAR (4)   NOT NULL,
    [FAX_NO]                       NVARCHAR (25)  NOT NULL,
    [EMAIL]                        NVARCHAR (100) NULL,
    [WEBSITE]                      NVARCHAR (100) NULL,
    [IS_VALIDATE]                  NVARCHAR (1)   CONSTRAINT [DF_MASTER_INSURANCE_IS_ACTIVE] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]                     DATETIME       NOT NULL,
    [CRE_BY]                       NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS]               NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]                     DATETIME       NOT NULL,
    [MOD_BY]                       NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS]               NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [OLD_TAX_FILE_NO]              NVARCHAR (20)  NULL,
    [NITKU]                        NVARCHAR (50)  NULL,
    [NPWP_HO]                      NVARCHAR (50)  NULL,
    CONSTRAINT [PK_SYS_INSURANCE] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_INSURANCE_Delete_Audit]    
			ON [dbo].[MASTER_INSURANCE]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE]
([CODE],[INSURANCE_NO],[INSURANCE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[INSURANCE_TYPE],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[INSURANCE_BUSINESS_UNIT],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[INSURANCE_NO],[INSURANCE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[INSURANCE_TYPE],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[INSURANCE_BUSINESS_UNIT],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_INSURANCE_Update_Audit]      
			ON [dbo].[MASTER_INSURANCE]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([INSURANCE_NO]) THEN '[INSURANCE_NO]-' ELSE '' END + 
CASE WHEN UPDATE([INSURANCE_NAME]) THEN '[INSURANCE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([CONTACT_PERSON_NAME]) THEN '[CONTACT_PERSON_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([CONTACT_PERSON_AREA_PHONE_NO]) THEN '[CONTACT_PERSON_AREA_PHONE_NO]-' ELSE '' END + 
CASE WHEN UPDATE([CONTACT_PERSON_PHONE_NO]) THEN '[CONTACT_PERSON_PHONE_NO]-' ELSE '' END + 
CASE WHEN UPDATE([INSURANCE_TYPE]) THEN '[INSURANCE_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([TAX_FILE_TYPE]) THEN '[TAX_FILE_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([TAX_FILE_NO]) THEN '[TAX_FILE_NO]-' ELSE '' END + 
CASE WHEN UPDATE([TAX_FILE_NAME]) THEN '[TAX_FILE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([TAX_FILE_ADDRESS]) THEN '[TAX_FILE_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([INSURANCE_BUSINESS_UNIT]) THEN '[INSURANCE_BUSINESS_UNIT]-' ELSE '' END + 
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
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE]
([CODE],[INSURANCE_NO],[INSURANCE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[INSURANCE_TYPE],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[INSURANCE_BUSINESS_UNIT],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[INSURANCE_NO],[INSURANCE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[INSURANCE_TYPE],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[INSURANCE_BUSINESS_UNIT],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE]
([CODE],[INSURANCE_NO],[INSURANCE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[INSURANCE_TYPE],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[INSURANCE_BUSINESS_UNIT],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[INSURANCE_NO],[INSURANCE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[INSURANCE_TYPE],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[INSURANCE_BUSINESS_UNIT],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_INSURANCE_Insert_Audit] 
			ON [dbo].[MASTER_INSURANCE]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE]
([CODE],[INSURANCE_NO],[INSURANCE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[INSURANCE_TYPE],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[INSURANCE_BUSINESS_UNIT],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[INSURANCE_NO],[INSURANCE_NAME],[CONTACT_PERSON_NAME],[CONTACT_PERSON_AREA_PHONE_NO],[CONTACT_PERSON_PHONE_NO],[INSURANCE_TYPE],[TAX_FILE_TYPE],[TAX_FILE_NO],[TAX_FILE_NAME],[TAX_FILE_ADDRESS],[INSURANCE_BUSINESS_UNIT],[AREA_PHONE_NO],[PHONE_NO],[AREA_FAX_NO],[FAX_NO],[EMAIL],[WEBSITE],[IS_VALIDATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'INSURANCE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama atas data maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'INSURANCE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama kontrak person atas data maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'CONTACT_PERSON_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode area nomor telepon kontrak person atas data maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'CONTACT_PERSON_AREA_PHONE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor telepon kontak person atas data maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'CONTACT_PERSON_PHONE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe asuransi dari maskapai asuransi tersebut - Life, menginformasikan bahwa maskapai tersebut merupakan maskapai untuk asuransi jiwa - non Life, menginformasikan bahwa maskapai tersebut merupakan maskapai untuk asuransi non life', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'INSURANCE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe NPWP atas data maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'TAX_FILE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor NPWP atas data maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'TAX_FILE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama NPWP atas data maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'TAX_FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alamat NPWP atas data maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'TAX_FILE_ADDRESS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe bisnis unit atas data maskapai asuransi tersebut - Konvensional, menginformasikan bahwa maskapai tersebut tipe bisnisnya adalah konvensional -Syariah, menginformasikan bahwa maskapai tersebut tipe bisnisnya adalah syariah', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'INSURANCE_BUSINESS_UNIT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode area nomor telepon atas data maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'AREA_PHONE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor telepon atas data maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'PHONE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode area faksimili atas data maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'AREA_FAX_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor faksimili atas data maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'FAX_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alamat email dari data maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'EMAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alamat website dari data maskapai asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'WEBSITE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data maskapai asuransi tersebut, apakah data tersebut sudah dilakukan proses validasi?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE', @level2type = N'COLUMN', @level2name = N'IS_VALIDATE';

