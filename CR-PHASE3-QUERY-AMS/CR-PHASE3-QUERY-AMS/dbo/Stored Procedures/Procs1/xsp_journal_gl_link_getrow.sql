
CREATE PROCEDURE dbo.xsp_journal_gl_link_getrow
(
	@p_code			 nvarchar(50)
	,@p_company_code nvarchar(50)
)
as
begin
	select	code
			,name
			,is_bank
			,is_expense
	from	journal_gl_link
	where	code			 = @p_code
			and company_code = @p_company_code ;
end ;
