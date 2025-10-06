CREATE TABLE [dbo].[MASTER_ROUNDING_DETAIL] (
    [ID]              BIGINT          IDENTITY (1, 1) NOT NULL,
    [ROUNDING_CODE]   NVARCHAR (50)   NOT NULL,
    [FACILITY_CODE]   NVARCHAR (50)   NOT NULL,
    [ROUNDING_TYPE]   NVARCHAR (10)   NOT NULL,
    [ROUNDING_AMOUNT] DECIMAL (18, 2) NOT NULL,
    [CRE_DATE]        DATETIME        NOT NULL,
    [CRE_BY]          NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]  NVARCHAR (15)   NOT NULL,
    [MOD_DATE]        DATETIME        NOT NULL,
    [MOD_BY]          NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]  NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_LOS_MASTER_ROUNDING_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MASTER_ROUNDING_DETAIL_MASTER_ROUNDING] FOREIGN KEY ([ROUNDING_CODE]) REFERENCES [dbo].[MASTER_ROUNDING] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_ROUNDING_DETAIL_Delete_Audit]    
			ON [dbo].[MASTER_ROUNDING_DETAIL]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_ROUNDING_DETAIL]
([ID],[ROUNDING_CODE],[FACILITY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[ROUNDING_CODE],[FACILITY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_ROUNDING_DETAIL_Update_Audit]      
			ON [dbo].[MASTER_ROUNDING_DETAIL]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ID]) THEN '[ID]-' ELSE '' END + 
CASE WHEN UPDATE([ROUNDING_CODE]) THEN '[ROUNDING_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([FACILITY_CODE]) THEN '[FACILITY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([ROUNDING_TYPE]) THEN '[ROUNDING_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([ROUNDING_AMOUNT]) THEN '[ROUNDING_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_ROUNDING_DETAIL]
([ID],[ROUNDING_CODE],[FACILITY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[ROUNDING_CODE],[FACILITY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_ROUNDING_DETAIL]
([ID],[ROUNDING_CODE],[FACILITY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[ROUNDING_CODE],[FACILITY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_ROUNDING_DETAIL_Insert_Audit] 
			ON [dbo].[MASTER_ROUNDING_DETAIL]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_ROUNDING_DETAIL]
([ID],[ROUNDING_CODE],[FACILITY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[ROUNDING_CODE],[FACILITY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ROUNDING_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode rounding ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ROUNDING_DETAIL', @level2type = N'COLUMN', @level2name = N'ROUNDING_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode facility yang digunakan pada proses rounding tersebut ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ROUNDING_DETAIL', @level2type = N'COLUMN', @level2name = N'FACILITY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe pembulatan pada data rounding tersebut - Up, menginformasikan bahwa pembulatan tersebut merupakan pembulatan ke atas - Down, menginformasikan bahwa pembulatan tersebut merupakan pembulatan ke bawah - Normal, menginformasikan bahwa pembulatan yang digunakan bisa ke atas dan kebawah tergantung dari angka yang akan dibulatkan (6 sampai 9 dibulatkan ke atas, dan 1 sampai 5 dibulatkan ke bawah)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ROUNDING_DETAIL', @level2type = N'COLUMN', @level2name = N'ROUNDING_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pembulatan pada data rounding tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ROUNDING_DETAIL', @level2type = N'COLUMN', @level2name = N'ROUNDING_AMOUNT';

