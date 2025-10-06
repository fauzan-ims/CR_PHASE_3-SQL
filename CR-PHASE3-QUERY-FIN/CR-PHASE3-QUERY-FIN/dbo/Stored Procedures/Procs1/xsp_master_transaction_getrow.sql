CREATE PROCEDURE dbo.xsp_master_transaction_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	mt.code
			,mt.transaction_name
			,mt.module_name
			,mt.is_active
			,mt.is_calculated
			,mt.gl_link_code
			,jgl.gl_link_name
	from	master_transaction mt
			inner join dbo.journal_gl_link jgl on (jgl.code = mt.gl_link_code)
	where	mt.code = @p_code ;
end ;
