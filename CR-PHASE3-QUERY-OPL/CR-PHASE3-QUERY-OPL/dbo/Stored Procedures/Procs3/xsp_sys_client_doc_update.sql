CREATE PROCEDURE dbo.xsp_sys_client_doc_update
(
	@p_code			   nvarchar(50)
	,@p_client_code	   nvarchar(50)
	,@p_doc_type	   nvarchar(50)
	,@p_doc_no		   nvarchar(50)
	,@p_doc_status	   nvarchar(50)
	,@p_eff_date	   datetime
	,@p_exp_date	   datetime
	,@p_is_default	   nvarchar(1)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_default = 'T'
		set @p_is_default = '1' ;
	else
		set @p_is_default = '0' ;

	begin try
		update	sys_client_doc
		set		client_code			= @p_client_code
				,doc_type			= @p_doc_type
				,doc_no				= @p_doc_no
				,doc_status			= @p_doc_status
				,eff_date			= @p_eff_date
				,exp_date			= @p_exp_date
				,is_default			= @p_is_default
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;
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
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;

