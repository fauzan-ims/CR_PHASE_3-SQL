CREATE TABLE [dbo].[SYS_GENERAL_SUBCODE] (
    [CODE]           NVARCHAR (50)   NOT NULL,
    [DESCRIPTION]    NVARCHAR (4000) NOT NULL,
    [GENERAL_CODE]   NVARCHAR (50)   NOT NULL,
    [OJK_CODE]       NVARCHAR (50)   NOT NULL,
    [ORDER_KEY]      INT             NOT NULL,
    [IS_ACTIVE]      NVARCHAR (1)    NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_SYS_GENERAL_SUBCODE] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_SYS_GENERAL_SUBCODE_SYS_GENERAL_CODE] FOREIGN KEY ([GENERAL_CODE]) REFERENCES [dbo].[SYS_GENERAL_CODE] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[SYS_GENERAL_SUBCODE_Update_Audit]      
			ON [dbo].[SYS_GENERAL_SUBCODE]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([GENERAL_CODE]) THEN '[GENERAL_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([OJK_CODE]) THEN '[OJK_CODE]-' ELSE '' END + 
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
			          INSERT INTO [dbo].[Z_AUDIT_SYS_GENERAL_SUBCODE]
([CODE],[DESCRIPTION],[GENERAL_CODE],[OJK_CODE],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[GENERAL_CODE],[OJK_CODE],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_GENERAL_SUBCODE]
([CODE],[DESCRIPTION],[GENERAL_CODE],[OJK_CODE],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[GENERAL_CODE],[OJK_CODE],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[SYS_GENERAL_SUBCODE_Insert_Audit] 
			ON [dbo].[SYS_GENERAL_SUBCODE]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_GENERAL_SUBCODE]
([CODE],[DESCRIPTION],[GENERAL_CODE],[OJK_CODE],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[GENERAL_CODE],[OJK_CODE],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_GENERAL_SUBCODE_Delete_Audit]    
			ON [dbo].[SYS_GENERAL_SUBCODE]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_GENERAL_SUBCODE]
([CODE],[DESCRIPTION],[GENERAL_CODE],[OJK_CODE],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[GENERAL_CODE],[OJK_CODE],[ORDER_KEY],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data general sub code tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_GENERAL_SUBCODE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deskripsi atas data general sub code tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_GENERAL_SUBCODE', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'General code atas data general sub code tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_GENERAL_SUBCODE', @level2type = N'COLUMN', @level2name = N'GENERAL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode OJK atas data general sub code tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_GENERAL_SUBCODE', @level2type = N'COLUMN', @level2name = N'OJK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor urut atas data general sub code tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_GENERAL_SUBCODE', @level2type = N'COLUMN', @level2name = N'ORDER_KEY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status atas data general sub code tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_GENERAL_SUBCODE', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

