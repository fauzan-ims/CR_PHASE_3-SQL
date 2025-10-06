CREATE TABLE [dbo].[SYS_DIMENSION_VALUE] (
    [CODE]           NVARCHAR (50)  NOT NULL,
    [DIMENSION_CODE] NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]    NVARCHAR (250) NOT NULL,
    [VALUE]          NVARCHAR (250) NOT NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_SYS_DIMENSION_VALUE] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[SYS_DIMENSION_VALUE_Update_Audit]      
			ON [dbo].[SYS_DIMENSION_VALUE]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DIMENSION_CODE]) THEN '[DIMENSION_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([VALUE]) THEN '[VALUE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_DIMENSION_VALUE]
([CODE],[DIMENSION_CODE],[DESCRIPTION],[VALUE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DIMENSION_CODE],[DESCRIPTION],[VALUE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_DIMENSION_VALUE]
([CODE],[DIMENSION_CODE],[DESCRIPTION],[VALUE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DIMENSION_CODE],[DESCRIPTION],[VALUE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[SYS_DIMENSION_VALUE_Insert_Audit] 
			ON [dbo].[SYS_DIMENSION_VALUE]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_DIMENSION_VALUE]
([CODE],[DIMENSION_CODE],[DESCRIPTION],[VALUE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DIMENSION_CODE],[DESCRIPTION],[VALUE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_DIMENSION_VALUE_Delete_Audit]    
			ON [dbo].[SYS_DIMENSION_VALUE]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_DIMENSION_VALUE]
([CODE],[DIMENSION_CODE],[DESCRIPTION],[VALUE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DIMENSION_CODE],[DESCRIPTION],[VALUE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_DIMENSION_VALUE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE DIMENSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_DIMENSION_VALUE', @level2type = N'COLUMN', @level2name = N'DIMENSION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DESKRIPSI TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_DIMENSION_VALUE', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NILAI DARI DATA DIMENSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_DIMENSION_VALUE', @level2type = N'COLUMN', @level2name = N'VALUE';

