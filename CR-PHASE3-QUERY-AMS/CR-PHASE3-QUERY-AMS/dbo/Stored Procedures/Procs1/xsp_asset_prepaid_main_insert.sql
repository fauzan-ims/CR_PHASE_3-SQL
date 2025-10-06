CREATE PROCEDURE dbo.xsp_asset_prepaid_main_insert
(
	@p_prepaid_no					nvarchar(50)	output
	,@p_fa_code						nvarchar(50)
	,@p_prepaid_date				datetime
	,@p_prepaid_remark				nvarchar(4000)
	,@p_prepaid_type				nvarchar(15)
	,@p_monthly_amount				decimal(18,2)
	,@p_total_prepaid_amount		decimal(18,2)
	,@p_total_accrue_amount			decimal(18,2)
	,@p_last_accue_period			nvarchar(6)
	,@p_reff_no						NVARCHAR(50)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 
			,@year				nvarchar(4)
			,@month				nvarchar(4)

	begin try

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @p_prepaid_no output
												,@p_branch_code			 = ''
												,@p_sys_document_code	 = ''
												,@p_custom_prefix		 = 'APM'
												,@p_year				 = @year
												,@p_month				 = @month
												,@p_table_name			 = 'ASSET_PREPAID_MAIN'
												,@p_run_number_length	 = 5
												,@p_delimiter			= '.'
												,@p_run_number_only		 = '0' ;

	insert into dbo.asset_prepaid_main
	(
		prepaid_no
		,fa_code
		,prepaid_date
		,prepaid_remark
		,prepaid_type
		,monthly_amount
		,total_prepaid_amount
		,total_accrue_amount
		,last_accue_period
		,reff_no
		--
		,cre_date
		,cre_by
		,cre_ip_address
		,mod_date
		,mod_by
		,mod_ip_address
	)
	values
	(
		@p_prepaid_no
		,@p_fa_code
		,@p_prepaid_date
		,@p_prepaid_remark
		,@p_prepaid_type
		,@p_monthly_amount
		,@p_total_prepaid_amount
		,@p_total_accrue_amount
		,@p_last_accue_period
		,@p_reff_no
		--
		,@p_cre_date
		,@p_cre_by
		,@p_cre_ip_address
		,@p_mod_date
		,@p_mod_by
		,@p_mod_ip_address
	)

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
end
