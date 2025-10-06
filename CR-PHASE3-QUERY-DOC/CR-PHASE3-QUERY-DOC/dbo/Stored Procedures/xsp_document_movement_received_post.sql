CREATE PROCEDURE dbo.xsp_document_movement_received_post
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					   nvarchar(max)
			,@replacement_code		   nvarchar(50)
			,@document_main_code	   nvarchar(50)
			,@is_reject				   nvarchar(1)
			,@branch_name			   nvarchar(250)
			,@branch_code			   nvarchar(50)
			,@movement_date			   datetime
			,@movement_type			   nvarchar(50)
			,@movement_location		   nvarchar(50)
			,@movement_status		   nvarchar(10)
			,@document_status		   nvarchar(20)
			,@movement_remark		   nvarchar(250)
			,@movement_receive_remark  nvarchar(250)
			,@movement_by_emp_name	   nvarchar(250)
			,@thirdparty_type		   nvarchar(50)
			,@receive_date			   datetime
			,@history_movement_type	   nvarchar(50)
			,@mutation_date			   datetime
			,@document_movement_to	   nvarchar(50)
			,@document_movement_from   nvarchar(50)
			,@movement_from			   nvarchar(50)
			,@movement_to			   nvarchar(50)
			,@document_type			   nvarchar(50)
			,@plafond_no			   nvarchar(50)
			,@agreement_no			   nvarchar(50)
			,@client_no				   nvarchar(50)
			,@client_name			   nvarchar(250)
			,@collateral_no			   nvarchar(50)
			,@collateral_name		   nvarchar(250)
			,@plafond_collateral_no	   nvarchar(50)
			,@plafond_collateral_name  nvarchar(250)
			,@asset_no				   nvarchar(50)
			,@asset_name			   nvarchar(250)
			,@custody_branch_code	   nvarchar(50)
			,@custody_branch_name	   nvarchar(250)
			,@mutation_location		   nvarchar(50)
			,@estimate_return_date	   datetime
			,@document_pending_code	   nvarchar(50)
			,@send_to_branch_code	   nvarchar(50)
			,@send_to_branch_name	   nvarchar(250)
			,@return_date			   datetime
			,@cstdy_branch_code		   nvarchar(50)
			,@movement_to_branch_code  nvarchar(50)
			,@replacement_request_id   bigint
			,@cover_note_no			   nvarchar(50)
			,@cover_note_date		   datetime
			,@cover_note_exp_date	   datetime
			,@file_name				   nvarchar(250) = null
			,@file_paths			   nvarchar(250) = null
			,@asset_type			   nvarchar(50)
			,@vendor_code			   nvarchar(50)
			,@vendor_name			   nvarchar(250)
			,@vendor_address		   nvarchar(4000)
			,@vendor_pic_name		   nvarchar(250)
			,@vendor_pic_area_phone_no nvarchar(4)
			,@vendor_pic_phone_no	   nvarchar(15) 
			,@mutation_type			   nvarchar(50)

	begin try
		select	@branch_name				= dmv.branch_name
				,@branch_code				= dm.branch_code
				,@cstdy_branch_code			= dm.custody_branch_code
				,@movement_to_branch_code	= dmv.movement_to_branch_code
				,@movement_date				= dmv.movement_date
				,@movement_type				= dmv.movement_type
				,@movement_location			= dmv.movement_location
				,@movement_status			= dmv.movement_status
				,@movement_remark			= dmv.movement_remarks
				,@movement_receive_remark	= dmv.receive_remark
				,@movement_by_emp_name		= dmv.movement_by_emp_name
				,@thirdparty_type			= sgs.description
				,@receive_date				= dmv.receive_date
				,@document_movement_to		= isnull(dmv.movement_to, dmv.movement_to_branch_name)
				,@mutation_date				= dm.mutation_date
				,@mutation_location			= dm.mutation_location
				,@estimate_return_date		= dmv.estimate_return_date
				,@movement_from				= dmv.movement_from
		from	dbo.document_movement dmv
				left join dbo.document_movement_detail dmd on (dmv.code = dmd.movement_code)
				left join dbo.document_main dm on (dmd.document_code	= dm.code)
				left join dbo.sys_general_subcode sgs on (sgs.code		= dmv.movement_to_thirdparty_type)
				left join dbo.sys_branch sb on (sb.branch_code			= dmv.branch_code)
		where	dmv.code												= @p_code ;

		if (@movement_location = 'BORROW CLIENT')
		begin
			if (isnull(@movement_to_branch_code, '') = '')
			begin
				set @movement_to_branch_code = @cstdy_branch_code
			end
		END
        
		--	if (CAST(@movement_date AS DATE) <> (select dbo.xfn_get_system_date()))
		--begin
		--	set @msg = 'Date must be equal than System Date' ;
		--	RAISERROR(@msg, 16, -1) ;
		--END

		if not exists
		(
			select	1
			from	dbo.document_movement_detail
			where	movement_code = @p_code
		)
		begin
			set @msg = N'Please add document before Proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@movement_status = 'HOLD')
		begin
			if (
				   @movement_date is null
				   or	@movement_remark is null
			   )
			begin
				set @msg = N'Please input Date and Remark before Post' ;

				raiserror(@msg, 16, -1) ;
			end ;
			else
			begin
				if (@movement_remark is null)
				begin
					set @msg = N'Please input Remark before Post' ;

					raiserror(@msg, 16, -1) ;
				end ;
			end ;
		end ;

		if (@movement_status = 'ON PROCESS')
		begin
			if (
				   @receive_date is null
				   or	@movement_receive_remark is null
			   )
			begin
				set @msg = N'Please input Receive Date and Receive Remark before Post' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end ;
		else
		begin
			if (@movement_remark is null)
			begin
				set @msg = N'Please input Remark before Post' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end ;

		if (@movement_status = 'POST')
		begin
			raiserror('Data already Process', 16, 1) ;
		end ;
		else
		begin
			declare cursor_movement cursor fast_forward read_only for
			select	dmd.document_code
					,dmd.is_reject
					,dmd.document_pending_code
					,dp.document_type
			from	dbo.document_movement_detail dmd
					left join dbo.document_pending dp on (dp.code = dmd.document_pending_code)
			where	movement_code = @p_code ;

			open cursor_movement ;

			fetch next from cursor_movement
			into @document_main_code
				 ,@is_reject
				 ,@document_pending_code 
				 ,@document_type

			while @@fetch_status = 0
			begin
				if (@movement_location = 'ENTRY') -- untuk data masuk pertama kali
				begin
					select	@asset_no				   = dp.asset_no
							,@asset_name			   = dp.asset_name
							,@branch_code			   = dp.branch_code
							,@branch_name			   = dp.branch_name
							,@custody_branch_code	   = case is_custody_branch
													   		when '0' then custody_branch_code
													   		else dp.branch_code
													   	end
							,@custody_branch_name	   = case is_custody_branch
													   		when '0' then custody_branch_name
													   		else dp.branch_name
													   	end
							,@cover_note_no			   = cover_note_no
							,@cover_note_date		   = cover_note_date
							,@cover_note_exp_date	   = cover_note_exp_date
							,@file_name				   = dp.file_name
							,@file_paths			   = dp.file_path
							,@asset_type			   = fam.asset_type_code
							,@vendor_code			   = vendor_code
							,@vendor_name			   = vendor_name
							,@vendor_address		   = vendor_address
							,@vendor_pic_name		   = vendor_pic_name
							,@vendor_pic_area_phone_no = vendor_pic_area_phone_no
							,@vendor_pic_phone_no	   = vendor_pic_phone_no
					from	dbo.document_pending dp
							left join dbo.sys_branch sb on (sb.branch_code = dp.branch_code)
							left join dbo.fixed_asset_main fam on (fam.asset_no = dp.asset_no)
					where	code = @document_pending_code ; 
					
					exec dbo.xsp_document_movement_to_document_main @p_document_main_code		= @document_main_code output
																	,@p_branch_code				= @branch_code
																	,@p_branch_name				= @branch_name
																	,@p_movement_date			= @movement_date
																	,@p_movement_by_emp_name	= @movement_by_emp_name
																	,@p_document_movement_to	= N'BRANCH'
																	,@p_document_movement_from	= N'VENDOR'
																	,@p_document_type			= @document_type
																	,@p_asset_no				= @asset_no	
																	,@p_asset_name				= @asset_name
																	,@p_custody_branch_code		= @custody_branch_code
																	,@p_custody_branch_name		= @custody_branch_name 
																	,@p_cover_note_no			= @cover_note_no			
																	,@p_cover_note_date			= @cover_note_date		
																	,@p_cover_note_exp_date		= @cover_note_exp_date	
																	,@p_vendor_code				= @vendor_code				 
																	,@p_vendor_name				= @vendor_name				 
																	,@p_vendor_address			= @vendor_address			 
																	,@p_vendor_pic_name			= @vendor_pic_name			 
																	,@p_vendor_pic_area_phone_no= @vendor_pic_area_phone_no 
																	,@p_vendor_pic_phone_no		= @vendor_pic_phone_no	
																	,@p_file_name				= null
																	,@p_file_paths				= null
																	,@p_asset_type				= @asset_type
																	,@p_mod_date				= @p_mod_date
																	,@p_mod_by					= @p_mod_by
																	,@p_mod_ip_address			= @p_mod_ip_address 
					

					update	dbo.document_movement
					set		movement_status =  N'POST'
							,mod_date		= @p_mod_date
							,mod_by			= @p_mod_by
							,mod_ip_address = @p_mod_ip_address
					where	code			= @p_code ;
				
				end ;
				else
				begin
					if (@movement_type = 'SEND') --- ini receive atas transaksi borrow
					begin
						set @mutation_type = 'BORROW'
						if @is_reject = '1'
						begin
							set @document_status = N'ON HAND' ;
							set @history_movement_type = N'RECEIVED - REJECT' ;
						end ;
						else
						begin 
							-- jika cabang tujuan adalah cabang custody nya status menjadi on hand 
							if (@movement_to_branch_code = @cstdy_branch_code)
							begin
								set @document_status = N'ON HAND' ;
								set @history_movement_type = N'RECEIVED' ;
							end ;
							else
							begin
								set @document_status = N'ON BORROW' ;
								set @history_movement_type = N'RECEIVED' ;
							end ;
						end ;
						if (@movement_location = 'DEPARTMENT')
						begin
							select	@document_movement_to = dmv.movement_to_dept_name
									,@send_to_branch_code = dmv.branch_code
									,@send_to_branch_name = dmv.branch_name
							from	dbo.document_movement dmv
							where	dmv.code = @p_code ;

							set @movement_remark = N'RECEIVED BY DEPARTMENT ' + @document_movement_to + N' ' + isnull(@movement_receive_remark,'') ;
							 
						end ;
						else if (@movement_location = 'BRANCH')
						begin
							select	@document_movement_to = dmv.movement_to_branch_name
									,@send_to_branch_code = dmv.movement_to_branch_code
									,@send_to_branch_name = dmv.movement_to_branch_name
							from	dbo.document_movement dmv
							where	dmv.code = @p_code ;

							set @movement_remark = N'RECEIVED BY BRANCH ' + @branch_name + N' TO ' + @document_movement_to + N' ' + @document_movement_to ;
						end ;
						else if (@movement_location = 'BORROW CLIENT')
						begin
							set @mutation_type			= 'RECEIVED'
							set @movement_location		= ''
							set @branch_name			= null
							set @document_movement_to	= null
							set @movement_by_emp_name	= null
							set @movement_date			= null
							set @estimate_return_date	= null
							set @thirdparty_type		= null

							select	@document_movement_to  = dmv.branch_name
									, @send_to_branch_code = dmv.branch_code
									, @send_to_branch_name = dmv.branch_name
									, @client_name		   = dmv.movement_to_client_name
							from	dbo.document_movement dmv
							where	dmv.code = @p_code ;
					 
							set @movement_remark = N'RECEIVE FROM BORROW CLIENT '+ @client_name + ' '+ isnull(@movement_receive_remark,'') ;
						end ;

						if @is_reject = '1'
						begin
							update	dbo.document_main
							set		document_status = @document_status
									,mod_date = @p_mod_date
									,mod_by = @p_mod_by
									,mod_ip_address = @p_mod_ip_address
							where	code = @document_main_code ;
						end ;
						else
						begin
							update	dbo.document_main
							set		document_status			= @document_status
									,branch_code			= @send_to_branch_code
									,branch_name			= @send_to_branch_name
									,mutation_type			= @mutation_type
									,mutation_location		= @movement_location	 
									,mutation_from			= @branch_name			 
									,mutation_to			= @document_movement_to	 
									,mutation_by			= @movement_by_emp_name	 
									,mutation_date			= @movement_date		 
									,mutation_return_date	= @estimate_return_date  
									,last_mutation_type		= @mutation_location
									,last_mutation_date		= @mutation_date
									,borrow_thirdparty_type = @thirdparty_type		
									,mod_date				= @p_mod_date
									,mod_by					= @p_mod_by
									,mod_ip_address			= @p_mod_ip_address
							where	code					= @document_main_code ;
						end ;
					end ;
					else --mutation type received, return (ini receive atas pengembalian)
					begin
						if @is_reject = '1'
						begin
							set @document_status = N'ON BORROW' ;
							set @history_movement_type = N'RECEIVED - REJECT' ;
						end ;
						else
						begin
							set @document_status = N'ON HAND' ;
							set @history_movement_type = N'RECEIVED' ;
						end ;

						if (@movement_type = 'RETURN')
						begin
							if (@movement_location = 'DEPARTMENT')
							begin
								select	@document_movement_to = dmv.movement_from_dept_name
										,@send_to_branch_code = dmv.branch_code
										,@send_to_branch_name = dmv.branch_name
								from	dbo.document_movement dmv
								where	dmv.code = @p_code ;

								set @movement_remark = N'RETURN FROM DEPARTMENT ' + @document_movement_to + N' ' + isnull(@movement_receive_remark,'') ;
							end ;

							if (@movement_location = 'BRANCH')
							begin
								select	@document_movement_to = dmv.movement_to_branch_name
										,@send_to_branch_code = dmv.movement_to_branch_code
										,@send_to_branch_name = dmv.movement_to_branch_name
								from	dbo.document_movement dmv
								where	dmv.code = @p_code ;

								set @movement_remark = N'RETURN FROM BRANCH ' + @branch_name + N' TO ' + @document_movement_to + N' ' + isnull(@movement_receive_remark,'') ;
							end ;
						end ;

						if (@movement_type = 'RECEIVED')
						begin
							if (@movement_location = 'THIRD PARTY')
							begin
								select	@document_movement_to = dmv.movement_to
										,@send_to_branch_code = dmv.branch_code
										,@send_to_branch_name = dmv.branch_name
								from	dbo.document_movement dmv
								where	dmv.code = @p_code ;
								
								set @movement_remark = N'RECEIVED FROM ' + @thirdparty_type + N' TO ' + @document_movement_to + N' ' + @movement_remark ;
							end ;
						end ;

						if @is_reject <> '1'
						begin
							update	dbo.document_main
							set		document_status			= @document_status
									,branch_code			= @send_to_branch_code
									,branch_name			= @send_to_branch_name
									,mutation_type			= 'RECEIVED'
									,mutation_location		= ''
									,mutation_from			= null
									,mutation_to			= null
									,mutation_by			= null
									,mutation_date			= null
									,mutation_return_date	= @estimate_return_date
									,last_mutation_type		= @mutation_location
									,last_mutation_date		= @mutation_date
									,borrow_thirdparty_type = null
									,mod_date				= @p_mod_date
									,mod_by					= @p_mod_by
									,mod_ip_address			= @p_mod_ip_address
							where	code					= @document_main_code ;
						end ;
						else
						begin
							update	dbo.document_main
							set		document_status		= @document_status
									,mod_date			= @p_mod_date
									,mod_by				= @p_mod_by
									,mod_ip_address		= @p_mod_ip_address
							where	code				= @document_main_code ;
						end ;
					end ;
				end ;

				if (@movement_location = 'THIRD PARTY')
				begin
					set @movement_from = @movement_from ;
					set @movement_to = @branch_name ; 
				end ;
				else
				begin
					set @movement_from = @branch_name ;
					set @movement_to = @document_movement_to ; 
				end ; 
				 
				if(@document_type = 'COVER NOTE')
				begin
					set @document_type = 'COVERNOTE'
				end

				if(isnull(@document_type, '') <> 'COVERNOTE')
				begin
					exec dbo.xsp_document_history_insert @p_id						= 0
														 ,@p_document_code			= @document_main_code
														 ,@p_document_status		= @document_status
														 ,@p_movement_type			= @history_movement_type
														 ,@p_movement_location		= @movement_location
														 ,@p_movement_from			= @movement_from
														 ,@p_movement_to			= @movement_to
														 ,@p_movement_by			= @movement_by_emp_name
														 ,@p_movement_date			= @movement_date
														 ,@p_movement_return_date	= @return_date
														 ,@p_locker_position		= 'OUT LOCKER'
														 ,@p_locker_code			= null
														 ,@p_drawer_code			= null
														 ,@p_row_code				= null
														 ,@p_remarks				= @movement_remark
														 ,@p_cre_date				= @p_mod_date
														 ,@p_cre_by					= @p_mod_by
														 ,@p_cre_ip_address			= @p_mod_ip_address
														 ,@p_mod_date				= @p_mod_date
														 ,@p_mod_by					= @p_mod_by
														 ,@p_mod_ip_address			= @p_mod_ip_address ;
				end

				fetch next from cursor_movement
				into @document_main_code
					 ,@is_reject
					 ,@document_pending_code 
					 ,@document_type
			end ;

			close cursor_movement ;
			deallocate cursor_movement ; 

			update	dbo.document_movement
			set		movement_status =  N'POST'
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;
		end ;
	end try
	begin catch
		if cursor_status('global', 'cursor_movement') >= -1
		begin
			if cursor_status('global', 'cursor_movement') > -1
			begin
				close cursor_movement ;
			end ;

			deallocate cursor_movement ;
		end ;

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


