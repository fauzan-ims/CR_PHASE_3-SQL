--Created, Arif at 06-01-2023

CREATE PROCEDURE dbo.xsp_rpt_invoice_faktur
(
	@p_code				  nvarchar(50)
	,@p_user_id			  nvarchar(50)
	,@p_bank_name		  nvarchar(4000)
	,@p_bank_account_name nvarchar(50)
	,@p_bank_account_no	  nvarchar(20)
	
)
as
begin
	declare @msg			 nvarchar(max)
			,@report_company nvarchar(250)
			,@report_title	 nvarchar(250) = 'FAKTUR PAJAK'
			,@report_image	 nvarchar(250)
			,@invoice_no	 nvarchar(50)
			,@assign_name	 nvarchar(50) 
			,@npwp_company   nvarchar(50)
			,@address_company nvarchar(4000)

	delete dbo.rpt_invoice_faktur
	where	user_id = @p_user_id ;

	delete dbo.rpt_invoice_faktur_detail
	where	user_id = @p_user_id ;

	select	@report_company = value
	from	dbo.SYS_GLOBAL_PARAM
	where	CODE = 'COMP' ;

	select	@assign_name = value
	from	dbo.SYS_GLOBAL_PARAM
	where	CODE = 'INVASSIGN' ;

	select	@npwp_company = value
	from	dbo.SYS_GLOBAL_PARAM
	where	CODE = 'INVNPWP' ;

	select	@address_company = value
	from	dbo.SYS_GLOBAL_PARAM
	where	CODE = 'INVADD' ;

	select	@report_image = value
	from	dbo.SYS_GLOBAL_PARAM
	where	CODE = 'IMGDSF' ;

	begin try
		insert into dbo.rpt_invoice_faktur
		(
			user_id
			,report_company
			,report_title
			,report_image
			,npwp_company
			,address_company
			,invoice_no
			,branch_name
			,invoice_type
			,invoice_date
			,invoice_due_date
			,invoice_name
			,client_name
			,client_address
			,client_area_phone_no
			,client_phone_no
			,client_npwp
			,currency_code
			,total_billing_amount
			,credit_billing_amount
			,total_discount_amount
			,total_ppn_amount
			,credit_ppn_amount
			,total_pph_amount
			,credit_pph_amount
			,total_amount
			,faktur_no
			,bank_name
			,bank_account_name
			,bank_account_no
			,description
			,tax
			,assign_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,@npwp_company
				,@address_company
				,invoice_no
				,branch_name
				,invoice_type
				,invoice_date
				,invoice_due_date
				,invoice_name
				,client_name
				,client_address
				,client_area_phone_no
				,client_phone_no
				,client_npwp
				,currency_code
				,total_billing_amount
				,credit_billing_amount
				,total_discount_amount
				,total_ppn_amount
				,credit_ppn_amount
				,total_pph_amount
				,credit_pph_amount
				,total_amount
				,faktur_no
				,@p_bank_name
				,@p_bank_account_name
				,@p_bank_account_no
				,dbo.terbilang(total_amount)
				,(TOTAL_BILLING_AMOUNT - TOTAL_DISCOUNT_AMOUNT)
				,@assign_name
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
		from	dbo.invoice
		where	invoice_no = @p_code ;

		insert into dbo.rpt_invoice_faktur_detail
		(
			user_id
			,invoice_no
			,agreement_no
			,asset_no
			,asset_name
			,billing_no
			,description
			,quantity
			,tax_scheme_code
			,tax_scheme_name
			,billing_amount
			,discount_amount
			,ppn_pct
			,ppn_amount
			,pph_pct
			,pph_amount
			,total_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,invoice_no
				,id.AGREEMENT_NO
				,id.asset_no
				,aa.asset_name
				,billing_no
				,description
				,quantity
				,tax_scheme_code
				,tax_scheme_name
				,billing_amount
				,id.discount_amount
				,ppn_pct
				,ppn_amount
				,pph_pct
				,pph_amount
				,total_amount
				--
				,id.cre_date
				,id.cre_by
				,id.cre_ip_address
				,id.mod_date
				,id.mod_by
				,id.mod_ip_address
		from	dbo.invoice_detail id
				inner join	dbo.agreement_asset aa on (id.agreement_no = aa.agreement_no)
		where	invoice_no = @p_code ;
		
	end try
	Begin catch
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
