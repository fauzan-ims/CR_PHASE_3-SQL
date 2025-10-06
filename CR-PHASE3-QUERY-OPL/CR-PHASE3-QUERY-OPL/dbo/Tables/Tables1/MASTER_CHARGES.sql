CREATE TABLE [dbo].[MASTER_CHARGES] (
    [CODE]             NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]      NVARCHAR (250) NOT NULL,
    [CHARGES_FIX_CODE] NVARCHAR (50)  NULL,
    [IS_ACTIVE]        NVARCHAR (1)   NOT NULL,
    [CRE_DATE]         DATETIME       NOT NULL,
    [CRE_BY]           NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    [MOD_DATE]         DATETIME       NOT NULL,
    [MOD_BY]           NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_CHARGES] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_CHARGES_Delete_Audit]    
			ON [dbo].[MASTER_CHARGES]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_CHARGES]
([CODE],[DESCRIPTION],[CHARGES_FIX_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[CHARGES_FIX_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_CHARGES_Update_Audit]      
			ON [dbo].[MASTER_CHARGES]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([CHARGES_FIX_CODE]) THEN '[CHARGES_FIX_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_CHARGES]
([CODE],[DESCRIPTION],[CHARGES_FIX_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[CHARGES_FIX_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_CHARGES]
([CODE],[DESCRIPTION],[CHARGES_FIX_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[CHARGES_FIX_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_CHARGES_Insert_Audit] 
			ON [dbo].[MASTER_CHARGES]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_CHARGES]
([CODE],[DESCRIPTION],[CHARGES_FIX_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[CHARGES_FIX_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode charge untuk masing masing facility', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CHARGES', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deskripsi atas master charges tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CHARGES', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis charge yang ada pada sistem', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CHARGES', @level2type = N'COLUMN', @level2name = N'CHARGES_FIX_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data master charges tersebut, apakah data charges tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CHARGES', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

