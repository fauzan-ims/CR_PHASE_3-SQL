CREATE TABLE [dbo].[MASTER_DOCUMENT_CONTRACT] (
    [CODE]           NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]    NVARCHAR (250) NOT NULL,
    [DOCUMENT_TYPE]  NVARCHAR (4)   NOT NULL,
    [TEMPLATE_NAME]  NVARCHAR (250) NULL,
    [RPT_NAME]       NVARCHAR (250) NULL,
    [SP_NAME]        NVARCHAR (250) NOT NULL,
    [TABLE_NAME]     NVARCHAR (250) CONSTRAINT [DF_LOS_MASTER_APPLICATION_DOCUMENT_CONTRACT_TABLE_NAME] DEFAULT ('') NOT NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_APPLICATION_CONTRACT] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_DOCUMENT_CONTRACT_Update_Audit]      
			ON [dbo].[MASTER_DOCUMENT_CONTRACT]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([DOCUMENT_TYPE]) THEN '[DOCUMENT_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([TEMPLATE_NAME]) THEN '[TEMPLATE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([RPT_NAME]) THEN '[RPT_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([SP_NAME]) THEN '[SP_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([TABLE_NAME]) THEN '[TABLE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_DOCUMENT_CONTRACT]
([CODE],[DESCRIPTION],[DOCUMENT_TYPE],[TEMPLATE_NAME],[RPT_NAME],[SP_NAME],[TABLE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[DOCUMENT_TYPE],[TEMPLATE_NAME],[RPT_NAME],[SP_NAME],[TABLE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_DOCUMENT_CONTRACT]
([CODE],[DESCRIPTION],[DOCUMENT_TYPE],[TEMPLATE_NAME],[RPT_NAME],[SP_NAME],[TABLE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[DOCUMENT_TYPE],[TEMPLATE_NAME],[RPT_NAME],[SP_NAME],[TABLE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_DOCUMENT_CONTRACT_Insert_Audit] 
			ON [dbo].[MASTER_DOCUMENT_CONTRACT]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_DOCUMENT_CONTRACT]
([CODE],[DESCRIPTION],[DOCUMENT_TYPE],[TEMPLATE_NAME],[RPT_NAME],[SP_NAME],[TABLE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[DOCUMENT_TYPE],[TEMPLATE_NAME],[RPT_NAME],[SP_NAME],[TABLE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_DOCUMENT_CONTRACT_Delete_Audit]    
			ON [dbo].[MASTER_DOCUMENT_CONTRACT]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_DOCUMENT_CONTRACT]
([CODE],[DESCRIPTION],[DOCUMENT_TYPE],[TEMPLATE_NAME],[RPT_NAME],[SP_NAME],[TABLE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[DOCUMENT_TYPE],[TEMPLATE_NAME],[RPT_NAME],[SP_NAME],[TABLE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode document contract', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deskripsi atas data document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe dari data dcoument contract tersebut, DOC atau PDF?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT', @level2type = N'COLUMN', @level2name = N'DOCUMENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama template dari data document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT', @level2type = N'COLUMN', @level2name = N'TEMPLATE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama file crystal report atas data document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT', @level2type = N'COLUMN', @level2name = N'RPT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama store procedure atas document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT', @level2type = N'COLUMN', @level2name = N'SP_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama table atas data document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT', @level2type = N'COLUMN', @level2name = N'TABLE_NAME';

