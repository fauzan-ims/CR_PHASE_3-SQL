-- Stored Procedure

CREATE PROCEDURE dbo.xsp_ap_invoice_registration_proceed_approval
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@id_detail					bigint
			,@id_grn					bigint
			,@amount_invoice			decimal(18, 2)
			,@amount_grn				decimal(18, 2)
			,@code						nvarchar(50)
			,@code_grn					nvarchar(50)
			,@code_final				nvarchar(50)
			,@asset_code				nvarchar(50)
			,@ppn						decimal(18, 2)
			,@faktur_no					nvarchar(50)
			,@discount					decimal(18, 2)
			,@purchase					decimal(18, 2)
			,@temp_grn_code				nvarchar(50)
			,@file_invoice				nvarchar(50)
			,@remark					nvarchar(4000)
			,@to_bank_code				nvarchar(50)
			,@proc_req_code				nvarchar(50)
			,@item_code					nvarchar(50)
			,@item_name					nvarchar(250)
			,@proc_type					nvarchar(50)
			,@category_type				nvarchar(50)
			,@branch_code_adjust		nvarchar(50)
			,@branch_name_adjust		nvarchar(250)
			,@fa_code_adjust			nvarchar(50)
			,@fa_name_adjust			nvarchar(250)
			,@division_code_adjust		nvarchar(50)
			,@division_name_adjust		nvarchar(250)
			,@department_code_adjust	nvarchar(50)
			,@department_name_adjust	nvarchar(250)
			,@specification_adjust		nvarchar(4000)
			,@code_asset_for_adjustment nvarchar(50)
			,@name_asset_for_adjustment nvarchar(250)
			,@date						datetime	  = dbo.xfn_get_system_date()
			,@item_code_adj				nvarchar(50)
			,@item_name_adj				nvarchar(250)
			,@uom_name_adj				nvarchar(15)
			,@quantity_adj				int
			,@adjustment_amount			decimal(18, 2)
			,@reff_no					nvarchar(50)
			,@invoice_date				datetime
			,@pph						decimal(18, 2)
			,@total_amount				decimal(18, 2)
			,@value						int
			,@value2					int
			,@receive_date				datetime 
			--
			,@request_code					nvarchar(50)
			,@request_code_doc				nvarchar(50)
			,@req_date						datetime
			,@interface_remarks				nvarchar(4000)
			,@reff_approval_category_code	nvarchar(50)
			,@table_name					nvarchar(50)
			,@primary_column				nvarchar(50)
			,@dimension_code				nvarchar(50)
			,@dim_value						nvarchar(50)
			,@approval_code					nvarchar(50)
			,@reff_dimension_code			nvarchar(50)
			,@reff_dimension_name			nvarchar(50)
			,@approval_path					nvarchar(4000)
			,@path							nvarchar(250)
			,@url_path						nvarchar(250)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@requestor_name				nvarchar(250)
			,@purchase_order_code			nvarchar(50)

	begin try
		if exists
		(
			select	1
			from	dbo.ap_invoice_registration
			where	code	   = @p_code
					and status = 'HOLD'
		)
		begin
			update	dbo.ap_invoice_registration
			set		status			= 'ON PROCESS'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code ;
		end ;
		else
		begin
			set @msg = N'Data already process' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if not exists
		(
			select	1
			from	dbo.ap_invoice_registration_detail
			where	invoice_register_code = @p_code
		)
		begin
			set @msg = N'Please add item list.' ;
			raiserror(@msg, 16, 1) ;
		end ;
		
		if exists (
					select 1 from dbo.ap_invoice_registration_detail invd
					inner join dbo.list_data_cleansing_invoice_dan_monitoring_ap_sebelum_crpriority_naik temptbl on invd.grn_code = temptbl.invoice_or_gnr_no
					where invd.invoice_register_code = @p_code
				)
		begin
			SET @msg = N'Pleace Contact IT Dept For Proceed This GRN Code.' ;
			raiserror(@msg, 16, 1) ;	    
		end

		select	@file_invoice  = isnull(file_invoice_no, '')
				,@remark	   = isnull(remark, '')
				,@to_bank_code = isnull(to_bank_code, '')
				,@invoice_date = tax_invoice_date
				,@receive_date = invoice_date
		from	dbo.ap_invoice_registration
		where	code = @p_code ;

		select	@value = value
		from	dbo.sys_global_param
		where	code = 'APINVBCM' ;

		if (@receive_date < dateadd(month, -@value, dbo.xfn_get_system_date()))
		begin
			set @msg = N'Invoice receive date cannot be back dated for more than ' + convert(varchar(1), @value) + N' months.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		select	@value2 = value
		from	dbo.sys_global_param
		where	CODE = 'APTXBCM' ;

		if (@invoice_date < dateadd(month, -@value2, dbo.xfn_get_system_date()))
		begin
			set @msg = N'Invoice tax date cannot be back dated for more than ' + convert(varchar(1), @value2) + N' months.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@invoice_date > dbo.xfn_get_system_date())
		begin
			set @msg = N'Invoice tax date must be less or equal than system date.' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if (@file_invoice = '')
		begin
			set @msg = N'Please input invoice no.' ;

			raiserror(@msg, 16, 1) ;
		end ;
		else if (@remark = '')
		begin
			set @msg = N'Please input remark.' ;

			raiserror(@msg, 16, 1) ;
		end ;
		else if (@to_bank_code = '')
		begin
			set @msg = N'Please input bank.' ;

			raiserror(@msg, 16, 1) ;
		end ;


		create table #TempGrnCode
		(
		    code_grn	nvarchar(50)
		)

		declare curr_diff_purchase cursor fast_forward read_only for
		select	ard.id
				,grnd.id
				,grnd.good_receipt_note_code
				,fgrnd.final_good_receipt_note_code
				,isnull(podoi.asset_code,'')
		from	dbo.ap_invoice_registration_detail				ard
				inner join dbo.ap_invoice_registration			air on ard.invoice_register_code		   = air.code
				inner join dbo.good_receipt_note_detail			grnd on grnd.good_receipt_note_code		   = ard.grn_code
																		and grnd.receive_quantity		   <> 0
																		and grnd.purchase_order_detail_id  = ard.purchase_order_id
				inner join dbo.final_good_receipt_note_detail	fgrnd on grnd.id						   = fgrnd.good_receipt_note_detail_id
				left join dbo.purchase_order_detail_object_info podoi on podoi.good_receipt_note_detail_id = grnd.id
		where	air.code = @p_code ;

		open curr_diff_purchase

		fetch next from curr_diff_purchase 
		into @id_detail
			,@id_grn
			,@code_grn
			,@code_final
			,@asset_code

		while @@fetch_status = 0
		begin
				select @amount_invoice	= purchase_amount
						,@ppn			= ppn
						,@discount		= discount
						,@pph			= pph
						,@total_amount	= total_amount
				from dbo.ap_invoice_registration_detail
				where id = @id_detail

				select @amount_grn = price_amount 
				from dbo.good_receipt_note_detail
				where id = @id_grn

				select @faktur_no = faktur_no 
				from dbo.ap_invoice_registration_detail_faktur
				where invoice_registration_detail_id = @id_detail

				if (@ppn > 0)
				begin
					if (isnull(@faktur_no,'') = '')
					begin
						set @msg = 'Please input faktur no.' ;
						raiserror(@msg, 16, 1) ;
					end
					else
					begin
						if(@amount_invoice <> @amount_grn)
						begin
							insert into #TempGrnCode
							(
								code_grn
							)
							values
							(
								@code_grn
							)

								--update	dbo.good_receipt_note_detail
								--set		price_amount		= @amount_invoice
								--		,ppn_amount			= @ppn
								--		,pph_amount			= @pph
								--		,discount_amount	= @discount
								--		,total_amount		= @total_amount
								--where	id = @id_grn ;
						end
					end
				end


		    fetch next from curr_diff_purchase 
			into @id_detail
				,@id_grn
				,@code_grn
				,@code_final
				,@asset_code
		end

		close curr_diff_purchase
		deallocate curr_diff_purchase

		----(+) sepria 07012025: ambil type ASSET, jika ada namun asset di ams belum terbentuk, keluarkan validasi.

		--select	top 1 @purchase_order_code = grn.purchase_order_code
		--from	dbo.ap_invoice_registration_detail				invd
		--		INNER join dbo.good_receipt_note_detail grnd on grnd.good_receipt_note_code = invd.GRN_CODE and grnd.item_code collate sql_latin1_general_cp1_ci_as = invd.item_code collate sql_latin1_general_cp1_ci_as and invd.quantity > 0
		--		inner join dbo.good_receipt_note				grn on (grn.code							  = grnd.good_receipt_note_code)
		--		inner join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
		--		inner join dbo.purchase_order_detail			pod on (
		--																	pod.po_code						  = po.code
		--																	and pod.id						  = grnd.purchase_order_detail_id
		--																)
		--		left join dbo.purchase_order_detail_object_info podoi on (
		--																		podoi.purchase_order_detail_id	  = pod.id
		--																		and   grnd.id					  = podoi.good_receipt_note_detail_id
		--																	)
		--		inner join dbo.supplier_selection_detail		ssd on (ssd.id								  = pod.supplier_selection_detail_id)
		--		left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
		--		inner join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
		--		inner join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
		--		inner join dbo.procurement_request_item			pri on (
		--																	pr.code							  = pri.procurement_request_code
		--																	and pri.item_code				  = grnd.item_code
		--																)

		--where	invoice_register_code = @p_code
		--		and grnd.receive_quantity		   <> 0
		--		and pri.category_type			   = 'ASSET'
		--		and isnull(podoi.asset_code,'') = '' 

		--if (isnull(@purchase_order_code,'') <> '')
		--begin

		--		set @msg = 'Please Post Final GRN Request For PO No. ' + isnull(@purchase_order_code,'')
		--		raiserror(@msg,16,1)
		--end

		select @branch_code		= value
				,@branch_name	= description
		from dbo.sys_global_param
		where code = 'HO'

		-- inser ke approval
		begin
			declare curr_grn_appv cursor fast_forward read_only for
			select pr.remark
					,pr.invoice_date
					,pr.mod_by
					,sem.name
			from dbo.ap_invoice_registration pr
			left join ifinsys.dbo.sys_employee_main sem on sem.code collate latin1_general_ci_as = pr.mod_by
			where pr.code = @p_code

			open curr_grn_appv

			fetch next from curr_grn_appv 
			into @remark
				,@req_date
				,@request_code
				,@requestor_name

			while @@fetch_status = 0
			begin
			    set @interface_remarks = 'Approval ' + ' Invoice Registration for ' + @p_code + ', branch ' + ': ' + @branch_name + ' ' + @remark ;

				select	@reff_approval_category_code = reff_approval_category_code
				from	dbo.master_approval
				where	code						 = 'INVAPV' ;

				--select path di global param
				select	@url_path = value
				from	dbo.sys_global_param
				where	code = 'URL_PATH' ;

				select	@path = @url_path + value
				from	dbo.sys_global_param
				where	code = 'PATHINV'

				--set approval path
				set	@approval_path = @path + @p_code

				exec dbo.xsp_proc_interface_approval_request_insert @p_code						= @request_code output
																	,@p_branch_code				= @branch_code
																	,@p_branch_name				= @branch_name
																	,@p_request_status			= 'HOLD'
																	,@p_request_date			= @req_date
																	,@p_request_amount			= 0
																	,@p_request_remarks			= @interface_remarks
																	,@p_reff_module_code		= 'IFINPROC'
																	,@p_reff_no					= @p_code
																	,@p_reff_name				= 'INVOICE REGISTRATION APPROVAL'
																	,@p_paths					= @approval_path
																	,@p_approval_category_code	= @reff_approval_category_code
																	,@p_approval_status			= 'HOLD'
																	,@p_requestor_code			= @request_code
																	,@p_requesttor_name			= @requestor_name
																	,@p_cre_date				= @p_mod_date	  
																	,@p_cre_by					= @p_mod_by		  
																	,@p_cre_ip_address			= @p_mod_ip_address
																	,@p_mod_date				= @p_mod_date	  
																	,@p_mod_by					= @p_mod_by		  
																	,@p_mod_ip_address			= @p_mod_ip_address

				declare curr_appv cursor fast_forward read_only for
				select 	approval_code
						,reff_dimension_code
						,reff_dimension_name
						,dimension_code
				from	dbo.master_approval_dimension
				where	approval_code = 'INVAPV'

				open curr_appv

				fetch next from curr_appv 
				into @approval_code
					,@reff_dimension_code
					,@reff_dimension_name
					,@dimension_code

				while @@fetch_status = 0
				begin
					select	@table_name					 = table_name
							,@primary_column			 = primary_column
					from	dbo.sys_dimension
					where	code						 = @dimension_code

					exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
																,@p_reff_code	= @p_code
																,@p_reff_table	= 'AP_INVOICE_REGISTRATION'
																,@p_output		= @dim_value output ;

					exec dbo.xsp_proc_interface_approval_request_dimension_insert @p_id						= 0
																				  ,@p_request_code			= @request_code
																				  ,@p_dimension_code		= @reff_dimension_code
																				  ,@p_dimension_value		= @dim_value
																				  ,@p_cre_date				= @p_mod_date
																				  ,@p_cre_by				= @p_mod_by
																				  ,@p_cre_ip_address		= @p_mod_ip_address
																				  ,@p_mod_date				= @p_mod_date
																				  ,@p_mod_by				= @p_mod_by
																				  ,@p_mod_ip_address		= @p_mod_ip_address

					-- GRN TIDAK ADA DOCUMENT

				end

			close curr_appv
			deallocate curr_appv

			    fetch next from curr_grn_appv 
				into @remark
					,@req_date
					,@request_code
					,@requestor_name

			end

			close curr_grn_appv
			deallocate curr_grn_appv

				update	dbo.ap_invoice_registration
				set		status = 'ON PROCESS'
						--  
						,mod_date = @p_mod_date
						,mod_by = @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code = @p_code ;
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
