CREATE PROCEDURE dbo.xsp_sale_detail_upload_image_update
(
	@p_code			nvarchar(50)
	,@p_file_name	nvarchar(250)
	,@p_file_paths	nvarchar(250)
)
as
begin
	declare @msg	nvarchar(max);

	begin try
	
		update	dbo.sale_detail
		set		file_name		= upper(@p_file_name)
				,file_path			= upper(@p_file_paths)
		where	sale_code			= @p_code
				--and branch_code = @p_branch_code ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'v' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%v;%' or error_message() like '%e;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'e;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
end ;
