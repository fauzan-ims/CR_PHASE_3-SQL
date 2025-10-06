--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_per_unit_trial
(
	@p_user_id			nvarchar(50)
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(50)
	,@p_is_condition	nvarchar(1) = '0'
)
as
begin

	delete dbo.rpt_per_unit
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)	
			,@branch_code					nvarchar(50)	
			,@branch_name					nvarchar(50)	
			,@agreement_no					nvarchar(50)	
			,@customer						nvarchar(150)	
			,@obj_lease						nvarchar(50)	
			,@provinsi						nvarchar(50)	
			,@kota							nvarchar(50)	
			,@plat_no						nvarchar(50)	
			,@chassis_no					nvarchar(50)	
			,@engine_no						nvarchar(50)	
			,@periode						nvarchar(50)	
			,@contract_period_from			datetime		
			,@contract_period_to			datetime		
			,@budget_skd					decimal(18,2)
			,@budget_month					decimal(18,2)	
			,@current_period				int	
			,@current_budget				decimal(18,2)	
			,@current_maintenance			decimal(18,2)	
			,@frequency_service				int
			,@profit_loss					decimal(18,2)	
	
	begin try
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set	@report_title = 'Report Per Unit';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		DECLARE @total_frequency TABLE (
			asset_code	NVARCHAR(50)
			,frequency	int
		)

		DECLARE @schedule_amortisasi TABLE (
			agreement_no	NVARCHAR(50)
			,start_date		DATETIME
			,end_date		DATETIME
		)

		DECLARE @asset_expense TABLE (
		asset_code			NVARCHAR(50)
		,expense_amount		DECIMAL(18,2)
		)
		
		INSERT INTO @asset_expense
		(
		    asset_code,
		    expense_amount
		)
		Select		ait.ASSET_CODE,
					SUM(expense_amount) 'CUR_MAIN_ACTUAL'
		from		ifinams.dbo.asset_expense_ledger ait with (nolock)
		where		ait.reff_name	   in ('WORK ORDER', 'OPRT-SERVICE & MAINTENANCE-SERVICE FEE', 'OPRT-SERVICE & MAINTENANCE-SPARE PART', 'OPRT-VEHICLE EXPENSE-SERVICE FEE', 'OPRT-VEHICLE EXPENSE-SPARE PART & OTHER')
		group by	asset_code


		insert into @total_frequency
		(
		    asset_code,
		    frequency
		)
		select		amts.asset_code
					,count(id)
		from		ifinams.dbo.asset_maintenance_schedule amts with (nolock)
		inner join dbo.asset ast with (nolock) on ast.code  = amts.asset_code
		inner join ifinopl.dbo.agreement_main am with (nolock) on am.agreement_no = ast.agreement_no
		where		amts.maintenance_status in ('ad hoc done','schedule done')
					and amts.maintenance_date > am.agreement_date
					and	am.agreement_status = 'GO LIVE'
		group by	amts.asset_code

		insert into @schedule_amortisasi
		(
		    agreement_no,
		    start_date,
		    end_date
		)
		select		aamor.agreement_no
					,min(due_date) 'start_date'
					,max(due_date) 'end_date'
		from		ifinopl.dbo.agreement_asset_amortization aamor with (nolock)
		group by	agreement_no


	BEGIN

			INSERT INTO rpt_per_unit
			(
				user_id
				,report_company
				,report_title
				,report_image
				,branch_code	
				,branch_name	
				,agreement_no
				,customer
				,obj_lease
				,provinsi
				,kota
				,plat_no
				,chassis_no
				,engine_no
				,periode
				,contract_period_from
				,contract_period_to
				,budget_skd
				,budget_month
				,current_period
				,current_budget
				,current_maintenance
				,frequency_service
				,profit_loss
				,IS_CONDITION


			)
			select	distinct @p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_branch_code
					,@p_branch_name
					,agm.agreement_external_no
					,agm.client_name
					,ast.item_name
					,ast.unit_province_name
					,ast.unit_city_name
					,avi.plat_no
					,avi.chassis_no
					,avi.engine_no
					,agm.periode
					,dt.start_date
					,dt.end_date
					,isnull(maintenance.BUDGET_MAINTENANCE_AMOUNT, 0) 'budget_skd'
					,isnull(maintenance.BUDGET_MAINTENANCE_AMOUNT / agm.PERIODE, 0) 'budget_month'
					,ain.current_installment_no
					,isnull((isnull(maintenance.budget_maintenance_amount, 0) / agm.periode) * ain.current_installment_no, 0) 'current_budget'
					,isnull(mnt.payment_amount,0)--isnull(asa.mobilization_amount, 0) 'current_main_actual'
					,isnull(hit.freq_serv, 0) 'frequency_service'
					,isnull(maintenance.budget_maintenance_amount, 0) - isnull(mnt.payment_amount,0) --isnull(sim.cur_main_actual, 0) 'profit_loss'
					,@p_is_condition
			from	ifinopl.dbo.agreement_main agm
					inner join ifinopl.dbo.agreement_information ain with (nolock) on ain.agreement_no = agm.agreement_no
					inner join ifinams.dbo.asset ast with (nolock) ON ast.agreement_no = agm.agreement_no
					inner join ifinopl.dbo.agreement_asset asa WITH (nolock) on asa.fa_code = ast.code
					inner join ifinopl.dbo.agreement_main agrm with (nolock) ON agrm.agreement_no = asa.agreement_no
					left join ifinams.dbo.asset_vehicle avi with (nolock) ON avi.asset_code = ast.code
					--left join ifinams.dbo.asset_expense_ledger ael on ael.agreement_no = agm.agreement_no
					outer apply
					(
						--select		min(due_date) 'start_date'
						--			,max(due_date) 'end_date'
						--from		ifinopl.dbo.agreement_asset_amortization aamor with (nolock)
						--where		aamor.agreement_no = agm.agreement_no
						--group by	agreement_no
						select  start_date,
								end_date 
						from	@schedule_amortisasi
						where	agreement_no = agm.agreement_no
					) dt
							outer apply
					(
						--select		sum(expense_amount) 'CUR_MAIN_ACTUAL'
						--from		ifinams.dbo.asset_expense_ledger ait with (nolock)
						--where		ait.reff_name	   in ('WORK ORDER', 'OPRT-SERVICE & MAINTENANCE-SERVICE FEE', 'OPRT-SERVICE & MAINTENANCE-SPARE PART', 'OPRT-VEHICLE EXPENSE-SERVICE FEE', 'OPRT-VEHICLE EXPENSE-SPARE PART & OTHER')
						--			and ait.asset_code = ast.code
						--group by	asset_code
						select	expense_amount 'CUR_MAIN_ACTUAL'
						from	@asset_expense
						where	asset_code = ast.code
					) sim
					outer apply
					(
						--select		count(id) 'freq_serv'
						--from		ifinams.dbo.asset_maintenance_schedule amts with (nolock)
						--where		amts.maintenance_status in ('AD HOC DONE','SCHEDULE DONE')
						--and agm.agreement_status = 'GO LIVE'
						--and amts.maintenance_date > agm.AGREEMENT_DATE
						--and amts.asset_code = ast.code
						--group by	amts.asset_code
						--select		count(id) 'freq_serv'
						--			,amts.ASSET_CODE
						--from		ifinams.dbo.asset_maintenance_schedule amts
						--			inner join dbo.asset				   ass on (amts.asset_code	= ass.code)
						--			inner join ifinopl.dbo.agreement_main  agm on (agm.agreement_no = ass.agreement_no)
						--where		amts.maintenance_status in
						--(
						--	'AD HOC DONE', 'SCHEDULE DONE'
						--)
						--			and agm.agreement_status  = 'GO LIVE'
						--			and amts.maintenance_date > agm.AGREEMENT_DATE
						--group by	amts.asset_code
						select	frequency 'freq_serv'
						from	@total_frequency
						where	asset_code = ast.CODE						
					) hit
					outer apply
						(
							select BUDGET_MAINTENANCE_AMOUNT
							from ifinopl.dbo.AGREEMENT_ASSET aat with (nolock)
							where aat.fa_code = ast.CODE
							and aat.agreement_no = agm.agreement_no
						) maintenance
					outer apply 
						(
							SELECT	SUM(wo.payment_amount) 'payment_amount' 
							FROM	dbo.maintenance mnt 
							INNER join dbo.work_order wo on mnt.code = wo.maintenance_code 
							WHERE	mnt.asset_code = ast.code 
							GROUP by mnt.asset_code
						) mnt
			where	agm.branch_code = case @p_branch_code
										  when 'ALL' then agm.branch_code
										  else @p_branch_code
									  end
			and asa.budget_maintenance_amount > 0
			and AGRM.agreement_status = 'GO LIVE';

			if not exists (select * from dbo.rpt_per_unit where user_id = @p_user_id)
			begin
					insert into dbo.rpt_per_unit
					(
					    user_id
					    ,report_company
					    ,report_title
					    ,report_image
					    ,branch_code
					    ,branch_name
					    ,agreement_no
					    ,customer
					    ,obj_lease
					    ,provinsi
					    ,kota
					    ,plat_no
					    ,chassis_no
					    ,engine_no
					    ,periode
					    ,contract_period_from
					    ,contract_period_to
					    ,budget_skd
					    ,budget_month
					    ,current_period
					    ,current_budget
					    ,current_maintenance
					    ,frequency_service
					    ,profit_loss
					    ,is_condition
					)
					values
					(   
						@p_user_id
					    ,@report_company
					    ,@report_title
					    ,@report_image
					    ,@p_branch_code
					    ,@p_branch_name
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,@p_is_condition
					 )
			END
            
			delete @total_frequency
			delete @schedule_amortisasi
            
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_per_unit_trial] TO [ims-raffyanda]
    AS [dbo];

