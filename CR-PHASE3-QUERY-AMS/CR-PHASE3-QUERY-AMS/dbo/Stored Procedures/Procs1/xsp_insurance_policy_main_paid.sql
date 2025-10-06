/*
	alterd : Nia, 27 Mei 2020
*/
CREATE PROCEDURE dbo.xsp_insurance_policy_main_paid
(		
	@p_code					NVARCHAR(50)
	--
	,@p_cre_date			DATETIME
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@remark						nvarchar(4000)
			,@agreement_no					nvarchar(50)
			,@client_name					nvarchar(250)
			,@fa_code						nvarchar(50)
			,@fa_name						nvarchar(250)
			,@date							datetime	= dbo.xfn_get_system_date()
			,@reff_remark					nvarchar(4000)
			,@payment_amount				BIGINT--decimal(18,2)
			,@total_premi_buy_amount		decimal(18,2)
			,@invoice_code					nvarchar(50)
			,@prepaid_no					nvarchar(50)
			,@total_net_premi_amount		decimal(18,2)
			,@usefull						int
			,@monthly_amount				decimal(18,2)
			,@counter						int
			,@sisa							decimal(18,2)
			,@amount						decimal(18,2)
			,@date_prepaid					datetime
			,@year_periode					int
			,@policy_asset_code				nvarchar(50)
			,@code_insurance_asset			NVARCHAR(50)

	begin try
		select  @invoice_code				= ipm.invoice_no
		from	dbo.insurance_policy_main ipm
				inner join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
		where   ipm.code = @p_code

		select	@total_premi_buy_amount = sum(ipac.buy_amount)
				,@policy_asset_code		= ipa.code
		from	dbo.insurance_policy_asset					   ipa
				inner join dbo.insurance_policy_asset_coverage ipac on ipac.register_asset_code = ipa.code and ipac.coverage_type = 'NEW'
		where	policy_code		 = @p_code
				and invoice_code = @invoice_code
		group by ipa.code

		
		if exists (select 1 from dbo.insurance_policy_main where code = @p_code and policy_payment_status = 'ON PROCESS')
		begin
			-- untuk case jika ada gantungan payment 
			if exists
			(
				select	1
				from	dbo.payment_request
				where	payment_source_no		= @p_code
						and payment_status		= 'POST'
						and payment_request_date < '2024-08-10'
			)
			begin
				exec dbo.xsp_prepaid_insurance @p_code				= @p_code
											   ,@p_mod_date			= @p_mod_date
											   ,@p_mod_by			= @p_mod_by
											   ,@p_mod_ip_address	= @p_mod_ip_address ;
			end ;

			update	dbo.insurance_policy_main
			set		policy_payment_status = 'PAID'
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code

			update dbo.insurance_policy_asset
			set		status_asset	= 'ACTIVE'
					,insert_type	= 'EXISTING'
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	policy_code		= @p_code

			update dbo.insurance_policy_asset_coverage
			set		coverage_type	= 'EXISTING'
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	register_asset_code = @policy_asset_code

			declare curr_policy_expense cursor fast_forward read_only for
			select fa_code
					,ass.item_name
					,ass.agreement_no
					,ass.client_name
					,coverage.buy_amount
			from dbo.insurance_policy_asset ipa
			inner join dbo.asset ass on (ass.code = ipa.fa_code)
			outer apply (select sum(ipac.buy_amount) 'buy_amount' from dbo.insurance_policy_asset_coverage ipac where ipac.register_asset_code = ipa.code) coverage
			where policy_code = @p_code
			
			open curr_policy_expense
			
			fetch next from curr_policy_expense 
			into @fa_code
				,@fa_name
				,@agreement_no
				,@client_name
				,@payment_amount
			
			while @@fetch_status = 0
			begin
			    --insert ke expense ledger
				set @reff_remark = 'Insurance policy for ' + @fa_code + ' - ' + @fa_name
				exec dbo.xsp_asset_expense_ledger_insert @p_id					= 0
														 ,@p_asset_code			= @fa_code
														 ,@p_date				= @date
														 ,@p_reff_code			= @p_code
														 ,@p_reff_name			= 'INSURANCE POLICY'
														 ,@p_reff_remark		= @reff_remark
														 ,@p_expense_amount		= @payment_amount
														 ,@p_agreement_no		= @agreement_no
														 ,@p_client_name		= @client_name
														 --
														 ,@p_cre_date			= @p_mod_date	  
														 ,@p_cre_by				= @p_mod_by		
														 ,@p_cre_ip_address		= @p_mod_ip_address
														 ,@p_mod_date			= @p_mod_date	  
														 ,@p_mod_by				= @p_mod_by		
														 ,@p_mod_ip_address		= @p_mod_ip_address
			
			    fetch next from curr_policy_expense 
				into @fa_code
					,@fa_name
					,@agreement_no
					,@client_name
					,@payment_amount
			end
			
			close curr_policy_expense
			deallocate curr_policy_expense

			set @remark = 'POLICY PAID'
			exec dbo.xsp_insurance_policy_main_history_insert @p_id					= 0         
			                                                  ,@p_policy_code		= @p_code                  
			                                                  ,@p_history_date		= @p_cre_date
			                                                  ,@p_history_type		= 'POLICY PAID'                  
			                                                  ,@p_policy_status		= 'POLICY'                  
			                                                  ,@p_history_remarks	= @remark                
			                                                  ,@p_cre_date			= @p_cre_date	
															  ,@p_cre_by			= @p_cre_by			
															  ,@p_cre_ip_address	= @p_cre_ip_address
															  ,@p_mod_date			= @p_mod_date		
															  ,@p_mod_by			= @p_mod_by			
															  ,@p_mod_ip_address	= @p_mod_ip_address

			--declare curr_prepaid cursor fast_forward read_only for
			--select ipac.initial_buy_amount
			--		,datediff(year, ipm.policy_eff_date, ipm.policy_exp_date)
			--		,ipa.fa_code
			--		,ipa.CODE
			--from dbo.insurance_policy_main ipm
			--inner join dbo.insurance_policy_asset ipa on (ipa.policy_code = ipm.code)
			--inner join dbo.insurance_policy_asset_coverage ipac on (ipac.register_asset_code = ipa.code)
			--where ipm.code = @p_code
			--AND ipac.initial_buy_amount <> 0
			
			--open curr_prepaid
			
			--fetch next from curr_prepaid 
			--into @total_net_premi_amount
			--	,@year_periode
			--	,@fa_code
			--	,@code_insurance_asset
			
			--while @@fetch_status = 0
			--begin
			--	set @usefull = 1 * 12
			--	set @monthly_amount = round(@total_net_premi_amount / @usefull,0)
				
			--    exec dbo.xsp_asset_prepaid_main_insert @p_prepaid_no			 = @prepaid_no output
			--											,@p_fa_code				 = @fa_code
			--											,@p_prepaid_date		 = @date
			--											,@p_prepaid_remark		 = 'PREPAID INSURANCE'
			--											,@p_prepaid_type		 = 'INSURANCE'
			--											,@p_monthly_amount		 = @monthly_amount
			--											,@p_total_prepaid_amount = @total_net_premi_amount
			--											,@p_total_accrue_amount	 = 0
			--											,@p_last_accue_period	 = ''
			--											,@p_reff_no				 = @code_insurance_asset
			--											,@p_cre_date			 = @p_mod_date		
			--											,@p_cre_by				 = @p_mod_by			
			--											,@p_cre_ip_address		 = @p_mod_ip_address
			--											,@p_mod_date			 = @p_mod_date		
			--											,@p_mod_by				 = @p_mod_by			
			--											,@p_mod_ip_address		 = @p_mod_ip_address

			--	set @counter = 0
			--	set @amount =  @total_net_premi_amount
			--	set @date_prepaid = dbo.xfn_get_system_date()
			--	while (@counter < @usefull)
			--	begin
			--		set @amount = @amount - @monthly_amount

			--		if(@counter = (@usefull - 1))
			--		begin
			--			set @monthly_amount = @monthly_amount + @amount
			--		end

			--		exec dbo.xsp_asset_prepaid_schedule_insert @p_id					= 0
			--													,@p_prepaid_no			= @prepaid_no
			--													,@p_prepaid_date		= @date_prepaid
			--													,@p_prepaid_amount		= @monthly_amount
			--													,@p_accrue_reff_code	= ''
			--													,@p_accrue_date			= null
			--													,@p_cre_date			= @p_mod_date		
			--													,@p_cre_by				= @p_mod_by		
			--													,@p_cre_ip_address		= @p_mod_ip_address
			--													,@p_mod_date			= @p_mod_date		
			--													,@p_mod_by				= @p_mod_by		
			--													,@p_mod_ip_address		= @p_mod_ip_address

			--		set @counter = @counter + 1 ;
			--		set @date_prepaid = dateadd(month, 1, @date_prepaid)
			--	end	
			
			--    fetch next from curr_prepaid 
			--	into @total_net_premi_amount
			--		,@year_periode
			--		,@fa_code
			--		,@code_insurance_asset
			--end
			
			--close curr_prepaid
			--deallocate curr_prepaid

		end
		else
		begin
		    raiserror('Data already proceed',16,1)
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


