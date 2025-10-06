CREATE TABLE [dbo].[MASTER_SELLING_ATTACHMENT_GROUP] (
    [CODE]              NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]       NVARCHAR (250) NOT NULL,
    [DIM_COUNT]         NVARCHAR (2)   NULL,
    [IS_ACTIVE]         NVARCHAR (1)   NOT NULL,
    [SELL_TYPE]         NVARCHAR (50)  CONSTRAINT [DF_MASTER_SELLING_ATTACHMENT_GROUP_DOCUMENT_GROUP_TYPE_CODE] DEFAULT (N'') NOT NULL,
    [DIM_COUNT1]        INT            CONSTRAINT [DF_MASTER_SELLING_ATTACHMENT_GROUP_DIM_COUNT1] DEFAULT ((0)) NOT NULL,
    [DIM_1]             NVARCHAR (50)  NULL,
    [OPERATOR_1]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_1]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_1]    NVARCHAR (50)  NULL,
    [DIM_2]             NVARCHAR (50)  NULL,
    [OPERATOR_2]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_2]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_2]    NVARCHAR (50)  NULL,
    [DIM_3]             NVARCHAR (50)  NULL,
    [OPERATOR_3]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_3]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_3]    NVARCHAR (50)  NULL,
    [DIM_4]             NVARCHAR (50)  NULL,
    [OPERATOR_4]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_4]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_4]    NVARCHAR (50)  NULL,
    [DIM_5]             NVARCHAR (50)  NULL,
    [OPERATOR_5]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_5]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_5]    NVARCHAR (50)  NULL,
    [DIM_6]             NVARCHAR (50)  NULL,
    [OPERATOR_6]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_6]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_6]    NVARCHAR (50)  NULL,
    [DIM_7]             NVARCHAR (50)  NULL,
    [OPERATOR_7]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_7]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_7]    NVARCHAR (50)  NULL,
    [DIM_8]             NVARCHAR (50)  NULL,
    [OPERATOR_8]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_8]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_8]    NVARCHAR (50)  NULL,
    [DIM_9]             NVARCHAR (50)  NULL,
    [OPERATOR_9]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_9]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_9]    NVARCHAR (50)  NULL,
    [DIM_10]            NVARCHAR (50)  NULL,
    [OPERATOR_10]       NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_10] NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_10]   NVARCHAR (50)  NULL,
    [CRE_DATE]          DATETIME       NOT NULL,
    [CRE_BY]            NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    [MOD_DATE]          DATETIME       NOT NULL,
    [MOD_BY]            NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_SELLING_ATTACHMENT_GROUP] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe group document atas data document group tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'SELL_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Count dimensi atas data document group tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_COUNT1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 1 atas data document group tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 1 data document group tersebut - Equal, menginformasikan bahwa dimensi 1 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 1 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 1 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 1 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 2 atas data document group tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 2 data document group tersebut - Equal, menginformasikan bahwa dimensi 2 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 2 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 2 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 2 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 3 atas data document group tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 3 data document group tersebut - Equal, menginformasikan bahwa dimensi 3 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 3 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 3 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 3 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 4 atas data document group tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 4 data document group tersebut - Equal, menginformasikan bahwa dimensi 4 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 4 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 4 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 4 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 4', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 4', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 5 atas data document group tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_5';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 5 data document group tersebut - Equal, menginformasikan bahwa dimensi 5 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 5 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 5 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 5 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_5';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 5', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_5';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 5', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_5';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 6 atas data document group tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_6';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 6 data document group tersebut - Equal, menginformasikan bahwa dimensi 6 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 6 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 6 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 6 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_6';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 6', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_6';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 6', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_6';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 7 atas data document group tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_7';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 7 data document group tersebut - Equal, menginformasikan bahwa dimensi 7 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 7 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 7 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 7 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_7';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 7', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_7';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 7', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_7';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 8 atas data document group tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_8';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 8 data document group tersebut - Equal, menginformasikan bahwa dimensi 8 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 8 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 8 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 8 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_8';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 8', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_8';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 8', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_8';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 9 atas data document group tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_9';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 9 data document group tersebut - Equal, menginformasikan bahwa dimensi 9 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 9 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 9 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 9 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_9';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 9', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_9';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 9', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_9';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 10 atas data document group tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_10';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 10 data document group tersebut - Equal, menginformasikan bahwa dimensi 10 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 10 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 10 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 10 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_10';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 10', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_10';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 10', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_10';

