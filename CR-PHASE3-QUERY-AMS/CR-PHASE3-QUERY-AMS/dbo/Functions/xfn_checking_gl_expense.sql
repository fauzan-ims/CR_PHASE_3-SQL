CREATE FUNCTION dbo.xfn_checking_gl_expense
(
	@p_gl_link_code nvarchar(50)
)
returns int
as
begin
	declare @is_expense int
		
	if exists (select 1 from dbo.journal_gl_link where code = @p_gl_link_code and is_expense = '1')
		set @is_expense = 1
	else
		set @is_expense = 0

	return @is_expense
end ;
