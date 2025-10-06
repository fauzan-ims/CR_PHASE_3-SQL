CREATE TABLE [dbo].[MASTER_BAST_CHECKLIST_ASSET] (
    [CODE]            NVARCHAR (50)  NOT NULL,
    [ASSET_TYPE_CODE] NVARCHAR (50)  NOT NULL,
    [CHECKLIST_NAME]  NVARCHAR (250) NOT NULL,
    [ORDER_KEY]       INT            NOT NULL,
    [IS_ACTIVE]       NVARCHAR (1)   NOT NULL,
    [CRE_DATE]        DATETIME       NOT NULL,
    [CRE_BY]          NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]  NVARCHAR (15)  NOT NULL,
    [MOD_DATE]        DATETIME       NOT NULL,
    [MOD_BY]          NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]  NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_BAST_CHECKLIST_ASSET] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_BAST_CHECKLIST_ASSET_Delete_Audit]    
			ON [dbo].[MASTER_BAST_CHECKLIST_ASSET]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_BAST_CHECKLIST_ASSET]
([CODE],[ASSET_TYPE_CODE],[CHECKLIST_NAME],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[ASSET_TYPE_CODE],[CHECKLIST_NAME],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_BAST_CHECKLIST_ASSET_Update_Audit]      
			ON [dbo].[MASTER_BAST_CHECKLIST_ASSET]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([ASSET_TYPE_CODE]) THEN '[ASSET_TYPE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CHECKLIST_NAME]) THEN '[CHECKLIST_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([ORDER_KEY]) THEN '[ORDER_KEY]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_BAST_CHECKLIST_ASSET]
([CODE],[ASSET_TYPE_CODE],[CHECKLIST_NAME],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[ASSET_TYPE_CODE],[CHECKLIST_NAME],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_BAST_CHECKLIST_ASSET]
([CODE],[ASSET_TYPE_CODE],[CHECKLIST_NAME],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[ASSET_TYPE_CODE],[CHECKLIST_NAME],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_BAST_CHECKLIST_ASSET_Insert_Audit] 
			ON [dbo].[MASTER_BAST_CHECKLIST_ASSET]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_BAST_CHECKLIST_ASSET]
([CODE],[ASSET_TYPE_CODE],[CHECKLIST_NAME],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[ASSET_TYPE_CODE],[CHECKLIST_NAME],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_BAST_CHECKLIST_ASSET', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TIPE ASSET (''VHCL'', ''MCHN'')', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_BAST_CHECKLIST_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama checklist pada proses BAST checklist detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_BAST_CHECKLIST_ASSET', @level2type = N'COLUMN', @level2name = N'CHECKLIST_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOMOR URUT TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_BAST_CHECKLIST_ASSET', @level2type = N'COLUMN', @level2name = N'ORDER_KEY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'AKTIF(1), TIDAK AKTIF(0)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_BAST_CHECKLIST_ASSET', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

