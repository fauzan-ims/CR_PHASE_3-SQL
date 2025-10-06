CREATE PROCEDURE [dbo].[xsp_register_main_insert]
(
	@p_code						 nvarchar(50) output
	,@p_branch_code				 nvarchar(50)
	,@p_branch_name				 nvarchar(250)
	,@p_register_date			 datetime
	,@p_register_status			 nvarchar(10)
	,@p_register_process_by		 nvarchar(50)	= ''
	,@p_service_code			 nvarchar(50)	= ''
	,@p_register_remarks		 nvarchar(4000) = ''
	,@p_fa_code					 nvarchar(50)
	,@p_stnk_no					 nvarchar(50)	= null
	,@p_stnk_tax_date			 datetime		= null
	,@p_stnk_expired_date		 datetime		= null
	,@p_keur_no					 nvarchar(50)	= null
	,@p_keur_date				 datetime		= null
	,@p_keur_expired_date		 datetime		= null
	,@p_is_reimburse			 nvarchar(1)
	,@p_is_reimburse_to_customer nvarchar(1)	= ''
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg		  nvarchar(max)
			,@year		  nvarchar(4)
			,@month		  nvarchar(4)
			,@register_no nvarchar(50)
			,@code		  nvarchar(50)
			,@client_name nvarchar(250) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'RMN'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'REGISTER_MAIN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @register_no output	-- nvarchar(50)
												,@p_branch_code = @p_branch_code		-- nvarchar(10)
												,@p_sys_document_code = N'RMN'			-- nvarchar(10)
												,@p_custom_prefix = N''					-- nvarchar(10)
												,@p_year = @year						-- nvarchar(2)
												,@p_month = @month						-- nvarchar(2)
												,@p_table_name = N'REGISTER_MAIN'		-- nvarchar(100)
												,@p_run_number_length = 6				-- int
												,@p_delimiter = N'.'					-- nvarchar(1)
												,@p_run_number_only = N'0'				-- nvarchar(1)
												,@p_specified_column = 'register_no' ;

	begin try
		if @p_is_reimburse = 'T'
			set @p_is_reimburse = '1' ;
		else
			set @p_is_reimburse = '0' ;

		if @p_is_reimburse_to_customer = 'T'
			set @p_is_reimburse_to_customer = '1' ;
		else
			set @p_is_reimburse_to_customer = '0' ;

		if (cast(@p_register_date as date) > dbo.xfn_get_system_date())
		begin
			set @msg = N'Register Date must be less or equal than System Date' ;

			raiserror(@msg, 16, 1) ;
		end ;

		select	@client_name = isnull(client_name, '')
		from	dbo.asset
		where	code = @p_fa_code ;

		if (
			   @client_name = ''
			   and	@p_is_reimburse = '1'
		   )
		begin
			set @msg = N'Cannot disburse this asset to customer.' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if (
			   @client_name = ''
			   and	@p_is_reimburse_to_customer = '1'
		   )
		begin
			set @msg = N'Cannot reimburse this asset to customer.' ;

			raiserror(@msg, 16, 1) ;
		end ;

		insert into register_main
		(
			code
			,branch_code
			,branch_name
			,register_no
			,register_date
			,register_status
			,register_process_by
			,register_remarks
			,fa_code
			,realization_invoice_no
			,realization_internal_income
			,realization_actual_fee
			,realization_service_fee
			,public_service_settlement_amount
			,stnk_no
			,stnk_tax_date
			,stnk_expired_date
			,keur_no
			,keur_date
			,keur_expired_date
			,is_reimburse
			,is_reimburse_to_customer
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
			@code
			,@p_branch_code
			,@p_branch_name
			,@register_no
			,@p_register_date
			,@p_register_status
			,@p_register_process_by
			,@p_register_remarks
			,@p_fa_code
			,''
			,0
			,0
			,0
			,0
			,@p_stnk_no
			,@p_stnk_tax_date
			,@p_stnk_expired_date
			,@p_keur_no
			,@p_keur_date
			,@p_keur_expired_date
			,@p_is_reimburse
			,@p_is_reimburse_to_customer
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @code ;

		if (isnull(@p_service_code, '') <> '')
		begin
			exec dbo.xsp_register_detail_insert @p_id = 0
												,@p_register_code = @code
												,@p_service_code = @p_service_code
												,@p_cre_date = @p_cre_date
												,@p_cre_by = @p_cre_by
												,@p_cre_ip_address = @p_cre_ip_address
												,@p_mod_date = @p_mod_date
												,@p_mod_by = @p_mod_by
												,@p_mod_ip_address = @p_mod_ip_address ;
		end ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
