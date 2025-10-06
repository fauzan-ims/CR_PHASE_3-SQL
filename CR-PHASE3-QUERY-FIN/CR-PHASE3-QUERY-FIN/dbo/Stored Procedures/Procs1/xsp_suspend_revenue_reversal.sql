CREATE PROCEDURE dbo.xsp_suspend_revenue_reversal
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
			,@suspend_code				nvarchar(50)
			,@revenue_amount			decimal(18, 2)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@revenue_date				datetime
			,@suspend_currency_code		nvarchar(3)
			,@id						bigint

	begin try
	
		if exists (select 1 from dbo.suspend_revenue where code = @p_code and revenue_status <> 'POST')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			
			declare cur_suspend_revenue_detail cursor fast_forward read_only for
			
			select	srd.suspend_code
					,srd.revenue_amount
					,sr.branch_code
					,sr.branch_name
					,sm.suspend_currency_code
					,sr.revenue_date
			from	dbo.suspend_revenue_detail srd
					inner join dbo.suspend_revenue sr on (sr.code = srd.suspend_revenue_code)
					inner join dbo.suspend_main sm on (sm.code = srd.suspend_code)
			where	suspend_revenue_code = @p_code

			open cur_suspend_revenue_detail
		
			fetch next from cur_suspend_revenue_detail 
			into	@suspend_code
					,@revenue_amount
					,@branch_code
					,@branch_name
					,@suspend_currency_code
					,@revenue_date

			while @@fetch_status = 0
			begin

				update	dbo.suspend_main
				set		suspend_amount					= suspend_amount + @revenue_amount
						,mod_date						= @p_mod_date
						,mod_by							= @p_mod_by
						,mod_ip_address					= @p_mod_ip_address
				where	code							= @suspend_code
				
				exec dbo.xsp_suspend_history_insert @p_id					= 0
													,@p_branch_code			= @branch_code
													,@p_branch_name			= @branch_name
													,@p_suspend_code		= @suspend_code
													,@p_transaction_date	= @p_cre_date
													,@p_orig_amount			= @revenue_amount
													,@p_orig_currency_code	= @suspend_currency_code
													,@p_exch_rate			= 1
													,@p_base_amount			= @revenue_amount
													,@p_agreement_no		= null
													,@p_source_reff_code	= @p_code
													,@p_source_reff_name	= N'Suspend Revenue Reversal'
													,@p_cre_date			= @p_cre_date		
													,@p_cre_by				= @p_cre_by			
													,@p_cre_ip_address		= @p_cre_ip_address
													,@p_mod_date			= @p_mod_date		
													,@p_mod_by				= @p_mod_by			
													,@p_mod_ip_address		= @p_mod_ip_address


				fetch next from cur_suspend_revenue_detail 
				into	@suspend_code
						,@revenue_amount
						,@branch_code
						,@branch_name
						,@suspend_currency_code
						,@revenue_date
			
			end
			close cur_suspend_revenue_detail
			deallocate cur_suspend_revenue_detail
			
			
			update	dbo.suspend_revenue
			set		revenue_status		= 'REVERSE'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code
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


