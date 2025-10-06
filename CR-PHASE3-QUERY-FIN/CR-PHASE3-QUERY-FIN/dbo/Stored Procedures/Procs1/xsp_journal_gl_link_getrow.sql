

CREATE PROCEDURE dbo.xsp_journal_gl_link_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,gl_link_name
			,is_bank
			,is_active
			,is_provit_or_cost
	from	journal_gl_link
	where	code = @p_code ;
end ;
