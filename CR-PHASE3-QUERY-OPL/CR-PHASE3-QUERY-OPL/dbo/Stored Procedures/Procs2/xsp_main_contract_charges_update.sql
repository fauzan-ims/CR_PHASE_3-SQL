CREATE PROCEDURE [dbo].[xsp_main_contract_charges_update]
(
	@p_id					   bigint
	,@p_main_contract_no		   nvarchar(50)
	,@p_charges_code		   nvarchar(50)
	,@p_dafault_charges_rate   decimal(9, 6)
	,@p_dafault_charges_amount decimal(18, 2)
	,@p_calculate_by		   nvarchar(10)
	,@p_charges_rate		   decimal(9, 6)   = 0
	,@p_charges_amount		   decimal(18, 2)  = 0
	,@p_new_calculate_by	   nvarchar(10)	   = null
	,@p_new_charges_rate	   decimal(9, 6)   = null
	,@p_new_charges_amount	   decimal(18, 2)  = null
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists
		(
			select	1
			from	main_contract_charges
			where	main_contract_no = @p_main_contract_no
					and charges_code   = @p_charges_code
					and id <> @p_id
		)
		begin
			set @msg = 'Charges already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	main_contract_charges
		set		charges_code			= @p_charges_code
				,dafault_charges_rate	= @p_dafault_charges_rate
				,dafault_charges_amount = @p_dafault_charges_amount
				,calculate_by			= @p_calculate_by
				,charges_rate			= @p_charges_rate
				,charges_amount			= @p_charges_amount
				,new_calculate_by		= case when isnull(@p_new_calculate_by, '') = '' then @p_calculate_by else @p_new_calculate_by end
				,new_charges_rate		= case when @p_new_charges_rate is null then @p_charges_rate else @p_new_charges_rate end
				,new_charges_amount		= case when @p_new_charges_amount is null then @p_charges_amount else @p_new_charges_amount end
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id
				and main_contract_no		= @p_main_contract_no ;
		
		update	dbo.application_extention
		set		is_valid					= '0'
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	main_contract_no			= @p_main_contract_no
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

