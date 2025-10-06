CREATE PROCEDURE dbo.xsp_insurance_register_update
(
	@p_code						 nvarchar(50)
	,@p_register_no				 nvarchar(50)
	,@p_branch_code				 nvarchar(50)
	,@p_branch_name				 nvarchar(250)
	,@p_register_status			 nvarchar(10)
	,@p_register_name			 nvarchar(250)	= ''
	,@p_register_qq_name		 nvarchar(250)
	,@p_register_object_name	 nvarchar(250)	= ''
	,@p_register_remarks		 nvarchar(4000)
	,@p_currency_code			 nvarchar(3)
	,@p_insurance_code			 nvarchar(50)
	,@p_insurance_type			 nvarchar(50)
	,@p_eff_rate				 decimal(9, 6)  = null
	,@p_year_period				 INT            = null
	,@p_is_renual				 nvarchar(1)
	,@p_from_date				 datetime 
	--,@p_to_date					 datetime 
	,@p_insurance_payment_type	 nvarchar(10) = ''
	,@p_insurance_paid_by		 nvarchar(10) = 'MF'
	,@p_is_authorized_workshop	 nvarchar(1)
	,@p_is_commercial			 nvarchar(1)
	,@p_policy_code				 nvarchar(50) = null
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@to_date    datetime ;

	if @p_is_renual = 'T'
		set @p_is_renual = '1' ;
	else
		set @p_is_renual = '0' ;

	if @p_is_commercial = 'T'
		set @p_is_commercial = '1' ;
	else
		set @p_is_commercial = '0' ;

	if @p_is_authorized_workshop = 'T'
		set @p_is_authorized_workshop = '1' ;
	else
		set @p_is_authorized_workshop = '0' ;

	begin try
   --      if @p_insurance_type = 'LIFE'
		 --begin
			--set @p_source_type            = 'AGREEMENT'
		 --end

		if (@p_year_period = 0)
		begin
        	set @msg = 'Year (Month) must be greater than 0';
			raiserror(@msg, 16, -1) ;
		end
		
		SET @to_date = DATEADD(MONTH, @p_year_period, @p_from_date) 

		--jika ada data di tab period
		if exists(select 1 from dbo.insurance_register_period
		where register_code = @p_code)
		begin
			update	insurance_register
			set		register_no					= @p_register_no
					,branch_code				= @p_branch_code
					,branch_name				= @p_branch_name
					--,source_type				= @p_source_type
					,register_status			= @p_register_status
					,register_name				= @p_register_name
					,register_qq_name			= UPPER(@p_register_qq_name)
					,register_object_name		= @p_register_object_name
					,register_remarks			= @p_register_remarks
					,currency_code				= @p_currency_code
					,insurance_code				= @p_insurance_code
					,insurance_type				= @p_insurance_type
					,eff_rate					= @p_eff_rate
					,year_period				= @p_year_period
					,is_renual					= @p_is_renual
					,from_date					= @p_from_date
					,to_date					= @to_date
					,insurance_paid_by			= @p_insurance_paid_by
					,policy_code				= @p_policy_code
					--
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	code						= @p_code ;
		end
		else
		begin
			update	insurance_register
			set		register_no					= @p_register_no
					,branch_code				= @p_branch_code
					,branch_name				= @p_branch_name
					--,source_type				= @p_source_type
					,register_status			= @p_register_status
					,register_name				= @p_register_name
					,register_qq_name			= UPPER(@p_register_qq_name)
					,register_object_name		= @p_register_object_name
					,register_remarks			= @p_register_remarks
					,currency_code				= @p_currency_code
					,insurance_code				= @p_insurance_code
					,insurance_type				= @p_insurance_type
					,eff_rate					= @p_eff_rate
					,year_period				= @p_year_period
					,is_renual					= @p_is_renual
					,from_date					= @p_from_date
					,to_date					= @to_date
					,insurance_paid_by			= @p_insurance_paid_by
					,insurance_payment_type		= @p_insurance_payment_type
					,policy_code				= @p_policy_code
					--
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	code						= @p_code ;
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

