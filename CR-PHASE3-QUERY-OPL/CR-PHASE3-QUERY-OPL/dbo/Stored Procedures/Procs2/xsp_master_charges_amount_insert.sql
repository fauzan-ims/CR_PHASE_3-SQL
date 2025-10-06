---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_charges_amount_insert
(
	@p_code				 nvarchar(50)	output
	,@p_charge_code		 nvarchar(50)
	,@p_effective_date	 datetime
	,@p_facility_code	 nvarchar(50)
	,@p_currency_code	 nvarchar(3)
	,@p_calculate_by	 nvarchar(10)
	,@p_charges_rate	 decimal(9, 6)	= 0
	,@p_charges_amount	 decimal(18, 2) = 0
	,@p_fn_default_name	 nvarchar(250) = null
	,@p_is_fn_override	 nvarchar(1)
	,@p_fn_override_name nvarchar(250) = null
	--
	,@p_cre_date		 datetime
	,@p_cre_by			 nvarchar(15)
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'MCA'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'MASTER_CHARGES_AMOUNT'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	if @p_is_fn_override = 'T'
		set @p_is_fn_override = '1' ;
	else
		set @p_is_fn_override = '0' ;

	begin try
		if exists
		(
			select	1
			from	master_charges_amount
			where	charge_code						 = @p_charge_code
					and facility_code				 = @p_facility_code
					and currency_code				 = @p_currency_code
					and cast(effective_date as date) = cast(@p_effective_date as date)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (cast(@p_effective_date as date) < dbo.xfn_get_system_date())
		begin
			set @msg = 'Effective Date cannot be less than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		insert into master_charges_amount
		(
			code
			,charge_code
			,effective_date
			,facility_code
			,currency_code
			,calculate_by
			,charges_rate
			,charges_amount
			,fn_default_name
			,is_fn_override
			,fn_override_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_charge_code
			,@p_effective_date
			,@p_facility_code
			,@p_currency_code
			,@p_calculate_by
			,@p_charges_rate
			,@p_charges_amount
			,lower(@p_fn_default_name)
			,@p_is_fn_override
			,lower(@p_fn_override_name)
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @code ;
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

