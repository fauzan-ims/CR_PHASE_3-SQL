CREATE TABLE [dbo].[MASTER_FEE] (
    [CODE]              NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]       NVARCHAR (250) NOT NULL,
    [GL_LINK_CODE]      NVARCHAR (50)  NOT NULL,
    [IS_CALCULATE_PSAK] NVARCHAR (1)   NOT NULL,
    [PSAK_GL_LINK_CODE] NVARCHAR (50)  NULL,
    [IS_CALCULATED]     NVARCHAR (1)   CONSTRAINT [DF_MASTER_FEE_IS_CALCULATED] DEFAULT ((0)) NOT NULL,
    [IS_ACTIVE]         NVARCHAR (1)   NOT NULL,
    [CRE_DATE]          DATETIME       NOT NULL,
    [CRE_BY]            NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    [MOD_DATE]          DATETIME       NOT NULL,
    [MOD_BY]            NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_SYS_MASTER_FEE] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_FEE_Delete_Audit]    
			ON [dbo].[MASTER_FEE]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_FEE]
([CODE],[DESCRIPTION],[GL_LINK_CODE],[IS_CALCULATE_PSAK],[PSAK_GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[GL_LINK_CODE],[IS_CALCULATE_PSAK],[PSAK_GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_FEE_Insert_Audit] 
			ON [dbo].[MASTER_FEE]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_FEE]
([CODE],[DESCRIPTION],[GL_LINK_CODE],[IS_CALCULATE_PSAK],[PSAK_GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[GL_LINK_CODE],[IS_CALCULATE_PSAK],[PSAK_GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_FEE_Update_Audit]      
			ON [dbo].[MASTER_FEE]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([GL_LINK_CODE]) THEN '[GL_LINK_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_CALCULATE_PSAK]) THEN '[IS_CALCULATE_PSAK]-' ELSE '' END + 
CASE WHEN UPDATE([PSAK_GL_LINK_CODE]) THEN '[PSAK_GL_LINK_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_CALCULATED]) THEN '[IS_CALCULATED]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_FEE]
([CODE],[DESCRIPTION],[GL_LINK_CODE],[IS_CALCULATE_PSAK],[PSAK_GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[GL_LINK_CODE],[IS_CALCULATE_PSAK],[PSAK_GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_FEE]
([CODE],[DESCRIPTION],[GL_LINK_CODE],[IS_CALCULATE_PSAK],[PSAK_GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[GL_LINK_CODE],[IS_CALCULATE_PSAK],[PSAK_GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data master fee tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deskripsi atas data master fee tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode GL link atas data master fee tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE', @level2type = N'COLUMN', @level2name = N'GL_LINK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data fee tersebut dilakukan perhitungan terhadap PSAK?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE', @level2type = N'COLUMN', @level2name = N'IS_CALCULATE_PSAK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode GL link atas data master fee tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE', @level2type = N'COLUMN', @level2name = N'PSAK_GL_LINK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data fee tersebut, apakah data fee tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE', @level2type = N'COLUMN', @level2name = N'IS_CALCULATED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data fee tersebut, apakah data fee tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

