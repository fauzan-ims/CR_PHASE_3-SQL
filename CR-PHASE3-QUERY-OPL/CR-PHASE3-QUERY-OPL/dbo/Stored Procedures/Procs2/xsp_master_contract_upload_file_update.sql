CREATE PROCEDURE [dbo].[xsp_master_contract_upload_file_update]
(
	@p_main_contract_no nvarchar(50)
	,@p_file_name		nvarchar(250)	= ''
	,@p_file_paths		nvarchar(250)	= ''
	,@p_memo_file_name	nvarchar(250)	= ''
	,@p_memo_file_path	nvarchar(250)	= ''
	,@p_type			nvarchar(50)	= ''
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if(@p_type = 'MEMO')
		begin
			update	dbo.master_contract
			set		memo_file_name	= upper(@p_file_name)
					,memo_file_path	= upper(@p_file_paths)
			where	main_contract_no = @p_main_contract_no ;
		end
		else
		begin
			update	dbo.master_contract
			set		file_name		= upper(@p_file_name)
					,file_path		= upper(@p_file_paths)
			where	main_contract_no = @p_main_contract_no ;
		end
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
