CREATE PROCEDURE dbo.xsp_received_request_proceed
(
	@p_code					nvarchar(50)
	,@p_rate				decimal(18, 6) -- (+) Fadlan 06/09/2022 : 04:30 pm  Notes : rate di ambil ketika process 
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
			,@received_transaction_code	nvarchar(50)
			,@system_date				datetime = dbo.xfn_get_system_date()
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@received_amount			decimal(18, 2)
			,@base_amount				decimal(18, 2)
			,@received_remarks			nvarchar(4000)
			,@received_currency_code	nvarchar(3)
			,@branch_bank_code		    nvarchar(50)
			,@branch_bank_name		    nvarchar(250)
			,@branch_bank_gl_link_code  nvarchar(50)
			,@is_fix_bank				nvarchar(1)

	begin try

		if exists (select 1 from dbo.received_request where code = @p_code and received_status <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else if exists (select 1 from dbo.received_request where code = @p_code and isnull(received_transaction_code,'') <> '')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			select	@received_currency_code		= received_currency_code
					,@received_amount			= received_amount
					,@branch_code				= branch_code
					,@branch_name				= branch_name
					,@received_remarks			= received_remarks
					,@branch_bank_code		    = isnull(branch_bank_code,'')		     
					,@branch_bank_name		    = isnull(branch_bank_name,'')			
					,@branch_bank_gl_link_code  = branch_bank_gl_link_code
			from	dbo.received_request 
			where	code = @p_code

			if not exists (select 1 from dbo.received_transaction where received_status = 'HOLD' and 
						  received_orig_currency_code = @received_currency_code and branch_code = @branch_code)
			begin
					if @branch_bank_code <> ''
					begin
					    set @is_fix_bank = '1';
					end
					exec dbo.xsp_received_transaction_insert @p_code							= @received_transaction_code output
															 ,@p_branch_code					= @branch_code
															 ,@p_branch_name					= @branch_name
															 ,@p_received_status				= N'HOLD'
															 ,@p_received_from					= N'' 
															 ,@p_received_transaction_date		= @system_date
															 ,@p_received_value_date			= @system_date
															 ,@p_received_orig_amount			= 0
															 ,@p_received_orig_currency_code	= @received_currency_code
															 ,@p_received_exch_rate				= @p_rate
															 ,@p_received_base_amount			= 0
															 ,@p_received_remarks				= @received_remarks
															 ,@p_bank_gl_link_code				= @branch_bank_gl_link_code 		   
															 ,@p_branch_bank_code				= @branch_bank_code		   
															 ,@p_branch_bank_name				= @branch_bank_name
                                                             ,@p_is_fix_bank					= @is_fix_bank
															 ,@p_cre_date						= @p_cre_date		
															 ,@p_cre_by							= @p_cre_by			
															 ,@p_cre_ip_address					= @p_cre_ip_address
															 ,@p_mod_date						= @p_mod_date		
															 ,@p_mod_by							= @p_mod_by			
															 ,@p_mod_ip_address					= @p_mod_ip_address
					
			end
			else
			begin
			    select	@received_transaction_code	= code 
				from	dbo.received_transaction 
				where	received_status = 'HOLD' 
						and received_orig_currency_code = @received_currency_code
						and branch_code = @branch_code
			end

			set @base_amount = @received_amount * @p_rate -- (+) Fadlan 06/09/2022 : 04:32 pm  Notes :  set base amount
			exec dbo.xsp_received_transaction_detail_insert @p_id							= 0
															,@p_received_transaction_code	= @received_transaction_code
															,@p_received_request_code		= @p_code
															,@p_orig_curr_code				= @received_currency_code
															,@p_orig_amount					= @received_amount
															,@p_exch_rate					= @p_rate
															,@p_base_amount					= @base_amount
															,@p_cre_date					= @p_cre_date		
															,@p_cre_by						= @p_cre_by			
															,@p_cre_ip_address				= @p_cre_ip_address
															,@p_mod_date					= @p_mod_date		
															,@p_mod_by						= @p_mod_by			
															,@p_mod_ip_address				= @p_mod_ip_address
			
			update	dbo.received_request
			set		received_status				= 'ON PROCESS'
					,received_transaction_code	= @received_transaction_code
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	code						= @p_code
			
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
