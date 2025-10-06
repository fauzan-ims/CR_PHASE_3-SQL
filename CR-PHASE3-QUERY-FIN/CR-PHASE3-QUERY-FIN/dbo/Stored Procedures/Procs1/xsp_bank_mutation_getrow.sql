CREATE PROCEDURE dbo.xsp_bank_mutation_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	bm.code
			,branch_code
			,branch_name
			,gl_link_code
			,bm.branch_bank_name 'gl_link_name'
			,balance_amount
	from	bank_mutation bm
			left join dbo.journal_gl_link jgl on (jgl.code = bm.gl_link_code)
	where	bm.code = @p_code ;
end ;
