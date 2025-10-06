CREATE PROCEDURE dbo.xsp_quotation_review_post
(
	@p_code			   nvarchar(50)
	,@p_company_code   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					   nvarchar(max)
			,@count_procurement		   int
			,@count_request			   int
			,@id					   bigint
			,@id1					   bigint
			,@vendor_code			   nvarchar(50)	  = ''
			,@vendor_name			   nvarchar(250)  = ''
			,@remark				   nvarchar(4000)
			,@budget_amount			   decimal(18, 2) = 0
			,@purchase_type_code	   nvarchar(50)
			,@code					   nvarchar(50)
			,@year					   nvarchar(2)
			,@month					   nvarchar(2)
			,@purchase_type_name	   nvarchar(50)
			,@quotation_date		   datetime
			,@expired_date			   datetime
			,@item_group_code		   nvarchar(50)
			,@branch_code			   nvarchar(50)
			,@branch_name			   nvarchar(250)
			,@division_code			   nvarchar(50)
			,@division_name			   nvarchar(250)
			,@department_code		   nvarchar(50)
			,@department_name		   nvarchar(250)
			,@sub_departmet_code	   nvarchar(50)
			,@sub_department_name	   nvarchar(250)
			,@unit_code				   nvarchar(50)
			,@unit_name				   nvarchar(250)
			,@flag_document			   nvarchar(5)
			,@remark_unpost			   nvarchar(4000)
			,@remark_review			   nvarchar(4000)
			,@procurement_request_code nvarchar(50)
			,@currency_code			   nvarchar(20)
			,@currency_name			   nvarchar(250)
			,@payment_methode_code	   nvarchar(50)
			,@item_code				   nvarchar(50)
			,@item_name				   nvarchar(250)
			,@supplier_code			   nvarchar(50)
			,@tax_code				   nvarchar(50)
			,@warranty_month		   int
			,@warranty_part_month	   int
			,@quantity				   int
			,@approved_quantity		   int
			,@remaining_quantity	   int
			,@uom_code				   nvarchar(50)
			,@price_amount			   decimal(18, 2)
			,@winner_amount			   decimal(18, 2)
			,@winner_quantity		   int
			,@discount_amount		   decimal(18, 2)
			,@reff_type				   nvarchar(20)
			,@requestor_code		   nvarchar(50)
			,@remark_detail			   nvarchar(4000)
			,@minsupp				   nvarchar(250)
			,@count_detail			   nvarchar(50)
			,@index					   int ;

	begin try
		update	dbo.quotation_review
		set		status			= 'POST'
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	code			= @p_code ;

		select	@minsupp				= value
		from	dbo.sys_global_param
		where	code					= 'MINSUPP' ;

		select	@quotation_date			= quotation_review_date
				,@expired_date			= expired_date
				,@item_group_code		= item_group_code
				,@branch_code			= branch_code
				,@branch_name			= branch_name
				,@division_code			= division_code
				,@division_name			= division_name
				,@department_code		= department_code
				,@department_name		= department_name
				,@sub_departmet_code	= sub_departmet_code
				,@sub_department_name	= sub_department_name
				,@unit_code				= unit_code
				,@unit_name				= unit_name
				,@flag_document			= flag_document
				,@remark_unpost			= remark_unpost
				,@remark				= remark
				,@requestor_code		= requestor_code
		from	dbo.quotation_review
		where	code					= @p_code ;

		begin
			exec dbo.xsp_quotation_insert @p_code						= @code output
										  ,@p_company_code				= @p_company_code
										  ,@p_quotation_date			= @quotation_date
										  ,@p_quotation_review_code		= @p_code
										  ,@p_expired_date				= @expired_date
										  ,@p_item_group_code			= @item_group_code
										  ,@p_branch_code				= @branch_code
										  ,@p_branch_name				= @branch_name
										  ,@p_division_code				= @division_code
										  ,@p_division_name				= @division_name
										  ,@p_department_code			= @department_code
										  ,@p_department_name			= @department_name
										  ,@p_sub_department_code		= @sub_departmet_code
										  ,@p_sub_department_name		= @sub_department_name
										  ,@p_unit_code					= @unit_code
										  ,@p_unit_name					= @unit_name
										  ,@p_requestor_code			= @requestor_code
										  ,@p_flag_document				= @flag_document
										  ,@p_remark_unpost				= @remark_unpost
										  ,@p_status					= 'NEW'
										  ,@p_remark					= @remark
										  ,@p_cre_date					= @p_mod_date
										  ,@p_cre_by					= @p_mod_by
										  ,@p_cre_ip_address			= @p_mod_ip_address
										  ,@p_mod_date					= @p_mod_date
										  ,@p_mod_by					= @p_mod_by
										  ,@p_mod_ip_address			= @p_mod_ip_address ;

			declare c_invoice_register_detail cursor for
			select	reff_no
					,currency_code
					,currency_name
					,payment_methode_code
					,item_code
					,item_name
					,supplier_code
					,tax_code
					,warranty_month
					,warranty_part_month
					,quantity
					,approved_quantity
					,remaining_quantity
					,uom_code
					,price_amount
					,winner_amount
					,winner_quantity
					,discount_amount
					,reff_type
					,remark
					,requestor_code
			from	dbo.quotation_review_detail
			where	quotation_review_code = @p_code ;

			open c_invoice_register_detail ;

			fetch c_invoice_register_detail
			into @procurement_request_code
				 ,@currency_code
				 ,@currency_name
				 ,@payment_methode_code
				 ,@item_code
				 ,@item_name
				 ,@supplier_code
				 ,@tax_code
				 ,@warranty_month
				 ,@warranty_part_month
				 ,@quantity
				 ,@approved_quantity
				 ,@remaining_quantity
				 ,@uom_code
				 ,@price_amount
				 ,@winner_amount
				 ,@winner_quantity
				 ,@discount_amount
				 ,@reff_type
				 ,@remark_detail
				 ,@requestor_code ;

			while @@fetch_status = 0
			begin
				set @index = 1

				while (@index <= @minsupp)
				begin
					declare @p_id bigint ;

					exec dbo.xsp_quotation_detail_insert @p_id							= @p_id output
														 ,@p_quotation_code				= @code
														 ,@p_procurement_request_code	= @procurement_request_code
														 ,@p_branch_code				= @branch_code
														 ,@p_branch_name				= @branch_name
														 ,@p_currency_code				= @currency_code
														 ,@p_currency_name				= @currency_name
														 ,@p_payment_methode_code		= @payment_methode_code
														 ,@p_item_code					= @item_code
														 ,@p_item_name					= @item_name
														 ,@p_supplier_code				= @supplier_code
														 ,@p_tax_code					= @tax_code
														 ,@p_warranty_month				= @warranty_month
														 ,@p_warranty_part_month		= @warranty_part_month
														 ,@p_quantity					= @quantity
														 ,@p_approved_quantity			= @approved_quantity
														 ,@p_remaining_quantity			= @remaining_quantity
														 ,@p_uom_code					= @uom_code
														 ,@p_price_amount				= @price_amount
														 ,@p_winner_amount				= @winner_amount
														 ,@p_winner_quantity			= @winner_quantity
														 ,@p_discount_amount			= @discount_amount
														 ,@p_reff_type					= @reff_type
														 ,@p_requestor_code				= @requestor_code
														 ,@p_remark						= @remark_detail
														 ,@p_cre_date					= @p_mod_date
														 ,@p_cre_by						= @p_mod_by
														 ,@p_cre_ip_address				= @p_mod_ip_address
														 ,@p_mod_date					= @p_mod_date
														 ,@p_mod_by						= @p_mod_by
														 ,@p_mod_ip_address				= @p_mod_ip_address ;

					set @index = @index + 1

				end ;

				fetch c_invoice_register_detail
				into @procurement_request_code
					 ,@currency_code
					 ,@currency_name
					 ,@payment_methode_code
					 ,@item_code
					 ,@item_name
					 ,@supplier_code
					 ,@tax_code
					 ,@warranty_month
					 ,@warranty_part_month
					 ,@quantity
					 ,@approved_quantity
					 ,@remaining_quantity
					 ,@uom_code
					 ,@price_amount
					 ,@winner_amount
					 ,@winner_quantity
					 ,@discount_amount
					 ,@reff_type
					 ,@remark_detail
					 ,@requestor_code ;
			end ;

			close c_invoice_register_detail ;
			deallocate c_invoice_register_detail ;

			declare @document_code	  nvarchar(50)
					,@file_path		  nvarchar(250)
					,@file_name		  nvarchar(250)
					,@remark_document nvarchar(4000) ;

			declare c_quotation_review_document cursor for
			select	document_code
					,file_path
					,file_name
					,remark
			from	dbo.quotation_review_document
			where	quotation_review_code = @p_code ;

			open c_quotation_review_document ;

			fetch c_quotation_review_document
			into @document_code
				 ,@file_path
				 ,@file_name
				 ,@remark_document ;

			while @@fetch_status = 0
			begin
				declare @p_id1 bigint ;

				exec dbo.xsp_quotation_document_insert @p_id					= @p_id1 output
													   ,@p_quotation_code		= @code
													   ,@p_document_code		= @document_code
													   ,@p_file_path			= @file_path
													   ,@p_file_name			= @file_name
													   ,@p_remark				= @remark_document
													   ,@p_cre_date				= @p_mod_date
													   ,@p_cre_by				= @p_mod_by
													   ,@p_cre_ip_address		= @p_mod_ip_address
													   ,@p_mod_date				= @p_mod_date
													   ,@p_mod_by				= @p_mod_by
													   ,@p_mod_ip_address		= @p_mod_ip_address ;

				fetch c_quotation_review_document
				into @document_code
					 ,@file_path
					 ,@file_name
					 ,@remark_document ;
			end ;

			close c_quotation_review_document ;
			deallocate c_quotation_review_document ;
		end ;

		--if (@count_procurement = @count_request)
		--begin
		--	update	procurement_request
		--	set		status = 'POST'
		--			--
		--			,mod_date = @p_mod_date
		--			,mod_by = @p_mod_by
		--			,mod_ip_address = @p_mod_ip_address
		--	where	code = @p_procurement_request_code ;
		--end ;

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
