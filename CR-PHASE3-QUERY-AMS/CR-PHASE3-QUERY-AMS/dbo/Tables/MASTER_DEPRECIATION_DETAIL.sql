CREATE TABLE [dbo].[MASTER_DEPRECIATION_DETAIL] (
    [ID]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [DEPRECIATION_CODE] NVARCHAR (50)  NOT NULL,
    [TENOR]             INT            NOT NULL,
    [RATE]              DECIMAL (9, 6) NOT NULL,
    [CRE_DATE]          DATETIME       NOT NULL,
    [CRE_BY]            NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    [MOD_DATE]          DATETIME       NOT NULL,
    [MOD_BY]            NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_DEPRECIATION_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MASTER_DEPRECIATION_DETAIL_MASTER_DEPRECIATION] FOREIGN KEY ([DEPRECIATION_CODE]) REFERENCES [dbo].[MASTER_DEPRECIATION] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_DEPRECIATION_DETAIL_Delete_Audit]    
			ON [dbo].[MASTER_DEPRECIATION_DETAIL]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_DEPRECIATION_DETAIL]
([ID],[DEPRECIATION_CODE],[TENOR],[RATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[DEPRECIATION_CODE],[TENOR],[RATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_DEPRECIATION_DETAIL_Insert_Audit] 
			ON [dbo].[MASTER_DEPRECIATION_DETAIL]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_DEPRECIATION_DETAIL]
([ID],[DEPRECIATION_CODE],[TENOR],[RATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[DEPRECIATION_CODE],[TENOR],[RATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_DEPRECIATION_DETAIL_Update_Audit]      
			ON [dbo].[MASTER_DEPRECIATION_DETAIL]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ID]) THEN '[ID]-' ELSE '' END + 
CASE WHEN UPDATE([DEPRECIATION_CODE]) THEN '[DEPRECIATION_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([TENOR]) THEN '[TENOR]-' ELSE '' END + 
CASE WHEN UPDATE([RATE]) THEN '[RATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_DEPRECIATION_DETAIL]
([ID],[DEPRECIATION_CODE],[TENOR],[RATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[DEPRECIATION_CODE],[TENOR],[RATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_DEPRECIATION_DETAIL]
([ID],[DEPRECIATION_CODE],[TENOR],[RATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[DEPRECIATION_CODE],[TENOR],[RATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEPRECIATION_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode depreciation atas data master depreciation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEPRECIATION_DETAIL', @level2type = N'COLUMN', @level2name = N'DEPRECIATION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah angsuran atas data master depreciation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEPRECIATION_DETAIL', @level2type = N'COLUMN', @level2name = N'TENOR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai rate persentase depresiasi atas data master depreciation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEPRECIATION_DETAIL', @level2type = N'COLUMN', @level2name = N'RATE';

