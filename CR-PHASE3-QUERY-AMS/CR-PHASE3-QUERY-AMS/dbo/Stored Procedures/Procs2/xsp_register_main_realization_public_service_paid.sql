CREATE PROCEDURE [dbo].[xsp_register_main_realization_public_service_paid]
(
	@p_code									nvarchar(50)
	,@p_public_service_settlement_date		datetime
	,@p_public_service_settlement_voucher	nvarchar(50)
	--
	,@p_mod_date							datetime
	,@p_mod_by								nvarchar(15)
	,@p_mod_ip_address						nvarchar(15)
)
as
begin

	declare	@msg								nvarchar(max)
			,@regis_status						nvarchar(20)
			,@customer_settlement_date			datetime
			,@is_reimburse						nvarchar(1)
			,@reff_remark						nvarchar(4000)
			,@fa_code							nvarchar(50)
			,@item_name							nvarchar(250)
			,@date								datetime
			,@agreement_no						nvarchar(50)
			,@client_name						nvarchar(250)
			,@expense							decimal(18,2)
			,@prepaid_no						nvarchar(50)
			,@total_net_premi_amount			decimal(18,2)
			,@usefull							int
			,@monthly_amount					decimal(18,2)
			,@counter							int
			,@date_prepaid						datetime
			,@year_periode						int
			,@amount							decimal(18,2)
			,@service_code						nvarchar(50)
			,@code_register						nvarchar(50)

	begin try
		set @date = dbo.xfn_get_system_date()

		select	@regis_status						= rm.register_status
				,@is_reimburse						= rm.is_reimburse
				,@fa_code							= rm.fa_code
				,@item_name							= ass.item_name
				,@agreement_no						= ass.agreement_no
				,@client_name						= ass.client_name
				,@expense							= rm.realization_actual_fee
		from	dbo.register_main rm
		inner join dbo.asset ass on (rm.fa_code = ass.code)
		where	rm.code = @p_code
		
		--if @regis_status <> 'PENDING'
		--begin
		--	set @msg = 'Data already proceed.'
		--	raiserror(@msg ,16,-1)
		--end

		update	dbo.register_main
		set		public_service_settlement_date		= @p_public_service_settlement_date
				,public_service_settlement_voucher	= @p_public_service_settlement_voucher
				,payment_status						= 'PAID'
				,register_status					= 'PENDING'
				,mod_date							= @p_mod_date
				,mod_by								= @p_mod_by
				,mod_ip_address						= @p_mod_ip_address
		where	code = @p_code

		--if @is_reimburse = '0'
		--begin
			set @reff_remark = 'Register for ' + @fa_code + ' - ' + @item_name
			exec dbo.xsp_asset_expense_ledger_insert @p_id					= 0
													 ,@p_asset_code			= @fa_code
													 ,@p_date				= @date
													 ,@p_reff_code			= @p_code
													 ,@p_reff_name			= 'REGISTER'
													 ,@p_reff_remark		= @reff_remark
													 ,@p_expense_amount		= @expense
													 ,@p_agreement_no		= @agreement_no
													 ,@p_client_name		= @client_name
													 --
													 ,@p_cre_date			= @p_mod_date
													 ,@p_cre_by				= @p_mod_by
													 ,@p_cre_ip_address		= @p_mod_ip_address
													 ,@p_mod_date			= @p_mod_date		
													 ,@p_mod_by				= @p_mod_by			
													 ,@p_mod_ip_address		= @p_mod_ip_address
		--end

		--declare curr_asset_prepaid cursor fast_forward read_only for
		--select service_code 
		--		,register_code
		--from dbo.register_detail
		--where register_code = @p_code
		
		--open curr_asset_prepaid
		
		--fetch next from curr_asset_prepaid 
		--into @service_code
		--	,@code_register

		--while @@fetch_status = 0
		--begin
		--		if(@service_code = 'PBSPKEUR' or @service_code = 'PBSPSTN')
		--		begin -- prepaid
		--			if(@service_code = 'PBSPSTN')
		--			begin
		--				set @usefull = 1 * 12
		--			end
		--			else
		--			begin
		--				set @usefull = 1 * 6
		--			end
		--			set @monthly_amount = round(@expense / @usefull,0)
					

		--			exec dbo.xsp_asset_prepaid_main_insert @p_prepaid_no			 = @prepaid_no output
		--													,@p_fa_code				 = @fa_code
		--													,@p_prepaid_date		 = @date
		--													,@p_prepaid_remark		 = 'PREPAID REGISTER'
		--													,@p_prepaid_type		 = 'REGISTER'
		--													,@p_monthly_amount		 = @monthly_amount
		--													,@p_total_prepaid_amount = @expense
		--													,@p_total_accrue_amount	 = 0
		--													,@p_last_accue_period	 = ''
		--													,@p_reff_no				 = @code_register
		--													,@p_cre_date			 = @p_mod_date		
		--													,@p_cre_by				 = @p_mod_by			
		--													,@p_cre_ip_address		 = @p_mod_ip_address
		--													,@p_mod_date			 = @p_mod_date		
		--													,@p_mod_by				 = @p_mod_by			
		--													,@p_mod_ip_address		 = @p_mod_ip_address

		--			set @counter = 0
		--			set @amount =  @expense
		--			set @date_prepaid = dbo.xfn_get_system_date()
		--			while (@counter < @usefull)
		--			begin
		--				set @amount = @amount - @monthly_amount

		--				if(@counter = (@usefull - 1))
		--				begin
		--					set @monthly_amount = @monthly_amount + @amount
		--				end

		--				exec dbo.xsp_asset_prepaid_schedule_insert @p_id					= 0
		--															,@p_prepaid_no			= @prepaid_no
		--															,@p_prepaid_date		= @date_prepaid
		--															,@p_prepaid_amount		= @monthly_amount
		--															,@p_accrue_reff_code	= ''
		--															,@p_accrue_date			= null
		--															,@p_cre_date			= @p_mod_date		
		--															,@p_cre_by				= @p_mod_by		
		--															,@p_cre_ip_address		= @p_mod_ip_address
		--															,@p_mod_date			= @p_mod_date		
		--															,@p_mod_by				= @p_mod_by		
		--															,@p_mod_ip_address		= @p_mod_ip_address

		--				set @counter = @counter + 1 ;
		--				set @date_prepaid = dateadd(month, 1, @date_prepaid)
		--			end	
		--		end
		
		--    fetch next from curr_asset_prepaid 
		--	into @service_code
		--		,@code_register
		--end
		
		--close curr_asset_prepaid
		--deallocate curr_asset_prepaid
		
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

end



