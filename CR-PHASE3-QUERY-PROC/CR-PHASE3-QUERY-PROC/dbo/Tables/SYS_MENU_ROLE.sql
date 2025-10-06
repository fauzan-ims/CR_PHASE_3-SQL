CREATE TABLE [dbo].[SYS_MENU_ROLE] (
    [ROLE_CODE]      NVARCHAR (50)  NOT NULL,
    [MENU_CODE]      NVARCHAR (50)  NOT NULL,
    [ROLE_NAME]      NVARCHAR (250) CONSTRAINT [DF_SYS_MENU_ROLE_ROLE_NAME] DEFAULT (N'-') NOT NULL,
    [ROLE_ACCESS]    NVARCHAR (1)   CONSTRAINT [DF_SYS_MENU_ROLE_ROLE_ACCESS] DEFAULT (N'-') NOT NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_SYS_MENU_ROLE_1] PRIMARY KEY CLUSTERED ([ROLE_CODE] ASC),
    CONSTRAINT [FK_SYS_MENU_ROLE_SYS_MENU] FOREIGN KEY ([MENU_CODE]) REFERENCES [dbo].[SYS_MENU] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[SYS_MENU_ROLE_Update_Audit]      
			ON [dbo].[SYS_MENU_ROLE]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ROLE_CODE]) THEN '[ROLE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([MENU_CODE]) THEN '[MENU_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([ROLE_NAME]) THEN '[ROLE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([ROLE_ACCESS]) THEN '[ROLE_ACCESS]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_MENU_ROLE]
([ROLE_CODE],[MENU_CODE],[ROLE_NAME],[ROLE_ACCESS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [ROLE_CODE],[MENU_CODE],[ROLE_NAME],[ROLE_ACCESS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_MENU_ROLE]
([ROLE_CODE],[MENU_CODE],[ROLE_NAME],[ROLE_ACCESS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [ROLE_CODE],[MENU_CODE],[ROLE_NAME],[ROLE_ACCESS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[SYS_MENU_ROLE_Insert_Audit] 
			ON [dbo].[SYS_MENU_ROLE]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_MENU_ROLE]
([ROLE_CODE],[MENU_CODE],[ROLE_NAME],[ROLE_ACCESS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [ROLE_CODE],[MENU_CODE],[ROLE_NAME],[ROLE_ACCESS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_MENU_ROLE_Delete_Audit]    
			ON [dbo].[SYS_MENU_ROLE]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_MENU_ROLE]
([ROLE_CODE],[MENU_CODE],[ROLE_NAME],[ROLE_ACCESS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [ROLE_CODE],[MENU_CODE],[ROLE_NAME],[ROLE_ACCESS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode role atas menu tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_MENU_ROLE', @level2type = N'COLUMN', @level2name = N'ROLE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode menu atas role tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_MENU_ROLE', @level2type = N'COLUMN', @level2name = N'MENU_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama role atas menu tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_MENU_ROLE', @level2type = N'COLUMN', @level2name = N'ROLE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Role akses atas menu tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_MENU_ROLE', @level2type = N'COLUMN', @level2name = N'ROLE_ACCESS';

