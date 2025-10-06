CREATE PROCEDURE dbo.xsp_change_item_type_post
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@company_code			nvarchar(50)
			,@status				nvarchar(20)
			,@code_detail			nvarchar(50)
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid				int 
			,@max_day				int
			,@date					datetime
			,@process_code			nvarchar(50)
			,@nett_book_value		decimal(18,2)
			,@asset_code			nvarchar(50)
			,@to_item_code			nvarchar(10)
			,@item_type				nvarchar(50)
			,@new_status			nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)

	begin try
		select	@status				= cit.status
				,@company_code		= cit.company_code
				,@date				= date
				,@nett_book_value	= ast.net_book_value_comm
				,@asset_code		= ast.code
				,@to_item_code		= cit.to_item_code
				,@branch_code		= ast.branch_code
				,@branch_name		= ast.branch_name
		from	dbo.change_item_type cit
		inner join dbo.asset ast on cit.asset_code = ast.code collate Latin1_General_CI_AS
		where	cit.code = @p_code ;
	
		-- Trisna 07-Nov-2022 ket : for handle double process transaction (+)
		if exists (select 1 from dbo.change_category where asset_code = @asset_code and status = 'POST')
		begin
		    set @msg = 'Data cannot be processed. The asset has been used in other transaction processes on the Change Category menu.';
			raiserror(@msg ,16,-1);	
		end
		if exists (select 1 from dbo.change_item_type where asset_code = @asset_code and status = 'POST')
		begin
		    set @msg = 'Data cannot be processed. The asset has been used in other transaction processes on the Change Item menu.';
			raiserror(@msg ,16,-1);	
		end
		if exists (select 1 from dbo.adjustment where asset_code = @asset_code and status = 'POST')
		begin
		    set @msg = 'Data cannot be processed. The asset has been used in other transaction processes on the Adjustment menu.';
			raiserror(@msg ,16,-1);	
		end
		-- End of additional control ===================================================

		if (@status = 'ON PROGRESS')
		begin
			    if @nett_book_value > 0
				begin
					exec dbo.xsp_efam_journal_change_item_register @p_change_category_code	= @p_code
			    													,@p_process_code		= 'CHITY'
			    													,@p_company_code		= @company_code
			    													,@p_reff_source_no		= N''
			    													,@p_reff_source_name	= N''
			    													,@p_mod_date			= @p_mod_date
			    													,@p_mod_by				= @p_mod_by
			    													,@p_mod_ip_address		= @p_mod_ip_address
				end
				else
				begin
				    exec dbo.xsp_efam_journal_change_item_register @p_change_category_code	= @p_code
			    													,@p_process_code		= 'CHITYNN'
			    													,@p_company_code		= @company_code
			    													,@p_reff_source_no		= N''
			    													,@p_reff_source_name	= N''
			    													,@p_mod_date			= @p_mod_date
			    													,@p_mod_by				= @p_mod_by
			    													,@p_mod_ip_address		= @p_mod_ip_address
				end
			    
				
				update	dbo.change_item_type
				set		status			= 'POST'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_code ;

				select @new_status = case @item_type when 'EXPNSE' then 'INVALIDEXPENSE' else 'INVALIDINVENTORY' end

				update	dbo.asset
				set		status			= @new_status --'INVALID'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @asset_code ;
				
				-- send mail attachment based on setting ================================================
				--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'PSRQTR'
				--												,@p_doc_code		= @p_code
				--												,@p_attachment_flag = 0
				--												,@p_attachment_file = ''
				--												,@p_attachment_path = ''
				--												,@p_company_code	= @company_code
				--												,@p_trx_no			= @p_code
				--												,@p_trx_type		= 'CHANGE ITEM TYPE'
				-- End of send mail attachment based on setting ================================================

				
				exec dbo.xsp_asset_mutation_history_insert @p_id							 = 0
														   ,@p_asset_code					 = @asset_code
														   ,@p_date							 = @date
														   ,@p_document_refference_no		 = @p_code
														   ,@p_document_refference_type		 = 'CIT'
														   ,@p_usage_duration				 = 0
														   ,@p_from_branch_code				 = @branch_code
														   ,@p_from_branch_name				 = @branch_name
														   ,@p_to_branch_code				 = ''
														   ,@p_to_branch_name				 = ''
														   ,@p_from_location_code			 = ''
														   ,@p_to_location_code				 = ''
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
														   ,@p_from_sub_department_code		 = ''
														   ,@p_from_sub_department_name		 = ''
														   ,@p_to_sub_department_code		 = ''
														   ,@p_to_sub_department_name		 = ''
														   ,@p_from_unit_code				 = ''
														   ,@p_from_unit_name				 = ''
														   ,@p_to_unit_code					 = ''
														   ,@p_to_unit_name					 = ''
														   ,@p_cre_date						 = @p_mod_date	  
														   ,@p_cre_by						 = @p_mod_by		  
														   ,@p_cre_ip_address				 = @p_mod_ip_address
														   ,@p_mod_date						 = @p_mod_date	  
														   ,@p_mod_by						 = @p_mod_by		  
														   ,@p_mod_ip_address				 = @p_mod_ip_address
				
		end
		else
		begin
			set @msg = 'Data already proceed.';
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
