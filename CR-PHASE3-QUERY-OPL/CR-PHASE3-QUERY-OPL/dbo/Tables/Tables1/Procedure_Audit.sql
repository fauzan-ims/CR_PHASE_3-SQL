CREATE TABLE [dbo].[Procedure_Audit] (
    [EventID]      INT            IDENTITY (1, 1) NOT NULL,
    [EventType]    NVARCHAR (MAX) NULL,
    [ObjectName]   NVARCHAR (MAX) NULL,
    [ObjectSchema] NVARCHAR (MAX) NULL,
    [SqlText]      NVARCHAR (MAX) NULL,
    [EventDate]    DATETIME       DEFAULT (getdate()) NULL,
    [LoginName]    NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([EventID] ASC)
);

