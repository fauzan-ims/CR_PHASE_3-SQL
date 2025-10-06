CREATE TABLE [dbo].[TEMP_GRN] (
    [ID]               BIGINT          IDENTITY (1, 1) NOT NULL,
    [PROCUREMENT_TYPE] NVARCHAR (50)   NULL,
    [ID_DETAIL]        INT             NULL,
    [CODE_GRN]         NVARCHAR (50)   NULL,
    [CODE_PO]          NVARCHAR (50)   NULL,
    [CODE_ASSET]       NVARCHAR (50)   NULL,
    [PLAT]             NVARCHAR (50)   NULL,
    [ENGINE]           NVARCHAR (50)   NULL,
    [CHASSIS]          NVARCHAR (50)   NULL,
    [RECEIVE_QTY]      INT             NULL,
    [UNIT_PRICE]       DECIMAL (18, 2) NULL,
    [DISCOUNT]         DECIMAL (18, 2) NULL,
    [PPN]              DECIMAL (18, 2) NULL,
    [PPH]              DECIMAL (18, 2) NULL,
    [TOTAL_AMOUNT]     DECIMAL (18, 2) NULL,
    [UNIT_EXC_PPN]     DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_TEMP_GRN] PRIMARY KEY CLUSTERED ([ID] ASC)
);

