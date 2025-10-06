CREATE PROCEDURE dbo.xsp_opname_post
(
	@p_code			    nvarchar(50)
	,@p_company_code	nvarchar(50)
	--
	,@p_mod_date	    datetime
	,@p_mod_by		    nvarchar(15)
	,@p_mod_ip_address  nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@status				nvarchar(20)
			,@code_disposal			nvarchar(50)	= ''
			,@code_mutaion			nvarchar(50)	= ''
			,@code_sell				nvarchar(50)	= ''
			,@condition				nvarchar(50)
			,@location_in			nvarchar(50)
			,@asset_code			nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@date					datetime
			,@location_code			nvarchar(50)
			,@diposal_header		int
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid				int 
			,@max_day				int
			,@opname_date			datetime
			,@requestor_name		nvarchar(250)
			,@company_code			nvarchar(50)
			,@nbv_amount			decimal(18,2)
			,@remarks				nvarchar(4000)
			,@last_location_code	nvarchar(50)
			,@last_location_name	nvarchar(250)
			,@last_meter			int ;

	begin try		

		select	@opname_date	= opname_date
				,@company_code	= company_code
				,@date			= opname_date
		from	dbo.opname
		where	code = @p_code ;

		set @remarks = 'OPNAME TRANSACTION FOR PERIOD ' + convert(nvarchar(max), @date, 106)

		--if exists(select 1 from dbo.opname_detail a where a.opname_code = @p_code and a.location_code = '')
		--begin
		--	set @msg = 'Please fill in the Located In column first.';
		--	raiserror(@msg ,16,-1);	 
		--end

		--if exists(select 1 from dbo.opname_detail a where a.opname_code = @p_code and a.condition_code = '')
		--begin
		--	set @msg = 'Please fill in the Conditiion In column first.';
		--	raiserror(@msg ,16,-1);	 
		--end

		if exists(select 1 from dbo.opname_detail where opname_code = @p_code and isnull(km,'') = '')
		begin
			set @msg = 'KM cannot be empty.';
			raiserror(@msg ,16,-1);
		end

		if exists(select 1 from dbo.opname_detail where opname_code = @p_code and isnull(condition_code,'') = '')
		begin
			set @msg = 'Condition cannot be empty.';
			raiserror(@msg ,16,-1);
		end

		if exists(select 1 from dbo.opname_detail where opname_code = @p_code and isnull(date,'') = '')
		begin
			set @msg = 'Date cannot be empty.';
			raiserror(@msg ,16,-1);
		end


		declare c_opname_main cursor fast_forward read_only for
        select	 dor.status
				,od.condition_code
				,od.location_name
				,od.asset_code
				,dor.branch_code
				,dor.branch_name
				,od.location_code
				,ast.net_book_value_comm
				,od.km
		from	dbo.opname dor
			left join dbo.opname_detail od on (od.opname_code = dor.code)
			inner join dbo.asset ast on (od.asset_code = ast.code)
		where	dor.code = @p_code ;
		
		open c_opname_main
		
		fetch next from c_opname_main 
		into 
			 @status	
			,@condition	
			,@location_in
			,@asset_code
			,@branch_code
			,@branch_name
			,@location_code
			,@nbv_amount
			,@last_meter
		
		while @@fetch_status = 0
		begin
			set @date = dbo.xfn_get_system_date()
			
			if (@location_in in ('MUTATIONTOOTHER', 'MUTATIONTOHO'))
			begin
					if(@code_mutaion = '')
					begin
						
						exec dbo.xsp_mutation_insert @p_code						 = @code_mutaion output
													 ,@p_company_code				 = @p_company_code
													 ,@p_mutation_date				 = @date
													 ,@p_requestor_code				 = @p_mod_by
													 ,@p_requestor_name				 = ''
													 ,@p_branch_request_code		 = @branch_code
													 ,@p_branch_request_name		 = @branch_name
													 ,@p_from_branch_code			 = @branch_code
													 ,@p_from_branch_name			 = @branch_name
													 ,@p_from_division_code			 = ''
													 ,@p_from_division_name			 = ''
													 ,@p_from_department_code		 = ''
													 ,@p_from_department_name		 = ''
													 ,@p_from_pic_code				 = ''
													 ,@p_to_branch_code				 = ''
													 ,@p_to_branch_name				 = ''
													 ,@p_to_division_code			 = ''
													 ,@p_to_division_name			 = ''
													 ,@p_to_department_code			 = ''
													 ,@p_to_department_name			 = ''
													 ,@p_to_pic_code				 = ''
													 ,@p_status						 = 'NEW'
													 ,@p_remark						 = @remarks
													 ,@p_cre_date					 = @p_mod_date	  
													 ,@p_cre_by						 = @p_mod_by		  
													 ,@p_cre_ip_address				 = @p_mod_ip_address
													 ,@p_mod_date					 = @p_mod_date	  
													 ,@p_mod_by						 = @p_mod_by		  
													 ,@p_mod_ip_address				 = @p_mod_ip_address
					end

					exec dbo.xsp_mutation_detail_insert @p_id						= 0
														    ,@p_mutation_code		= @code_mutaion
														    ,@p_asset_code			= @asset_code
														    ,@p_description			= @condition
														    ,@p_receive_date		= null
														    ,@p_remark_unpost		= ''
														    ,@p_remark_return		= ''
														    ,@p_cre_date			= @p_mod_date	  
														    ,@p_cre_by				= @p_mod_by		 
														    ,@p_cre_ip_address		= @p_mod_ip_address
														    ,@p_mod_date			= @p_mod_date	  
														    ,@p_mod_by				= @p_mod_by		 
														    ,@p_mod_ip_address		= @p_mod_ip_address

			end
            else if (@location_in in('DISPOSED','NOTFOUND'))
			begin
					if(@code_disposal = '')
					begin
						exec dbo.xsp_disposal_insert @p_code				= @code_disposal output
													,@p_company_code		= @p_company_code
													,@p_disposal_date		= @date
													,@p_branch_code			= @branch_code
													,@p_branch_name			= @branch_name
													--,@p_location_code		= @location_code
													,@p_description			= @remarks
													,@p_reason_type			= ''
													,@p_remarks				= @remarks
													,@p_status				= 'NEW'
													,@p_cre_date			= @p_mod_date	  
													,@p_cre_by				= @p_mod_by		 
													,@p_cre_ip_address		= @p_mod_ip_address
													,@p_mod_date			= @p_mod_date	  
													,@p_mod_by				= @p_mod_by		 
													,@p_mod_ip_address		= @p_mod_ip_address
					end
					
					exec dbo.xsp_disposal_detail_insert @p_id				= 0
														,@p_disposal_code	= @code_disposal
														,@p_asset_code		= @asset_code
														,@p_description		= @condition
														,@p_net_book_value	= @nbv_amount
														,@p_cre_date		= @p_mod_date	  
														,@p_cre_by			= @p_mod_by		 
														,@p_cre_ip_address	= @p_mod_ip_address
														,@p_mod_date		= @p_mod_date	  
														,@p_mod_by			= @p_mod_by		 
														,@p_mod_ip_address	= @p_mod_ip_address			
			end
			--else if (@location_in = 'SELL')
			--begin
			--		if (@code_sell = '')
			--		begin
			--			exec dbo.xsp_sale_insert @p_code				= @code_sell output
			--									 ,@p_company_code		= @p_company_code
			--									 ,@p_sale_date			= @date
			--									 ,@p_description		= ''
			--									 ,@p_branch_code		= @branch_code
			--									 ,@p_branch_name		= @branch_name
			--									 ,@p_location_code		= @location_code
			--									 ,@p_buyer				= ''
			--									 ,@p_buyer_phone_no		= ''
			--									 ,@p_sale_amount_header = 0
			--									 ,@p_remark				= @remarks
			--									 ,@p_status				= 'NEW'
			--									 ,@p_cre_date			= @p_mod_date	  
			--									 ,@p_cre_by				= @p_mod_by		 
			--									 ,@p_cre_ip_address		= @p_mod_ip_address
			--									 ,@p_mod_date			= @p_mod_date	  
			--									 ,@p_mod_by				= @p_mod_by		 
			--									 ,@p_mod_ip_address		= @p_mod_ip_address
						
			--		end
			--		exec dbo.xsp_sale_detail_insert @p_id				= 0
			--										,@p_sale_code		= @code_sell					
			--										,@p_asset_code		= @asset_code				
			--										,@p_description		= ''					
			--										,@p_sale_value		= 0					
			--										,@p_cre_date		= @p_mod_date	  
			--										,@p_cre_by			= @p_mod_by		 
			--										,@p_cre_ip_address	= @p_mod_ip_address
			--										,@p_mod_date		= @p_mod_date	  
			--										,@p_mod_by			= @p_mod_by		 
			--										,@p_mod_ip_address	= @p_mod_ip_address
						
			--end			
			
			update	dbo.asset
			set		last_so_date		= @opname_date
					,last_meter			= @last_meter
					,last_so_condition	= @condition
					,last_location_code	= @location_code
					,last_location_name	= @location_in
			where	code = @asset_code


		    fetch next from c_opname_main 
			into 
				 @status	
				,@condition	
				,@location_in
				,@asset_code
				,@branch_code
				,@branch_name
				,@location_code
				,@nbv_amount
				,@last_meter
		end
		
		close c_opname_main
		deallocate c_opname_main

		if (@status = 'ON PROCESS')
		begin
		    update	dbo.opname
			set		status			= 'POST'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;

			insert into dbo.opname_history
			(
			    code
				,company_code
				,opname_date
				,branch_code
				,branch_name
				,location_code
				,division_code
				,division_name
				,department_code
				,department_name
				,status
				,description
				,remark
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	code
					,company_code
					,opname_date
					,branch_code
					,branch_name
					,location_code
					,division_code
					,division_name
					,department_code
					,department_name
					,status
					,description
					,remark
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address 
			from	dbo.opname 
			where	code = @p_code ;
		end
		else
		begin
			set @msg = 'Data already proceed.';
			raiserror(@msg ,16,-1);
		end

		-- send mail attachment based on setting ================================================
		--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'PSRQTR'
		--												,@p_doc_code		= @p_code
		--												,@p_attachment_flag = 0
		--												,@p_attachment_file = ''
		--												,@p_attachment_path = ''
		--												,@p_company_code	= @company_code
		--												,@p_trx_no			= @p_code
		--												,@p_trx_type		= 'OPNAME'
		-- End of send mail attachment based on setting ================================================
						
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
