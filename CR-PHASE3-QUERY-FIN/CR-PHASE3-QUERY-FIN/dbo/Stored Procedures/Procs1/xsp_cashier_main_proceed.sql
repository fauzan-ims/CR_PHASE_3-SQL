CREATE PROCEDURE dbo.xsp_cashier_main_proceed
(
	@p_code					nvarchar(50) output
	,@p_cashier_code		nvarchar(50) -- ini nomor cashier
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
	declare	@msg							nvarchar(max)
			,@p_currency_code				nvarchar(3)
			,@p_branch_bank_name			nvarchar(250)
			,@p_branch_bank_code			nvarchar(50) 
			,@p_bank_gl_link_code			nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@cashier_open_date				datetime
			,@cashier_innitial_amount		decimal(18, 2)
			,@remarks						nvarchar(4000)

	begin try
	
		if exists (select 1 from dbo.cashier_main where code = @p_cashier_code and cashier_innitial_amount <= 0)
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			--(-) SEPRIA 08/07/2023: DI TUTUP DIPO TIDAK MENGUNAKAN CASHIER CASH
			--select	@branch_code				= branch_code
			--	   ,@branch_name				= branch_name
			--	   ,@cashier_open_date			= cashier_open_date
			--	   ,@cashier_innitial_amount	= cashier_innitial_amount
			--	   ,@remarks					= 'Innitial Amount for Cashier No : ' + code + ' - ' + employee_name
			--from	dbo.cashier_main
			--where	code = @p_cashier_code

			--exec dbo.xsp_account_transfer_insert @p_code					= @p_code output
			--									 ,@p_transfer_status		= N'HOLD'
			--									 ,@p_transfer_trx_date		= @cashier_open_date
			--									 ,@p_transfer_value_date	= @cashier_open_date
			--									 ,@p_cashier_amount			= @cashier_innitial_amount
			--									 ,@p_transfer_remarks		= @remarks
			--									 ,@p_cashier_code			= @p_cashier_code
			--									 ,@p_from_branch_code		= @branch_code
			--									 ,@p_from_branch_name		= @branch_name
			--									 ,@p_from_currency_code		= null
			--									 ,@p_from_branch_bank_code	= null
			--									 ,@p_from_branch_bank_name	= null
			--									 ,@p_from_gl_link_code		= null
			--									 ,@p_from_exch_rate			= 1
			--									 ,@p_from_orig_amount		= 0
			--									 ,@p_to_branch_code			= @branch_code
			--									 ,@p_to_branch_name			= @branch_name
			--									 ,@p_to_currency_code		= @p_currency_code
			--									 ,@p_to_branch_bank_code	= @p_branch_bank_code
			--									 ,@p_to_branch_bank_name	= @p_branch_bank_name
			--									 ,@p_to_gl_link_code		= @p_bank_gl_link_code
			--									 ,@p_to_exch_rate			= 1
			--									 ,@p_to_orig_amount			= @cashier_innitial_amount
			--									 ,@p_cre_date				= @p_cre_date		
			--									 ,@p_cre_by					= @p_cre_by			
			--									 ,@p_cre_ip_address			= @p_cre_ip_address
			--									 ,@p_mod_date				= @p_mod_date		
			--									 ,@p_mod_by					= @p_mod_by			
			--									 ,@p_mod_ip_address			= @p_mod_ip_address
			 
			
			update	dbo.cashier_main
			set		cashier_status		= 'ON PROCESS'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_cashier_code
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
