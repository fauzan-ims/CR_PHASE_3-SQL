CREATE PROCEDURE [dbo].[xsp_reason_return_update]
(
	@p_code									NVARCHAR(50)
	,@p_reason_return_code					nvarchar(50)
	,@p_reason_return						nvarchar(50)
	,@p_remark_return						nvarchar(4000) 
	--
	,@p_mod_date						  datetime
	,@p_mod_by							  nvarchar(15)
	,@p_mod_ip_address					  nvarchar(15)
)
as
begin
declare @msg				nvarchar(max);

	begin try
		
		UPDATE	register_main
		set		register_status			= 'REVISI'
				,payment_status			= 'CANCEL'
				,return_by				= @p_mod_by
				,return_date			= dbo.fn_get_system_date()
				,reason_return_code		= @p_reason_return_code
				,reason_return_desc		= @p_reason_return
				,reason_return_remark	= @p_remark_return
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;

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


