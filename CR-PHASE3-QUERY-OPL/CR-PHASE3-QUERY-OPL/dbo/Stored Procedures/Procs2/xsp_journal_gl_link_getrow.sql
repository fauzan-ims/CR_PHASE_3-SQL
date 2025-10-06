
CREATE PROCEDURE dbo.xsp_journal_gl_link_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,gl_link_name
			,is_active
	from	journal_gl_link
	where	code = @p_code ;
end ;
