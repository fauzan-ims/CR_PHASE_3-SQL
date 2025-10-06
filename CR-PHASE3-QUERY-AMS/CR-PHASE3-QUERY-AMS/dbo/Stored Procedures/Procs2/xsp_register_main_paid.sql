create PROCEDURE dbo.xsp_register_main_paid
(
	@p_code								nvarchar(50)
	,@p_dp_to_public_service_date		datetime
	,@p_dp_to_public_service_voucher	nvarchar(50)
	--
	,@p_cre_date						datetime
	,@p_cre_by							nvarchar(15)
	,@p_cre_ip_address					nvarchar(15)
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	
	declare @msg						nvarchar(max)
			,@register_status			nvarchar(20)

	begin try
		
		select	@register_status		= register_status
		from	dbo.register_main
		where	code = @p_code
			

		if @register_status <> 'ON PROCESS'
		BEGIN
			SET @msg = 'Data already proceed.'
			raiserror(@msg ,16,-1)
		end
				

		update	dbo.register_main
		set		register_status				= case register_process_by
												when 'INTERNAL' then 'PAID'
												when 'CUSTOMER' then 'DONE'
											end
				--,dp_from_customer_date		= @p_dp_from_customer_date
				--,dp_from_customer_voucher	= @p_dp_from_customer_voucher
				,dp_to_public_service_date		= @p_dp_to_public_service_date
				,dp_to_public_service_voucher	= @p_dp_to_public_service_voucher
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	code = @p_code
	
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;

end
