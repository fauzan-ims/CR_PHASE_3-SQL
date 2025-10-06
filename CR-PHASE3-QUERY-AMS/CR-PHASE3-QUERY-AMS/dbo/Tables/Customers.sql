CREATE TABLE [dbo].[Customers] (
    [CustomerID]       INT                                                           NOT NULL,
    [Email]            VARCHAR (100) MASKED WITH (FUNCTION = 'email()')              NULL,
    [SSN]              CHAR (11) MASKED WITH (FUNCTION = 'partial(1, "XXX-XX-", 4)') NULL,
    [CreditCardNumber] VARCHAR (16) MASKED WITH (FUNCTION = 'default()')             NULL,
    CONSTRAINT [PK__Customer__A4AE64B8BAE44C4A] PRIMARY KEY CLUSTERED ([CustomerID] ASC)
);

