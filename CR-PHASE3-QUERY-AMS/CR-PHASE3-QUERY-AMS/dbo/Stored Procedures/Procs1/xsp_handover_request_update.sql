CREATE PROCEDURE dbo.xsp_handover_request_update
(
	@p_code			   nvarchar(50)
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	,@p_type		   nvarchar(10)
	,@p_status		   nvarchar(10)
	,@p_date		   datetime
	,@p_handover_from  nvarchar(250)
	,@p_handover_to	   nvarchar(250)
	,@p_fa_code		   nvarchar(50)
	,@p_remark		   nvarchar(4000)
	,@p_reff_code	   nvarchar(50)
	,@p_reff_name	   nvarchar(50)
	,@p_handover_code  nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	handover_request
		set		branch_code		= @p_branch_code
				,branch_name	= @p_branch_name
				,type			= @p_type
				,status			= @p_status
				,date			= @p_date
				,handover_from	= @p_handover_from
				,handover_to	= @p_handover_to
				,fa_code		= @p_fa_code
				,remark			= @p_remark
				,reff_code		= @p_reff_code
				,reff_name		= @p_reff_name
				,handover_code	= @p_handover_code
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code ;
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
