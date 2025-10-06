CREATE PROCEDURE dbo.xsp_monitoring_ap_proceed
(
	@p_code			   nvarchar(50)
	,@p_date_flag	   datetime
	,@p_supplier_code  nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
	,@p_podoi_id		bigint = 0
)
AS
begin
	declare @msg				  nvarchar(max)
			,@code_invoice		  nvarchar(50)
			,@date				  datetime	   = dbo.xfn_get_system_date()
			,@supplier_code		  nvarchar(50)
			,@supplier_name		  nvarchar(250)
			,@purchase_order_code nvarchar(50) ;

	begin TRY
	
	if (isnull(@p_podoi_id,0) = 0) -- valdiasi jika dari ui tidak mengirim id po object id
	begin
	    raiserror ('Please Check The Completeness Of The Data',16,1)
		return
	end

		if not exists
		(
			select	1
			from	dbo.ap_invoice_registration b
			where	b.status = 'HOLD'
			and		b.date_flag = @p_date_flag
			and		b.supplier_code = @p_supplier_code
		)
		begin
			select	@supplier_code		  = grn.supplier_code
					,@supplier_name		  = grn.supplier_name
					,@purchase_order_code = grn.purchase_order_code
			from	dbo.good_receipt_note					grn
					inner join dbo.good_receipt_note_detail grnd on grn.code = grnd.good_receipt_note_code
			where	grn.code = @p_code 
				
			begin
				exec dbo.xsp_ap_invoice_registration_insert @p_code = @code_invoice output
															,@p_company_code = 'DSF'
															,@p_invoice_date = @date
															,@p_currency_code = 'IDR'
															,@p_supplier_code = @supplier_code
															,@p_supplier_name = @supplier_name
															,@p_invoice_amount = 0
															,@p_file_invoice_no = ''
															,@p_ppn = 0
															,@p_pph = 0
															,@p_bill_type = 'PO'
															,@p_discount = 0
															,@p_due_date = @date
															,@p_purchase_order_code = ''
															,@p_tax_invoice_date = @date
															,@p_branch_code = ''
															,@p_branch_name = ''
															,@p_division_code = ''
															,@p_division_name = ''
															,@p_department_code = ''
															,@p_department_name = ''
															,@p_to_bank_code = ''
															,@p_to_bank_name = ''
															,@p_to_bank_account_name = ''
															,@p_to_bank_account_no = ''
															,@p_payment_by = ''
															,@p_status = 'HOLD'
															,@p_remark = ''
															,@p_file_name = ''
															,@p_file_paths = ''
															,@p_unit_price = 0
															,@p_date_flag = @p_date_flag
															,@p_cre_date = @p_mod_date
															,@p_cre_by = @p_mod_by
															,@p_cre_ip_address = @p_mod_ip_address
															,@p_mod_date = @p_mod_date
															,@p_mod_by = @p_mod_by
															,@p_mod_ip_address = @p_mod_ip_address ;
			end ;
		end 
		else
        begin
            select	@code_invoice = b.code
			from	dbo.ap_invoice_registration b 
			where	b.status	= 'HOLD'
			and		b.supplier_code = @p_supplier_code
        end
	
		if(isnull(@code_invoice,'') <> '')
		begin
		    
			exec dbo.xsp_ap_invoice_registration_detail_insert_item_list @p_invoice_register_code	= @code_invoice
																		 ,@p_grn_code				= @p_code
																		 ,@p_cre_date				= @p_mod_date
																		 ,@p_cre_by					= @p_mod_by
																		 ,@p_cre_ip_address			= @p_mod_ip_address
																		 ,@p_mod_date				= @p_mod_date
																		 ,@p_mod_by					= @p_mod_by
																		 ,@p_mod_ip_address			= @p_mod_ip_address 
																		 ,@p_podoi_id				= @p_podoi_id
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
