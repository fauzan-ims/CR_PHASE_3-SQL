CREATE PROCEDURE dbo.xsp_change_category_post
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
			,@company_code				nvarchar(50)
			,@status					nvarchar(20)
			,@code_detail				nvarchar(50)
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid					int 
			,@max_day					int
			,@date						datetime
			--
			,@asset_code				nvarchar(50)
			,@item_code					nvarchar(50)
			,@item_name					nvarchar(250)
			,@depre_comm				nvarchar(50)
			,@depre_fiscal				nvarchar(50)
			,@category_code				nvarchar(50)
			,@category_name				nvarchar(250)
			,@cost_center				nvarchar(50)
			,@purchase_price			decimal(18,2)
			,@to_net_book_value_comm	decimal(18,2)
			,@to_net_book_value_fiscal	decimal(18,2)
			,@asset_type_code			nvarchar(50)
			,@usefull					int
			,@previous_barcode			nvarchar(50)
			,@new_barcode				nvarchar(50)
			,@previous_usefull			int
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@total_depre				decimal(18,2)
			,@nbv						decimal(18,2)
			,@journal_code				nvarchar(50)
			,@depre_period				nvarchar(6)
			,@depre_period_fiscal		nvarchar(6)
			,@total_depre_fiscal		decimal(18,2)
			,@nbv_fiscal				decimal(18,2)
			,@system_date				datetime = dbo.xfn_get_system_date()
			,@last_depre				datetime


	begin try
		select	@status						= cc.status
				,@company_code				= cc.company_code
				,@date						= date
				,@item_code					= to_item_code
				,@item_name					= to_item_name
				,@asset_code				= asset_code
				,@depre_comm				= to_depre_category_comm_code
				,@depre_fiscal				= to_depre_category_fiscal_code
				,@category_code				= to_category_code
				,@category_name				= mc.description
				,@purchase_price			= ass.purchase_price
				,@to_net_book_value_comm	= cc.to_net_book_value_comm
				,@to_net_book_value_fiscal	= cc.to_net_book_value_fiscal
				,@asset_type_code			= mc.asset_type_code
				,@usefull					= mdc.usefull
				,@previous_barcode			= ass.barcode
				,@previous_usefull			= mdcp.usefull
				,@branch_code				= ass.branch_code
				,@branch_name				= ass.branch_name
				,@depre_period				= ass.depre_period_comm
		from	dbo.change_category cc
			inner join dbo.master_category mc on (mc.code = cc.to_category_code)
			inner join dbo.asset ass on (ass.code = cc.asset_code)
			inner join dbo.master_depre_category_commercial mdc on (mdc.code = cc.to_depre_category_comm_code)
			inner join dbo.master_depre_category_commercial mdcp on (mdcp.code = cc.from_depre_category_comm_code)
		where	cc.code = @p_code ;
		
		-- Trisna 07-Nov-2022 ket : for handle double process transaction (+)
		if exists (select 1 from dbo.change_category where asset_code = @asset_code and status in ('NEW', 'ON PROGRESS'))
		begin
		    set @msg = 'Data cannot be processed. The asset has been used in other transaction processes on the Change Category menu.';
			raiserror(@msg ,16,-1);	
		end
		if exists (select 1 from dbo.change_item_type where asset_code = @asset_code and status in ('NEW', 'ON PROGRESS'))
		begin
		    set @msg = 'Data cannot be processed. The asset has been used in other transaction processes on the Change Item menu.';
			raiserror(@msg ,16,-1);	
		end
		if exists (select 1 from dbo.adjustment where asset_code = @asset_code and status in ('NEW', 'ON PROGRESS'))
		begin
		    set @msg = 'Data cannot be processed. The asset has been used in other transaction processes on the Adjustment menu.';
			raiserror(@msg ,16,-1);	
		end
		-- End of additional control ===================================================

		if (@status = 'ON PROGRESS')
		begin
			
			-- Arga 29-Oct-2022 ket : with nbv and similar nbv (+)    
			if @previous_usefull = @usefull and @to_net_book_value_comm > 0
			begin
			print 'masuk if'
				exec dbo.xsp_efam_journal_change_category_register @p_change_category_code		= @p_code
			    													,@p_process_code			= 'CHCYKVM'
			    													,@p_company_code			= @company_code
			    													,@p_reff_source_no			= ''
			    													,@p_reff_source_name		= ''
			    													,@p_mod_date				= @p_mod_date
			    													,@p_mod_by					= @p_mod_by
			    													,@p_mod_ip_address			= @p_mod_ip_address

			end

			-- Arga 29-Oct-2022 ket : without nbv (+)
			if @to_net_book_value_comm = 0
			begin
			print 'masuk else'
				exec dbo.xsp_efam_journal_change_category_register @p_change_category_code		= @p_code
			    													,@p_process_code			= 'CHCYN'
			    													,@p_company_code			= @company_code
			    													,@p_reff_source_no			= ''
			    													,@p_reff_source_name		= ''
			    													,@p_mod_date				= @p_mod_date
			    													,@p_mod_by					= @p_mod_by
			    													,@p_mod_ip_address			= @p_mod_ip_address
			end

			update	dbo.change_category
			set		status			= 'POST'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;
				
			-- send mail attachment based on setting ================================================
			--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'PSRQTR'
			--												,@p_doc_code		= @p_code
			--												,@p_attachment_flag = 0
			--												,@p_attachment_file = ''
			--												,@p_attachment_path = ''
			--												,@p_company_code	= @company_code
			--												,@p_trx_no			= @p_code
			--												,@p_trx_type		= 'CHANGE CATEGORY'
			-- End of send mail attachment based on setting ================================================

			--Update Data di Asset
			update	dbo.asset
			set		depre_category_comm_code		= @depre_comm
					,depre_category_fiscal_code		= @depre_fiscal
					,category_code					= @category_code
					,category_name					= @category_name
					,item_code						= @item_code
					,item_name						= @item_name
					--,total_depre_comm				= @to_net_book_value_comm
					--,total_depre_fiscal				= @to_net_book_value_fiscal
					,type_code						= @asset_type_code
					,use_life						= @usefull
			where	code = @asset_code
			
			-- update barcode
			--exec dbo.xsp_asset_generate_barcode_number @p_asset_code	= @asset_code
			--										   ,@p_user_id		= @p_mod_by ;
			
			--calculate ulang depre
			select @is_valid = dbo.xfn_depre_threshold_validation(@company_code, @category_code, @purchase_price)
			if @is_valid = 1
			begin
				exec dbo.xsp_asset_depreciation_schedule_commercial_generate @p_code			 = @asset_code
																			 ,@p_mod_date		 = @p_mod_date	  
																			 ,@p_mod_by			 = @p_mod_by		  
																			 ,@p_mod_ip_address	 = @p_mod_ip_address

				exec dbo.xsp_asset_depreciation_schedule_fiscal_generate @p_code			 = @asset_code
																		 ,@p_mod_date		 = @p_mod_date	  
																		 ,@p_mod_by			 = @p_mod_by		
																		 ,@p_mod_ip_address	 = @p_mod_ip_address

			end
			
			-- Arga 29-Oct-2022 ket : with nbv and diff usefull. ada jurnal yang membutuhkan nilai schedue depre yang baru (+)
			if @previous_usefull <> @usefull and @to_net_book_value_comm > 0
			begin
				exec dbo.xsp_efam_journal_change_category_register @p_change_category_code		= @p_code
			    													,@p_process_code			= 'CHCYKVS'
			    													,@p_company_code			= @company_code
			    													,@p_reff_source_no			= ''
			    													,@p_reff_source_name		= ''
			    													,@p_mod_date				= @p_mod_date
			    													,@p_mod_by					= @p_mod_by
			    													,@p_mod_ip_address			= @p_mod_ip_address
			end

			if isnull(@depre_period,'') <> '' and @is_valid = 1
			begin
				-- check terakhir depre kapan
				select	@last_depre = max(depreciation_date)
				from	dbo.asset_depreciation
				where	asset_code = @asset_code
				and		status = 'POST'
				set @last_depre = isnull(@last_depre,@system_date)

				-- Arga 06-Nov-2022 ket : update depre to the current schedule (+)
				select	@journal_code = code
				from	dbo.efam_interface_journal_gl_link_transaction
				where	transaction_code = @p_code

				update	dbo.asset_depreciation_schedule_commercial
				set		transaction_code = @journal_code
				where	asset_code = @asset_code
				and		convert(char(6),depreciation_date,112) <= convert(char(6),@last_depre,112)--@depre_period
				and		transaction_code = ''
				
				-- Arga 06-Nov-2022 ket : back to last data with current depre (+)
				select	top 1
						@nbv			= net_book_value
						,@total_depre	= accum_depre_amount
						,@depre_period	= convert(char(6),depreciation_date,112)
				from	dbo.asset_depreciation_schedule_commercial
				where	asset_code = @asset_code
				and		convert(char(6),depreciation_date,112) <= convert(char(6),@last_depre,112) --@depre_period
				and		cre_by = @p_mod_by
				order by depreciation_date desc
			
				select	top 1
						@nbv_fiscal				= net_book_value
						,@total_depre_fiscal	= accum_depre_amount
						,@depre_period_fiscal	= convert(char(6),depreciation_date,112)
				from	dbo.asset_depreciation_schedule_fiscal
				where	asset_code = @asset_code
				and		convert(char(6),depreciation_date,112) <= convert(char(6),@last_depre,112) --@depre_period
				and		cre_by = @p_mod_by
				order by depreciation_date desc

				update	dbo.asset
				set		total_depre_comm				= isnull(@total_depre,0)
						,total_depre_fiscal				= isnull(@total_depre_fiscal,0)
						,net_book_value_comm			= @nbv --isnull(@nbv,0)
						,net_book_value_fiscal			= @nbv_fiscal --isnull(@nbv_fiscal,0)
						,depre_period_comm				= @depre_period
						,depre_period_fiscal			= @depre_period_fiscal
				where	code = @asset_code
				
				update	dbo.change_category
				set		to_net_book_value_comm		= @nbv
						,to_net_book_value_fiscal	= @nbv_fiscal
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_code ;	
				
			end

			-- insert to barcode history
			select	@new_barcode = barcode 
			from	dbo.asset 
			where	code = @asset_code ;

			exec dbo.xsp_asset_barcode_history_insert @p_id					= 0
			                                         ,@p_asset_code			= @asset_code
			                                         ,@p_previous_barcode	= @previous_barcode
			                                         ,@p_new_barcode		= @new_barcode
			                                         ,@p_remark				= 'New Barcode from Change Category Process'
			                                         ,@p_cre_date			= @p_mod_date
			                                         ,@p_cre_by				= @p_mod_by
			                                         ,@p_cre_ip_address		= @p_mod_ip_address
			                                         ,@p_mod_date			= @p_mod_date
			                                         ,@p_mod_by				= @p_mod_by
			                                         ,@p_mod_ip_address		= @p_mod_ip_address ;

			
			exec dbo.xsp_asset_mutation_history_insert @p_id							 = 0
														,@p_asset_code					 = @asset_code
														,@p_date							 = @date
														,@p_document_refference_no		 = @p_code
														,@p_document_refference_type		 = 'CTG'
														,@p_usage_duration				 = 0
														,@p_from_branch_code				 = @branch_code
														,@p_from_branch_name				 = @branch_name
														,@p_to_branch_code				 = ''
														,@p_to_branch_name				 = ''
														,@p_from_pic_code				 = ''
														,@p_to_pic_code					 = ''
														,@p_from_division_code			 = ''
														,@p_from_division_name			 = ''
														,@p_to_division_code				 = ''
														,@p_to_division_name				 = ''
														,@p_from_department_code			 = ''
														,@p_from_department_name			 = ''
														,@p_to_department_code			 = ''
														,@p_to_department_name			 = ''
														,@p_cre_date						 = @p_mod_date	  
														,@p_cre_by						 = @p_mod_by		  
														,@p_cre_ip_address				 = @p_mod_ip_address
														,@p_mod_date						 = @p_mod_date	  
														,@p_mod_by						 = @p_mod_by		  
														,@p_mod_ip_address				 = @p_mod_ip_address
			
		end
		else
		begin
			set @msg = 'Data sudah di proses.';
			raiserror(@msg ,16,-1);
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
