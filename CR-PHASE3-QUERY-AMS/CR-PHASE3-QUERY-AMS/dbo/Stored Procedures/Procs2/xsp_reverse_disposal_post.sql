CREATE PROCEDURE dbo.xsp_reverse_disposal_post
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
			,@status				nvarchar(20)
			,@company_code			nvarchar(50)
			,@asset_code			nvarchar(50)
			,@date					datetime = getdate()
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid				int 
			,@max_day				int
			,@reverse_disposal_date	datetime 
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@code_asset			nvarchar(50)

	begin try -- 

		select	@status					 = status
				,@asset_code			 = rdd.asset_code
				,@company_code			 = rd.company_code
				,@reverse_disposal_date	 = rd.reverse_disposal_date
				,@branch_code			 = rd.branch_code
				,@branch_name			 = rd.branch_name
				,@date					 = rd.reverse_disposal_date
		from	dbo.reverse_disposal  rd
			inner join dbo.reverse_disposal_detail rdd on (rd.code=rdd.reverse_disposal_code)
		where	code = @p_code ;

		if (@status = 'ON PROCESS')
		begin

				exec dbo.xsp_efam_journal_reverse_disposal_register @p_reverse_disposal_code	= @p_code
			    													,@p_process_code			= 'RVSDISP' -- nvarchar(50)
			    													,@p_company_code			= @company_code
			    													,@p_reff_source_no			= ''
			    													,@p_reff_source_name		= ''
			    													,@p_mod_date				= @p_mod_date
			    													,@p_mod_by					= @p_mod_by
			    													,@p_mod_ip_address			= @p_mod_ip_address
				

			    

				update	dbo.reverse_disposal
				set		status			= 'POST'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_code ;


				update	dbo.asset
				set		status			= 'STOCK'
						,disposal_date	= null
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			in (select asset_code from dbo.reverse_disposal_detail where reverse_disposal_code = @p_code)

				
				declare curr_reverse_disposal cursor fast_forward read_only for
				
				select asset_code 
				from dbo.reverse_disposal_detail
				where reverse_disposal_code = @p_code

				open curr_reverse_disposal
				
				fetch next from curr_reverse_disposal 
				into @code_asset
				
				while @@fetch_status = 0
				begin
					if not exists(select 1 from dbo.asset_mutation_history where asset_code = @code_asset and document_refference_no = @p_code)
					begin
						exec dbo.xsp_asset_mutation_history_insert @p_id							 = 0
															   ,@p_asset_code					 = @code_asset
															   ,@p_date							 = @date
															   ,@p_document_refference_no		 = @p_code
															   ,@p_document_refference_type		 = 'RDS'
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
				
				    fetch next from curr_reverse_disposal 
					into @code_asset
				end
				
				close curr_reverse_disposal
				deallocate curr_reverse_disposal

			-- send mail attachment based on setting ================================================
			--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'PSRQTR'
			--												,@p_doc_code		= @p_code
			--												,@p_attachment_flag = 0
			--												,@p_attachment_file = ''
			--												,@p_attachment_path = ''
			--												,@p_company_code	= @company_code
			--												,@p_trx_no			= @p_code
			--												,@p_trx_type		= 'REVERSE DISPOSAL'
			-- End of send mail attachment based on setting ================================================

			end 
			else 
			begin
				set @msg = 'Data sudah di proses.';
				raiserror(@msg ,16,-1);
            end	

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
