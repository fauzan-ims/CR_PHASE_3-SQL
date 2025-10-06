--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_per_customer
(
	@p_user_id			nvarchar(50)
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(50)
	,@p_is_condition	nvarchar(1)
)
as
begin

	delete dbo.rpt_per_customer
	where	user_id = @p_user_id;

	DECLARE @msg							NVARCHAR(MAX)
			,@report_company				NVARCHAR(250)
			,@report_title					NVARCHAR(250)
			,@report_image					NVARCHAR(250)
			,@customer_name					NVARCHAR(50)
			,@sisa_budget					decimal(18, 2)
			,@actual_cos_or_total_budget	decimal(18, 6)
			,@actual_cos_or_current_budget	decimal(18, 6)
	
	begin try
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set	@report_title = 'Report Per customer';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

	BEGIN

					-- 24jt / 24 bln = 1jt / 1bln
					-- bulan ke 10 => 1jt * 10bln = 10jt

			declare @total_budget table
			(
				client_no	nvarchar(50)
				,amount		decimal(18,2)
			)

			declare @current_budget	table
			(
				client_no	nvarchar(50)
				,amount		decimal(18,2)
			)

			declare @total_actual_cost	table
			(
				client_no	nvarchar(50)
				,amount		decimal(18,2)
			)

			declare @total_unit table
			(
				client_no	nvarchar(50)
				,unit		int
			)

			declare @total_periode table
			(
				agreement_no	nvarchar(50)
				,current_period		int
			)

			INSERT INTO @total_periode
			(
			    agreement_no,
			    current_period
			)
			select		agreement_no
						,ceiling(cast(datediff(day, min(due_date), dbo.xfn_get_system_date()) as decimal(18, 2)) / 30) 'current_period'
			from		ifinopl.dbo.agreement_asset_amortization with (nolock)
			group by	agreement_no

			-- select total budget
			insert into @total_budget
			(
				client_no
				,amount
			)
			select	agm1.client_no
					,isnull(sum(agreement_asset1.total_budget_amount), 0) 'total_budget'
			from	ifinopl.dbo.agreement_main					 agm1 with (nolock)
			outer apply (select isnull(asa1.total_budget_amount,0) 'total_budget_amount' from ifinopl.dbo.agreement_asset asa1 with (nolock) where asa1.AGREEMENT_NO = agm1.AGREEMENT_NO) agreement_asset1
			--outer apply (select ast1.code from dbo.asset ast1 where ast1.agreement_no = agm1.agreement_no) asset
			--outer apply (select isnull(asa1.total_budget_amount,0) 'total_budget_amount' from ifinopl.dbo.agreement_asset asa1 where asa1.FA_CODE = asset.CODE) agreement_asset1
			where agm1.agreement_status = 'GO LIVE'
			group by agm1.client_no


			--select current budget
			insert into @current_budget
			(
				client_no
				,amount
			)
			select		agm2.client_no
						,sum(isnull((isnull(agreement_asset2.total_budget_amount, 0) / isnull(agm2.periode, 1)) * current_period.current_period, 0)) 'current_budget'
			from		ifinopl.dbo.agreement_main					 agm2 with (nolock)
			outer apply (select isnull(asa2.total_budget_amount,0) 'total_budget_amount' from ifinopl.dbo.agreement_asset asa2 with (nolock) where asa2.AGREEMENT_NO = agm2.AGREEMENT_NO) agreement_asset2
			--outer apply (select ast2.code from dbo.asset ast2 where ast2.agreement_no = agm2.agreement_no) asset
			--outer apply (select isnull(asa2.total_budget_amount,0) 'total_budget_amount' from ifinopl.dbo.agreement_asset asa2 where asa2.fa_code = asset.code) agreement_asset2
			outer apply
			(
				--select		agreement_no
				--			,ceiling(cast(datediff(day, min(due_date), dbo.xfn_get_system_date()) as decimal(18, 2)) / 30) 'current_period'
				--from		ifinopl.dbo.agreement_asset_amortization with (nolock)
				--where		agreement_no = agm2.agreement_no
				--group by	agreement_no
				select agreement_no,
                       current_period 
				from @total_periode
				where	agm2.agreement_no = agreement_no
			)														 current_period
			where agm2.agreement_status = 'GO LIVE'
			group by	agm2.CLIENT_NO ;

			--select total actual lost
			insert into @total_actual_cost
			(
				client_no
				,amount
			)
			select		agm3.client_no
						,sum(expense_asset.expense_amount) 'total_actual_cost'
			from		ifinopl.dbo.agreement_main					 agm3 with (nolock)
			outer apply (select isnull(ael3.expense_amount,0) 'expense_amount' from dbo.ASSET_EXPENSE_LEDGER ael3 with (nolock) where ael3.agreement_no = agm3.agreement_no) expense_asset
			where agm3.agreement_status = 'GO LIVE'
			group by	agm3.client_no ;

			--select total unit
			insert into @total_unit
			(
				client_no
				,unit
			)
			select		agm4.client_no
						,count(agreement_asset3.fa_code) 'total_unit'
			from		ifinopl.dbo.agreement_main					 agm4 with (nolock)
						outer apply (select asa4.fa_code from ifinopl.dbo.agreement_asset asa4 with (nolock) WHERE asa4.AGREEMENT_NO = agm4.agreement_no) agreement_asset3
						--outer apply (select ast4.code from dbo.asset ast4 where ast4.agreement_no = agm4.agreement_no) asset
						--outer apply (select asa4.fa_code from ifinopl.dbo.agreement_asset asa4 where asa4.fa_code = asset.code) agreement_asset3
			where agm4.agreement_status = 'GO LIVE'
			group by	agm4.client_no ;
			

			insert into rpt_per_customer
			(
				user_id
				,report_company
				,report_title
				,report_image
				,branch_code
				,branch_name
				,customer_name
				,total_unit
				,total_budget
				,current_budget
				,total_actual_cost
				,sisa_budget
				,actual_cos_or_total_budget
				,actual_cos_or_current_budget
				,is_condition

			)select distinct 
					@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_branch_code
					,@p_branch_name
					,client_name
					,total_unit.unit
					,total_budget.amount
					,current_budget.amount
					,total_actual.amount
					,total_budget.amount - total_actual.amount
					,(case
							when isnull(total_budget.amount, 0) = 0 then 0
							else isnull(total_actual.amount, 0) / isnull(total_budget.amount, 1)
						end
					) * 100 'actual_cost_total_budget'
					,(case
							when isnull(current_budget.amount, 0) = 0 then 0
							else isnull(total_actual.amount, 0) / isnull(current_budget.amount, 1)
						end
					) * 100  'actual_cost_current_budget'
					,@p_is_condition
			from ifinopl.dbo.agreement_main agm with (nolock)
			outer apply (SELECT tb.amount FROM @total_budget tb where tb.client_no = agm.client_no) total_budget
			outer apply (SELECT cb.amount FROM @current_budget cb where cb.client_no = agm.CLIENT_NO) current_budget
			outer apply (SELECT tac.amount FROM @total_actual_cost tac where tac.client_no = agm.client_no) total_actual
			outer apply (SELECT tu.unit FROM @total_unit tu where tu.client_no = agm.client_no) total_unit
			where agm.branch_code =  case @p_branch_code
										  when 'ALL' then agm.branch_code
										  else @p_branch_code
									  end
			and agm.agreement_status = 'GO LIVE'

			--select	distinct @p_user_id
			--		,@report_company
			--		,@report_title
			--		,@report_image
			--		,@p_branch_code
			--		,@p_branch_name
			--		,agm.client_name
			--		,isnull(total4.total_unit, 0) 'total_unit'
			--		,isnull(total.total_budget, 0) 'total_budget'
			--		,isnull(total2.current_budget, 0) 'current_budget'
			--		,isnull(total3.total_actual_cost, 0) 'total_actual_cost'
			--		,isnull(total.total_budget, 0) - isnull(total3.total_actual_cost, 0) 'sisa_budget'
			--		,(case
			--													when isnull(total.total_budget, 0) = 0 then 0
			--													else isnull(total3.total_actual_cost, 0) / isnull(total.total_budget, 1)
			--												end
			--											   ) * 100 'actual_cost_total_budget'
			--		,(case
			--													when isnull(total2.current_budget, 0) = 0 then 0
			--													else isnull(total3.total_actual_cost, 0) / isnull(total2.current_budget, 1)
			--												end
			--											   ) * 100 'actual_cost_current_budget'
			--		,@p_is_condition
			--from	ifinopl.dbo.agreement_main agm
			--		inner join ifinopl.dbo.agreement_information ain on ain.agreement_no = agm.agreement_no
			--		inner join ifinams.dbo.asset ast on ast.agreement_no				 = agm.agreement_no
			--		inner join ifinopl.dbo.agreement_asset asa on asa.fa_code			 = ast.code
			--		left join ifinams.dbo.asset_vehicle avi on avi.asset_code			 = ast.code
			--		left join ifinams.dbo.asset_expense_ledger ael on ael.agreement_no	 = agm.agreement_no
			--outer apply
			--(
			--	select		isnull(sum(asa1.total_budget_amount), 0) 'total_budget'
			--	from		ifinopl.dbo.agreement_main agm1
			--				inner join ifinopl.dbo.agreement_information ain1 on ain1.agreement_no = agm1.agreement_no
			--				inner join ifinams.dbo.asset ast1 on ast1.agreement_no				   = agm1.agreement_no
			--				inner join ifinopl.dbo.agreement_asset asa1 on asa1.fa_code			   = ast1.code
			--	where		agm1.CLIENT_NO = agm.CLIENT_NO
			--	group by	agm1.CLIENT_NO
			--) total
			--outer apply
			--(
			--	select		sum(isnull((isnull(asa2.total_budget_amount, 0) / ISNULL(agm2.periode,1)) * current_period.current_period, 0)) 'current_budget'
			--	from		ifinopl.dbo.agreement_main agm2
			--				inner join ifinopl.dbo.agreement_information ain2 on ain2.agreement_no = agm2.agreement_no
			--				inner join ifinams.dbo.asset ast2 on ast2.agreement_no				   = agm2.agreement_no
			--				inner join ifinopl.dbo.agreement_asset asa2 on asa2.fa_code			   = ast2.code
			--				outer apply(
			--						select		agreement_no
			--									,ceiling(cast(datediff(day, min(due_date), dbo.xfn_get_system_date()) as decimal(18, 2)) / 30) 'current_period'
			--						from		ifinopl.dbo.agreement_asset_amortization
			--						where		agreement_no = agm2.agreement_no
			--						group by	agreement_no
			--				)current_period
			--	where		agm2.CLIENT_NO = agm.CLIENT_NO
			--	group by	agm2.CLIENT_NO
			--) total2
			----			outer apply
			----(
			----	select		isnull((isnull(asa.total_budget_amount, 0) / ISNULL(agm.periode,1)) * ain.current_installment_no, 0) 'current_budget'
			----	from		ifinopl.dbo.agreement_main agm2
			----				inner join ifinopl.dbo.agreement_information ain2 on ain2.agreement_no = agm2.agreement_no
			----				inner join ifinams.dbo.asset ast2 on ast2.agreement_no				   = agm2.agreement_no
			----				inner join ifinopl.dbo.agreement_asset asa2 on asa2.fa_code			   = ast2.code
			----	where		agm2.CLIENT_NO = agm.CLIENT_NO
			----	group by	agm2.CLIENT_NO
			----) total2
			--outer apply
			--(
			--	select		sum(ael3.expense_amount) 'total_actual_cost'
			--	from		ifinopl.dbo.agreement_main agm3
			--				inner join ifinopl.dbo.agreement_information ain3 on ain3.agreement_no = agm3.agreement_no
			--				inner join ifinams.dbo.asset ast3 on ast3.agreement_no				   = agm3.agreement_no
			--				inner join ifinopl.dbo.agreement_asset asa3 on asa3.fa_code			   = ast3.code
			--				left join ifinams.dbo.asset_expense_ledger ael3 on ael3.agreement_no   = agm3.agreement_no
			--	where		agm3.client_no = agm.client_no
			--	group by	agm3.client_no
			--) total3
			--outer apply
			--(
			--	select	count(fa_code) 'total_unit'
			--	from	ifinopl.dbo.agreement_main agm4
			--			inner join ifinopl.dbo.agreement_information ain4 on ain4.agreement_no = agm4.agreement_no
			--			inner join ifinams.dbo.asset ast4 on ast4.agreement_no = agm4.agreement_no
			--			INNER join ifinopl.dbo.agreement_asset asa4 on asa4.fa_code = ast4.code
			--	where	agm4.CLIENT_NO = agm.CLIENT_NO
			--	group by agm4.CLIENT_NO  
			--) total4
			--where	agm.branch_code = case @p_branch_code
			--							  when 'all' then agm.branch_code
			--							  else @p_branch_code
			--						  end ;
			
			if not exists (select * from dbo.rpt_per_customer where user_id = @p_user_id)
			begin
					insert into dbo.rpt_per_customer
					(
					    user_id
					    ,report_company
					    ,report_title
					    ,report_image
					    ,branch_code
					    ,branch_name
					    ,customer_name
					    ,total_unit
					    ,total_budget
					    ,current_budget
					    ,total_actual_cost
					    ,sisa_budget
					    ,actual_cos_or_total_budget
					    ,actual_cos_or_current_budget
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
					    ,@p_is_condition
					)
			end


			delete @total_unit
			delete @total_actual_cost
			delete @current_budget
			delete @total_budget
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
    ON OBJECT::[dbo].[xsp_rpt_per_customer] TO [ims-raffyanda]
    AS [dbo];

