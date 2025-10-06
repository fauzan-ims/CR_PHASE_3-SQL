CREATE PROCEDURE dbo.xsp_mutation_received
(
	@p_code					nvarchar(50)
    --,@p_receive_date		datetime
	,@p_file_name			nvarchar(250)
	--,@p_file_path			nvarchar(250)
	,@p_id					int
    --
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)as
begin
	declare @to_location					nvarchar(50)
			,@to_branch						nvarchar(50)
			,@to_branch_name				nvarchar(250)
			,@mutation_code					nvarchar(50)
			,@from_branch_code				nvarchar(50)
			,@from_branch_name				nvarchar(250)
			,@from_location					nvarchar(50)
			,@asset_code					nvarchar(50)
			,@id_mutation					int
            ,@code_barcode					nvarchar(50)
			,@item_code						nvarchar(50)
			,@status						nvarchar(50)
			,@count_status					int
            ,@count_status_sent				int
			,@remaks_return					nvarchar(400)
			,@object_info					nvarchar(400)
			,@pic							nvarchar(50)
			,@status_asset					nvarchar(50)
			,@branch_description			nvarchar(50) --deskripsicabang untuk api
			--
			,@to_pic_code					nvarchar(50)
			,@from_division_code			nvarchar(50)
			,@from_division_name			nvarchar(250)
			,@to_division_code				nvarchar(50)
			,@to_division_name				nvarchar(250)
			,@from_department_code			nvarchar(50)
			,@from_department_name			nvarchar(250)
			,@to_department_code			nvarchar(50)
			,@to_department_name			nvarchar(250)
			,@from_sub_department_code		nvarchar(50)
			,@from_sub_department_name		nvarchar(250)
			,@to_sub_department_code		nvarchar(50)
			,@to_sub_department_name		nvarchar(250)
			,@from_units_code				nvarchar(50)
			,@from_units_name				nvarchar(250)
			,@to_units_code					nvarchar(50)
			,@to_units_name					nvarchar(250)
			--
			,@last_date						datetime
			,@usage_duration				int
			--
			,@accounting_date				datetime		= getdate()
			,@add_to_asset_id				int
			,@amortize_flag					int
			,@ap_distribution_line_number	int
			,@asset_category_id				int				= 0
			,@asset_key_ccid				int
			,@asset_number					int
			,@asset_type					nvarchar(50)	= ''
			,@assigned_to					int
			,@beginning_nbv					int
			,@book_type_code				nvarchar(50)	= ''
			,@create_batch_date				datetime
			,@create_batch_id				int	
			,@created_by					int				= 0
			,@creation_date					datetime		= @p_mod_date
			,@date_placed_in_service		datetime		= getdate()
			,@depreciate_flag				nvarchar(50)		= ''
			,@deprn_reserve					int			
			,@expense_code_combination_id	int				= 0
			,@feeder_system_name			nvarchar(50)
			,@fixed_assets_cost				int				= 0
			,@fixed_assets_units			nvarchar(50)	= ''
			,@fully_rsvd_revals_counter		int
			,@invoice_created_by			int
			,@invoice_date					datetime
			,@invoice_id					int
			,@invoice_number				nvarchar(50)
			,@invoice_updated_by			int
			,@last_update_date				datetime		= getdate()
			,@last_update_login				int				= 0
			,@last_updated_by				int				= 0
			,@location_id					int				= 0
			,@mass_addition_id				int				= 0
			,@manufacturer_name				nvarchar(50)
			,@merge_invoice_number			nvarchar(50)
			,@merge_vendor_number			nvarchar(50)
			,@model_number					nvarchar(50)
			,@new_master_flag				nvarchar(50)
			,@parent_asset_id				int				= 0
			,@parent_mass_addition_id		int
			,@payables_batch_name			nvarchar(50)
			,@payables_code_combination_id	int				= 0
			,@payables_cost					int				= 0
			,@payables_units				int				= 0
			,@po_number						nvarchar(50)
			,@po_vendor_id					int
			,@post_batch_id					int
			,@posting_status				nvarchar(50)	= ''
			,@production_capacity			int
			,@queue_name					nvarchar(50)	= ''
			,@reval_amortization_basis		int
			,@reval_reserve					int
			,@reviewer_comments				nvarchar(60)
			,@salvage_value					int
			,@serial_number					nvarchar(50)
			,@split_merged_code				nvarchar(50)
			,@tag_number					nvarchar(50)
			,@unit_of_measure				nvarchar(50)
			,@unrevalued_cost				int
			,@vendor_number					nvarchar(50)
			,@ytd_deprn						int
			,@ytd_reval_deprn_expense		int
			,@msg							nvarchar(max)
			,@date							datetime = dbo.xfn_get_system_date() -- Arga 02-Nov-2022 ket : ganti tggl sistem for UAT (-/+) --getdate() 
			,@to_location_name				nvarchar(250)
			,@is_valid						int 
			,@max_day						int 
			,@company_code					nvarchar(50)
			,@category_code					nvarchar(50)
			,@purchase_price				decimal(18,2)
			,@system_date					datetime = dbo.xfn_get_system_date() -- Arga 02-Nov-2022 ket : ganti tggl sistem for UAT (-/+)

	begin try
			if (isnull(@p_file_name, '') = '')
			begin
				set @msg = 'Please upload files before Receive Assets';
				raiserror(@msg ,16,-1);
			end
    
			select  @status			= md.status_received
					,@remaks_return = isnull(md.remark_unpost, '') 
			from	dbo.mutation mt
					inner join dbo.mutation_detail md on (md.mutation_code = mt.code)
			where	 mt.code = @p_code

			if	(@status = 'POST')
			begin
				set @msg = 'Data already posted';
				raiserror(@msg ,16,-1);	
			end 
	
			select	 @status	= status_received 
			from	 dbo.mutation_detail
			where	 id = @p_id

			if	(@status = 'RECEIVED')
			begin
				set @msg = 'Data already received';
				raiserror(@msg ,16,-1);		
			end 
						
			-- Arga 16-Oct-2022 ket : for WOM to control back date based on setting (+) ====
			set @is_valid = dbo.xfn_date_validation(@date)
			select @max_day = cast(value as int) from dbo.sys_global_param where code = 'MDT'

			if @is_valid = 0
			begin
				set @msg = 'Maximum input Back Date Transaction on the ' + cast(@max_day as char(2)) + ' of every month';
				raiserror(@msg ,16,-1);	    
			end
			-- End of additional control =================================================== 


			select	 @to_branch					= mt.to_branch_code
					,@to_branch_name			= mt.to_branch_name
					,@mutation_code				= md.mutation_code
					,@asset_code				= md.asset_code
					,@from_branch_code			= mt.from_branch_code
					,@from_branch_name			= mt.from_branch_name
					,@item_code					= md.asset_code
					,@pic						= ass.pic_code
					,@to_pic_code				= mt.to_pic_code
					,@from_division_code		= mt.from_division_code
					,@from_division_name		= mt.from_division_name
					,@to_division_code			= mt.to_division_code
					,@to_division_name			= mt.to_division_name
					,@from_department_code		= mt.from_department_code
					,@from_department_name		= mt.from_department_name
					,@to_department_code		= mt.to_department_code
					,@to_department_name		= mt.to_department_name
					,@company_code				= mt.company_code
					,@category_code				= ass.category_code
					,@purchase_price			= ass.purchase_price
			from	 dbo.mutation_detail md
					inner join dbo.mutation mt on (mt.code = md.mutation_code)
					inner join dbo.asset ass on (ass.code = md.asset_code)
			where	md.id = @p_id
	
			update	dbo.asset
			set		status = 'STOCK'
			where	code = @asset_code;
			
			update	dbo.mutation_detail
			set		receive_date		= @system_date --@date
					,status_received	= 'RECEIVED'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	id = @p_id
	
			--update	dbo.mutation_document
			--set		file_name			= @p_file_name
			--		,path				= @p_file_path 
			--		--
			--		,mod_date			= @p_mod_date
			--		,mod_by				= @p_mod_by
			--		,mod_ip_address		= @p_mod_ip_address
			--where	id = @p_id	

			if exists (select 1 from dbo.asset_mutation_history where asset_code = @item_code and document_refference_type in ('GRN', 'UPE', 'MTT', 'MNE'))
			begin
				select @last_date = max(date) from dbo.asset_mutation_history where asset_code = @item_code and document_refference_type in ('GRN', 'UPE', 'MTT', 'MNE')
			end
			else
			begin
				select @last_date = purchase_date from dbo.asset where code = @item_code
			end

			select @usage_duration  = datediff(day,@last_date,dbo.xfn_get_system_date())
					,@to_pic_code	= isnull(@to_pic_code,'')
					,@pic			= isnull(@pic,'')

			if not exists(select 1 from dbo.asset_mutation_history where asset_code = @item_code and document_refference_no = @mutation_code)
			begin
				exec dbo.xsp_asset_mutation_history_insert @p_id						 = 0
														   ,@p_asset_code				 = @item_code
														   ,@p_date						 = @date
														   ,@p_document_refference_no	 = @mutation_code
														   ,@p_document_refference_type	 = 'MTT'
														   ,@p_usage_duration			 = @usage_duration
														   ,@p_from_branch_code			 = @from_branch_code
														   ,@p_from_branch_name			 = @from_branch_name
														   ,@p_to_branch_code			 = @to_branch
														   ,@p_to_branch_name			 = @to_branch_name
														   ,@p_from_location_code		 = @from_location
														   ,@p_to_location_code			 = @to_location
														   ,@p_from_pic_code			 = @pic
														   ,@p_to_pic_code				 = @to_pic_code
														   ,@p_from_division_code		 = @from_division_code
														   ,@p_from_division_name		 = @from_division_name
														   ,@p_to_division_code			 = @to_division_code
														   ,@p_to_division_name			 = @to_division_name
														   ,@p_from_department_code		 = @from_department_code
														   ,@p_from_department_name		 = @from_department_name
														   ,@p_to_department_code		 = @to_department_code
														   ,@p_to_department_name		 = @to_department_name
														   ,@p_from_sub_department_code	 = @from_sub_department_code
														   ,@p_from_sub_department_name	 = @from_sub_department_name
														   ,@p_to_sub_department_code	 = @to_sub_department_code
														   ,@p_to_sub_department_name	 = @to_sub_department_name
														   ,@p_from_unit_code			 = @from_units_code
														   ,@p_from_unit_name			 = @from_units_name
														   ,@p_to_unit_code				 = @to_units_code
														   ,@p_to_unit_name				 = @to_units_name
														   ,@p_cre_date					 = @p_mod_date
														   ,@p_cre_by					 = @p_mod_by
														   ,@p_cre_ip_address			 = @p_mod_ip_address
														   ,@p_mod_date					 = @p_mod_date
														   ,@p_mod_by					 = @p_mod_by
														   ,@p_mod_ip_address			 = @p_mod_ip_address
			end
			

			select	 @count_status_sent		 = count(id)
			from	 dbo.mutation_detail
			where	 mutation_code			 = @mutation_code
					 and	status_received	 = 'RECEIVED'			

			select	 @count_status	 = count(id)
			from	 dbo.mutation_detail
			where	 mutation_code	 = @mutation_code 
			

			if (@count_status = @count_status_sent)
			begin
				update dbo.mutation
				set status = 'POST'
				where code = @mutation_code
			end    

			update	dbo.asset
			set		branch_code			 = @to_branch
					,branch_name		 = @to_branch_name
					,division_code		 = @to_division_code
					,division_name		 = @to_division_name
					,department_code	 = @to_department_code
					,department_name	 = @to_department_name
					,pic_code			 = @to_pic_code
					--
					,mod_date			 = @p_mod_date
					,mod_by				 = @p_mod_by
					,mod_ip_address		 = @p_mod_ip_address
			where	code				 = @asset_code;
			
			
			-- Arga 19-Oct-2022 ket : additional control for WOM (+)
			select @is_valid = dbo.xfn_depre_threshold_validation(@company_code, @category_code, @purchase_price)			
			if @is_valid = 1
			begin
				if @from_branch_code <> @to_branch
				begin
					exec dbo.xsp_efam_journal_mutation_register @p_mutation_code		= @p_code
																,@p_process_code		= 'MUTATION'
																,@p_company_code		= @company_code
																,@p_reff_source_no		= @asset_code
																,@p_reff_source_name	= ''
																,@p_mod_date			= @p_mod_date
																,@p_mod_by				= @p_mod_by
																,@p_mod_ip_address		= @p_mod_ip_address
				end
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
end
