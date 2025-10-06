CREATE TABLE [dbo].[MASTER_COLLECTION_BUCKET] (
    [CODE]            NVARCHAR (50)  NOT NULL,
    [BUCKET_NAME]     NVARCHAR (100) NOT NULL,
    [OVERDUE_MIN_DAY] INT            NOT NULL,
    [OVERDUE_MAX_DAY] INT            NOT NULL,
    [FACILITY_CODE]   NVARCHAR (50)  NOT NULL,
    [FACILITY_NAME]   NVARCHAR (250) NOT NULL,
    [BUCKET_TYPE]     NVARCHAR (10)  NOT NULL,
    [IS_LIFE_BUCKET]  NVARCHAR (1)   NOT NULL,
    [IS_REMEDIAL]     NVARCHAR (1)   NOT NULL,
    [IS_ACTIVE]       NVARCHAR (1)   NOT NULL,
    [CRE_DATE]        DATETIME       NOT NULL,
    [CRE_BY]          NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]  NVARCHAR (15)  NOT NULL,
    [MOD_DATE]        DATETIME       NOT NULL,
    [MOD_BY]          NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]  NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_COLLECTION_BUCKET] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_COLLECTION_BUCKET_Delete_Audit]    
			ON [dbo].[MASTER_COLLECTION_BUCKET]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_COLLECTION_BUCKET]
([CODE],[BUCKET_NAME],[OVERDUE_MIN_DAY],[OVERDUE_MAX_DAY],[FACILITY_CODE],[FACILITY_NAME],[BUCKET_TYPE],[IS_LIFE_BUCKET],[IS_REMEDIAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[BUCKET_NAME],[OVERDUE_MIN_DAY],[OVERDUE_MAX_DAY],[FACILITY_CODE],[FACILITY_NAME],[BUCKET_TYPE],[IS_LIFE_BUCKET],[IS_REMEDIAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_COLLECTION_BUCKET_Update_Audit]      
			ON [dbo].[MASTER_COLLECTION_BUCKET]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([BUCKET_NAME]) THEN '[BUCKET_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([OVERDUE_MIN_DAY]) THEN '[OVERDUE_MIN_DAY]-' ELSE '' END + 
CASE WHEN UPDATE([OVERDUE_MAX_DAY]) THEN '[OVERDUE_MAX_DAY]-' ELSE '' END + 
CASE WHEN UPDATE([FACILITY_CODE]) THEN '[FACILITY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([FACILITY_NAME]) THEN '[FACILITY_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([BUCKET_TYPE]) THEN '[BUCKET_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_LIFE_BUCKET]) THEN '[IS_LIFE_BUCKET]-' ELSE '' END + 
CASE WHEN UPDATE([IS_REMEDIAL]) THEN '[IS_REMEDIAL]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_COLLECTION_BUCKET]
([CODE],[BUCKET_NAME],[OVERDUE_MIN_DAY],[OVERDUE_MAX_DAY],[FACILITY_CODE],[FACILITY_NAME],[BUCKET_TYPE],[IS_LIFE_BUCKET],[IS_REMEDIAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[BUCKET_NAME],[OVERDUE_MIN_DAY],[OVERDUE_MAX_DAY],[FACILITY_CODE],[FACILITY_NAME],[BUCKET_TYPE],[IS_LIFE_BUCKET],[IS_REMEDIAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_COLLECTION_BUCKET]
([CODE],[BUCKET_NAME],[OVERDUE_MIN_DAY],[OVERDUE_MAX_DAY],[FACILITY_CODE],[FACILITY_NAME],[BUCKET_TYPE],[IS_LIFE_BUCKET],[IS_REMEDIAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[BUCKET_NAME],[OVERDUE_MIN_DAY],[OVERDUE_MAX_DAY],[FACILITY_CODE],[FACILITY_NAME],[BUCKET_TYPE],[IS_LIFE_BUCKET],[IS_REMEDIAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_COLLECTION_BUCKET_Insert_Audit] 
			ON [dbo].[MASTER_COLLECTION_BUCKET]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_COLLECTION_BUCKET]
([CODE],[BUCKET_NAME],[OVERDUE_MIN_DAY],[OVERDUE_MAX_DAY],[FACILITY_CODE],[FACILITY_NAME],[BUCKET_TYPE],[IS_LIFE_BUCKET],[IS_REMEDIAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[BUCKET_NAME],[OVERDUE_MIN_DAY],[OVERDUE_MAX_DAY],[FACILITY_CODE],[FACILITY_NAME],[BUCKET_TYPE],[IS_LIFE_BUCKET],[IS_REMEDIAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada bucket collection tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTION_BUCKET', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama pada bucket collection tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTION_BUCKET', @level2type = N'COLUMN', @level2name = N'BUCKET_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai batas bawah overdue pada bucket collection tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTION_BUCKET', @level2type = N'COLUMN', @level2name = N'OVERDUE_MIN_DAY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai batas atas overdue pada bucket collection tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTION_BUCKET', @level2type = N'COLUMN', @level2name = N'OVERDUE_MAX_DAY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode fasilitas pada bucket collection tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTION_BUCKET', @level2type = N'COLUMN', @level2name = N'FACILITY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama fasilitas pada bucket collection tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTION_BUCKET', @level2type = N'COLUMN', @level2name = N'FACILITY_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe bucket pada bucket collection tersebut - DESKCOLL, menginformasikan bahwa data bucket tersebut diperuntukkan untuk deskcollection - FIELDCOLL, menginformasikan bahwa data bucket tersebut diperuntukkan untuk field collection', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTION_BUCKET', @level2type = N'COLUMN', @level2name = N'BUCKET_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah bucket tersebut merupakan bucket hidup?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTION_BUCKET', @level2type = N'COLUMN', @level2name = N'IS_LIFE_BUCKET';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah bucket tersebut merupakan bucket untuk proses remedial?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTION_BUCKET', @level2type = N'COLUMN', @level2name = N'IS_REMEDIAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada bucket collection tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTION_BUCKET', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

