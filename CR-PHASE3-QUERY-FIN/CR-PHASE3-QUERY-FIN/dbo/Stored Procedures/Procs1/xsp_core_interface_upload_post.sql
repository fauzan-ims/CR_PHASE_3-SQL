CREATE PROCEDURE dbo.xsp_core_interface_upload_post
(
	@p_cre_by				nvarchar(15)
	,@p_code_table			nvarchar(50)
)
as
begin
	
	declare @sp_post_name		nvarchar(250)
			,@execute_sp_name		nvarchar(max)


	select	@sp_post_name	= sp_post_name
	from	dbo.master_upload_table
	where	code				= @p_code_table    

	exec	@sp_post_name
	        @p_cre_by

end
