--Created, ALIV at 26/12/2022
CREATE PROCEDURE dbo.xsp_order_main_post
(
	@p_code					nvarchar(50)
	,@p_branch_code			nvarchar(50)
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
    
	declare @msg						nvarchar(max)
			,@year						nvarchar(4)
			,@month						nvarchar(2)
			,@date						datetime		= getdate()
			,@code						nvarchar(50)
			,@order_date				datetime
			,@order_amount				decimal(18, 2)
			,@order_remarks				nvarchar(50)
			,@bank_acc_name				nvarchar(250)
			,@bank_name					nvarchar(250)
			,@bank_acc_no				nvarchar(250)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(50)
			,@payment_branch_code		nvarchar(50)
			,@payment_branch_name		nvarchar(50)		
			,@payment_source			nvarchar(50)
			,@payment_request_date		datetime
			,@payment_source_no			nvarchar(50)
			,@payment_status			nvarchar(50)
			,@payment_currency_code		nvarchar(50)
			,@payment_to				nvarchar(250)
			,@to_bank_name				nvarchar(50)
			,@to_bank_account_name		nvarchar(50)
			,@payment_transaction_code	nvarchar(50)
			,@tax_file_type				nvarchar(50)               
			,@tax_file_no				nvarchar(50)    
			,@tax_payer_reff_code		nvarchar(50)    
			,@tax_file_name				NVARCHAR(50)
			,@public_service_code		nvarchar(50)
			,@currency					nvarchar(3);

	begin try

	if exists (select 1 from dbo.order_main where code = @p_code and ORDER_STATUS <> 'HOLD')
	begin
		set @msg = 'Data Already Post.';
		raiserror(@msg, 16, -1) ;
	end

	set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
												,@p_branch_code			 = @p_branch_code
												,@p_sys_document_code	 = ''
												,@p_custom_prefix		 = 'BRU'
												,@p_year				 = @year
												,@p_month				 = @month
												,@p_table_name			 = 'ORDER_MAIN'
												,@p_run_number_length	 = 6
												,@p_delimiter			= '.'
												,@p_run_number_only		 = '0' ;
		update	dbo.order_main
		set		order_status	= 'POST'
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code ;

		select	@branch_code			= branch_code
				,@branch_name			= branch_name
				,@order_date			= order_date
				,@order_amount			= order_amount
				,@order_remarks			= order_remarks
		from	dbo.order_main
		where	code = @p_code ;	

		select	@order_amount					= om.order_amount
				,@branch_name					= om.branch_name
				,@bank_acc_name					= mpsb.bank_account_name
				,@branch_code					= om.branch_code
				,@payment_to					= mps.public_service_name
				,@bank_name						= mpsb.bank_name
				,@bank_acc_no					= mpsb.bank_account_no
				,@order_date					= om.order_date
				,@order_amount					= om.order_amount
				,@order_remarks					= om.order_remarks
				,@currency						= currency_code
				,@public_service_code			= om.public_service_code
		from	dbo.order_main om
				inner join dbo.master_public_service mps on mps.code = om.public_service_code
				left join dbo.master_public_service_bank mpsb on (mpsb.public_service_code = mps.code and mpsb.is_default = '1')
		where	om.code = @p_code

		select		@tax_file_type			= tax_file_type
				   ,@tax_file_no			= tax_file_no
				   ,@tax_file_name			= tax_file_name
		from dbo.master_public_service
		where code = @public_service_code

		--Bagian untuk insert ke dalam tabel tujuan
		EXEC dbo.xsp_payment_request_insert @p_code							= @code,                      
		                                    @p_branch_code					= @branch_code,               
		                                    @p_branch_name					= @branch_name,               
		                                    @p_payment_branch_code			= @branch_code,               
		                                    @p_payment_branch_name			= @branch_name,               
		                                    @p_payment_source				= 'DP ORDER PUBLIC SERVICE',  
		                                    @p_payment_request_date			= @order_date, 
		                                    @p_payment_source_no			= @code,                      
		                                    @p_payment_status				= 'HOLD',                     
		                                    @p_payment_currency_code		= @currency,                  
		                                    @p_payment_amount				= @order_amount,              
		                                    @p_payment_to					= @payment_to,                         
		                                    @p_payment_remarks				= @order_remarks,             
		                                    @p_to_bank_name					= @bank_name,                 
		                                    @p_to_bank_account_name			= @bank_acc_name,             
		                                    @p_to_bank_account_no			= @bank_acc_no,               
		                                    @p_payment_transaction_code		= '',              
		                                    @p_tax_type						= @tax_file_type,             
		                                    @p_tax_file_no					= @tax_file_no,               
		                                    @p_tax_payer_reff_code			= @public_service_code,       
		                                    @p_tax_file_name				= @tax_file_name,             
		                                    @p_cre_date						= @p_cre_date,        
		                                    @p_cre_by						= @p_cre_by,              
		                                    @p_cre_ip_address				= @p_cre_ip_address,      
		                                    @p_mod_date						= @p_mod_date,            
		                                    @p_mod_by						= @p_mod_by,              
		                                    @p_mod_ip_address				= @p_mod_ip_address       

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


