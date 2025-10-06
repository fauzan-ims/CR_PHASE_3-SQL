CREATE TABLE [dbo].[SYS_MENU] (
    [CODE]             NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [NAME]             NVARCHAR (250) NOT NULL,
    [ABBREVIATION]     NVARCHAR (50)  NOT NULL,
    [MODULE_CODE]      NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PARENT_MENU_CODE] NVARCHAR (50)  NULL,
    [ROUTING_MENU]     NVARCHAR (250) NULL,
    [URL_MENU]         NVARCHAR (250) NOT NULL,
    [ORDER_KEY]        INT            NOT NULL,
    [CSS_ICON]         NVARCHAR (250) NOT NULL,
    [IS_ACTIVE]        NVARCHAR (1)   NOT NULL,
    [TYPE]             NVARCHAR (5)   NULL,
    [CRE_DATE]         DATETIME       NOT NULL,
    [CRE_BY]           NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    [MOD_DATE]         DATETIME       NOT NULL,
    [MOD_BY]           NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_SYS_MENU_1] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_SYS_MENU_SYS_MODULE] FOREIGN KEY ([MODULE_CODE]) REFERENCES [dbo].[SYS_MODULE] ([CODE])
);


GO
    
			CREATE TRIGGER [dbo].[SYS_MENU_Insert_Audit] 
			ON [dbo].[SYS_MENU]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_MENU]
([CODE],[NAME],[ABBREVIATION],[MODULE_CODE],[PARENT_MENU_CODE],[ROUTING_MENU],[URL_MENU],[ORDER_KEY],[CSS_ICON],[IS_ACTIVE],[TYPE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[NAME],[ABBREVIATION],[MODULE_CODE],[PARENT_MENU_CODE],[ROUTING_MENU],[URL_MENU],[ORDER_KEY],[CSS_ICON],[IS_ACTIVE],[TYPE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_MENU_Delete_Audit]    
			ON [dbo].[SYS_MENU]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_MENU]
([CODE],[NAME],[ABBREVIATION],[MODULE_CODE],[PARENT_MENU_CODE],[ROUTING_MENU],[URL_MENU],[ORDER_KEY],[CSS_ICON],[IS_ACTIVE],[TYPE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[NAME],[ABBREVIATION],[MODULE_CODE],[PARENT_MENU_CODE],[ROUTING_MENU],[URL_MENU],[ORDER_KEY],[CSS_ICON],[IS_ACTIVE],[TYPE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[SYS_MENU_Update_Audit]      
			ON [dbo].[SYS_MENU]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([NAME]) THEN '[NAME]-' ELSE '' END + 
CASE WHEN UPDATE([ABBREVIATION]) THEN '[ABBREVIATION]-' ELSE '' END + 
CASE WHEN UPDATE([MODULE_CODE]) THEN '[MODULE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([PARENT_MENU_CODE]) THEN '[PARENT_MENU_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([ROUTING_MENU]) THEN '[ROUTING_MENU]-' ELSE '' END + 
CASE WHEN UPDATE([URL_MENU]) THEN '[URL_MENU]-' ELSE '' END + 
CASE WHEN UPDATE([ORDER_KEY]) THEN '[ORDER_KEY]-' ELSE '' END + 
CASE WHEN UPDATE([CSS_ICON]) THEN '[CSS_ICON]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([TYPE]) THEN '[TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_MENU]
([CODE],[NAME],[ABBREVIATION],[MODULE_CODE],[PARENT_MENU_CODE],[ROUTING_MENU],[URL_MENU],[ORDER_KEY],[CSS_ICON],[IS_ACTIVE],[TYPE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[NAME],[ABBREVIATION],[MODULE_CODE],[PARENT_MENU_CODE],[ROUTING_MENU],[URL_MENU],[ORDER_KEY],[CSS_ICON],[IS_ACTIVE],[TYPE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_MENU]
([CODE],[NAME],[ABBREVIATION],[MODULE_CODE],[PARENT_MENU_CODE],[ROUTING_MENU],[URL_MENU],[ORDER_KEY],[CSS_ICON],[IS_ACTIVE],[TYPE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[NAME],[ABBREVIATION],[MODULE_CODE],[PARENT_MENU_CODE],[ROUTING_MENU],[URL_MENU],[ORDER_KEY],[CSS_ICON],[IS_ACTIVE],[TYPE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode menu', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_MENU', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama menu', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_MENU', @level2type = N'COLUMN', @level2name = N'NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama singkatan dari menu tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_MENU', @level2type = N'COLUMN', @level2name = N'ABBREVIATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode modul atas menu tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_MENU', @level2type = N'COLUMN', @level2name = N'MODULE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode parent atas menu tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_MENU', @level2type = N'COLUMN', @level2name = N'PARENT_MENU_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Routing angular pada menu tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_MENU', @level2type = N'COLUMN', @level2name = N'ROUTING_MENU';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'URL atas menu tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_MENU', @level2type = N'COLUMN', @level2name = N'URL_MENU';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor urut dari menu tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_MENU', @level2type = N'COLUMN', @level2name = N'ORDER_KEY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CSS icon atas menu tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_MENU', @level2type = N'COLUMN', @level2name = N'CSS_ICON';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari menu tersebut, apakah menu tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_MENU', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

