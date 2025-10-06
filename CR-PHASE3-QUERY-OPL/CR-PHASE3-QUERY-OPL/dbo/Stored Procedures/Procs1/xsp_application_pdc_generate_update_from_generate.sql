CREATE PROCEDURE dbo.xsp_application_pdc_generate_update_from_generate
(
	@p_application_no			nvarchar(50)
	,@p_pdc_no_prefix			nvarchar(10) = null
	,@p_pdc_no_running			nvarchar(10) 
	,@p_pdc_no_postfix			nvarchar(10) = null
	,@p_pdc_frequency_month		int
	,@p_pdc_count				int
	,@p_pdc_bank_code			nvarchar(50)
	,@p_pdc_bank_name			nvarchar(250)
	,@p_pdc_first_date			datetime
	,@p_pdc_allocation_type		nvarchar(50)
	,@p_pdc_currency_code		nvarchar(3)
	,@p_pdc_value_amount		decimal(18, 2)
	,@p_pdc_inkaso_fee_amount	decimal(18, 2)
	,@p_pdc_clearing_fee_amount decimal(18, 2)
	,@p_pdc_amount				decimal(18, 2)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if(@p_pdc_count < 1)
		begin		
			set @msg =  'Number Of PDC must be greather than 0'; 
			raiserror(@msg,16,1)
		end

		update	application_pdc_generate
		set		pdc_no_prefix				= upper(@p_pdc_no_prefix)
				,pdc_no_running				= @p_pdc_no_running
				,pdc_no_postfix				= upper(@p_pdc_no_postfix)
				,pdc_frequency_month		= @p_pdc_frequency_month
				,pdc_count					= @p_pdc_count
				,pdc_bank_code				= @p_pdc_bank_code
				,pdc_bank_name				= @p_pdc_bank_name
				,pdc_first_date				= @p_pdc_first_date
				,pdc_allocation_type		= @p_pdc_allocation_type
				,pdc_currency_code			= @p_pdc_currency_code
				,pdc_value_amount			= @p_pdc_value_amount
				,pdc_inkaso_fee_amount		= @p_pdc_inkaso_fee_amount
				,pdc_clearing_fee_amount	= @p_pdc_clearing_fee_amount
				,pdc_amount					= @p_pdc_amount
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	application_no				= @p_application_no ;
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

