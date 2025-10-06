CREATE TABLE [dbo].[CustomerData] (
    [ID]         INT                                                                      IDENTITY (1, 1) NOT NULL,
    [FullName]   NVARCHAR (100) MASKED WITH (FUNCTION = 'default()')                      NULL,
    [Email]      NVARCHAR (100) MASKED WITH (FUNCTION = 'email()')                        NULL,
    [CreditCard] VARCHAR (50) MASKED WITH (FUNCTION = 'partial(0, "XXXX-XXXX-XXXX-", 4)') NULL,
    [BirthDate]  DATE MASKED WITH (FUNCTION = 'default()')                                NULL,
    CONSTRAINT [PK__Customer__3214EC275F135032] PRIMARY KEY CLUSTERED ([ID] ASC)
);

