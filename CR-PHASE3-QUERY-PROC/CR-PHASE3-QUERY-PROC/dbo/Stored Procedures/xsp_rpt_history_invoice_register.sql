CREATE procedure [dbo].[xsp_rpt_history_invoice_register]
(
	@p_user_id		   nvarchar(max)
	,@p_from_date	   datetime
	,@p_to_date		   datetime
)
as
begin
	delete	dbo.rpt_history_invoice_register
	where	USER_ID = @p_user_id ;

	declare @msg			 nvarchar(max)
			,@report_company nvarchar(250)
			,@report_image	 nvarchar(250)
			,@report_title	 nvarchar(250)
			,@po_code		 nvarchar(50)
			,@po_date		 datetime
			,@eta_date		 datetime
			,@supplier		 nvarchar(250)
			,@item_code		 nvarchar(50)
			,@item_name		 nvarchar(250)
			,@category_type	 nvarchar(50)
			,@unit_price	 decimal(18, 2)
			,@engine_no		 nvarchar(50)
			,@chasis_no		 nvarchar(50)
			,@branch_name	 nvarchar(250)
			,@date			 datetime = dbo.xfn_get_system_date()

	begin try
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		set @report_title = N'Report History Invoice Register' ;

		insert into dbo.rpt_history_invoice_register
		(
			user_id
			,filter_from_date
			,filter_to_date
			,report_company
			,report_title
			,report_image
			,code_invoice
			,supplier_name
			,invoice_receive_date
			,due_date
			,tax_invoice_date
			,invoice_no
			,discount_amount
			,ppn_amount
			,pph_amount
			,total_amount
			,remarks
			,to_bank_name
			,to_bank_account_no
			,to_bank_account_name
			,total_grn
			,status
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@p_from_date
				,@p_to_date
				,@report_company
				,@report_title
				,@report_image
				,code
				,air.supplier_name
				,air.invoice_date
				,air.due_date
				,air.tax_invoice_date
				,air.file_invoice_no
				,air.discount
				,air.ppn
				,air.pph
				,air.invoice_amount
				,air.remark
				,air.to_bank_name
				,air.to_bank_account_no
				,air.to_bank_account_name
				,0
				,air.status
				--
				,@date
				,@p_user_id
				,@p_user_id
				,@date
				,@p_user_id
				,@p_user_id
		from	dbo.ap_invoice_registration air
		where	air.tax_invoice_date
		between @p_from_date and @p_to_date ;

		if not exists
		(
			select	*
			from	dbo.rpt_history_invoice_register
			where	user_id = @p_user_id
		)
		begin
			insert into dbo.rpt_history_invoice_register
			(
				user_id
				,filter_from_date
				,filter_to_date
				,report_company
				,report_title
				,report_image
				,code_invoice
				,supplier_name
				,invoice_receive_date
				,due_date
				,tax_invoice_date
				,invoice_no
				,discount_amount
				,ppn_amount
				,pph_amount
				,total_amount
				,remarks
				,to_bank_name
				,to_bank_account_no
				,to_bank_account_name
				,total_grn
				,status
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(
				@p_user_id
				,@p_from_date
				,@p_to_date
				,@report_company
				,@report_title
				,@report_image
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,@date
				,@p_user_id
				,@p_user_id
				,@date
				,@p_user_id
				,@p_user_id
			) ;

			select user_id
				  ,filter_from_date
				  ,filter_to_date
				  ,report_company
				  ,report_title
				  ,report_image
				  ,code_invoice
				  ,supplier_name
				  ,invoice_receive_date
				  ,due_date
				  ,tax_invoice_date
				  ,invoice_no
				  ,discount_amount
				  ,ppn_amount
				  ,pph_amount
				  ,total_amount
				  ,remarks
				  ,to_bank_name
				  ,to_bank_account_no
				  ,to_bank_account_name
				  ,total_grn
				  ,status
				  ,cre_date
				  ,cre_by
				  ,cre_ip_address
				  ,mod_date
				  ,mod_by
				  ,mod_ip_address 
			from dbo.rpt_history_invoice_register
		end ;
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
