CREATE TABLE [dbo].[MASTER_AUCTION_ADDRESS] (
    [ID]             BIGINT          IDENTITY (1, 1) NOT NULL,
    [AUCTION_CODE]   NVARCHAR (50)   NOT NULL,
    [PROVINCE_CODE]  NVARCHAR (50)   NOT NULL,
    [PROVINCE_NAME]  NVARCHAR (250)  NOT NULL,
    [CITY_CODE]      NVARCHAR (50)   NOT NULL,
    [CITY_NAME]      NVARCHAR (250)  NOT NULL,
    [ZIP_CODE]       NVARCHAR (50)   NOT NULL,
    [SUB_DISTRICT]   NVARCHAR (250)  NOT NULL,
    [VILLAGE]        NVARCHAR (250)  NOT NULL,
    [ADDRESS]        NVARCHAR (4000) NOT NULL,
    [RT]             NVARCHAR (5)    NOT NULL,
    [RW]             NVARCHAR (5)    NOT NULL,
    [IS_LATEST]      NVARCHAR (1)    NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_MASTER_AUCTION_ADDRESS] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MASTER_AUCTION_ADDRESS_MASTER_AUCTION] FOREIGN KEY ([AUCTION_CODE]) REFERENCES [dbo].[MASTER_AUCTION] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_AUCTION_ADDRESS_Insert_Audit] 
			ON [dbo].[MASTER_AUCTION_ADDRESS]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_ADDRESS]
([ID],[AUCTION_CODE],[PROVINCE_CODE],[PROVINCE_NAME],[CITY_CODE],[CITY_NAME],[ZIP_CODE],[SUB_DISTRICT],[VILLAGE],[ADDRESS],[RT],[RW],[IS_LATEST],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[AUCTION_CODE],[PROVINCE_CODE],[PROVINCE_NAME],[CITY_CODE],[CITY_NAME],[ZIP_CODE],[SUB_DISTRICT],[VILLAGE],[ADDRESS],[RT],[RW],[IS_LATEST],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_AUCTION_ADDRESS_Update_Audit]      
			ON [dbo].[MASTER_AUCTION_ADDRESS]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ID]) THEN '[ID]-' ELSE '' END + 
CASE WHEN UPDATE([AUCTION_CODE]) THEN '[AUCTION_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([PROVINCE_CODE]) THEN '[PROVINCE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([PROVINCE_NAME]) THEN '[PROVINCE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([CITY_CODE]) THEN '[CITY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CITY_NAME]) THEN '[CITY_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([ZIP_CODE]) THEN '[ZIP_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([SUB_DISTRICT]) THEN '[SUB_DISTRICT]-' ELSE '' END + 
CASE WHEN UPDATE([VILLAGE]) THEN '[VILLAGE]-' ELSE '' END + 
CASE WHEN UPDATE([ADDRESS]) THEN '[ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([RT]) THEN '[RT]-' ELSE '' END + 
CASE WHEN UPDATE([RW]) THEN '[RW]-' ELSE '' END + 
CASE WHEN UPDATE([IS_LATEST]) THEN '[IS_LATEST]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_ADDRESS]
([ID],[AUCTION_CODE],[PROVINCE_CODE],[PROVINCE_NAME],[CITY_CODE],[CITY_NAME],[ZIP_CODE],[SUB_DISTRICT],[VILLAGE],[ADDRESS],[RT],[RW],[IS_LATEST],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[AUCTION_CODE],[PROVINCE_CODE],[PROVINCE_NAME],[CITY_CODE],[CITY_NAME],[ZIP_CODE],[SUB_DISTRICT],[VILLAGE],[ADDRESS],[RT],[RW],[IS_LATEST],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_ADDRESS]
([ID],[AUCTION_CODE],[PROVINCE_CODE],[PROVINCE_NAME],[CITY_CODE],[CITY_NAME],[ZIP_CODE],[SUB_DISTRICT],[VILLAGE],[ADDRESS],[RT],[RW],[IS_LATEST],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[AUCTION_CODE],[PROVINCE_CODE],[PROVINCE_NAME],[CITY_CODE],[CITY_NAME],[ZIP_CODE],[SUB_DISTRICT],[VILLAGE],[ADDRESS],[RT],[RW],[IS_LATEST],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_AUCTION_ADDRESS_Delete_Audit]    
			ON [dbo].[MASTER_AUCTION_ADDRESS]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_ADDRESS]
([ID],[AUCTION_CODE],[PROVINCE_CODE],[PROVINCE_NAME],[CITY_CODE],[CITY_NAME],[ZIP_CODE],[SUB_DISTRICT],[VILLAGE],[ADDRESS],[RT],[RW],[IS_LATEST],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[AUCTION_CODE],[PROVINCE_CODE],[PROVINCE_NAME],[CITY_CODE],[CITY_NAME],[ZIP_CODE],[SUB_DISTRICT],[VILLAGE],[ADDRESS],[RT],[RW],[IS_LATEST],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_ADDRESS', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode balai lelang pada data alamat balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_ADDRESS', @level2type = N'COLUMN', @level2name = N'AUCTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode provinsi pada data alamat balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_ADDRESS', @level2type = N'COLUMN', @level2name = N'PROVINCE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama provinsi pada data alamat balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_ADDRESS', @level2type = N'COLUMN', @level2name = N'PROVINCE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kota pada data alamat balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_ADDRESS', @level2type = N'COLUMN', @level2name = N'CITY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama kota pada data alamat balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_ADDRESS', @level2type = N'COLUMN', @level2name = N'CITY_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pos pada data alamat balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_ADDRESS', @level2type = N'COLUMN', @level2name = N'ZIP_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kecamatan pada data alamat balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_ADDRESS', @level2type = N'COLUMN', @level2name = N'SUB_DISTRICT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kelurahan pada data alamat balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_ADDRESS', @level2type = N'COLUMN', @level2name = N'VILLAGE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alamat pada data alamat balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_ADDRESS', @level2type = N'COLUMN', @level2name = N'ADDRESS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor RT pada data alamat balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_ADDRESS', @level2type = N'COLUMN', @level2name = N'RT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor RW pada data alamat balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_ADDRESS', @level2type = N'COLUMN', @level2name = N'RW';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah alamat tersebut merupakan alamat terakhir pada data alamat balai lelang tersebut?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_ADDRESS', @level2type = N'COLUMN', @level2name = N'IS_LATEST';

