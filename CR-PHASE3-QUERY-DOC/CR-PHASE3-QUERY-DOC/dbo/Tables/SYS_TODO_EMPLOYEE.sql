CREATE TABLE [dbo].[SYS_TODO_EMPLOYEE] (
    [ID]             BIGINT         IDENTITY (1, 1) NOT NULL,
    [EMPLOYEE_CODE]  NVARCHAR (50)  NOT NULL,
    [EMPLOYEE_NAME]  NVARCHAR (250) NOT NULL,
    [TODO_CODE]      NVARCHAR (50)  NOT NULL,
    [PRIORITY]       NVARCHAR (10)  NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_SYS_TODO_EMPLOYEE] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SYS_TODO_EMPLOYEE_SYS_TODO] FOREIGN KEY ([TODO_CODE]) REFERENCES [dbo].[SYS_TODO] ([CODE])
);


GO
    
			CREATE TRIGGER [dbo].[SYS_TODO_EMPLOYEE_Insert_Audit] 
			ON [dbo].[SYS_TODO_EMPLOYEE]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_TODO_EMPLOYEE]
([ID],[EMPLOYEE_CODE],[EMPLOYEE_NAME],[TODO_CODE],[PRIORITY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[EMPLOYEE_CODE],[EMPLOYEE_NAME],[TODO_CODE],[PRIORITY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_TODO_EMPLOYEE_Delete_Audit]    
			ON [dbo].[SYS_TODO_EMPLOYEE]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_TODO_EMPLOYEE]
([ID],[EMPLOYEE_CODE],[EMPLOYEE_NAME],[TODO_CODE],[PRIORITY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[EMPLOYEE_CODE],[EMPLOYEE_NAME],[TODO_CODE],[PRIORITY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[SYS_TODO_EMPLOYEE_Update_Audit]      
			ON [dbo].[SYS_TODO_EMPLOYEE]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ID]) THEN '[ID]-' ELSE '' END + 
CASE WHEN UPDATE([EMPLOYEE_CODE]) THEN '[EMPLOYEE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([EMPLOYEE_NAME]) THEN '[EMPLOYEE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([TODO_CODE]) THEN '[TODO_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([PRIORITY]) THEN '[PRIORITY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_TODO_EMPLOYEE]
([ID],[EMPLOYEE_CODE],[EMPLOYEE_NAME],[TODO_CODE],[PRIORITY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[EMPLOYEE_CODE],[EMPLOYEE_NAME],[TODO_CODE],[PRIORITY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_TODO_EMPLOYEE]
([ID],[EMPLOYEE_CODE],[EMPLOYEE_NAME],[TODO_CODE],[PRIORITY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[EMPLOYEE_CODE],[EMPLOYEE_NAME],[TODO_CODE],[PRIORITY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas to do tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_TODO_EMPLOYEE', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama atas to do tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_TODO_EMPLOYEE', @level2type = N'COLUMN', @level2name = N'EMPLOYEE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Link address atas to do tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_TODO_EMPLOYEE', @level2type = N'COLUMN', @level2name = N'EMPLOYEE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama atas to do tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_TODO_EMPLOYEE', @level2type = N'COLUMN', @level2name = N'TODO_CODE';

