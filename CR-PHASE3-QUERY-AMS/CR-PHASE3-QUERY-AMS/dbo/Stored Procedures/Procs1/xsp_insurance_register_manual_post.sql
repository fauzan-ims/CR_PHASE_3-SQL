/*
	alterd : Nidya, 20 Mei 2020
	*to renewal
*/
CREATE PROCEDURE dbo.xsp_insurance_register_manual_post
(		
	@p_code					nvarchar(50)
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
			,@branch_code			    nvarchar(50)
			,@branch_name			    nvarchar(250)
			,@agreement_no			    nvarchar(50)
			,@collateral_no			    nvarchar(50)
			,@register_status		    nvarchar(10)
			,@register_name		        nvarchar(250)
			,@register_qq_name		    nvarchar(250)
			,@register_object_name	    nvarchar(250)
			,@request_remark		    nvarchar(4000)
			,@currency				    nvarchar(3)
			,@sell_amount				decimal(18, 2)
			,@sell_amount_loading		decimal(18, 2)
			,@gl_link_code				nvarchar(50)
			,@sp_name					nvarchar(250)
			,@transaction_name			nvarchar(250)
			,@debet_or_credit			nvarchar(10)
			,@orig_amount_db			decimal(18, 2)
			,@return_value				decimal(18, 2)
			,@payment_amount			decimal(18, 2)
			,@facility_code		        nvarchar(50)
			,@facility_name		        nvarchar(250)
			,@purpose_loan_code         nvarchar(50)
			,@purpose_loan_name         nvarchar(250)
			,@purpose_loan_detail_code  nvarchar(50)
			,@purpose_loan_detail_name  nvarchar(250)
			,@cashier_received_request  nvarchar(50)
			,@source					nvarchar(10)
			,@insurance_paid_by			nvarchar(10)

	begin try
    
		select @branch_name			        = ir.branch_name
			   ,@branch_code			    = ir.branch_code    
			   ,@collateral_no              = ir.FA_CODE       
			   ,@register_status            = register_status     
			   ,@register_name              = register_name       
			   ,@register_qq_name           = register_qq_name    
			   ,@register_object_name       = register_object_name 
			   ,@currency					= ir.currency_code 
			   ,@insurance_paid_by			= insurance_paid_by
			   ,@request_remark				= 'Receive insurance renewal, ' + @p_code
		from   dbo.insurance_register ir
			   left join dbo.asset am	on (am.code = ir.fa_code)
		where  ir.code = @p_code

		select @sell_amount = sum(total_sell_amount)
		from dbo.insurance_register_period 
		where register_code = @p_code

		select @sell_amount_loading = sum(initial_sell_amount)
		from dbo.insurance_register_loading 
		where register_code = @p_code

		set @sell_amount = ISNULL(@sell_amount, 0) + ISNULL(@sell_amount_loading, 0)

		if exists (select 1 from dbo.insurance_register where code = @p_code and register_status = 'HOLD')
		begin
			update	dbo.insurance_register
			set		register_status = 'ON PROCESS'
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code

			if (
					@source = ''
					and	@insurance_paid_by = 'CLIENT'
				)
			begin 
				select @payment_amount  = sum(payment_amount)
				from dbo.efam_interface_payment_request 
				where code = @p_code

				select @orig_amount_db = sum(orig_amount) 
				from dbo.efam_interface_cashier_received_request_detail
				where cashier_received_request_code = @p_code

				--+ validasi : total detail =  payment_amount yang di header
				if (@payment_amount <> abs(@orig_amount_db))
				begin
					set @msg = 'Amount does not balance';
    				raiserror(@msg, 16, -1) ;
				end
			end
			else
			begin
				exec dbo.xsp_insurance_renewal_paid @p_code           = @p_code,                      
													@p_cre_date       = @p_cre_date,		
													@p_cre_by	      = @p_cre_by,		
													@p_cre_ip_address = @p_cre_ip_address,	
													@p_mod_date       = @p_mod_date,		
													@p_mod_by         = @p_mod_by,			
													@p_mod_ip_address = @p_mod_ip_address
				
			end
			end
		else
		begin
			set @msg = 'Data already proceed' ;
			raiserror(@msg, 16, -1) ;	
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


