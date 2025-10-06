CREATE TABLE [dbo].[rpt_CustomerData] (
    [ID]         INT                                                                      IDENTITY (1, 1) NOT NULL,
    [FullName]   NVARCHAR (100) MASKED WITH (FUNCTION = 'default()')                      NULL,
    [Email]      NVARCHAR (100) MASKED WITH (FUNCTION = 'email()')                        NULL,
    [CreditCard] VARCHAR (50) MASKED WITH (FUNCTION = 'partial(0, "XXXX-XXXX-XXXX-", 4)') NULL,
    [BirthDate]  DATE MASKED WITH (FUNCTION = 'default()')                                NULL,
    CONSTRAINT [PK__rpt_Cust__3214EC274355A520] PRIMARY KEY CLUSTERED ([ID] ASC)
);

