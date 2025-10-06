
CREATE PROCEDURE [dbo].[xsp_master_fee_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mf.code
			,description
			,gl_link_code
			,jgl.gl_link_name
			,is_calculate_psak
			,mf.psak_gl_link_code
			,jgl2.gl_link_name 'psak_gl_link_name'
			,mf.is_active
			,mf.is_calculated
	from	master_fee mf
			inner join dbo.journal_gl_link jgl on (jgl.code = mf.gl_link_code)
			left join dbo.journal_gl_link jgl2 on (jgl2.code = mf.psak_gl_link_code)
	where	mf.code = @p_code ;
end ;
