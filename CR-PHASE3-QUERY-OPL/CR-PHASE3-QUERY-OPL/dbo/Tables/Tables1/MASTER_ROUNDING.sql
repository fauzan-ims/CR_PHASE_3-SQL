CREATE TABLE [dbo].[MASTER_ROUNDING] (
    [CODE]            NVARCHAR (50)   NOT NULL,
    [CURRENCY_CODE]   NVARCHAR (3)    NOT NULL,
    [ROUNDING_TYPE]   NVARCHAR (10)   NOT NULL,
    [ROUNDING_AMOUNT] DECIMAL (18, 2) NOT NULL,
    [CRE_DATE]        DATETIME        NOT NULL,
    [CRE_BY]          NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]  NVARCHAR (15)   NOT NULL,
    [MOD_DATE]        DATETIME        NOT NULL,
    [MOD_BY]          NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]  NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_MASTER_ROUNDING] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_ROUNDING_Insert_Audit] 
			ON [dbo].[MASTER_ROUNDING]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_ROUNDING]
([CODE],[CURRENCY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[CURRENCY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_ROUNDING_Update_Audit]      
			ON [dbo].[MASTER_ROUNDING]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CURRENCY_CODE]) THEN '[CURRENCY_CODE]-' ELSE '' END + 
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
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_ROUNDING]
([CODE],[CURRENCY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[CURRENCY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_ROUNDING]
([CODE],[CURRENCY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[CURRENCY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_ROUNDING_Delete_Audit]    
			ON [dbo].[MASTER_ROUNDING]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_ROUNDING]
([CODE],[CURRENCY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[CURRENCY_CODE],[ROUNDING_TYPE],[ROUNDING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses rounding tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ROUNDING', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode dari jenis mata uang yang digunakan pada proses rounding tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ROUNDING', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe pembulatan pada data rounding tersebut - Up, menginformasikan bahwa pembulatan tersebut merupakan pembulatan ke atas - Down, menginformasikan bahwa pembulatan tersebut merupakan pembulatan ke bawah - Normal, menginformasikan bahwa pembulatan yang digunakan bisa ke atas dan kebawah tergantung dari angka yang akan dibulatkan (6 sampai 9 dibulatkan ke atas, dan 1 sampai 5 dibulatkan ke bawah)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ROUNDING', @level2type = N'COLUMN', @level2name = N'ROUNDING_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pembulatan pada data rounding tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ROUNDING', @level2type = N'COLUMN', @level2name = N'ROUNDING_AMOUNT';

