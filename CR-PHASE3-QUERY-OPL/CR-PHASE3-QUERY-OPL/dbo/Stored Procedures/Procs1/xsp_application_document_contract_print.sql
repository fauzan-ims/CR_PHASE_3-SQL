CREATE procedure dbo.xsp_application_document_contract_print
	@p_document_contract_code nvarchar(50)
	,@p_application_no		  nvarchar(50)
	--
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
as
begin
	declare @print_count int
			,@msg		 nvarchar(max) ;

	begin try
		update	application_document_contract
		set		print_count = print_count + 1
				,last_print_date = dbo.xfn_get_system_date()
				,last_print_by = @p_mod_by
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	application_no			   = @p_application_no
				and document_contract_code = @p_document_contract_code ;
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
			set @msg = 'V' + ';' + @msg ;
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
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
