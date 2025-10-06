/*
	Created : Arif 23-02-2023
*/

CREATE PROCEDURE [dbo].[xsp_monitoring_insurance_proceed]
(
	@p_code				nvarchar(50)
	,@p_flag_date		datetime	
	,@p_budget_status	nvarchar(3)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
declare @msg						  nvarchar(max)
		,@insurance_code			  nvarchar(50)
		,@fa_code					  nvarchar(50)
		,@branch_code				  nvarchar(50)
		,@branch_name				  nvarchar(250)
		,@register_date				  datetime
		,@register_code				  nvarchar(50)
		,@currency_code				  nvarchar(3)	= N''
		,@buildyear					  nvarchar(4)
		,@collateral_type			  nvarchar(50)
		,@insurate_name				  nvarchar(250)
		,@insurate_code				  nvarchar(50)
		,@insurate_type				  nvarchar(4)
		,@depreciation_code			  nvarchar(50)
		,@collateral_category_code	  nvarchar(250)
		,@occupation_code			  nvarchar(50)
		,@region_code				  nvarchar(50)
		,@from_date					  datetime
		,@insuredqq					  nvarchar(4)
		,@fa_name					  nvarchar(50)
		,@asset_type				  nvarchar(50)
		,@sum_insured				  decimal(18, 2)
		,@date						  datetime		= getdate()
		,@insurance_asset_code		  nvarchar(50)
		,@agreement_no				  nvarchar(50)
		,@status_asset				  nvarchar(50)
		,@main_coverage_code		  nvarchar(50)
		,@tpl_coverage_code			  nvarchar(50)
		,@pll_coverage_code			  nvarchar(50)
		,@periode					  int
		,@month						  int			= 0
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
		,@coverage_periode			  nvarchar(4000) = ''
		,@coverage_asset			  nvarchar(4000) = ''
		,@flaging_periode			  nvarchar(3) = 'YES'
		,@coverage_name				  nvarchar(250)
		,@purchase_price			  decimal(18,2)
		,@ppn_amount				  decimal(18,2)
		,@code_insurance_register	  nvarchar(50)
		,@platno					  NVARCHAR(15)

	begin try
		--- cek data apakah ada data dengan status PAID or CANCEL di tabel insurance_register
		--if exists
		--(
		--	select	1
		--	from	dbo.insurance_register
		--	where	fa_code = @p_code 
		--			and register_status not in
		--					(
		--						'PAID', 'CANCEL'
		--					)
		--)
		--begin
		--	set @msg = 'Data already Proceed' ; 
		--	raiserror(@msg, 16, -1) ;
		--end ;
		select	@platno = plat_no
		from	dbo.asset_vehicle 
		where	asset_code = @p_code

		if exists
		(
			select	1
			from	sale_detail sd
			inner join dbo.sale s
					on s.code	= sd.sale_code
			where	sd.asset_code	= @p_code
					and s.status not in ('CANCEL','REJECT')
		)
		begin
			set @msg = N'Asset Is In Sales Request Process, For Plat No: ' + @platno;

			raiserror(@msg, 16, -1);
		end;


		create table #coverage
		(
			main_coverage			nvarchar(50)
		)

		create table #coverage_existing
		(
			insurance_register_code	nvarchar(50)
			,main_coverage			nvarchar(4000)
		)

		-- select data yang tidak ada status PAID or CANCEL di tabel register_main 
		select	@fa_code			= ass.code
				,@branch_name		= 'JAKARTA HEAD OFFICE'--ass.branch_name
				,@branch_code		= '1000'--ass.branch_code branch polis tidak perlu mengikuti branch asset karena polis selalu di proses di HO (raffy) 2025/08/30
				,@fa_name			= ass.item_name
				,@asset_type		= ass.type_code
				--,@sum_insured		= ass.net_book_value_comm
				,@agreement_no		= ass.agreement_external_no
				,@status_asset		= ass.rental_status
				,@purchase_price	= ass.purchase_price
				,@ppn_amount		= isnull(ass.ppn_amount,0)
		from	dbo.asset ass
		where	ass.code = @p_code ;

		set @sum_insured = @purchase_price + @ppn_amount

		select	@periode				= am.periode / 12
				,@main_coverage_code	= isnull(air.main_coverage_code,'')
				,@tpl_coverage_code		= isnull(air.tpl_coverage_code,'')
				,@pll_coverage_code		= isnull(air.pll_coverage_code,'')
				,@month					= am.periode
				,@is_use_pa_passanger	= air.is_use_pa_passenger
				,@is_use_pa_driver		= air.is_use_pa_driver
				,@is_use_srcc			= air.is_use_srcc
				,@is_use_ts				= air.is_use_ts
				,@is_use_flood			= air.is_use_flood
				,@is_use_earthquake		= air.is_use_earthquake
				,@is_commercial_use		= air.is_commercial_use
				,@is_authorize_workshop	= air.is_authorize_workshop
				,@is_tbod				= air.is_tbod
		from dbo.asset_insurance air
		inner join ifinopl.dbo.agreement_main am on air.agreement_external_no = am.agreement_external_no
		where asset_code = @p_code
		and air.agreement_external_no = @agreement_no

		--if not exists
		--(
		--	select	1
		--	from	dbo.master_coverage
		--	where	is_active	 = '1'
		--			and
		--			(
		--				code	 = @main_coverage_code
		--				or	code = @tpl_coverage_code
		--				or	CODE = @pll_coverage_code
		--				or	CODE = 'PAFP'
		--				or	CODE = 'PAFD'
		--				or	CODE = 'SRCC'
		--				or	CODE = 'TRRSBT'
		--				or	CODE = 'FLWINS'
		--				or	CODE = 'ERQTSN'
		--				or	CODE = 'RNTLUS'
		--				or	CODE = 'AUTHWOR'
		--				or	CODE = 'TBOD'
		--			)
		--)
		--begin
		--	set @msg = N'Please setting insurance coverage first.' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;

		if (@is_tbod = '1')
		begin
			if not exists
			(
				select	1
				from	dbo.master_coverage
				where	is_active	 = '1'
						and CODE = 'TBOD'
			)
			begin
				set @msg = N'Please setting insurance coverage THEFT OWN DRIVER first.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end

		if (@is_authorize_workshop = '1')
		begin
			if not exists
			(
				select	1
				from	dbo.master_coverage
				where	is_active	 = '1'
						and CODE = 'AUTHWOR'
			)
			begin
				set @msg = N'Please setting insurance coverage LOADING AUTHORIZED WORKSHOP first.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end


		if (@is_commercial_use = '1')
		begin
			if not exists
			(
				select	1
				from	dbo.master_coverage
				where	is_active	 = '1'
						and CODE = 'RNTLUS'
			)
			begin
				set @msg = N'Please setting insurance coverage LOADING RENTAL USAGE first.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end

		if (@is_use_earthquake = '1')
		begin
			if not exists
			(
				select	1
				from	dbo.master_coverage
				where	is_active	 = '1'
						and CODE = 'ERQTSN'
			)
			begin
				set @msg = N'Please setting insurance coverage EARTHQUAKE & TSUNAMI first.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end

		if (@is_use_flood = '1')
		begin
			if not exists
			(
				select	1
				from	dbo.master_coverage
				where	is_active	 = '1'
						and CODE = 'FLWINS'
			)
			begin
				set @msg = N'Please setting insurance coverage FLOOD & WINDSTROM first.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end

		if (@is_use_ts = '1')
		begin
			if not exists
			(
				select	1
				from	dbo.master_coverage
				where	is_active	 = '1'
						and CODE = 'TRRSBT'
			)
			begin
				set @msg = N'Please setting insurance coverage TERRORISM & SABOTAGE (T&S) first.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end

		if (@is_use_srcc = '1')
		begin
			if not exists
			(
				select	1
				from	dbo.master_coverage
				where	is_active	 = '1'
						and CODE = 'SRCC'
			)
			begin
				set @msg = N'Please setting insurance coverage STRIKE, RIOT, CIVIL COMMOTION (SRCC) first.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end

		if (@is_use_pa_driver = '1')
		begin
			if not exists
			(
				select	1
				from	dbo.master_coverage
				where	is_active	 = '1'
						and CODE = 'PAFD'
			)
			begin
				set @msg = N'Please setting insurance coverage PERSONAL ACCIDENT FOR DRIVER first.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end

		if (@is_use_pa_passanger = '1')
		begin
			if not exists
			(
				select	1
				from	dbo.master_coverage
				where	is_active	 = '1'
						and CODE = 'PAFP'
			)
			begin
				set @msg = N'Please setting insurance coverage PERSONAL ACCIDENT FOR PASSENGER (/SEAT) first.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end

		if (@pll_coverage_code <> '')
		begin
			if not exists
			(
				select	1
				from	dbo.master_coverage
				where	is_active	 = '1'
						and CODE = @pll_coverage_code
			)
			begin
				select	@coverage_name = coverage_name
				from	dbo.master_coverage
				where	code = @pll_coverage_code ;

				set @msg = N'Please setting insurance coverage ' + isnull(@coverage_name,'') + ' first.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end

		if (@tpl_coverage_code <> '')
		begin
			if not exists
			(
				select	1
				from	dbo.master_coverage
				where	is_active	 = '1'
						and CODE = @tpl_coverage_code
			)
			begin
				select	@coverage_name = coverage_name
				from	dbo.master_coverage
				where	code = @tpl_coverage_code ;

				set @msg = N'Please setting insurance coverage ' + isnull(@coverage_name,'') + ' first.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end

		if (@main_coverage_code <> '')
		begin
			if not exists
			(
				select	1
				from	dbo.master_coverage
				where	is_active	 = '1'
						and CODE = @main_coverage_code
			)
			begin
				select	@coverage_name = coverage_name
				from	dbo.master_coverage
				where	code = @main_coverage_code ;

				set @msg = N'Please setting insurance coverage ' + @coverage_name + ' first.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end

		if (@status_asset = 'IN USE')
		begin
			if not exists
			(
				select	1
				from	dbo.asset_insurance
				where	asset_code				  = @fa_code
						and agreement_external_no = @agreement_no
			)
			begin
				set @msg = N'This asset does not have budget insurance.' ;
				raiserror(@msg, 16, -1) ;
			end ;
		end ;
		
		if(@p_budget_status = 'NO')
		begin
			if not exists(select 1 from dbo.insurance_register where budget_status = @p_budget_status and register_status = 'HOLD') --and flag_date = @p_flag_date)
			begin
				exec dbo.xsp_insurance_register_insert @p_code						= @insurance_code output
													   ,@p_branch_code				= @branch_code
													   ,@p_branch_name				= @branch_name
													   ,@p_source_type				= 'ASSET'
													   ,@p_register_status			= 'HOLD'
													   ,@p_register_name			= ''
													   ,@p_register_qq_name			= 'PT DIPO STAR FINANCE'
													   ,@p_register_object_name		= ''
													   ,@p_register_remarks			= ''
													   ,@p_currency_code			= 'IDR'
													   ,@p_insurance_code			= ''
													   ,@p_insurance_type			= 'NON LIFE'
													   ,@p_collateral_type			= ''
													   ,@p_occupation_code			= ''
													   ,@p_eff_rate					= null
													   ,@p_year_period				= @month
													   ,@p_is_renual				= '0'
													   ,@p_from_date				= null
													   ,@p_insurance_payment_type	= 'FTFP'
													   ,@p_insurance_paid_by		= 'MF'
													   ,@p_is_authorized_workshop	= ''
													   ,@p_is_commercial			= ''
													   ,@p_register_type			= 'NEW'
													   ,@p_policy_code				= null
													   ,@p_flag_date				= @p_flag_date
													   ,@p_budget_status			= @p_budget_status
													   ,@p_cre_date					= @p_cre_date
													   ,@p_cre_by					= @p_cre_by
													   ,@p_cre_ip_address			= @p_cre_ip_address
													   ,@p_mod_date					= @p_mod_date
													   ,@p_mod_by					= @p_mod_by
													   ,@p_mod_ip_address			= @p_mod_ip_address
			end
			else
			begin
				select	@insurance_code = code
				from	dbo.insurance_register
				where	budget_status = @p_budget_status
				and register_status = 'HOLD'
						--and flag_date = @p_flag_date ;
			end
		end
		else
		begin
			--select	@main_coverage_code			  = main_coverage_code
			--		,@tpl_coverage_code			  = tpl_coverage_code
			--		,@pll_coverage_code			  = pll_coverage_code
			--		,@coverage_use_pa_passanger	  = case is_use_pa_passenger
			--											when '1' then 'PAFP'
			--											else null
			--										end
			--		,@coverage_use_pa_driver	  = case is_use_pa_driver
			--											when '1' then 'PAFD'
			--											else null
			--										end
			--		,@coverage_use_srcc			  = case is_use_srcc
			--											when '1' then 'SRCC'
			--											else null
			--										end
			--		,@coverage_use_ts			  = case is_use_ts
			--											when '1' then 'TRRSBT'
			--											else null
			--										end
			--		,@coverage_use_flood		  = case is_use_flood
			--											when '1' then 'FLWINS'
			--											else null
			--										end
			--		,@coverage_use_earthquake	  = case is_use_earthquake
			--											when '1' then 'ERQTSN'
			--											else null
			--										end
			--		,@coverage_commercial_use	  = case is_commercial_use
			--											when '1' then 'RNTLUS'
			--											else null
			--										end
			--		,@coverage_authorize_workshop = case is_authorize_workshop
			--											when '1' then 'AUTHWOR'
			--											else null
			--										end
			--		,@coverage_tbod				  = case is_tbod
			--											when '1' then 'TBOD'
			--											else null
			--										end
			--from	dbo.asset_insurance
			--where	asset_code = @fa_code ;

			if (@main_coverage_code <> '')
			begin
				insert into #coverage
				(
					main_coverage
				)
				select	main_coverage_code
				from	dbo.asset_insurance
				where	asset_code = @fa_code ;
			end ;

			if (@tpl_coverage_code <> '')
			begin
				insert into #coverage
				(
					main_coverage
				)
				select	tpl_coverage_code
				from	dbo.asset_insurance
				where	asset_code = @fa_code ;
			end ;

			if (@pll_coverage_code <> '')
			begin
				insert into #coverage
				(
					main_coverage
				)
				select	pll_coverage_code
				from	dbo.asset_insurance
				where	asset_code = @fa_code ;
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

			--set @coverage_asset = isnull(@main_coverage_code,'') + N' ' + isnull(@tpl_coverage_code,'') + N' ' + isnull(@pll_coverage_code,'') + N' ' + isnull(@coverage_use_pa_passanger,'') + N' ' + isnull(@coverage_use_pa_driver,'') + N' ' + isnull(@coverage_use_srcc,'') + N' ' + isnull(@coverage_use_ts,'') + N' ' + isnull(@coverage_use_flood,'') + N' ' + isnull(@coverage_use_earthquake,'') + N' ' + isnull(@coverage_commercial_use,'') + N' ' + isnull(@coverage_authorize_workshop,'') + N' ' + isnull(@coverage_tbod,'') ;
			
			select	@coverage_asset = isnull(stuff((
				  select	distinct
							' ' + main_coverage
				  from		#coverage
				  for xml path('')
			  ), 1, 1, ''
			 ) ,'')


			--select	@coverage_periode = isnull(stuff((
			--	  select	distinct
			--				' ' + coverage_code
			--	  from		dbo.insurance_register_period	  irp
			--				inner join dbo.insurance_register ir on ir.code = irp.register_code
			--	  where		ir.register_status = 'HOLD' --ir.flag_date = @p_flag_date
			--	  for xml path('')
			--  ), 1, 1, ''
			-- ) ,'')

			
			DECLARE curr_insurance_register CURSOR FAST_FORWARD READ_ONLY for
            select code 
			from dbo.insurance_register
			where register_status = 'HOLD'
			
			OPEN curr_insurance_register
			
			FETCH NEXT FROM curr_insurance_register 
			into @code_insurance_register
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
			    DECLARE curr_same_periode CURSOR FAST_FORWARD READ_ONLY FOR
				select	isnull(stuff((
					  select	distinct
								' ' + coverage_code
					  from		dbo.insurance_register_period	  irp
								inner join dbo.insurance_register ir on ir.code = irp.register_code
					  where		ir.code = @code_insurance_register
					  for xml path('')
				  ), 1, 1, ''
				 ) ,'')

				OPEN curr_same_periode
				
				FETCH NEXT FROM curr_same_periode 
				into @coverage_periode
				
				WHILE @@FETCH_STATUS = 0
				begin
                
					insert into #coverage_existing
					(
						insurance_register_code
						,main_coverage
					)
					values
					(
						@code_insurance_register
						,@coverage_periode
					)

					--if(@coverage_asset <> @coverage_periode)
					--begin
					--	exec dbo.xsp_insurance_register_insert @p_code						= @insurance_code output					-- nvarchar(50)
					--											,@p_branch_code				= @branch_code
					--											,@p_branch_name				= @branch_name
					--											,@p_source_type				= 'ASSET'
					--											,@p_register_status			= 'HOLD'
					--											,@p_register_name			= ''
					--											,@p_register_qq_name		= 'PT DIPO STAR FINANCE'
					--											,@p_register_object_name	= ''
					--											,@p_register_remarks		= ''
					--											,@p_currency_code			= 'IDR'
					--											,@p_insurance_code			= ''
					--											,@p_insurance_type			= 'NON LIFE'
					--											,@p_collateral_type			= ''
					--											,@p_occupation_code			= ''
					--											,@p_eff_rate					= null
					--											,@p_year_period				= @month
					--											,@p_is_renual				= '0'
					--											,@p_from_date				= null
					--											,@p_insurance_payment_type	= 'FTFP'
					--											,@p_insurance_paid_by		= 'MF'
					--											,@p_is_authorized_workshop	= ''
					--											,@p_is_commercial			= ''
					--											,@p_register_type			= 'NEW'
					--											,@p_policy_code				= null
					--											,@p_flag_date				= @p_flag_date
					--											,@p_budget_status			= @p_budget_status
					--											,@p_cre_date					= @p_cre_date
					--											,@p_cre_by					= @p_cre_by
					--											,@p_cre_ip_address			= @p_cre_ip_address
					--											,@p_mod_date					= @p_mod_date
					--											,@p_mod_by					= @p_mod_by
					--											,@p_mod_ip_address			= @p_mod_ip_address
					--end
					--else
					--begin
					--	set @insurance_code = @code_insurance_register
					--end

				    FETCH NEXT FROM curr_same_periode 
					into @coverage_periode
				END
			
				CLOSE curr_same_periode
				DEALLOCATE curr_same_periode
			
			    FETCH NEXT FROM curr_insurance_register 
				into @code_insurance_register
			end
			
			CLOSE curr_insurance_register
			DEALLOCATE curr_insurance_register


			if exists
			(
				select	1
				from	#coverage_existing
				where	main_coverage = @coverage_asset
			)
			begin
				select	@code_insurance_register = insurance_register_code
				from	#coverage_existing
				where	main_coverage = @coverage_asset ;

				set @insurance_code = @code_insurance_register
				set @flaging_periode = 'NO'
			end
			else
			begin
				exec dbo.xsp_insurance_register_insert @p_code						= @insurance_code output					-- nvarchar(50)
													   ,@p_branch_code				= @branch_code
													   ,@p_branch_name				= @branch_name
													   ,@p_source_type				= 'ASSET'
													   ,@p_register_status			= 'HOLD'
													   ,@p_register_name			= ''
													   ,@p_register_qq_name			= 'PT DIPO STAR FINANCE'
													   ,@p_register_object_name		= ''
													   ,@p_register_remarks			= ''
													   ,@p_currency_code			= 'IDR'
													   ,@p_insurance_code			= ''
													   ,@p_insurance_type			= 'NON LIFE'
													   ,@p_collateral_type			= ''
													   ,@p_occupation_code			= ''
													   ,@p_eff_rate					= null
													   ,@p_year_period				= @month
													   ,@p_is_renual				= '0'
													   ,@p_from_date				= null
													   ,@p_insurance_payment_type	= 'FTFP'
													   ,@p_insurance_paid_by		= 'MF'
													   ,@p_is_authorized_workshop	= ''
													   ,@p_is_commercial			= ''
													   ,@p_register_type			= 'NEW'
													   ,@p_policy_code				= null
													   ,@p_flag_date				= @p_flag_date
													   ,@p_budget_status			= @p_budget_status
													   ,@p_cre_date					= @p_cre_date
													   ,@p_cre_by					= @p_cre_by
													   ,@p_cre_ip_address			= @p_cre_ip_address
													   ,@p_mod_date					= @p_mod_date
													   ,@p_mod_by					= @p_mod_by
													   ,@p_mod_ip_address			= @p_mod_ip_address
			end

			--if(@coverage_asset <> @coverage_periode)
			--begin
			--	exec dbo.xsp_insurance_register_insert @p_code						= @insurance_code output					-- nvarchar(50)
			--										   ,@p_branch_code				= @branch_code
			--										   ,@p_branch_name				= @branch_name
			--										   ,@p_source_type				= 'ASSET'
			--										   ,@p_register_status			= 'HOLD'
			--										   ,@p_register_name			= ''
			--										   ,@p_register_qq_name			= 'PT DIPO STAR FINANCE'
			--										   ,@p_register_object_name		= ''
			--										   ,@p_register_remarks			= ''
			--										   ,@p_currency_code			= 'IDR'
			--										   ,@p_insurance_code			= ''
			--										   ,@p_insurance_type			= 'NON LIFE'
			--										   ,@p_collateral_type			= ''
			--										   ,@p_occupation_code			= ''
			--										   ,@p_eff_rate					= null
			--										   ,@p_year_period				= @month
			--										   ,@p_is_renual				= '0'
			--										   ,@p_from_date				= null
			--										   ,@p_insurance_payment_type	= 'FTFP'
			--										   ,@p_insurance_paid_by		= 'MF'
			--										   ,@p_is_authorized_workshop	= ''
			--										   ,@p_is_commercial			= ''
			--										   ,@p_register_type			= 'NEW'
			--										   ,@p_policy_code				= null
			--										   ,@p_flag_date				= @p_flag_date
			--										   ,@p_budget_status			= @p_budget_status
			--										   ,@p_cre_date					= @p_cre_date
			--										   ,@p_cre_by					= @p_cre_by
			--										   ,@p_cre_ip_address			= @p_cre_ip_address
			--										   ,@p_mod_date					= @p_mod_date
			--										   ,@p_mod_by					= @p_mod_by
			--										   ,@p_mod_ip_address			= @p_mod_ip_address
			--end
			--else
			--begin
			--	select	@insurance_code		= code
			--			,@flaging_periode	= 'NO'
			--	from	dbo.insurance_register					 ir
			--			inner join dbo.insurance_register_period irp on irp.register_code = ir.code
			--	where	budget_status		  = @p_budget_status
			--			--and flag_date		  = @p_flag_date
			--			and ir.register_status = 'HOLD'

			--end
		end
		
		exec dbo.xsp_insurance_register_asset_insert @p_code						= @insurance_asset_code
													 ,@p_register_code				= @insurance_code
													 ,@p_fa_code					= @p_code
													 ,@p_sum_insured_amount			= @sum_insured
													 ,@p_depreciation_code			= ''
													 ,@p_collateral_type			= 'VHCL'
													 ,@p_collateral_category_code	= ''
													 ,@p_occupation_code			= ''
													 ,@p_region_code				= ''
													 ,@p_collateral_year			= ''
													 ,@p_is_authorized_workshop		= '0'
													 ,@p_is_commercial				= '0'
													 ,@p_insert_type				= 'NEW'
													 ,@p_is_manual					= '0'
													 ,@p_cre_date					= @p_cre_date
													 ,@p_cre_by						= @p_cre_by
													 ,@p_cre_ip_address				= @p_cre_ip_address
													 ,@p_mod_date					= @p_mod_date
													 ,@p_mod_by						= @p_mod_by
													 ,@p_mod_ip_address				= @p_mod_ip_address
		
		if @flaging_periode = 'YES'
		begin
			declare @counter int 
			set @counter=1
			while ( @counter <= @periode)
			begin
				if(@main_coverage_code <> '')
				begin
					exec dbo.xsp_insurance_register_period_insert @p_id					= 0
																  ,@p_register_code		= @insurance_code
																  ,@p_coverage_code		= @main_coverage_code
																  ,@p_year_periode		= @counter
																  ,@p_cre_date			= @p_cre_date
																  ,@p_cre_by			= @p_cre_by
																  ,@p_cre_ip_address	= @p_cre_ip_address
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address
				end
				if(@tpl_coverage_code <> '')
				begin
					exec dbo.xsp_insurance_register_period_insert @p_id					= 0
																  ,@p_register_code		= @insurance_code
																  ,@p_coverage_code		= @tpl_coverage_code
																  ,@p_year_periode		= @counter
																  ,@p_cre_date			= @p_cre_date
																  ,@p_cre_by			= @p_cre_by
																  ,@p_cre_ip_address	= @p_cre_ip_address
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address
				end
				if(@pll_coverage_code <> '')
				begin
					exec dbo.xsp_insurance_register_period_insert @p_id					= 0
																  ,@p_register_code		= @insurance_code
																  ,@p_coverage_code		= @pll_coverage_code
																  ,@p_year_periode		= @counter
																  ,@p_cre_date			= @p_cre_date
																  ,@p_cre_by			= @p_cre_by
																  ,@p_cre_ip_address	= @p_cre_ip_address
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address
				end
				if(@is_use_pa_passanger = '1')
				begin
					exec dbo.xsp_insurance_register_period_insert @p_id					= 0
																  ,@p_register_code		= @insurance_code
																  ,@p_coverage_code		= 'PAFP'
																  ,@p_year_periode		= @counter
																  ,@p_cre_date			= @p_cre_date
																  ,@p_cre_by			= @p_cre_by
																  ,@p_cre_ip_address	= @p_cre_ip_address
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address
				end
				if(@is_use_pa_driver = '1')
				begin
					exec dbo.xsp_insurance_register_period_insert @p_id					= 0
																  ,@p_register_code		= @insurance_code
																  ,@p_coverage_code		= 'PAFD'
																  ,@p_year_periode		= @counter
																  ,@p_cre_date			= @p_cre_date
																  ,@p_cre_by			= @p_cre_by
																  ,@p_cre_ip_address	= @p_cre_ip_address
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address
				end
				if(@is_use_srcc = '1')
				begin
					exec dbo.xsp_insurance_register_period_insert @p_id					= 0
																  ,@p_register_code		= @insurance_code
																  ,@p_coverage_code		= 'SRCC'
																  ,@p_year_periode		= @counter
																  ,@p_cre_date			= @p_cre_date
																  ,@p_cre_by			= @p_cre_by
																  ,@p_cre_ip_address	= @p_cre_ip_address
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address
				end
				if(@is_use_ts = '1')
				begin
					exec dbo.xsp_insurance_register_period_insert @p_id					= 0
																  ,@p_register_code		= @insurance_code
																  ,@p_coverage_code		= 'TRRSBT'
																  ,@p_year_periode		= @counter
																  ,@p_cre_date			= @p_cre_date
																  ,@p_cre_by			= @p_cre_by
																  ,@p_cre_ip_address	= @p_cre_ip_address
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address
				end
				if(@is_use_flood = '1')
				begin
					exec dbo.xsp_insurance_register_period_insert @p_id					= 0
																  ,@p_register_code		= @insurance_code
																  ,@p_coverage_code		= 'FLWINS'
																  ,@p_year_periode		= @counter
																  ,@p_cre_date			= @p_cre_date
																  ,@p_cre_by			= @p_cre_by
																  ,@p_cre_ip_address	= @p_cre_ip_address
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address
				end
				if(@is_use_earthquake = '1')
				begin
					exec dbo.xsp_insurance_register_period_insert @p_id					= 0
																  ,@p_register_code		= @insurance_code
																  ,@p_coverage_code		= 'ERQTSN'
																  ,@p_year_periode		= @counter
																  ,@p_cre_date			= @p_cre_date
																  ,@p_cre_by			= @p_cre_by
																  ,@p_cre_ip_address	= @p_cre_ip_address
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address
				end
				if(@is_commercial_use = '1')
				begin
					exec dbo.xsp_insurance_register_period_insert @p_id					= 0
																  ,@p_register_code		= @insurance_code
																  ,@p_coverage_code		= 'RNTLUS'
																  ,@p_year_periode		= @counter
																  ,@p_cre_date			= @p_cre_date
																  ,@p_cre_by			= @p_cre_by
																  ,@p_cre_ip_address	= @p_cre_ip_address
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address
				end
				if(@is_authorize_workshop = '1')
				begin
					exec dbo.xsp_insurance_register_period_insert @p_id					= 0
																  ,@p_register_code		= @insurance_code
																  ,@p_coverage_code		= 'AUTHWOR'
																  ,@p_year_periode		= @counter
																  ,@p_cre_date			= @p_cre_date
																  ,@p_cre_by			= @p_cre_by
																  ,@p_cre_ip_address	= @p_cre_ip_address
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address
				end
				if(@is_tbod = '1')
				begin
					exec dbo.xsp_insurance_register_period_insert @p_id					= 0
																  ,@p_register_code		= @insurance_code
																  ,@p_coverage_code		= 'TBOD'
																  ,@p_year_periode		= @counter
																  ,@p_cre_date			= @p_cre_date
																  ,@p_cre_by			= @p_cre_by
																  ,@p_cre_ip_address	= @p_cre_ip_address
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address
				end
			    set @counter  = @counter  + 1
			end
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
