CREATE PROCEDURE dbo.xsp_write_off_recovery_paid
(
	@p_code						nvarchar(50)
	,@p_agreement_no			nvarchar(50)
	,@p_process_reff_no			nvarchar(50) = null
	,@p_process_reff_name		nvarchar(250) = null
	,@p_process_date			datetime = null
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)

as
begin
	declare @msg							nvarchar(max)
			,@recovery_amount				decimal(18,2)
			,@wo_type						nvarchar(10)
			,@recovery_remarks				nvarchar(4000)
			,@recovery_date					datetime 
	
	begin try
		begin 

			select	@recovery_amount		    = ddt.recovery_amount * -1
					,@wo_type					= am.agreement_sub_status
					,@recovery_date				= ddt.recovery_date
					,@recovery_remarks			= ddt.recovery_remarks 	
			from	dbo.write_off_recovery ddt 
					inner join agreement_main am on (am.agreement_no = ddt.agreement_no)
			where	code = @p_code

			update	dbo.write_off_recovery
			set		recovery_status			= 'PAID'
					,process_reff_no		= @p_process_reff_no
					,process_reff_name		= @p_process_reff_name
					,process_date			= @p_process_date
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_code
		end
	end try
	Begin catch
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
	
end
