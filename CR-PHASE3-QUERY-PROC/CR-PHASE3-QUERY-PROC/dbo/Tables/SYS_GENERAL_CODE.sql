CREATE TABLE [dbo].[SYS_GENERAL_CODE] (
    [CODE]           NVARCHAR (50)   NOT NULL,
    [COMPANY_CODE]   NVARCHAR (50)   CONSTRAINT [DF_SYS_GENERAL_CODE_COMPANY_CODE_1] DEFAULT ('') NOT NULL,
    [DESCRIPTION]    NVARCHAR (4000) NOT NULL,
    [IS_EDITABLE]    NVARCHAR (1)    NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_SYS_GENERAL_CODE_1] PRIMARY KEY CLUSTERED ([CODE] ASC, [COMPANY_CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[SYS_GENERAL_CODE_Insert_Audit] 
			ON [dbo].[SYS_GENERAL_CODE]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_GENERAL_CODE]
([CODE],[COMPANY_CODE],[DESCRIPTION],[IS_EDITABLE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[DESCRIPTION],[IS_EDITABLE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_GENERAL_CODE_Delete_Audit]    
			ON [dbo].[SYS_GENERAL_CODE]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_GENERAL_CODE]
([CODE],[COMPANY_CODE],[DESCRIPTION],[IS_EDITABLE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[DESCRIPTION],[IS_EDITABLE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[SYS_GENERAL_CODE_Update_Audit]      
			ON [dbo].[SYS_GENERAL_CODE]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([COMPANY_CODE]) THEN '[COMPANY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([IS_EDITABLE]) THEN '[IS_EDITABLE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_GENERAL_CODE]
([CODE],[COMPANY_CODE],[DESCRIPTION],[IS_EDITABLE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[DESCRIPTION],[IS_EDITABLE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_GENERAL_CODE]
([CODE],[COMPANY_CODE],[DESCRIPTION],[IS_EDITABLE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[DESCRIPTION],[IS_EDITABLE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE GENERAL CODE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_GENERAL_CODE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PERUSAHAAN (DSF)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_GENERAL_CODE', @level2type = N'COLUMN', @level2name = N'COMPANY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DESKRIPSI GENERAL CODE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_GENERAL_CODE', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'STATUS GENERAL CODE, BISA DI EDIT (1) TIDAK BISA DI EDIT (0)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_GENERAL_CODE', @level2type = N'COLUMN', @level2name = N'IS_EDITABLE';

