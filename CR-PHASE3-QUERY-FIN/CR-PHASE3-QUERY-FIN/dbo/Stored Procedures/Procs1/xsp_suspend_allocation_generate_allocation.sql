CREATE PROCEDURE dbo.xsp_suspend_allocation_generate_allocation
(
	@p_code				nvarchar(50)
	--,@p_approval_reff		nvarchar(250)
	--,@p_approval_remark	nvarchar(4000)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg						nvarchar(max)
			,@agreement_no				nvarchar(50)
			,@gl_link_code				nvarchar(50)
			,@sp_name					nvarchar(250)
			--,@rate						decimal(18, 6)
			,@allocation_trx_date		datetime
			,@allocation_currency_code	nvarchar(3)

	begin try
	
		if exists (select 1 from dbo.suspend_allocation where code = @p_code and allocation_status <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			
			select	@allocation_currency_code	= isnull(am.currency_code,sa.allocation_currency_code) 
					,@agreement_no				= sa.agreement_no
					,@allocation_trx_date		= allocation_trx_date
			from	dbo.suspend_allocation sa 
					left join dbo.agreement_main am on (am.agreement_no = sa.agreement_no)
			where	code = @p_code

			--declare cur_master_cashier_priority cursor fast_forward read_only for
			
			if (isnull(@agreement_no,'') <> '')
			begin
				-- untuk yg ada agreeent
				select	mt.code
						,@allocation_currency_code 'currency_code'
						,mt.transaction_name
						,mt.module_name
						--,@rate 'rate'
				from	dbo.master_cashier_priority mcp
						inner join master_cashier_priority_detail mcd on (mcd.cashier_priority_code = mcp.code)
						inner join master_transaction mt on (mt.code = mcd.transaction_code)
				where	mcp.is_default = '1'
				order	by order_no
			end
			else
			begin
				-- jika tidak ada 
				select mt.code
						,@allocation_currency_code 'currency_code'
						,mt.transaction_name
						,mt.module_name
						--,@rate 'rate'
				from	dbo.master_transaction mt
						inner join dbo.sys_global_param sgp on (sgp.value = mt.code)
				where	sgp.code = 'TRXSPND'
			end
			--open cur_master_cashier_priority
		
			--fetch next from cur_master_cashier_priority 
			--into	@gl_link_code
			--		,@sp_name

			--while @@fetch_status = 0
			--begin
				
			--	-- exec @sp_name @last_id_job,  @last_id output, @row_count output   -- for example
			--	exec @sp_name 
			--	exec dbo.xsp_suspend_allocation_detail_insert @p_id						= 0
			--												   ,@p_suspend_allocation_code = @p_code
			--												   ,@p_transaction_code			= @gl_link_code
			--												   ,@p_received_request_code	= null
			--												   ,@p_is_paid					= N'F' 
			--												   ,@p_orig_amount				= null -- decimal(18, 2)
			--												   ,@p_orig_currency_code		= @cashier_currency_code
			--												   ,@p_exch_rate				= 1
			--												   ,@p_base_amount				= null -- decimal(18, 2)
			--												   ,@p_installment_no			= 0 -- int
			--												   ,@p_remarks					= N'' -- nvarchar(4000)
			--												   ,@p_cre_date					= @p_cre_date		
			--												   ,@p_cre_by					= @p_cre_by			
			--												   ,@p_cre_ip_address			= @p_cre_ip_address
			--												   ,@p_mod_date					= @p_mod_date		
			--												   ,@p_mod_by					= @p_mod_by			
			--												   ,@p_mod_ip_address			= @p_mod_ip_address
				
				

			--	fetch next from cur_master_cashier_priority 
			--	into	@gl_link_code
			--			,@sp_name
			
			--end
			--close cur_master_cashier_priority
			--deallocate cur_master_cashier_priority
			
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
end

