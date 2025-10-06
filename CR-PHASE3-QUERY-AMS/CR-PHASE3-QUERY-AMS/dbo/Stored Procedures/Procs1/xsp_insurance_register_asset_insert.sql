CREATE PROCEDURE [dbo].[xsp_insurance_register_asset_insert]
(
	@p_code						 NVARCHAR(50) OUTPUT
	,@p_register_code			 NVARCHAR(50)
	,@p_fa_code					 NVARCHAR(50)
	,@p_sum_insured_amount		 DECIMAL(18, 2)
	,@p_depreciation_code		 NVARCHAR(50)
	,@p_collateral_type			 NVARCHAR(10)
	,@p_collateral_category_code NVARCHAR(50)
	,@p_occupation_code			 NVARCHAR(50)	= ''
	,@p_region_code				 NVARCHAR(50)	= ''
	,@p_collateral_year			 NVARCHAR(4)	= ''
	,@p_is_authorized_workshop	 NVARCHAR(1)
	,@p_is_commercial			 NVARCHAR(1)
	,@p_insert_type				 NVARCHAR(20)	= ''
	--,@p_is_budget				 nvarchar(1)	= ''
	,@p_is_manual				 NVARCHAR(1)	= ''
	--
	,@p_cre_date				 DATETIME
	,@p_cre_by					 NVARCHAR(15)
	,@p_cre_ip_address			 NVARCHAR(15)
	,@p_mod_date				 DATETIME
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg						  nvarchar(max)
			,@year						  nvarchar(4)
			,@month						  nvarchar(2)
			,@code						  nvarchar(50)
			,@accessories				  nvarchar(4000)
			,@insurance_type			  nvarchar(50)
			,@depre_code				  nvarchar(50)
			,@agreement_no				  nvarchar(50)
			,@is_budget					  nvarchar(1)
			,@is_budget_register		  nvarchar(1)
			,@main_coverage_code		  nvarchar(50)
			,@tpl_coverage_code			  nvarchar(50)
			,@pll_coverage_code			  nvarchar(50)
			,@is_use_pa_passanger		  nvarchar(1)
			,@is_use_pa_driver			  nvarchar(1)
			,@is_use_srcc				  nvarchar(1)
			,@is_use_ts					  nvarchar(1)
			,@is_use_flood				  nvarchar(1)
			,@is_use_earthquake			  nvarchar(1)
			,@is_commercial_use			  nvarchar(1)
			,@is_authorize_workshop		  nvarchar(1)
			,@is_tbod					  nvarchar(1)
			,@coverage_use_pa_passanger	  nvarchar(50)
			,@coverage_use_pa_driver	  nvarchar(50)
			,@coverage_use_srcc			  nvarchar(50)
			,@coverage_use_ts			  nvarchar(50)
			,@coverage_use_flood		  nvarchar(50)
			,@coverage_use_earthquake	  nvarchar(50)
			,@coverage_commercial_use	  nvarchar(50)
			,@coverage_authorize_workshop nvarchar(50)
			,@coverage_tbod				  nvarchar(50)
			,@coverage_periode			  nvarchar(4000) = N''
			,@coverage_asset			  nvarchar(4000) = N'' ;

	if @p_is_authorized_workshop = 'T'
		set @p_is_authorized_workshop = '1' ;
	else
		set @p_is_authorized_workshop = '0' ;

	if @p_is_commercial = 'T'
		set @p_is_commercial = '1' ;
	else
		set @p_is_commercial = '0' ;

	begin TRY
    
		IF EXISTS
		(
			SELECT 1
			FROM SALE_DETAIL sd
				INNER JOIN dbo.ASSET ass
					ON (ass.CODE = sd.ASSET_CODE)
				INNER JOIN dbo.ASSET_VEHICLE av
					ON (av.ASSET_CODE = ass.CODE)
			WHERE STATUS NOT IN ( 'CANCEL', 'REJECT' ) AND av.ASSET_CODE = @p_fa_code
		)
		BEGIN
			--SELECT 'Asset Is In Sales Request Process, For Plat No: '+@p_fa_code
			set @msg = 'Asset Is In Sale Request Process, For Asset Code: '+@p_fa_code
			raiserror(@msg, 16, -1)
		END


		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		select @insurance_type = insurance_type 
		from dbo.insurance_register
		where code = @p_register_code

		--select @depre_code = depreciation_code 
		--from dbo.insurance_register_asset
		--where register_code = @p_register_code

		--if(@p_depreciation_code <> @depre_code)
		--begin
		--	set @msg = 'Please choose the same depreciation.' ;
		--	raiserror(@msg, 16, -1) ;
		--end


		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
													,@p_branch_code			 = 'DSF'
													,@p_sys_document_code	 = ''
													,@p_custom_prefix		 = 'IRA'
													,@p_year				 = @year
													,@p_month				 = @month
													,@p_table_name			 = 'INSURANCE_REGISTER_ASSET'
													,@p_run_number_length	 = 5
													,@p_delimiter			 = '.'
													,@p_run_number_only		 = '0' ;

		select @accessories =	stuff((
				  select	distinct ', ' + adjd.adjustment_description + ', Amount : ' + format (adjd.amount, '#,###.00', 'DE-de') + char(10)
				  from		dbo.adjustment adj
							left join dbo.adjustment_detail adjd on (adj.code = adjd.adjustment_code)
				  where		adj.asset_code = @p_fa_code
				  for xml path('')
			  ), 1, 1, ''
			 ) ;

		select	@agreement_no = agreement_external_no
		from	dbo.asset
		where	code = @p_fa_code ;

		if exists
		(
			select	1
			from	dbo.asset_insurance
			where	asset_code				  = @p_fa_code
					and agreement_external_no = @agreement_no
		)
		begin
			set @is_budget = N'1' ;
		end ;
		else
		begin
			set @is_budget = N'0' ;
		end ;

		if(@p_is_manual <> '')
		begin
			select	@is_budget_register = is_budget
			from	dbo.insurance_register_asset
			where	register_code = @p_register_code ;


			if(@is_budget_register is not null)
			begin
				if (@is_budget_register <> @is_budget)
				begin
					set @msg = N'This asset has different budget insurance setting.' ;

					raiserror(@msg, 16, -1) ;
				end
				else
				begin
					create table #coverage
					(
						main_coverage			nvarchar(50)
					)

					select	@main_coverage_code		= isnull(air.main_coverage_code, '')
							,@tpl_coverage_code		= isnull(air.tpl_coverage_code, '')
							,@pll_coverage_code		= isnull(air.pll_coverage_code, '')
							,@is_use_pa_passanger	= air.is_use_pa_passenger
							,@is_use_pa_driver		= air.is_use_pa_driver
							,@is_use_srcc			= air.is_use_srcc
							,@is_use_ts				= air.is_use_ts
							,@is_use_flood			= air.is_use_flood
							,@is_use_earthquake		= air.is_use_earthquake
							,@is_commercial_use		= air.is_commercial_use
							,@is_authorize_workshop = air.is_authorize_workshop
							,@is_tbod				= air.is_tbod
					from	dbo.asset_insurance					  air
							inner join ifinopl.dbo.agreement_main am on air.agreement_external_no = am.agreement_external_no
					where	asset_code					  = @p_fa_code
							and air.agreement_external_no = @agreement_no ;


					if (@main_coverage_code <> '')
					begin
						insert into #coverage
						(
							main_coverage
						)
						select	main_coverage_code
						from	dbo.asset_insurance
						where	asset_code = @p_fa_code ;
					end ;

					if (@tpl_coverage_code <> '')
					begin
						insert into #coverage
						(
							main_coverage
						)
						select	tpl_coverage_code
						from	dbo.asset_insurance
						where	asset_code = @p_fa_code ;
					end ;

					if (@pll_coverage_code <> '')
					begin
						insert into #coverage
						(
							main_coverage
						)
						select	pll_coverage_code
						from	dbo.asset_insurance
						where	asset_code = @p_fa_code ;
					end ;

					if (@is_use_pa_passanger = '1')
					begin
						insert into #coverage
						(
							main_coverage
						)
						values
						(
							'PAFP'
						)
					end ;

					if (@is_use_pa_driver = '1')
					begin
						insert into #coverage
						(
							main_coverage
						)
						values
						(
							'PAFD'
						)
					end ;

					if (@is_use_srcc = '1')
					begin
						insert into #coverage
						(
							main_coverage
						)
						values
						(
							'SRCC'
						)
					end ;

					if (@is_use_ts = '1')
					begin
						insert into #coverage
						(
							main_coverage
						)
						values
						(
							'TRRSBT'
						)
					end ;

					if (@is_use_flood = '1')
					begin
						insert into #coverage
						(
							main_coverage
						)
						values
						(
							'FLWINS'
						)
					end ;

					if (@is_use_earthquake = '1')
					begin
						insert into #coverage
						(
							main_coverage
						)
						values
						(
							'ERQTSN'
						)
					end ;

					if (@is_commercial_use = '1')
					begin
						insert into #coverage
						(
							main_coverage
						)
						values
						(
							'RNTLUS'
						)
					end ;

					if (@is_authorize_workshop = '1')
					begin
						insert into #coverage
						(
							main_coverage
						)
						values
						(
							'AUTHWOR'
						)
					end ;

					if (@is_tbod = '1')
					begin
						insert into #coverage
						(
							main_coverage
						)
						values
						(
							'TBOD'
						)
					end ;

					select	@coverage_asset = isnull(stuff((
						  select	distinct
									' ' + main_coverage
						  from		#coverage
						  for xml path('')
					  ), 1, 1, ''
					 ) ,'')
			
					select	@coverage_periode = isnull(stuff((
						  select	distinct
									' ' + coverage_code
						  from		dbo.insurance_register_period	  irp
									inner join dbo.insurance_register ir on ir.code = irp.register_code
						  where		irp.register_code = @p_register_code
						  for xml path('')
					  ), 1, 1, ''
					 ) ,'')
				    
					if(@coverage_asset <> @coverage_periode)
					begin
						set @msg = N'This asset have different budget insurance setting.' ;

						raiserror(@msg, 16, -1) ;
					end
				end
			end
		end

		insert into insurance_register_asset
		(
			code
			,register_code
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
			,accessories
			,insert_type
			,is_budget
			,is_manual
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
			,@p_register_code
			,@p_fa_code
			,@p_sum_insured_amount
			,@p_depreciation_code
			,@p_collateral_type
			,@p_collateral_category_code
			,@p_occupation_code
			,@p_region_code
			,@p_collateral_year
			,@p_is_authorized_workshop
			,@p_is_commercial
			,@accessories
			,@p_insert_type
			,@is_budget
			,@p_is_manual
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)set @p_code = @code ;
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
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
