﻿CREATE TABLE [dbo].[ASSET_GPS_SCHEDULE] (
    [ID]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [INSTALLMENT_NO]        NVARCHAR (50)   NOT NULL,
    [PERIODE]               NVARCHAR (250)  NULL,
    [FA_CODE]               NVARCHAR (50)   NOT NULL,
    [DUE_DATE]              DATETIME        NULL,
    [VENDOR_CODE]           NVARCHAR (50)   NOT NULL,
    [VENDOR_NAME]           NVARCHAR (250)  NOT NULL,
    [SUBCRIBE_AMOUNT_MONTH] DECIMAL (18, 2) NOT NULL,
    [NEXT_BILLING_DATE]     DATETIME        NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [STATUS]                NVARCHAR (25)   NULL,
    [VENDOR_NPWP]           NVARCHAR (50)   NULL,
    [VENDOR_NITKU]          NVARCHAR (50)   NULL,
    [VENDOR_NPWP_PUSAT]     NVARCHAR (50)   NULL,
    CONSTRAINT [PK__ASSET_GP__3214EC2766E10C26] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_ASSET_GPS_SCHEDULE_ASSET] FOREIGN KEY ([FA_CODE]) REFERENCES [dbo].[ASSET] ([CODE])
);

