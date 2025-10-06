CREATE PROCEDURE dbo.xsp_prepaid_insurance
(		
	@p_code					nvarchar(50)
	--
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
			,@payment_amount				bigint--decimal(18,2)
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
			,@code_insurance_asset			nvarchar(50)
			,@eff_date						datetime

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

		if exists (select 1 from dbo.insurance_policy_main where code = @p_code and policy_payment_status = 'APPROVE')
		begin		
			
			declare curr_prepaid cursor fast_forward read_only for
			select	coverage.initial_buy_amount
					,datediff(month, ipm.policy_eff_date, ipm.policy_exp_date)
					,ipa.fa_code
					,ipa.code
					,ipm.policy_eff_date
			from	dbo.insurance_policy_main			  ipm
					inner join dbo.insurance_policy_asset ipa on (ipa.policy_code = ipm.code)
					--inner join dbo.insurance_policy_asset_coverage ipac on (ipac.register_asset_code = ipa.code)
					outer apply
			(
				select		sum(ipac.initial_buy_amount) 'initial_buy_amount'
							,ipac.initial_buy_amount	 'buy_amount'
				from		dbo.insurance_policy_asset_coverage ipac
				where		ipac.register_asset_code = ipa.code
				group by	ipac.initial_buy_amount
			)											  coverage
			where	ipm.code				= @p_code
					and coverage.buy_amount <> 0 ;
			
			open curr_prepaid
			
			fetch next from curr_prepaid 
			into @total_net_premi_amount
				,@year_periode
				,@fa_code
				,@code_insurance_asset
				,@eff_date
			
			while @@fetch_status = 0
			begin
				set @usefull = @year_periode --1 * 12
				set @monthly_amount = round(@total_net_premi_amount / @usefull,0)
				
			    exec dbo.xsp_asset_prepaid_main_insert @p_prepaid_no			 = @prepaid_no output
														,@p_fa_code				 = @fa_code
														,@p_prepaid_date		 = @date
														,@p_prepaid_remark		 = 'PREPAID INSURANCE'
														,@p_prepaid_type		 = 'INSURANCE'
														,@p_monthly_amount		 = @monthly_amount
														,@p_total_prepaid_amount = @total_net_premi_amount
														,@p_total_accrue_amount	 = 0
														,@p_last_accue_period	 = ''
														,@p_reff_no				 = @code_insurance_asset
														,@p_cre_date			 = @p_mod_date		
														,@p_cre_by				 = @p_mod_by			
														,@p_cre_ip_address		 = @p_mod_ip_address
														,@p_mod_date			 = @p_mod_date		
														,@p_mod_by				 = @p_mod_by			
														,@p_mod_ip_address		 = @p_mod_ip_address

				set @counter = 0
				set @amount =  @total_net_premi_amount
				set @date_prepaid = @eff_date --dbo.xfn_get_system_date()
				while (@counter < @usefull)
				begin
					set @amount = @amount - @monthly_amount

					if(@counter = (@usefull - 1))
					begin
						set @monthly_amount = @monthly_amount + @amount
					end

					exec dbo.xsp_asset_prepaid_schedule_insert @p_id					= 0
																,@p_prepaid_no			= @prepaid_no
																,@p_prepaid_date		= @date_prepaid
																,@p_prepaid_amount		= @monthly_amount
																,@p_accrue_reff_code	= ''
																,@p_accrue_date			= null
																,@p_cre_date			= @p_mod_date		
																,@p_cre_by				= @p_mod_by		
																,@p_cre_ip_address		= @p_mod_ip_address
																,@p_mod_date			= @p_mod_date		
																,@p_mod_by				= @p_mod_by		
																,@p_mod_ip_address		= @p_mod_ip_address

					set @counter = @counter + 1 ;
					set @date_prepaid = dateadd(month, 1, @date_prepaid)
				end	
			
			    fetch next from curr_prepaid 
				into @total_net_premi_amount
					,@year_periode
					,@fa_code
					,@code_insurance_asset
					,@eff_date
			end
			
			close curr_prepaid
			deallocate curr_prepaid

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