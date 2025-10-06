CREATE TABLE [dbo].[MASTER_DEPRECIATION] (
    [CODE]              NVARCHAR (50)  NOT NULL,
    [DEPRECIATION_NAME] NVARCHAR (250) NOT NULL,
    [IS_ACTIVE]         NVARCHAR (1)   CONSTRAINT [DF_MASTER_DEPRECIATION_IS_ACTIVE] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]          DATETIME       NOT NULL,
    [CRE_BY]            NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    [MOD_DATE]          DATETIME       NOT NULL,
    [MOD_BY]            NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_SYS_INSURANCE_DEPRECIATION] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_DEPRECIATION_Update_Audit]      
			ON [dbo].[MASTER_DEPRECIATION]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DEPRECIATION_NAME]) THEN '[DEPRECIATION_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_DEPRECIATION]
([CODE],[DEPRECIATION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DEPRECIATION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_DEPRECIATION]
([CODE],[DEPRECIATION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DEPRECIATION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_DEPRECIATION_Delete_Audit]    
			ON [dbo].[MASTER_DEPRECIATION]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_DEPRECIATION]
([CODE],[DEPRECIATION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DEPRECIATION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_DEPRECIATION_Insert_Audit] 
			ON [dbo].[MASTER_DEPRECIATION]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_DEPRECIATION]
([CODE],[DEPRECIATION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DEPRECIATION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data master depreciation tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEPRECIATION', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama atas data master depreciation tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEPRECIATION', @level2type = N'COLUMN', @level2name = N'DEPRECIATION_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status atas data master depreciation tersebut, apakah data master depreciation tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEPRECIATION', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

