CREATE TABLE [dbo].[SYS_EMPLOYEE_WIDGET_SUBSCRIPTION] (
    [WIDGET_CODE]        NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [EMP_CODE]           NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [WIDGET_ORIENTATION] NVARCHAR (1)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ACTION_FLAG]        NVARCHAR (1)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_DATE]           DATETIME      NOT NULL,
    [CRE_BY]             NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]           DATETIME      NOT NULL,
    [MOD_BY]             NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_EMPLOYEE_WIDGET_SUBSCRIPTION] PRIMARY KEY CLUSTERED ([WIDGET_CODE] ASC, [EMP_CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[SYS_EMPLOYEE_WIDGET_SUBSCRIPTION_Delete_Audit]    
			ON [dbo].[SYS_EMPLOYEE_WIDGET_SUBSCRIPTION]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_EMPLOYEE_WIDGET_SUBSCRIPTION]
([WIDGET_CODE],[EMP_CODE],[WIDGET_ORIENTATION],[ACTION_FLAG],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [WIDGET_CODE],[EMP_CODE],[WIDGET_ORIENTATION],[ACTION_FLAG],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[SYS_EMPLOYEE_WIDGET_SUBSCRIPTION_Update_Audit]      
			ON [dbo].[SYS_EMPLOYEE_WIDGET_SUBSCRIPTION]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([WIDGET_CODE]) THEN '[WIDGET_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([EMP_CODE]) THEN '[EMP_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([WIDGET_ORIENTATION]) THEN '[WIDGET_ORIENTATION]-' ELSE '' END + 
CASE WHEN UPDATE([ACTION_FLAG]) THEN '[ACTION_FLAG]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_EMPLOYEE_WIDGET_SUBSCRIPTION]
([WIDGET_CODE],[EMP_CODE],[WIDGET_ORIENTATION],[ACTION_FLAG],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [WIDGET_CODE],[EMP_CODE],[WIDGET_ORIENTATION],[ACTION_FLAG],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_EMPLOYEE_WIDGET_SUBSCRIPTION]
([WIDGET_CODE],[EMP_CODE],[WIDGET_ORIENTATION],[ACTION_FLAG],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [WIDGET_CODE],[EMP_CODE],[WIDGET_ORIENTATION],[ACTION_FLAG],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[SYS_EMPLOYEE_WIDGET_SUBSCRIPTION_Insert_Audit] 
			ON [dbo].[SYS_EMPLOYEE_WIDGET_SUBSCRIPTION]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_EMPLOYEE_WIDGET_SUBSCRIPTION]
([WIDGET_CODE],[EMP_CODE],[WIDGET_ORIENTATION],[ACTION_FLAG],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [WIDGET_CODE],[EMP_CODE],[WIDGET_ORIENTATION],[ACTION_FLAG],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode widget', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EMPLOYEE_WIDGET_SUBSCRIPTION', @level2type = N'COLUMN', @level2name = N'WIDGET_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode karyawan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EMPLOYEE_WIDGET_SUBSCRIPTION', @level2type = N'COLUMN', @level2name = N'EMP_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orientation dari widget tersebut, left atau right?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EMPLOYEE_WIDGET_SUBSCRIPTION', @level2type = N'COLUMN', @level2name = N'WIDGET_ORIENTATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data widget tersebut, apakah data widget tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EMPLOYEE_WIDGET_SUBSCRIPTION', @level2type = N'COLUMN', @level2name = N'ACTION_FLAG';

