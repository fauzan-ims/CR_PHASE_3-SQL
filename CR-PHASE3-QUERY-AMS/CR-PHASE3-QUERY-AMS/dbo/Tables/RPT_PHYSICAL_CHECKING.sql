CREATE TABLE [dbo].[RPT_PHYSICAL_CHECKING] (
    [USER_ID]                 NVARCHAR (50)  NOT NULL,
    [REPORT_COMPANY]          NVARCHAR (250) NOT NULL,
    [REPORT_TITLE]            NVARCHAR (250) NOT NULL,
    [REPORT_IMAGE]            NVARCHAR (250) NOT NULL,
    [REPORT_ADDRESS]          NVARCHAR (250) NOT NULL,
    [FROM_DATE]               DATETIME       NULL,
    [CODE]                    NVARCHAR (50)  NULL,
    [EX_AGREEMENT_NO]         NVARCHAR (50)  NULL,
    [STATUS_UNIT]             NVARCHAR (50)  NULL,
    [STATUS_PEMAKAIAN]        NVARCHAR (50)  NULL,
    [LEASED_OBJECT]           NVARCHAR (250) NULL,
    [YEAR]                    NVARCHAR (50)  NULL,
    [CHASIS_NO]               NVARCHAR (50)  NULL,
    [PLAT_NO]                 NVARCHAR (50)  NULL,
    [PHYSICAL_CHECK_LOCATION] NVARCHAR (250) NULL,
    [DATE]                    DATETIME       NULL,
    [PIC]                     NVARCHAR (250) NULL,
    [CONDITION]               NVARCHAR (50)  NULL,
    [IS_CONDITION]            NVARCHAR (1)   NULL,
    [TO_DATE]                 DATETIME       NULL
);

