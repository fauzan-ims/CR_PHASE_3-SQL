CREATE PROCEDURE dbo.xsp_fin_interface_agreement_invoice_ledger_history_insert
(
	@p_id						bigint = 0 output
	,@p_agreement_no			nvarchar(50)
	,@p_asset_no				nvarchar(50)
	,@p_invoice_status			nvarchar(10)
	,@p_transaction_date		datetime
	,@p_transaction_no			nvarchar(50)
	,@p_transaction_name		nvarchar(250)
	,@p_transaction_amount		decimal(18, 2)
	,@p_customer_client_no		nvarchar(50)
	,@p_customer_name			nvarchar(250)
	,@p_invoice_no				nvarchar(50)
	,@p_invoice_date			datetime
	,@p_invoice_due_date		datetime
	,@p_invoice_past_due_date	datetime
	,@p_gross_amount			decimal(18, 2)
	,@p_vat_pct					decimal(9, 6)
	,@p_pph_pct					decimal(9, 6)
	,@p_net_amount				decimal(18, 2)
	,@p_used_amount				decimal(18, 2)
	,@p_remarks					nvarchar(4000)
	,@p_pug_date				datetime
	,@p_source_reff_module		nvarchar(50)
	,@p_source_reff_remarks		nvarchar(4000)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.fin_interface_agreement_invoice_ledger_history
		(
		    agreement_no		
		    ,asset_no		
		    ,invoice_status		
		    ,transaction_date	
		    ,transaction_no		
		    ,transaction_name	
		    ,transaction_amount
			,customer_client_no
			,customer_name
			,invoice_no
			,invoice_date
			,invoice_due_date	
			,invoice_past_due_date	
			,gross_amount
			,vat_pct
			,pph_pct
			,net_amount
			,used_amount
			,remarks
			,pug_date
		    ,source_reff_module	
		    ,source_reff_remarks	
			--
		    ,cre_date		
		    ,cre_by			
		    ,cre_ip_address	
		    ,mod_date		
		    ,mod_by			
		    ,mod_ip_address	
		)
		values
		(	@p_agreement_no		
			,@p_asset_no		
			,@p_invoice_status		
			,@p_transaction_date	
			,@p_transaction_no		
			,@p_transaction_name	
			,@p_transaction_amount	
			,@p_customer_client_no		
			,@p_customer_name			
			,@p_invoice_no				
			,@p_invoice_date			
			,@p_invoice_due_date		
			,@p_invoice_past_due_date	
			,@p_gross_amount			
			,@p_vat_pct					
			,@p_pph_pct					
			,@p_net_amount				
			,@p_used_amount				
			,@p_remarks					
			,@p_pug_date				
			,@p_source_reff_module	
			,@p_source_reff_remarks	
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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

