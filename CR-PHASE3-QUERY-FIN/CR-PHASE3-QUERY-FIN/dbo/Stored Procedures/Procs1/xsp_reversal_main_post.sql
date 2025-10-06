CREATE PROCEDURE dbo.xsp_reversal_main_post
(
	@p_code				nvarchar(50)
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
			,@source_reff_code			nvarchar(50)
			,@source_reff_name			nvarchar(250)
			,@gl_link_transaction_code	nvarchar(50)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@cashier_trx_date			datetime
			,@cashier_value_date		datetime
			,@bank_gl_link_code			nvarchar(50)
			,@orig_amount				decimal(18, 2)
			,@base_amount				decimal(18, 2)
			,@exch_rate					decimal(18, 6)
			,@currency_code				nvarchar(3)
			,@agreement_no				nvarchar(50)
			,@remarks					nvarchar(4000)
			,@base_amount_db			decimal(18, 2)
			,@base_amount_cr			decimal(18, 2)
			,@orig_amount_cr			decimal(18, 2)
			,@orig_amount_db			decimal(18, 2)
			,@cashier_base_amount		decimal(18, 2)		
			,@cashier_orig_amount		decimal(18, 2)	
			,@cashier_exch_rate			decimal(18, 6)	
			,@index						bigint = 1
			,@cashier_currency_code		nvarchar(3)
			,@cashier_remarks			nvarchar(4000)
			,@suspend_remarks			nvarchar(4000)
			,@received_request_code		nvarchar(50)
			,@gl_link_code				nvarchar(50)
			,@transaction_code			nvarchar(50)
			,@division_code				nvarchar(50)
			,@division_name				nvarchar(50)
			,@department_code			nvarchar(50)
			,@department_name			nvarchar(50)
			,@orig_currency_code		nvarchar(50)
			,@reff_source_name			nvarchar(250)
			,@agreement_branch_code		nvarchar(50)
			,@agreement_branch_name		nvarchar(250)
			,@suspend_main_code			nvarchar(50)
			,@reff_no					nvarchar(250)
			,@deposit_type				nvarchar(15)
			,@cashier_transaction_id	bigint

	begin try

		if exists (select 1 from dbo.reversal_main where code = @p_code and reversal_status <> 'ON PROCESS')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			select	@source_reff_code		= source_reff_code
					,@source_reff_name		= source_reff_name 
			from	dbo.reversal_main
			where	code	= @p_code

			update	dbo.reversal_main
			set		reversal_date = dbo.xfn_get_system_date()
			where	source_reff_code = @p_code ;
	
			if (@source_reff_name = 'Payment Voucher') --khusus untuk PV
			begin
				exec dbo.xsp_payment_voucher_reversal @p_code				= @source_reff_code
													  ,@p_cre_date			= @p_cre_date		
													  ,@p_cre_by			= @p_cre_by			
													  ,@p_cre_ip_address	= @p_cre_ip_address
													  ,@p_mod_date			= @p_mod_date		
													  ,@p_mod_by			= @p_mod_by			
													  ,@p_mod_ip_address	= @p_mod_ip_address
				
			end
			else if (@source_reff_name = 'Received Voucher') --khusus untuk RV
			begin
				exec dbo.xsp_received_voucher_reversal @p_code				= @source_reff_code
													   --
													   ,@p_cre_date			= @p_cre_date		
													   ,@p_cre_by			= @p_cre_by			
													   ,@p_cre_ip_address	= @p_cre_ip_address
													   ,@p_mod_date			= @p_mod_date		
													   ,@p_mod_by			= @p_mod_by			
													   ,@p_mod_ip_address	= @p_mod_ip_address
				
			end
			else if @source_reff_name in ('Payment Transaction') --khusus untuk PT
			begin
				exec dbo.xsp_payment_transaction_reversal @p_code				= @source_reff_code
														  --
														  ,@p_cre_date			= @p_cre_date		
														  ,@p_cre_by			= @p_cre_by			
														  ,@p_cre_ip_address	= @p_cre_ip_address
														  ,@p_mod_date			= @p_mod_date		
														  ,@p_mod_by			= @p_mod_by			
														  ,@p_mod_ip_address	= @p_mod_ip_address 
			end
			else if @source_reff_name in ('Received Transaction') --khusus untuk RT
			begin
				exec dbo.xsp_received_transaction_reversal @p_code				= @source_reff_code
														   --
														   ,@p_cre_date			= @p_cre_date		
														   ,@p_cre_by			= @p_cre_by			
														   ,@p_cre_ip_address	= @p_cre_ip_address
														   ,@p_mod_date			= @p_mod_date		
														   ,@p_mod_by			= @p_mod_by			
														   ,@p_mod_ip_address	= @p_mod_ip_address 
			end
			else if @source_reff_name in ('Cashier Transaction') --khusus untuk CT
			begin
				exec dbo.xsp_cashier_transaction_reversal @p_code				= @source_reff_code
														  --
														  ,@p_cre_date			= @p_cre_date		
														  ,@p_cre_by			= @p_cre_by			
														  ,@p_cre_ip_address	= @p_cre_ip_address
														  ,@p_mod_date			= @p_mod_date		
														  ,@p_mod_by			= @p_mod_by			
														  ,@p_mod_ip_address	= @p_mod_ip_address 
			end
            else if @source_reff_name in ('Suspend Allocation') -- khusus untuk SA
			begin
				exec dbo.xsp_suspend_allocation_reversal @p_code				= @source_reff_code
														  --
														  ,@p_cre_date			= @p_cre_date		
														  ,@p_cre_by			= @p_cre_by			
														  ,@p_cre_ip_address	= @p_cre_ip_address
														  ,@p_mod_date			= @p_mod_date		
														  ,@p_mod_by			= @p_mod_by			
														  ,@p_mod_ip_address	= @p_mod_ip_address 
			end
			else if @source_reff_name in ('Deposit Allocation') -- khusus untuk DA
			begin
				exec dbo.xsp_deposit_allocation_reversal @p_code				= @source_reff_code
														  --
														  ,@p_cre_date			= @p_cre_date		
														  ,@p_cre_by			= @p_cre_by			
														  ,@p_cre_ip_address	= @p_cre_ip_address
														  ,@p_mod_date			= @p_mod_date		
														  ,@p_mod_by			= @p_mod_by			
														  ,@p_mod_ip_address	= @p_mod_ip_address 
			end
			else
            begin
                raiserror('Source Name Does Not Cover for Reversal',16,1)
				return
            end

			select	@gl_link_transaction_code = code 
			from	dbo.fin_interface_journal_gl_link_transaction
			where	reversal_reff_no = @source_reff_code 

			if	(isnull(@gl_link_transaction_code,'') <> '')
			BEGIN
				select	@base_amount_cr		= sum(base_amount_cr) 
						,@base_amount_db	= sum(base_amount_db) 
				from	dbo.fin_interface_journal_gl_link_transaction_detail
				where	gl_link_transaction_code = @gl_link_transaction_code

				--+ validasi : total detail =  payment_amount yang di header
				if (@base_amount_db <> @base_amount_cr)
				begin
					set @msg = 'Journal does not balance';
    				raiserror(@msg, 16, -1) ;
				end
			end

			update	dbo.reversal_main
			set		reversal_status		= 'APPROVE'
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




