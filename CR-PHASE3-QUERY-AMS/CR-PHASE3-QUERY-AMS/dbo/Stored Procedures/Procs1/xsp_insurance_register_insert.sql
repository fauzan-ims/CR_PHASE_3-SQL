CREATE PROCEDURE [dbo].[xsp_insurance_register_insert]
(
	@p_code							nvarchar(50)  output
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_source_type					nvarchar(20)
	,@p_register_status				nvarchar(10)
	,@p_register_name				nvarchar(250) = ''
	,@p_register_qq_name			nvarchar(250)
	,@p_register_object_name		nvarchar(250) = ''
	,@p_register_remarks			nvarchar(4000)
	,@p_currency_code				nvarchar(3)
	,@p_insurance_code				nvarchar(50)
	,@p_insurance_type				nvarchar(50)
	,@p_collateral_type				nvarchar(10)  = null
	,@p_occupation_code				nvarchar(50)  = null
	,@p_eff_rate					decimal(9, 6) = null
	,@p_year_period					int
	,@p_is_renual					nvarchar(1)   = '0'
	,@p_from_date					datetime
	,@p_insurance_payment_type		nvarchar(10)  = ''
	,@p_insurance_paid_by			nvarchar(10)
	,@p_is_authorized_workshop		nvarchar(1)
	,@p_is_commercial				nvarchar(1)
	,@p_register_type				nvarchar(10)
	,@p_policy_code					nvarchar(50)	= null
	,@p_flag_date					datetime		= null
	,@p_budget_status				nvarchar(4)		= ''
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
	declare @msg									nvarchar(max)
			,@year									nvarchar(2)
			,@month									nvarchar(2)
			,@register_no							nvarchar(50)
			,@to_date								datetime
			,@coverage_code							nvarchar(50)
			,@year_periode							int
			,@fa_code								nvarchar(50)
			,@sum_insured_amount					decimal(18,2)
			,@depreciation_code						nvarchar(50)
			,@collateral_type						nvarchar(50)
			,@collateral_category_code				nvarchar(50)
			,@occupation_code						nvarchar(50)
			,@region_code							nvarchar(50)
			,@collateral_year						nvarchar(4)
			,@is_authorized_workshop				nvarchar(1)
			,@is_commercial							nvarchar(1)
			,@code_policy_asset						nvarchar(50)
			,@fa_code_policy_asset					nvarchar(50)
			,@sum_insured_amount_policy_asset		decimal(18,2)			
			,@depreciation_code_policy_asset		nvarchar(50)
			,@collateral_type_policy_asset			nvarchar(50)
			,@collateral_category_code_policy_asset	nvarchar(50)
			,@occupation_code_policy_asset			nvarchar(50)
			,@region_code_policy_asset				nvarchar(50)
			,@collateral_year_policy_asset			nvarchar(4)
			,@is_authorized_workshop_policy_asset	nvarchar(1)
			,@is_commercial_policy_asset			nvarchar(1)
			,@status_asset_policy_asset				nvarchar(1)
			,@sppa_code_policy_asset				nvarchar(50)
			,@invoice_code_policy_asset				nvarchar(50)

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code				= @register_no output -- nvarchar(50)
													,@p_branch_code				= @p_branch_code
													,@p_sys_document_code		= N'AMSRGS' -- nvarchar(10)
													,@p_custom_prefix			= N'' -- nvarchar(10)
													,@p_year					= @year -- nvarchar(2)
													,@p_month					= @month -- nvarchar(2)
													,@p_table_name				= N'INSURANCE_REGISTER' -- nvarchar(100)
													,@p_run_number_length		= 6 -- int
													,@p_delimiter				= N'.' -- nvarchar(1)
													,@p_run_number_only			= N'0' -- nvarchar(1)
													,@p_specified_column		= 'REGISTER_NO' ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code				= @p_code output
													,@p_branch_code				= @p_branch_code
													,@p_sys_document_code		= N''
													,@p_custom_prefix			= 'AMSIR'
													,@p_year					= @year
													,@p_month					= @month
													,@p_table_name				= 'INSURANCE_REGISTER'
													,@p_run_number_length		= 6
													,@p_delimiter				= '.'
													,@p_run_number_only			= N'0' ;
		
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
			set @to_date = dateadd(month, @p_year_period, @p_from_date) ;

		if @p_insurance_type = 'LIFE'
		begin
			set @p_insurance_payment_type = 'FTFP' ;
			set @p_source_type = 'AGREEMENT' ;
		end ;
		else if @p_insurance_type = 'CREDIT'
		begin
			set @p_insurance_payment_type = 'FTFP' ;
		end ;

		if @p_collateral_type = 'PROP'
		begin
			set @p_insurance_payment_type = 'FTFP' ;
		end ; 

		--if (
		--	   @p_collateral_type <> 'VHCL'
		--	   and	@p_occupation_code = ''
		--	   or	@p_occupation_code = null
		--   )
		--begin
		--	set @msg = 'Please input Occupation' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;

		--if exists
		--(
		--	select	1
		--	from	dbo.insurance_register
		--	where	fa_code = @p_fa_code
		--			and register_status not in
		--(
		--	'CANCEL', 'PAID'
		--)
		--)
		--begin 
		--	set @msg = 'Asset already On Process Policy Register' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;

		insert into dbo.insurance_register
		(
			code
			,register_no
			,branch_code
			,branch_name
			,source_type
			,register_type
			,register_status
			,register_name
			,register_qq_name
			,register_object_name
			,register_remarks
			,currency_code
			,insurance_code
			,insurance_type
			,eff_rate
			,year_period
			,is_renual
			,from_date
			,to_date
			,insurance_payment_type
			,insurance_paid_by
			,policy_code
			,flag_date
			,budget_status
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@register_no
			,@p_branch_code
			,@p_branch_name
			,@p_source_type
			,@p_register_type
			,@p_register_status
			,@p_register_name
			,upper(@p_register_qq_name)
			,@p_register_object_name
			,@p_register_remarks
			,@p_currency_code
			,@p_insurance_code
			,@p_insurance_type
			,@p_eff_rate
			,@p_year_period
			,@p_is_renual
			,@p_from_date
			,@to_date
			,@p_insurance_payment_type
			,@p_insurance_paid_by
			,@p_policy_code
			,@p_flag_date
			,@p_budget_status
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) 

		if(@p_register_type = 'ADDITIONAL')
		begin

			declare curr_add_aset cursor fast_forward read_only for
			select code
				  ,fa_code
				  ,sum_insured_amount
				  ,depreciation_code
				  ,collateral_type
				  ,collateral_category_code
				  ,occupation_code
				  ,region_code
				  ,collateral_year
				  ,is_authorized_workshop
				  ,is_commercial
				  ,status_asset
				  ,sppa_code
				  ,invoice_code
			from dbo.insurance_policy_asset
			where policy_code = @p_policy_code
			
			open curr_add_aset
			
			fetch next from curr_add_aset 
			into @code_policy_asset
				,@fa_code_policy_asset
				,@sum_insured_amount_policy_asset
				,@depreciation_code_policy_asset
				,@collateral_type_policy_asset
				,@collateral_category_code_policy_asset
				,@occupation_code_policy_asset
				,@region_code_policy_asset
				,@collateral_year_policy_asset
				,@is_authorized_workshop_policy_asset
				,@is_commercial_policy_asset
				,@status_asset_policy_asset
				,@sppa_code_policy_asset
				,@invoice_code_policy_asset
			
			while @@fetch_status = 0
			begin

				exec dbo.xsp_insurance_register_asset_insert @p_code						= 0
															 ,@p_register_code				= @p_code
															 ,@p_fa_code					= @fa_code_policy_asset
															 ,@p_sum_insured_amount			= @sum_insured_amount_policy_asset
															 ,@p_depreciation_code			= @depreciation_code_policy_asset
															 ,@p_collateral_type			= @collateral_type_policy_asset
															 ,@p_collateral_category_code	= @collateral_category_code_policy_asset
															 ,@p_occupation_code			= @occupation_code_policy_asset
															 ,@p_region_code				= @region_code_policy_asset
															 ,@p_collateral_year			= @collateral_year_policy_asset
															 ,@p_is_authorized_workshop		= @is_authorized_workshop_policy_asset
															 ,@p_is_commercial				= @is_commercial_policy_asset
															 ,@p_insert_type				= 'EXISTING'
															 ,@p_cre_date					= @p_cre_date
															 ,@p_cre_by						= @p_cre_by
															 ,@p_cre_ip_address				= @p_cre_ip_address
															 ,@p_mod_date					= @p_mod_date
															 ,@p_mod_by						= @p_mod_by
															 ,@p_mod_ip_address				= @p_mod_ip_address
			
			    fetch next from curr_add_aset 
				into @code_policy_asset
					,@fa_code_policy_asset
					,@sum_insured_amount_policy_asset
					,@depreciation_code_policy_asset
					,@collateral_type_policy_asset
					,@collateral_category_code_policy_asset
					,@occupation_code_policy_asset
					,@region_code_policy_asset
					,@collateral_year_policy_asset
					,@is_authorized_workshop_policy_asset
					,@is_commercial_policy_asset
					,@status_asset_policy_asset
					,@sppa_code_policy_asset
					,@invoice_code_policy_asset
			end
			
			close curr_add_aset
			deallocate curr_add_aset

			declare cursor_name cursor fast_forward read_only for
			--select	distinct
			--		irp.coverage_code
			--		,irp.year_periode
			--from dbo.insurance_register ir
			--inner join dbo.insurance_register_period irp on (ir.code = irp.register_code)
			--inner join dbo.sppa_request sr on (ir.code = sr.register_code)
			--inner join dbo.sppa_detail sd on (sd.sppa_request_code = sr.code)
			--inner join dbo.insurance_policy_main ipm on (ipm.sppa_code = sd.sppa_code)
			--where ipm.code = @p_policy_code

			select distinct
					coverage_code
					,year_periode 
			from dbo.insurance_policy_main_period
			where policy_code = @p_policy_code

			open cursor_name
			
			fetch next from cursor_name 
			into @coverage_code
				,@year_periode
			
			while @@fetch_status = 0
			begin
				
			    exec dbo.xsp_insurance_register_period_insert @p_id						= 0
															 ,@p_register_code			= @p_code
															 ,@p_coverage_code			= @coverage_code
															 ,@p_year_periode			= @year_periode
															 ,@p_cre_date				= @p_cre_date
															 ,@p_cre_by					= @p_cre_by
															 ,@p_cre_ip_address			= @p_cre_ip_address
															 ,@p_mod_date				= @p_mod_date
															 ,@p_mod_by					= @p_mod_by
															 ,@p_mod_ip_address			= @p_mod_ip_address
			
			    fetch next from cursor_name 
				into @coverage_code
					,@year_periode
			end
			
			close cursor_name
			deallocate cursor_name
			
		end
		else if (@p_register_type = 'PERIOD')
		begin
			declare curr_add_peiod cursor fast_forward read_only for
			select	ipa.fa_code
					,ipa.sum_insured_amount
					,ipa.depreciation_code
					,ipa.collateral_type
					,ipa.collateral_category_code
					,ipa.occupation_code
					,ipa.region_code
					,ipa.collateral_year
					,ipa.is_authorized_workshop
					,ipa.is_commercial
			from dbo.insurance_register ir
			inner join dbo.insurance_policy_main ipm on (ipm.code = ir.policy_code)
			inner join dbo.insurance_policy_asset ipa on (ipa.policy_code = ipm.code)
			where ir.code = @p_code
			
			open curr_add_peiod
			
			fetch next from curr_add_peiod 
			into @fa_code
				,@sum_insured_amount
				,@depreciation_code
				,@collateral_type
				,@collateral_category_code
				,@occupation_code
				,@region_code
				,@collateral_year
				,@is_authorized_workshop
				,@is_commercial
			
			while @@fetch_status = 0
			begin
			    exec dbo.xsp_insurance_register_asset_insert @p_code						= 0
			    											 ,@p_register_code				= @p_code
			    											 ,@p_fa_code					= @fa_code
			    											 ,@p_sum_insured_amount			= @sum_insured_amount
			    											 ,@p_depreciation_code			= @depreciation_code
			    											 ,@p_collateral_type			= @collateral_type
			    											 ,@p_collateral_category_code	= @collateral_category_code
			    											 ,@p_occupation_code			= @occupation_code
			    											 ,@p_region_code				= @region_code
			    											 ,@p_collateral_year			= @collateral_year
			    											 ,@p_is_authorized_workshop		= @is_authorized_workshop
			    											 ,@p_is_commercial				= @is_commercial
															 ,@p_insert_type				= 'EXISTING'
			    											 ,@p_cre_date					= @p_cre_date
			    											 ,@p_cre_by						= @p_cre_by
			    											 ,@p_cre_ip_address				= @p_cre_ip_address
			    											 ,@p_mod_date					= @p_mod_date
			    											 ,@p_mod_by						= @p_mod_by
			    											 ,@p_mod_ip_address				= @p_mod_ip_address
			    
			
			    fetch next from curr_add_peiod 
				into @fa_code
					,@sum_insured_amount
					,@depreciation_code
					,@collateral_type
					,@collateral_category_code
					,@occupation_code
					,@region_code
					,@collateral_year
					,@is_authorized_workshop
					,@is_commercial
			end
			
			close curr_add_peiod
			deallocate curr_add_peiod
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

