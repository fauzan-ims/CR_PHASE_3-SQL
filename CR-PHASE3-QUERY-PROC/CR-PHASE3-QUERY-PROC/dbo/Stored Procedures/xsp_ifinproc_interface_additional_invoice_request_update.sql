--CREATED by ALIV on 16/05/2023
create PROCEDURE  xsp_ifinproc_interface_additional_invoice_request_update
(
	@p_id							bigint			
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_date						datetime
	,@p_invoice_type				nvarchar(10)
	,@p_invoice_name				nvarchar(250)
	,@p_invoice_date				datetime
	,@p_invoice_due_date			datetime
	,@p_fa_code						nvarchar(50)	
	,@p_fa_name						nvarchar(250)
	,@p_client_no					nvarchar(50)	
	,@p_client_name					nvarchar(250)	
	,@p_client_address				nvarchar(4000)	
	,@p_client_area_phone_no		nvarchar(4)		
	,@p_client_phone_no				nvarchar(15)	
	,@p_client_npwp					nvarchar(50)	
	,@p_total_billing_amount		decimal(18,2)
	,@p_total_discount_amount		decimal(18,2)
	,@p_total_ppn_amount			decimal(18,2)
	,@p_total_pph_amount			decimal(18,2)
	,@p_total_amount				decimal(18,2)
	,@p_currency					nvarchar(3)
	,@p_reff_no						nvarchar(50)
	,@p_reff_name					nvarchar(250)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(50)
	,@p_mod_ip_address				nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	ifinproc_interface_additional_invoice_request
		set		branch_code					= @p_branch_code				
				,branch_name				= @p_branch_name					
				,date						= @p_date						
				,invoice_type				= @p_invoice_type				
				,invoice_name				= @p_invoice_name				
				,invoice_date				= @p_invoice_date				
				,invoice_due_date			= @p_invoice_due_date			
				,fa_code					= @p_fa_code						
				,fa_name					= @p_fa_name						
				,client_no					= @p_client_no					
				,client_name				= @p_client_name					
				,client_address				= @p_client_address				
				,client_area_phone_no		= @p_client_area_phone_no		
				,client_phone_no			= @p_client_phone_no				
				,client_npwp				= @p_client_npwp					
				,total_billing_amount		= @p_total_billing_amount		
				,total_discount_amount		= @p_total_discount_amount		
				,total_ppn_amount			= @p_total_ppn_amount			
				,total_pph_amount			= @p_total_pph_amount			
				,total_amount				= @p_total_amount				
				,currency					= @p_currency					
				,reff_no					= @p_reff_no						
				,reff_name					= @p_reff_name						
				--						
				,mod_date					= @p_mod_date			
				,mod_by						= @p_mod_by				
				,mod_ip_address				= @p_mod_ip_address		
		
		where	id = @p_id ;
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
