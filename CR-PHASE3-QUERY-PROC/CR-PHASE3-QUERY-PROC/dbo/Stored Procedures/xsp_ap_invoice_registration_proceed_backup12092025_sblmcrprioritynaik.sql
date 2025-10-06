CREATE PROCEDURE dbo.xsp_ap_invoice_registration_proceed_backup12092025_sblmcrprioritynaik
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
		,@adjustment_amount			decimal(18,2)
		,@reff_no					nvarchar(50)
		,@invoice_date				datetime
		,@pph						decimal(18,2)
		,@total_amount				decimal(18,2)
		,@value						int
		,@value2					int
		,@receive_date				datetime

	begin try
		if exists
		(
			select	1
			from	dbo.ap_invoice_registration
			where	code		= @p_code
					and status	= 'HOLD'
		)
		begin
			update	dbo.ap_invoice_registration
			set		status				= 'ON PROCESS'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code ;
		end ;
		else
		begin
			set @msg = 'Data already process' ;

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

		select	@file_invoice  = isnull(file_invoice_no, '')
				,@remark	   = isnull(remark, '')
				,@to_bank_code = isnull(to_bank_code, '')
				,@invoice_date = tax_invoice_date
				,@receive_date = invoice_date
		from	dbo.ap_invoice_registration
		where	code = @p_code ;

		select	@value = value
		from	dbo.sys_global_param
		where	CODE = 'APINVBCM' ;

		if(@receive_date < dateadd(month, -@value, dbo.xfn_get_system_date()))
		begin
			set @msg = N'Invoice receive date cannot be back dated for more than ' + convert(varchar(1), @value) + ' months.' ;

			raiserror(@msg, 16, -1) ;
		end

		select	@value2 = value
		from	dbo.sys_global_param
		where	CODE = 'APTXBCM' ;

		if(@invoice_date < dateadd(month, -@value2, dbo.xfn_get_system_date()))
		begin
			set @msg = N'Invoice tax date cannot be back dated for more than ' + convert(varchar(1), @value2) + ' months.' ;

			raiserror(@msg, 16, -1) ;
		end

		--if(month(@invoice_date)  < month(dbo.xfn_get_system_date()))
		--begin
		--	set @msg = 'Invoice tax date must be in the same month as sytem date.' ;

		--	raiserror(@msg, 16, 1) ;
		--end

		if(@invoice_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Invoice tax date must be less or equal than system date.' ;

			raiserror(@msg, 16, 1) ;
		end

		if(@file_invoice = '')
		begin
			set @msg = 'Please input invoice no.' ;

			raiserror(@msg, 16, 1) ;
		end
		else if(@remark = '')
		begin
			set @msg = 'Please input remark.' ;

			raiserror(@msg, 16, 1) ;
		end
		else if(@to_bank_code = '')
		begin
			set @msg = 'Please input bank.' ;

			raiserror(@msg, 16, 1) ;
		end
		

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

				update	dbo.good_receipt_note_detail
				set		ppn_amount		= @ppn
						,total_amount	= @total_amount
						,pph_amount		= @pph 
				where	id	= @id_grn

				select @faktur_no = faktur_no 
				from dbo.ap_invoice_registration_detail_faktur
				where invoice_registration_detail_id = @id_detail

				if ((@ppn > 0) or (@pph > 0))
				begin
					if ((@ppn > 0) and (isnull(@faktur_no,'') = ''))
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

		--cursor untuk reverse journal GRN dan FINAL
		DECLARE curr_rev_jour CURSOR FAST_FORWARD READ_ONLY for
		select	distinct
				code_grn
		from	#TempGrnCode							temp
		
		OPEN curr_rev_jour
		
		FETCH NEXT FROM curr_rev_jour 
		into @temp_grn_code
			--,@code_final
		
		while @@fetch_status = 0
		begin
		    		--bikin jurnal reverse untuk GRN
					exec dbo.xsp_reverse_journal_grn @p_code			= @temp_grn_code
													 ,@p_mod_date		= @p_mod_date
													 ,@p_mod_by			= @p_mod_by
													 ,@p_mod_ip_address = @p_mod_ip_address

					--Jurnal baru GRN
					--exec dbo.xsp_new_journal_grn @p_code			= @temp_grn_code
					--							 ,@p_mod_date		= @p_mod_date
					--							 ,@p_mod_by			= @p_mod_by
					--							 ,@p_mod_ip_address = @p_mod_ip_address

					if exists (select 1 from dbo.ifinproc_interface_journal_gl_link_transaction where reff_source_no = @code_final and transaction_name = 'Final Good Receipt Note')
					begin

						--cursor untuk reverse journal FINAL dan buat journal GRN baru
						DECLARE curr_rev_jour_final CURSOR FAST_FORWARD READ_ONLY for
						select	distinct
								fgrnd.final_good_receipt_note_code
						from	dbo.good_receipt_note_detail				  grnd
								inner join dbo.final_good_receipt_note_detail fgrnd on fgrnd.good_receipt_note_detail_id = grnd.id
								inner join dbo.purchase_order_detail			 pod on pod.id								  = grnd.purchase_order_detail_id
								left join dbo.purchase_order_detail_object_info podoi on podoi.good_receipt_note_detail_id	  = grnd.id
																	  and  podoi.purchase_order_detail_id = pod.id
						where	grnd.good_receipt_note_code = @temp_grn_code
								and grnd.receive_quantity	<> 0 ;
						
						OPEN curr_rev_jour_final
						
						FETCH NEXT FROM curr_rev_jour_final 
						into @code_final
					
						while @@fetch_status = 0
						begin
							select	@reff_no = isnull(pr.asset_no,'')
							from	dbo.good_receipt_note_detail					   grnd
									inner join dbo.good_receipt_note				   grn on (grn.code								 = grnd.good_receipt_note_code)
									left join dbo.good_receipt_note_detail_object_info grndoi on (grndoi.good_receipt_note_detail_id = grnd.id)
									inner join dbo.purchase_order					   po on (po.code								 = grn.purchase_order_code)
									left join dbo.purchase_order_detail				   pod on (
																								  pod.po_code						 = po.code
																								  and pod.id						 = grnd.purchase_order_detail_id
																							  )
									left join dbo.supplier_selection_detail			   ssd on (ssd.id								 = pod.supplier_selection_detail_id)
									left join dbo.quotation_review_detail			   qrd on (qrd.id								 = ssd.quotation_detail_id)
									inner join dbo.procurement						   prc on (prc.code collate Latin1_General_CI_AS = isnull(qrd.reff_no, ssd.reff_no))
									inner join dbo.procurement_request				   pr on (pr.code								 = prc.procurement_request_code)
							where	grnd.good_receipt_note_code = @temp_grn_code
									and grnd.receive_quantity	<> 0 ;
							
							if(@reff_no <> '')
							begin
								--bikin jurnal reverse untuk FINAL
								exec dbo.xsp_reverse_journal_multiple_final @p_code				= @temp_grn_code
																			,@p_final_grn_code	= @code_final
																			,@p_company_code	= 'DSF'
																			,@p_mod_date		= @p_mod_date
																			,@p_mod_by			= @p_mod_by
																			,@p_mod_ip_address	= @p_mod_ip_address

								--Jurnal baru FINAL
								--exec dbo.xsp_new_journal_multiple_final @p_code					= @temp_grn_code
								--										,@p_invoice_code		= @p_code
								--										,@p_final_grn_code		= @code_final
								--										,@p_company_code		= 'DSF'
								--										,@p_mod_date			= @p_mod_date
								--										,@p_mod_by				= @p_mod_by
								--										,@p_mod_ip_address		= @p_mod_ip_address
								
								
							end
							else
							begin
					    		--bikin jurnal reverse untuk FINAL
								exec dbo.xsp_reverse_journal_final @p_code				= @temp_grn_code
																   ,@p_final_grn_code	= @code_final
																   ,@p_company_code		= 'DSF'
																   ,@p_mod_date			= @p_mod_date
																   ,@p_mod_by			= @p_mod_by
																   ,@p_mod_ip_address	= @p_mod_ip_address
								
								--Jurnal baru FINAL
								--exec dbo.xsp_new_journal_final @p_code				= @temp_grn_code
								--							   ,@p_final_grn_code	= @code_final
								--							   ,@p_company_code		= 'DSF'
								--							   ,@p_mod_date			= @p_mod_date
								--							   ,@p_mod_by			= @p_mod_by
								--							   ,@p_mod_ip_address	= @p_mod_ip_address
							end

							select	@proc_req_code	= pr.code
									,@item_code		= grnd.item_code
									,@item_name		= grnd.item_name
									,@proc_type		= pr.procurement_type
							from	dbo.good_receipt_note_detail					grnd
									left join dbo.good_receipt_note					grn on (grn.code							  = grnd.good_receipt_note_code)
									left join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.good_receipt_note_detail_id	  = grnd.id)
									left join dbo.final_good_receipt_note			fgrn on (fgrn.code							  = fgrnd.final_good_receipt_note_code)
									left join dbo.purchase_order_detail_object_info podo on (podo.good_receipt_note_detail_id	  = grnd.id)
									left join dbo.sys_general_subcode				sgs on (sgs.code							  = grnd.type_asset_code)
																						   and	 sgs.company_code				  = 'DSF'
									left join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
									left join dbo.purchase_order_detail				pod on (
																							   pod.po_code						  = po.code
																							   and pod.id						  = grnd.purchase_order_detail_id
																						   )
									left join dbo.supplier_selection_detail			ssd on (ssd.id								  = pod.supplier_selection_detail_id)
									left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
									left join dbo.procurement						prc on (prc.code collate Latin1_General_CI_AS = isnull(qrd.reff_no,ssd.reff_no))
									left join dbo.procurement_request				pr on (pr.code								  = prc.procurement_request_code)
							where	fgrn.code				  = @code_final
									and grnd.receive_quantity <> 0 ;

							--declare curr_category_type cursor fast_forward read_only for
							--select	distinct category_type
							--from	dbo.procurement_request_item
							--where	procurement_request_code = @proc_req_code
							--		and item_code			 = @item_code ;
							
							--open curr_category_type
							
							--fetch next from curr_category_type 
							--into @category_type
							
							--while @@fetch_status = 0
							--begin
							--		if(@category_type = 'ASSET')
							--		begin
							--			declare curr_update_asset cursor fast_forward read_only for
							--			select	distinct
							--					podoi.asset_code
							--			from	dbo.good_receipt_note_detail				  grnd
							--					inner join dbo.final_good_receipt_note_detail fgrnd on fgrnd.good_receipt_note_detail_id = grnd.id
							--					inner join dbo.purchase_order_detail			 pod on pod.id								  = grnd.purchase_order_detail_id
							--					inner join dbo.purchase_order_detail_object_info podoi on podoi.good_receipt_note_detail_id	  = grnd.id
							--														  and  podoi.purchase_order_detail_id = pod.id
							--			where	grnd.good_receipt_note_code = @temp_grn_code
							--					and grnd.receive_quantity	<> 0 ;
							
							--			open curr_update_asset
							
							--			fetch next from curr_update_asset 
							--			into @asset_code
							
							--			while @@fetch_status = 0
							--			begin
							--			    select	@purchase		= sum(aird.purchase_amount - aird.discount) / aird.quantity
							--				from	dbo.final_good_receipt_note						fgrn
							--						inner join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.final_good_receipt_note_code  = fgrn.code)
							--						left join dbo.good_receipt_note_detail			grnd on (grnd.id							  = fgrnd.good_receipt_note_detail_id)
							--						left join dbo.good_receipt_note					grn on (grn.code							  = grnd.good_receipt_note_code)
							--						left join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
							--						left join dbo.purchase_order_detail				pod on (
							--																				   pod.po_code						  = po.code
							--																				   and pod.id						  = grnd.purchase_order_detail_id
							--																			   )
							--						inner join dbo.ap_invoice_registration_detail	aird on (
							--																					aird.purchase_order_id			  = pod.id
							--																					and	 grn.code					  = aird.grn_code
							--																				)
							--						left join dbo.purchase_order_detail_object_info podoi on (
							--																					 podoi.purchase_order_detail_id	  = aird.purchase_order_id
							--																					 and   grnd.id					  = podoi.good_receipt_note_detail_id
							--																				 )
							--						inner join dbo.supplier_selection_detail		ssd on (ssd.id								  = pod.supplier_selection_detail_id)
							--						left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
							--						inner join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
							--						inner join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
							--						inner join dbo.procurement_request_item			pri on (
							--																				   pr.code							  = pri.procurement_request_code
							--																				   and pri.item_code				  = grnd.item_code
							--																			   )
							--				where	fgrn.code = @code_final
							--				group by aird.quantity

							--				select	@amount_invoice = sum(aird.purchase_amount)--/aird.quantity
							--				from	dbo.final_good_receipt_note					  fgrn
							--						inner join dbo.final_good_receipt_note_detail fgrnd on (fgrnd.final_good_receipt_note_code	= fgrn.code)
							--						left join dbo.good_receipt_note_detail		  grnd on (grnd.id								= fgrnd.good_receipt_note_detail_id)
							--						left join dbo.good_receipt_note				  grn on (grn.code								= grnd.good_receipt_note_code)
							--						left join dbo.purchase_order				  po on (po.code								= grn.purchase_order_code)
							--						left join dbo.purchase_order_detail			  pod on (
							--																				 pod.po_code						= po.code
							--																				 and pod.id							= grnd.purchase_order_detail_id
							--																			 )
							--						inner join dbo.ap_invoice_registration_detail aird on (
							--																				  aird.purchase_order_id			= pod.id
							--																				  and  grn.code						= aird.grn_code
							--																			  )
							--						inner join dbo.supplier_selection_detail	  ssd on (ssd.id								= pod.supplier_selection_detail_id)
							--						left join dbo.quotation_review_detail		  qrd on (qrd.id								= ssd.quotation_detail_id)
							--						inner join dbo.procurement					  prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
							--						inner join dbo.procurement_request			  pr on (prc.procurement_request_code			= pr.code)
							--						inner join dbo.procurement_request_item		  pri on (
							--																				 pr.code							= pri.procurement_request_code
							--																				 and pri.item_code					= grnd.item_code
							--																			 )
							--				where	fgrn.code = @code_final
							--				group by aird.quantity

							--				--insert ke interface harga asset yang baru
							--				exec dbo.xsp_ifinproc_new_asset_insert @p_id				= 0
							--													   ,@p_asset_code		= @asset_code
							--													   ,@p_purchase_price	= @purchase
							--													   ,@p_orig_amount		= @amount_invoice
							--													   ,@p_cre_date			= @p_mod_date
							--													   ,@p_cre_by			= @p_mod_by
							--													   ,@p_cre_ip_address	= @p_mod_ip_address
							--													   ,@p_mod_date			= @p_mod_date
							--													   ,@p_mod_by			= @p_mod_by
							--													   ,@p_mod_ip_address	= @p_mod_ip_address
										
							--			    fetch next from curr_update_asset 
							--				into @asset_code
							--			end
										
							--			close curr_update_asset
							--			deallocate curr_update_asset
							--		end
							--		else if (@category_type = 'ACCESSORIES' or @category_type = 'KAROSERI')
							--		begin
							--			begin --insert ke adjustment
							--				declare cursor_name cursor fast_forward read_only for
							--				select	pr.branch_code
							--						,pr.branch_name
							--						,pri.fa_code
							--						,pri.fa_name
							--						,pr.division_code
							--						,pr.division_name
							--						,pr.department_code
							--						,pr.department_name
							--						,pri.specification
							--						,pri.item_code
							--						,pri.item_name
							--						,pri.uom_name
							--						,pri.approved_quantity
							--				from dbo.procurement_request pr
							--				left join dbo.procurement_request_item pri on (pr.code = pri.procurement_request_code)
							--				where pr.code = @proc_req_code
							--				and pri.item_code = @item_code
											
							--				open cursor_name
											
							--				fetch next from cursor_name 
							--				into @branch_code_adjust
							--					,@branch_name_adjust
							--					,@fa_code_adjust
							--					,@fa_name_adjust
							--					,@division_code_adjust
							--					,@division_name_adjust
							--					,@department_code_adjust
							--					,@department_name_adjust
							--					,@specification_adjust
							--					,@item_code_adj
							--					,@item_name_adj
							--					,@uom_name_adj
							--					,@quantity_adj
											
							--				while @@fetch_status = 0
							--				begin
							--						set @code_asset_for_adjustment = isnull(@fa_code_adjust, @code)
							--						set @name_asset_for_adjustment = isnull(@fa_name_adjust, @item_name)

							--						select	@amount_grn = grnd.price_amount
							--						from	dbo.good_receipt_note_detail				  grnd
							--								inner join dbo.final_good_receipt_note_detail fgrnd on grnd.id = fgrnd.good_receipt_note_detail_id
							--						where	fgrnd.final_good_receipt_note_code = @code_final ;

							--						select	@amount_invoice = ard.purchase_amount
							--						from	dbo.final_good_receipt_note_detail			  fgrnd
							--								inner join dbo.good_receipt_note_detail		  grnd on fgrnd.good_receipt_note_detail_id = grnd.id
							--								inner join dbo.ap_invoice_registration_detail ard on ard.grn_code						= grnd.good_receipt_note_code
							--								inner join dbo.ap_invoice_registration		  air on ard.invoice_register_code			= air.code
							--																					 and  air.code						= @p_code
							--						where	fgrnd.final_good_receipt_note_code = @code_final ;

							--						set @adjustment_amount = @amount_invoice - @amount_grn

							--						exec dbo.xsp_ifinproc_interface_adjustment_asset_insert @p_id					= 0
							--																				,@p_code				= @p_code
							--																				,@p_branch_code			= @branch_code_adjust
							--																				,@p_branch_name			= @branch_name_adjust
							--																				,@p_date				= @date
							--																				,@p_fa_code				= @code_asset_for_adjustment
							--																				,@p_fa_name				= @name_asset_for_adjustment
							--																				,@p_item_code			= @item_code_adj
							--																				,@p_item_name			= @item_name_adj
							--																				,@p_division_code		= @division_code_adjust
							--																				,@p_division_name		= @division_name_adjust
							--																				,@p_department_code		= @department_code_adjust
							--																				,@p_department_name		= @department_name_adjust
							--																				,@p_description			= @specification_adjust
							--																				,@p_adjustment_amount	= @adjustment_amount
							--																				,@p_quantity			= @quantity_adj
							--																				,@p_uom					= @uom_name_adj
							--																				,@p_type_asset			= 'SINGLE'
							--																				,@p_job_status			= 'HOLD'
							--																				,@p_failed_remarks		= ''
							--																				,@p_cre_date			= @p_mod_date
							--																				,@p_cre_by				= @p_mod_by
							--																				,@p_cre_ip_address		= @p_mod_ip_address
							--																				,@p_mod_date			= @p_mod_date
							--																				,@p_mod_by				= @p_mod_by
							--																				,@p_mod_ip_address		= @p_mod_ip_address
														
							--				    fetch next from cursor_name 
							--					into @branch_code_adjust
							--						,@branch_name_adjust
							--						,@fa_code_adjust
							--						,@fa_name_adjust
							--						,@division_code_adjust
							--						,@division_name_adjust
							--						,@department_code_adjust
							--						,@department_name_adjust
							--						,@specification_adjust
							--						,@item_code_adj
							--						,@item_name_adj
							--						,@uom_name_adj
							--						,@quantity_adj
							--				end
											
							--				close cursor_name
							--				deallocate cursor_name
							--			end
							--		end
							--    fetch next from curr_category_type 
							--	into @category_type
							--end
							
							--close curr_category_type
							--deallocate curr_category_type 

					    FETCH NEXT FROM curr_rev_jour_final 
						into @code_final
					END
						
						CLOSE curr_rev_jour_final
						DEALLOCATE curr_rev_jour_final
					end
					
		    FETCH NEXT FROM curr_rev_jour 
			into @temp_grn_code
		END
		
		CLOSE curr_rev_jour
		DEALLOCATE curr_rev_jour

		--update nilai GRN yang baru
		declare curr_update_grn cursor fast_forward read_only for
		select	ard.id
				,grnd.id
		from	dbo.ap_invoice_registration_detail				ard
				inner join dbo.ap_invoice_registration			air on ard.invoice_register_code		   = air.code
				inner join dbo.good_receipt_note_detail			grnd on grnd.good_receipt_note_code		   = ard.grn_code
																		and grnd.receive_quantity		   <> 0
																		and grnd.purchase_order_detail_id  = ard.purchase_order_id
		where	air.code = @p_code ;
		
		open curr_update_grn
		
		fetch next from curr_update_grn 
		into @id_detail
			,@id_grn
		
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

				if(@amount_grn <> @amount_invoice)
				begin
					update	dbo.good_receipt_note_detail
					set		price_amount		= @amount_invoice
							,ppn_amount			= @ppn
							,pph_amount			= @pph
							,discount_amount	= @discount
							,total_amount		= @total_amount
					where	id = @id_grn ;
				end

		    fetch next from curr_update_grn 
			into @id_detail
				,@id_grn
		end
		
		close curr_update_grn
		deallocate curr_update_grn

		-- cursor untuk buat journal GRN dan final baru
		DECLARE curr_rev_jour2 CURSOR FAST_FORWARD READ_ONLY for
		select	distinct
				code_grn
		from	#TempGrnCode							temp
		
		OPEN curr_rev_jour2
		
		FETCH NEXT FROM curr_rev_jour2 
		into @temp_grn_code
			--,@code_final
		
		while @@fetch_status = 0
		begin
					--Jurnal baru GRN
					exec dbo.xsp_new_journal_grn @p_code			= @temp_grn_code
												 ,@p_mod_date		= @p_mod_date
												 ,@p_mod_by			= @p_mod_by
												 ,@p_mod_ip_address = @p_mod_ip_address

					if exists (select 1 from dbo.ifinproc_interface_journal_gl_link_transaction where reff_source_no = @code_final and transaction_name = 'Final Good Receipt Note')
					begin

						--cursor untuk reverse journal FINAL dan buat journal GRN baru
						DECLARE curr_rev_jour_final2 CURSOR FAST_FORWARD READ_ONLY for
						select	distinct
								fgrnd.final_good_receipt_note_code
						from	dbo.good_receipt_note_detail				  grnd
								inner join dbo.final_good_receipt_note_detail fgrnd on fgrnd.good_receipt_note_detail_id = grnd.id
								inner join dbo.purchase_order_detail			 pod on pod.id								  = grnd.purchase_order_detail_id
								left join dbo.purchase_order_detail_object_info podoi on podoi.good_receipt_note_detail_id	  = grnd.id
																	  and  podoi.purchase_order_detail_id = pod.id
						where	grnd.good_receipt_note_code = @temp_grn_code
								and grnd.receive_quantity	<> 0 ;
						
						OPEN curr_rev_jour_final2
						
						FETCH NEXT FROM curr_rev_jour_final2 
						into @code_final
					
						while @@fetch_status = 0
						begin
							select	@reff_no		= isnull(pr.asset_no, '')
									,@category_type = mi.category_type
							from	dbo.good_receipt_note_detail					   grnd
									inner join dbo.good_receipt_note				   grn on (grn.code								 = grnd.good_receipt_note_code)
									left join dbo.good_receipt_note_detail_object_info grndoi on (grndoi.good_receipt_note_detail_id = grnd.id)
									inner join dbo.purchase_order					   po on (po.code								 = grn.purchase_order_code)
									left join dbo.purchase_order_detail				   pod on (
																								  pod.po_code						 = po.code
																								  and pod.id						 = grnd.purchase_order_detail_id
																							  )
									left join dbo.supplier_selection_detail			   ssd on (ssd.id								 = pod.supplier_selection_detail_id)
									left join dbo.quotation_review_detail			   qrd on (qrd.id								 = ssd.quotation_detail_id)
									inner join dbo.procurement						   prc on (prc.code collate Latin1_General_CI_AS = isnull(qrd.reff_no, ssd.reff_no))
									inner join dbo.procurement_request				   pr on (pr.code								 = prc.procurement_request_code)
									inner join ifinbam.dbo.master_item				   mi on (mi.code								 = grnd.item_code)
							where	grnd.good_receipt_note_code = @temp_grn_code
									and grnd.receive_quantity	<> 0 ;
							
							if(@reff_no <> '')
							begin
								--Jurnal baru FINAL
								exec dbo.xsp_new_journal_multiple_final @p_code					= @temp_grn_code
																		,@p_invoice_code		= @p_code
																		,@p_final_grn_code		= @code_final
																		,@p_company_code		= 'DSF'
																		,@p_mod_date			= @p_mod_date
																		,@p_mod_by				= @p_mod_by
																		,@p_mod_ip_address		= @p_mod_ip_address
								
								
							end
							else
							begin								
								--Jurnal baru FINAL
								exec dbo.xsp_new_journal_final @p_code				= @temp_grn_code
															   ,@p_final_grn_code	= @code_final
															   ,@p_company_code		= 'DSF'
															   ,@p_mod_date			= @p_mod_date
															   ,@p_mod_by			= @p_mod_by
															   ,@p_mod_ip_address	= @p_mod_ip_address
							end

							--declare curr_category_type2 cursor fast_forward read_only for
							----select	distinct category_type
							----from	dbo.procurement_request_item
							----where	procurement_request_code = @proc_req_code
							----		and item_code			 = @item_code ;
							--select	mi.category_type
							--from	dbo.ap_invoice_registration_detail aird
							--		left join ifinbam.dbo.master_item mi on mi.code collate Latin1_General_CI_AS = aird.item_code
							--where	aird.invoice_register_code = @p_code ;
							
							--open curr_category_type2
							
							--fetch next from curr_category_type2 
							--into @category_type
							
							--while @@fetch_status = 0
							--begin
								if(@reff_no = '')
								begin
									if(@category_type = 'ASSET')
									begin
										declare curr_update_asset cursor fast_forward read_only for
										select	distinct
												podoi.asset_code
										from	dbo.good_receipt_note_detail				  grnd
												inner join dbo.final_good_receipt_note_detail fgrnd on fgrnd.good_receipt_note_detail_id = grnd.id
												inner join dbo.purchase_order_detail			 pod on pod.id								  = grnd.purchase_order_detail_id
												inner join dbo.purchase_order_detail_object_info podoi on podoi.good_receipt_note_detail_id	  = grnd.id
																					  and  podoi.purchase_order_detail_id = pod.id
										where	grnd.good_receipt_note_code = @temp_grn_code
												and grnd.receive_quantity	<> 0 ;
							
										open curr_update_asset
							
										fetch next from curr_update_asset 
										into @asset_code
							
										while @@fetch_status = 0
										begin
											 --update harga asset
											select	@purchase = sum(grnd.price_amount - grnd.discount_amount)
											from	dbo.final_good_receipt_note						fgrn
													inner join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.final_good_receipt_note_code  = fgrn.code)
													left join dbo.good_receipt_note_detail			grnd on (grnd.id							  = fgrnd.good_receipt_note_detail_id)
													left join dbo.good_receipt_note					grn on (grn.code							  = grnd.good_receipt_note_code)
													left join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
													left join dbo.purchase_order_detail				pod on (
																											   pod.po_code						  = po.code
																											   and pod.id						  = grnd.purchase_order_detail_id
																										   )
													inner join dbo.supplier_selection_detail		ssd on (ssd.id								  = pod.supplier_selection_detail_id)
													left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
													inner join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
													inner join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
													inner join dbo.procurement_request_item			pri on (
																											   pr.code							  = pri.procurement_request_code
																											   and pri.item_code				  = grnd.item_code
																										   )
											where	fgrn.code = @code_final ;

											select	@amount_invoice = sum(grnd.price_amount)
											from	dbo.final_good_receipt_note					  fgrn
													inner join dbo.final_good_receipt_note_detail fgrnd on (fgrnd.final_good_receipt_note_code	= fgrn.code)
													left join dbo.good_receipt_note_detail		  grnd on (grnd.id								= fgrnd.good_receipt_note_detail_id)
													left join dbo.good_receipt_note				  grn on (grn.code								= grnd.good_receipt_note_code)
													left join dbo.purchase_order				  po on (po.code								= grn.purchase_order_code)
													left join dbo.purchase_order_detail			  pod on (
																											 pod.po_code						= po.code
																											 and pod.id							= grnd.purchase_order_detail_id
																										 )
													inner join dbo.supplier_selection_detail	  ssd on (ssd.id								= pod.supplier_selection_detail_id)
													left join dbo.quotation_review_detail		  qrd on (qrd.id								= ssd.quotation_detail_id)
													inner join dbo.procurement					  prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
													inner join dbo.procurement_request			  pr on (prc.procurement_request_code			= pr.code)
													inner join dbo.procurement_request_item		  pri on (
																											 pr.code							= pri.procurement_request_code
																											 and pri.item_code					= grnd.item_code
																										 )
											where	fgrn.code = @code_final

											--insert ke interface harga asset yang baru
											exec dbo.xsp_ifinproc_new_asset_insert @p_id					= 0
																				   ,@p_asset_code			= @asset_code
																				   ,@p_purchase_price		= @purchase
																				   ,@p_orig_amount			= @amount_invoice
																				   ,@p_type					= 'ASSET'
																				   ,@p_posting_date			= @date
																				   ,@p_return_date			= null
																				   ,@p_invoice_date_type	= 'POST'
																				   ,@p_invoice_code			= @p_code
																				   --
																				   ,@p_cre_date				= @p_mod_date
																				   ,@p_cre_by				= @p_mod_by
																				   ,@p_cre_ip_address		= @p_mod_ip_address
																				   ,@p_mod_date				= @p_mod_date
																				   ,@p_mod_by				= @p_mod_by
																				   ,@p_mod_ip_address		= @p_mod_ip_address
										
										    fetch next from curr_update_asset 
											into @asset_code
										end
										
										close curr_update_asset
										deallocate curr_update_asset
									end
									else if (@category_type = 'ACCESSORIES' or @category_type = 'KAROSERI') --or @category_type = 'GPS') DICOMMENT RAFFY, DI GRN GPS GAK BENTU ADJUSTMENT
									begin
										begin --insert ke adjustment
											--select code asset jika tidak adjust manual
											select	@asset_code = podoi.asset_code
													,@item_name	= pri.item_name
											from	dbo.final_good_receipt_note_detail				fgrnd
													inner join dbo.good_receipt_note_detail			grnd on grnd.id								  = fgrnd.good_receipt_note_detail_id
													inner join dbo.good_receipt_note				grn on (grn.code							  = grnd.good_receipt_note_code)
													inner join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
													inner join dbo.purchase_order_detail			pod on (
																											   pod.po_code						  = po.code
																											   and pod.id						  = grnd.purchase_order_detail_id
																										   )
													left join dbo.purchase_order_detail_object_info podoi on (
																												 podoi.purchase_order_detail_id	  = pod.id
																												 and   grnd.id					  = podoi.good_receipt_note_detail_id
																											 )
													inner join dbo.supplier_selection_detail		ssd on (ssd.id								  = pod.supplier_selection_detail_id)
													left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
													inner join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
													inner join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
													inner join dbo.procurement_request_item			pri on (
																											   pr.code							  = pri.procurement_request_code
																											   and pri.item_code				  = grnd.item_code
																										   )
											where	fgrnd.final_good_receipt_note_code = @code_final
													and grnd.receive_quantity	<> 0
													and pri.category_type		= 'ASSET' ;
											   													
											declare curr_diff_amount cursor fast_forward read_only for
											--select	ard.id
											--		,grnd.id
											--from	dbo.ap_invoice_registration_detail				ard
											--		inner join dbo.ap_invoice_registration			air on ard.invoice_register_code		   = air.code
											--		inner join dbo.good_receipt_note_detail			grnd on grnd.good_receipt_note_code		   = ard.grn_code
											--																and grnd.receive_quantity		   <> 0
											--																and grnd.purchase_order_detail_id  = ard.purchase_order_id
											--where	air.code = @p_code ;
											select	ard.id
													,grnd.id
											from	dbo.ap_invoice_registration_detail				ard
													inner join dbo.ap_invoice_registration			air on ard.invoice_register_code		   = air.code
													inner join dbo.good_receipt_note_detail			grnd on grnd.good_receipt_note_code		   = ard.grn_code
																											and grnd.receive_quantity		   <> 0
																											and grnd.purchase_order_detail_id  = ard.purchase_order_id
													inner join dbo.final_good_receipt_note_detail fgrnd on fgrnd.good_receipt_note_detail_id = grnd.id
											where	fgrnd.final_good_receipt_note_code = @code_final
											and ard.invoice_register_code = @p_code
											
											open curr_diff_amount
											
											fetch next from curr_diff_amount 
											into @id_detail
												,@id_grn
											
											while @@fetch_status = 0
											begin
														
														select	@amount_grn = grnd.orig_price_amount
														from	dbo.good_receipt_note_detail grnd
														where	grnd.ID = @id_grn ;

														select	@amount_invoice = purchase_amount
														from	dbo.ap_invoice_registration_detail
														where	id = @id_detail ;

														select	@proc_req_code  = pr.code
																,@item_code		= pri.item_code
														from	dbo.final_good_receipt_note_detail				fgrnd
																inner join dbo.good_receipt_note_detail			grnd on grnd.id								  = fgrnd.good_receipt_note_detail_id
																inner join dbo.good_receipt_note				grn on (grn.code							  = grnd.good_receipt_note_code)
																inner join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
																inner join dbo.purchase_order_detail			pod on (
																														   pod.po_code						  = po.code
																														   and pod.id						  = grnd.purchase_order_detail_id
																													   )
																left join dbo.purchase_order_detail_object_info podoi on (
																															 podoi.purchase_order_detail_id	  = pod.id
																															 and   grnd.id					  = podoi.good_receipt_note_detail_id
																														 )
																inner join dbo.supplier_selection_detail		ssd on (ssd.id								  = pod.supplier_selection_detail_id)
																left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
																inner join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
																inner join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
																inner join dbo.procurement_request_item			pri on (
																														   pr.code							  = pri.procurement_request_code
																														   and pri.item_code				  = grnd.item_code
																													   )
														where	grnd.id = @id_grn

														declare curr_adj cursor fast_forward read_only for
														select	pr.branch_code
																,pr.branch_name
																,pri.fa_code
																,pri.fa_name
																,pr.division_code
																,pr.division_name
																,pr.department_code
																,pr.department_name
																,pri.specification
																,pri.item_code
																,pri.item_name
																,pri.uom_name
																,pri.approved_quantity
														from dbo.procurement_request pr
														left join dbo.procurement_request_item pri on (pr.code = pri.procurement_request_code)
														where pr.code = @proc_req_code
														and pri.item_code = @item_code
											
														open curr_adj
														
														fetch next from curr_adj 
														into @branch_code_adjust
															,@branch_name_adjust
															,@fa_code_adjust
															,@fa_name_adjust
															,@division_code_adjust
															,@division_name_adjust
															,@department_code_adjust
															,@department_name_adjust
															,@specification_adjust
															,@item_code_adj
															,@item_name_adj
															,@uom_name_adj
															,@quantity_adj
														
														while @@fetch_status = 0
														begin
															set @code_asset_for_adjustment = isnull(@fa_code_adjust, @asset_code)
															set @name_asset_for_adjustment = isnull(@fa_name_adjust, @item_name)

															if(@amount_grn <> @amount_invoice)
															begin
															set @adjustment_amount = @amount_invoice - @amount_grn

															exec dbo.xsp_ifinproc_interface_adjustment_asset_insert @p_id					= 0
																													,@p_code				= @p_code
																													,@p_branch_code			= @branch_code_adjust
																													,@p_branch_name			= @branch_name_adjust
																													,@p_date				= @date
																													,@p_fa_code				= @code_asset_for_adjustment
																													,@p_fa_name				= @name_asset_for_adjustment
																													,@p_item_code			= @item_code_adj
																													,@p_item_name			= @item_name_adj
																													,@p_division_code		= @division_code_adjust
																													,@p_division_name		= @division_name_adjust
																													,@p_department_code		= @department_code_adjust
																													,@p_department_name		= @department_name_adjust
																													,@p_description			= @specification_adjust
																													,@p_adjustment_amount	= @adjustment_amount
																													,@p_quantity			= @quantity_adj
																													,@p_uom					= @uom_name_adj
																													,@p_type_asset			= 'SINGLE'
																													,@p_job_status			= 'HOLD'
																													,@p_failed_remarks		= ''
																													,@p_adjust_type			= 'INVOICE'
																													--
																													,@p_cre_date			= @p_mod_date
																													,@p_cre_by				= @p_mod_by
																													,@p_cre_ip_address		= @p_mod_ip_address
																													,@p_mod_date			= @p_mod_date
																													,@p_mod_by				= @p_mod_by
																													,@p_mod_ip_address		= @p_mod_ip_address


															--insert ke interface harga asset yang baru
															exec dbo.xsp_ifinproc_new_asset_insert @p_id					= 0
																								   ,@p_asset_code			= @asset_code
																								   ,@p_purchase_price		= @purchase
																								   ,@p_orig_amount			= @adjustment_amount
																								   ,@p_type					= 'NOT ASSET'
																								   ,@p_posting_date			= @date
																								   ,@p_return_date			= null
																								   ,@p_invoice_date_type	= 'POST'
																								   ,@p_invoice_code			= @p_code
																								   --
																								   ,@p_cre_date				= @p_mod_date
																								   ,@p_cre_by				= @p_mod_by
																								   ,@p_cre_ip_address		= @p_mod_ip_address
																								   ,@p_mod_date				= @p_mod_date
																								   ,@p_mod_by				= @p_mod_by
																								   ,@p_mod_ip_address		= @p_mod_ip_address
														end

															fetch next from curr_adj 
															into @branch_code_adjust
																,@branch_name_adjust
																,@fa_code_adjust
																,@fa_name_adjust
																,@division_code_adjust
																,@division_name_adjust
																,@department_code_adjust
																,@department_name_adjust
																,@specification_adjust
																,@item_code_adj
																,@item_name_adj
																,@uom_name_adj
																,@quantity_adj
														end
														
														close curr_adj
														deallocate curr_adj
													
													    fetch next from curr_diff_amount 
														into @id_detail
															,@id_grn
													end
											
											close curr_diff_amount
											deallocate curr_diff_amount
										end
									end
								end
								else
								begin
									declare curr_update_asset cursor fast_forward read_only for
									--select	distinct
									--		podoi.asset_code
									--from	dbo.good_receipt_note_detail				  grnd
									--		inner join dbo.final_good_receipt_note_detail fgrnd on fgrnd.good_receipt_note_detail_id = grnd.id
									--		inner join dbo.purchase_order_detail			 pod on pod.id								  = grnd.purchase_order_detail_id
									--		inner join dbo.purchase_order_detail_object_info podoi on podoi.good_receipt_note_detail_id	  = grnd.id
									--											  and  podoi.purchase_order_detail_id = pod.id
									--where	grnd.good_receipt_note_code = @temp_grn_code
									--		and grnd.receive_quantity	<> 0 ;
									select	podoi.asset_code
									from	dbo.final_good_receipt_note_detail				fgrnd
											inner join dbo.good_receipt_note_detail			grnd on grnd.id								  = fgrnd.good_receipt_note_detail_id
											inner join dbo.good_receipt_note				grn on (grn.code							  = grnd.good_receipt_note_code)
											inner join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
											inner join dbo.purchase_order_detail			pod on (
																									   pod.po_code						  = po.code
																									   and pod.id						  = grnd.purchase_order_detail_id
																								   )
											left join dbo.purchase_order_detail_object_info podoi on (
																										 podoi.purchase_order_detail_id	  = pod.id
																										 and   grnd.id					  = podoi.good_receipt_note_detail_id
																									 )
											inner join dbo.supplier_selection_detail		ssd on (ssd.id								  = pod.supplier_selection_detail_id)
											left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
											inner join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
											inner join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
											inner join dbo.procurement_request_item			pri on (
																									   pr.code							  = pri.procurement_request_code
																									   and pri.item_code				  = grnd.item_code
																								   )
									where	fgrnd.final_good_receipt_note_code = @code_final
											and grnd.receive_quantity		   <> 0
											and pri.category_type			   = 'ASSET' ;
							
									open curr_update_asset
							
									fetch next from curr_update_asset 
									into @asset_code
							
									while @@fetch_status = 0
									begin	
											 --update harga asset
											select	@purchase = sum(grnd.price_amount - grnd.discount_amount)
											from	dbo.final_good_receipt_note						fgrn
													inner join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.final_good_receipt_note_code  = fgrn.code)
													left join dbo.good_receipt_note_detail			grnd on (grnd.id							  = fgrnd.good_receipt_note_detail_id)
													left join dbo.good_receipt_note					grn on (grn.code							  = grnd.good_receipt_note_code)
													left join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
													left join dbo.purchase_order_detail				pod on (
																											   pod.po_code						  = po.code
																											   and pod.id						  = grnd.purchase_order_detail_id
																										   )
													inner join dbo.supplier_selection_detail		ssd on (ssd.id								  = pod.supplier_selection_detail_id)
													left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
													inner join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
													inner join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
													inner join dbo.procurement_request_item			pri on (
																											   pr.code							  = pri.procurement_request_code
																											   and pri.item_code				  = grnd.item_code
																										   )
											where	fgrn.code = @code_final ;

											select	@amount_invoice = sum(grnd.price_amount)
											from	dbo.final_good_receipt_note					  fgrn
													inner join dbo.final_good_receipt_note_detail fgrnd on (fgrnd.final_good_receipt_note_code	= fgrn.code)
													left join dbo.good_receipt_note_detail		  grnd on (grnd.id								= fgrnd.good_receipt_note_detail_id)
													left join dbo.good_receipt_note				  grn on (grn.code								= grnd.good_receipt_note_code)
													left join dbo.purchase_order				  po on (po.code								= grn.purchase_order_code)
													left join dbo.purchase_order_detail			  pod on (
																											 pod.po_code						= po.code
																											 and pod.id							= grnd.purchase_order_detail_id
																										 )
													inner join dbo.supplier_selection_detail	  ssd on (ssd.id								= pod.supplier_selection_detail_id)
													left join dbo.quotation_review_detail		  qrd on (qrd.id								= ssd.quotation_detail_id)
													inner join dbo.procurement					  prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
													inner join dbo.procurement_request			  pr on (prc.procurement_request_code			= pr.code)
													inner join dbo.procurement_request_item		  pri on (
																											 pr.code							= pri.procurement_request_code
																											 and pri.item_code					= grnd.item_code
																										 )
											where	fgrn.code = @code_final

											--insert ke interface harga asset yang baru
											exec dbo.xsp_ifinproc_new_asset_insert @p_id					= 0
																				   ,@p_asset_code			= @asset_code
																				   ,@p_purchase_price		= @purchase
																				   ,@p_orig_amount			= @amount_invoice
																				   ,@p_type					= 'ASSET'
																				   ,@p_posting_date			= @date
																				   ,@p_return_date			= null
																				   ,@p_invoice_date_type	= 'POST'
																				   ,@p_invoice_code			= @p_code
																				   --
																				   ,@p_cre_date				= @p_mod_date
																				   ,@p_cre_by				= @p_mod_by
																				   ,@p_cre_ip_address		= @p_mod_ip_address
																				   ,@p_mod_date				= @p_mod_date
																				   ,@p_mod_by				= @p_mod_by
																				   ,@p_mod_ip_address		= @p_mod_ip_address
										
										    fetch next from curr_update_asset 
											into @asset_code
										end
									
									close curr_update_asset
									deallocate curr_update_asset
								end

							--    fetch next from curr_category_type2 
							--	into @category_type
							--end
							
							--close curr_category_type2
							--deallocate curr_category_type2 

					    FETCH NEXT FROM curr_rev_jour_final2
						into @code_final
					END
						
						CLOSE curr_rev_jour_final2
						DEALLOCATE curr_rev_jour_final2
					end

					
		    FETCH NEXT FROM curr_rev_jour2 
			into @temp_grn_code
		END
		
		CLOSE curr_rev_jour2
		DEALLOCATE curr_rev_jour2

		-- Auto POST
		exec dbo.xsp_ap_invoice_registration_post @p_code				= @p_code
												  ,@p_company_code		= 'DSF'
												  ,@p_mod_date			= @p_mod_date	  
												  ,@p_mod_by			= @p_mod_by		  
												  ,@p_mod_ip_address	= @p_mod_ip_address
		
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
