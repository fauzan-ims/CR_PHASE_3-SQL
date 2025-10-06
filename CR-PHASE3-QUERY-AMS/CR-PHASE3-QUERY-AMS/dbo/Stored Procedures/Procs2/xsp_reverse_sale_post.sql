CREATE PROCEDURE dbo.xsp_reverse_sale_post
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
	declare @msg					nvarchar(max)
			,@status				nvarchar(20)
			,@asset_code			nvarchar(50) 
			,@date					datetime = getdate()
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid				int 
			,@max_day				int
			,@reverse_sale_date		datetime
			,@company_code			nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@code_asset			nvarchar(50)

	begin try -- 
		select	@status				= rs.status
				,@asset_code		= rsd.asset_code
				,@reverse_sale_date = rs.reverse_sale_date
				,@company_code	    = rs.company_code
				,@branch_code		= rs.branch_code
				,@branch_name		= rs.branch_name
				,@date				= rs.reverse_sale_date
		from	dbo.reverse_sale rs
				left join dbo.reverse_sale_detail rsd on (rs.code = rsd.reverse_sale_code)
		where	rs.code = @p_code ;

		if (@status = 'ON PROCESS')
		begin

			exec dbo.xsp_efam_journal_reverse_sale_register @p_reverse_sale_code	= @p_code
															,@p_process_code		= 'RVSSALE'
															,@p_company_code		= @p_company_code
															,@p_mod_date			= @p_mod_date
															,@p_mod_by				= @p_mod_by
															,@p_mod_ip_address		= @p_mod_ip_address
			
			update	dbo.reverse_sale
			set		status = 'POST'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code ;

			update	dbo.asset
			set		status			= 'STOCK'
					,sale_amount	= 0
					,sale_date		= null
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code in (select asset_code from dbo.reverse_sale_detail where reverse_sale_code = @p_code) ;

			
			declare curr_reverse_sale cursor fast_forward read_only for
            
			select asset_code 
			from dbo.reverse_sale_detail
			where reverse_sale_code = @p_code
			
			open curr_reverse_sale
			
			fetch next from curr_reverse_sale 
			into @code_asset
			
			while @@fetch_status = 0
			begin
				if not exists(select 1 from dbo.asset_mutation_history where asset_code = @code_asset and document_refference_no = @p_code)
				begin

					exec dbo.xsp_asset_mutation_history_insert		@p_id							 = 0
															   ,@p_asset_code					 = @code_asset
															   ,@p_date							 = @date
															   ,@p_document_refference_no		 = @p_code
															   ,@p_document_refference_type		 = 'RSL'
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
			
			    fetch next from curr_reverse_sale 
				into @code_asset
			end
			
			close curr_reverse_sale
			deallocate curr_reverse_sale

			-- send mail attachment based on setting ================================================
			--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'PSRQTR'
			--												,@p_doc_code		= @p_code
			--												,@p_attachment_flag = 0
			--												,@p_attachment_file = ''
			--												,@p_attachment_path = ''
			--												,@p_company_code	= @company_code
			--												,@p_trx_no			= @p_code
			--												,@p_trx_type		= 'REVERSE SELL'
			-- End of send mail attachment based on setting ================================================

		end ;
		else
		begin
			set @msg = 'Data already proceed.' ;

			raiserror(@msg, 16, -1) ;
		end ;

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
