CREATE TABLE [dbo].[MASTER_CASHIER_PRIORITY] (
    [CODE]           NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]    NVARCHAR (250) NOT NULL,
    [IS_DEFAULT]     NVARCHAR (1)   NOT NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_CASHIER_PRIORITY] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_CASHIER_PRIORITY_Delete_Audit]    
			ON [dbo].[MASTER_CASHIER_PRIORITY]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_CASHIER_PRIORITY]
([CODE],[DESCRIPTION],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_CASHIER_PRIORITY_Update_Audit]      
			ON [dbo].[MASTER_CASHIER_PRIORITY]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([IS_DEFAULT]) THEN '[IS_DEFAULT]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_CASHIER_PRIORITY]
([CODE],[DESCRIPTION],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_CASHIER_PRIORITY]
([CODE],[DESCRIPTION],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_CASHIER_PRIORITY_Insert_Audit] 
			ON [dbo].[MASTER_CASHIER_PRIORITY]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_CASHIER_PRIORITY]
([CODE],[DESCRIPTION],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data prioritas pembayaran kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CASHIER_PRIORITY', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deskripsi pada data prioritas pembayaran kasir tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CASHIER_PRIORITY', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah prioritas pembayaran pada kasir tersebut bersifat default?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CASHIER_PRIORITY', @level2type = N'COLUMN', @level2name = N'IS_DEFAULT';

