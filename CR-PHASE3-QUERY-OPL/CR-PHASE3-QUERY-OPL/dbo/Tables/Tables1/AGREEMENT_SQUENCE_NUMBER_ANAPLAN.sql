CREATE TABLE [dbo].[AGREEMENT_SQUENCE_NUMBER_ANAPLAN] (
    [ID]                    BIGINT        IDENTITY (1, 1) NOT NULL,
    [AGREEMENT_EXTERNAL_NO] NVARCHAR (50) NULL,
    [RUNNING_NO]            INT           NULL,
    [IS_MIGRASI]            NVARCHAR (1)  NULL
);

