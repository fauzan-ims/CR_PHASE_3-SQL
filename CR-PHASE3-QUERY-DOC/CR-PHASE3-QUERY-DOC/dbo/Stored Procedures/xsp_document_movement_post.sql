CREATE PROCEDURE dbo.xsp_document_movement_post
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
			,@document_request_code nvarchar(50) 
			,@document_main_code	nvarchar(50)
			,@document_code			nvarchar(50)
			,@document_no			nvarchar(50)
			,@is_reject				nvarchar(1)
			,@remarks				nvarchar(4000)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@agreement_no			nvarchar(50)
			,@collateral_no			nvarchar(50)
			,@asset_no				nvarchar(50)
			,@movement_date			datetime
			,@return_date			datetime
			,@movement_type			nvarchar(50)
			,@movement_location		nvarchar(50)
			,@doc_expired_date		datetime
			,@movement_status		nvarchar(10)
			,@document_status		nvarchar(20)
			,@movement_remark		nvarchar(250)
			,@movement_receive_remark	nvarchar(250)
			,@document_movement_from	nvarchar(250)
			,@document_movement_to		nvarchar(250)
			,@movement_to_agreement_no	nvarchar(50)
			,@movement_by_emp_name		nvarchar(250)
			,@movement_to				nvarchar(250)
			,@movement_to_client_name	nvarchar(250)
			,@movement_to_branch_code	nvarchar(50)
			,@movement_to_branch_name	nvarchar(250)
			,@movement_to_dept_code		nvarchar(50)
			,@movement_to_dept_name		nvarchar(250)
			,@movement_from				nvarchar(50)
			,@movement_from_dept_code	nvarchar(50)
			,@movement_from_dept_name	nvarchar(250)
			,@thirdparty_type			nvarchar(50)
			,@receive_date				datetime
            ,@history_movement_type		nvarchar(50)
			
			,@mutation_type				nvarchar(20)	 
			,@mutation_location			nvarchar(20)	 
			,@mutation_from				nvarchar(50)	 
			,@mutation_to				nvarchar(50)	 
			,@mutation_by				nvarchar(250)	 
			,@mutation_date				datetime	 
			,@mutation_return_date		datetime	 
			,@mutation_locker			nvarchar(50)	 
			,@mutation_drawer			nvarchar(50)	 
			,@mutation_row				nvarchar(50)
			,@document_type				nvarchar(20)
			,@agreement_number			nvarchar(50)
			,@coll_number				nvarchar(50)
			,@asset_number				nvarchar(50)
			,@file_name					nvarchar(250)
			,@path						nvarchar(250)

	begin try
			select 
                   @branch_code					= dmv.branch_code,
                   @branch_name					= dmv.branch_name,
                   @movement_date				= dmv.movement_date,
                   @movement_type				= dmv.movement_type,
                   @movement_location			= dmv.movement_location,
				   @movement_status				= dmv.movement_status,
				   @movement_remark				= dmv.movement_remarks,
				   @movement_receive_remark		= dmv.receive_remark,
				   @movement_by_emp_name		= dmv.movement_by_emp_name,
				   @return_date					= dmv.estimate_return_date,
				   @thirdparty_type				= dmv.movement_to_thirdparty_type,
				   
				   @movement_to					= dmv.movement_to,
				   @movement_to_agreement_no	= dmv.movement_to_agreement_no,
				   @movement_to_client_name		= dmv.movement_to_client_name,
				   @movement_to_branch_code		= dmv.movement_to_branch_code,
				   @movement_to_branch_name		= dmv.movement_to_branch_name,
				   @movement_to_dept_code		= dmv.movement_to_dept_code,
				   @movement_to_dept_name		= dmv.movement_to_dept_name,
				   @movement_from				= dmv.movement_from,
				   @movement_from_dept_code		= dmv.movement_from_dept_code,
				   @movement_from_dept_name		= dmv.movement_from_dept_name,

				   @agreement_number			= am.agreement_no,
				   @coll_number					= ac.collateral_no,
				   @asset_number				= ass.asset_no,
				   @receive_date				= dmv.receive_date
				 
			from dbo.document_movement dmv
				   left join dbo.document_movement_detail dmd on (dmv.code = dmd.movement_code)
				   left	join dbo.document_main dm on (dmd.document_code = dm.code)
				   left join dbo.agreement_main am on (dm.agreement_no = am.agreement_no)
				   left join dbo.agreement_collateral ac on (dm.collateral_no = ac.collateral_no)
				   left join dbo.agreement_asset ass on (dm.asset_no = ass.asset_no)
			where dmv.code = @p_code;

	   if not exists (select 1 from dbo.document_movement_detail where movement_code = @p_code)
		begin
			set @msg = 'Please add document before Proceed';
			raiserror(@msg, 16, -1) ;
		end
       
	   if (@movement_status = 'HOLD')
	   begin
			if (@movement_date is null or @movement_remark is null)
			begin
				set @msg = 'Please input Date and Remark before Post';
				raiserror(@msg, 16, -1) ;
			end
            ELSE
            begin
				if (@movement_remark is null)
				begin
					set @msg = 'Please input Remark before Post';
					raiserror(@msg, 16, -1) ;
				end
			end
	   end
	   
	   if (@movement_status = 'ON PROCESS')
	   begin
			if (@receive_date is null or @movement_receive_remark is null)
			begin
				set @msg = 'Please input Receive Date and Receive Remark before Post';
				raiserror(@msg, 16, -1) ;
			end
	   end
       else
       begin
			if (@movement_remark is null)
			begin
				set @msg = 'Please input Remark before Post';
				raiserror(@msg, 16, -1) ;
			end
	   end
	   
        
	   if (@movement_status =  'POST' )
			begin
				raiserror('Data already Post',16,1) ;
			end
        else
			BEGIN
				SET @movement_status = 'POST'

				declare cursor_movement cursor fast_forward read_only for 
					select	isnull(dmd.document_code,dp.code),
							is_reject,
							isnull(dmd.remarks,dr.remarks),
							isnull(dp.agreement_no,dr.agreement_no),
							isnull(dp.collateral_no,dr.collateral_no),
							isnull(dp.asset_no,dr.asset_no),
							dp.document_expired_date,
							dp.document_type,
							isnull(dp.general_document_code,dr.document_code),
							dmd.document_request_code
					from	dbo.document_movement_detail dmd
					left join dbo.document_pending dp on dp.code = dmd.document_pending_code
					left join dbo.document_request dr on dr.code = dmd.document_request_code
					where	movement_code = @p_code

				open cursor_movement
			
				fetch next from cursor_movement into 
					@document_main_code	
					,@is_reject		
					,@remarks			
					,@agreement_no		
					,@collateral_no		
					,@asset_no		
					,@doc_expired_date	
					,@document_type
					,@document_code
					,@document_request_code
				while @@fetch_status = 0
				begin
                
					select 
							@mutation_type			= mutation_type
							,@mutation_location		= mutation_location
							,@mutation_from			= mutation_from
							,@mutation_to			= mutation_to
							,@mutation_by			= mutation_by
							,@mutation_date			= mutation_date
							,@mutation_return_date	= mutation_return_date
							--
							--,@mutation_locker		= dm.locker_code
							--,@mutation_locker		= dm.locker_code
							--,@mutation_drawer		= dm.drawer_code
							--,@mutation_row			= dm.row_code
					from	dbo.document_main dm
					--inner join dbo.master_locker ml on (ml.code = dm.locker_code)
					--inner join dbo.master_drawer dr on (dr.code = dm.drawer_code)
					--inner join dbo.master_row rw	on (rw.code = dm.row_code)
					where	dm.code					= @document_main_code
				
				if (@movement_type = 'ENTRY') -- untuk data masuk pertama kali
				begin
					
					SET @history_movement_type	= @movement_type
					select 
						@file_name					= [file_name],
						@path						= paths,
						@document_no				= document_no
				   from  dbo.document_pending
				   where code = @document_main_code

					set @movement_status		= 'POST'
					set @document_status		= 'ON HAND'
					SET @movement_remark		= 'First Entry ' + @movement_remark
					set @document_movement_from = 'VENDOR'
					set @document_movement_to	= 'BRANCH'

					exec dbo.xsp_document_main_insert @p_code						= @document_main_code output,            
													  @p_branch_code				= @branch_code,                   
													  @p_branch_name				= @branch_name,                   
													  @p_general_document_code		= @document_code,       
													  @p_document_type				= @document_type,                          
													  @p_file_name					= @file_name,                             
													  @p_paths						= @path,                                  
													  @p_agreement_no				= @agreement_no,                           
													  @p_collateral_no				= @collateral_no,                          
													  @p_asset_no					= @asset_no,                               
													  @p_locker_position			='OUT LOCKER',                        
													  @p_locker_code				=  null,                            
													  @p_drawer_code				=  null,                          
													  @p_row_code					=  null,                              
													  @p_document_status			= 'ON HAND',                        
													  @p_mutation_type				= '',                          
													  @p_mutation_location			= @document_movement_to,                      
													  @p_mutation_from				= @document_movement_from,                          
													  @p_mutation_to				= @document_movement_to,                            
													  @p_mutation_by				= '',                            
													  @p_mutation_date				= @movement_date,        
													  @p_mutation_return_date		= null, 
													  @p_last_mutation_type			=  null,                        
													  @p_last_mutation_date			=  null,       
													  @p_last_locker_position		=  null,                     
													  @p_last_locker_code			=  null,                       
													  @p_last_drawer_code			=  null,                    
													  @p_last_row_code				=  null,                           
													  @p_document_expired_date		= @doc_expired_date,
													  @p_first_receive_date			= @movement_date,   
													  @p_release_customer_date		= null,
													  @p_document_no				= @document_no,
													  @p_custody_branch_code		= @branch_code,
													  @p_custody_branch_name		= @branch_name,
													  ---
													  @p_cre_date					= @p_mod_date  ,           
													  @p_cre_by						= @p_mod_by,                                 
													  @p_cre_ip_address				= @p_mod_ip_address,                         
													  @p_mod_date					= @p_mod_date,             
													  @p_mod_by						= @p_mod_by,                                 
													  @p_mod_ip_address				= @p_mod_ip_address     
					SET @document_code			= @document_main_code
                     
				end
				else if (@movement_type = 'BORROW' ) 
				begin
					SET @movement_status		= 'POST'
					--SET @movement_remark		= @movement_remark

					IF @is_reject = '1'
					BEGIN
						SET @document_status		= 'ON HAND'
						SET @history_movement_type	= @movement_type+ ' - REJECT'
					END
					ELSE
					BEGIN
						SET @document_status		= 'ON BORROW'
						SET @history_movement_type	= @movement_type
					END

					if ( @movement_location = 'BRANCH')
					BEGIN
						SET @movement_remark =  @movement_receive_remark
                    
						set @document_movement_from = @branch_name
						set @document_movement_to	= @movement_to_branch_name
						 

						IF @is_reject = '1'
						BEGIN
							SET @document_status		= 'ON HAND'
							SET @history_movement_type	= @movement_type+ ' - REJECT'

							update  dbo.document_main
							set		document_status			= @document_status
							where	code					= @document_main_code
						END
						ELSE
						BEGIN
							SET @document_status		= 'ON BORROW'
							SET @history_movement_type	= @movement_type

							exec dbo.xsp_document_request_insert @p_code					= '',                           
							                                     @p_branch_code				= @movement_to_branch_code,     
							                                     @p_branch_name				= @movement_to_branch_name,     
							                                     @p_request_type			= 'RETURN',                   
							                                     @p_request_location		= 'BRANCH',           
							                                     @p_request_from			= NULL,                 
							                                     @p_request_to				= NULL,                     
							                                     @p_request_to_client_name	= NULL,         
							                                     @p_request_to_branch_code	= @branch_code,        
							                                     @p_request_to_branch_name	= @branch_name,        
							                                     @p_request_from_dept_code	= NULL,         
							                                     @p_request_from_dept_name	= NULL,         
							                                     @p_request_to_dept_code	= NULL,         
							                                     @p_request_to_dept_name	= NULL,         
							                                     @p_request_by				= @p_mod_by,                  
							                                     @p_request_status			= 'HOLD',              
							                                     @p_request_date			= @return_date,
							                                     @p_remarks					= @remarks,
																 @p_document_code			= @document_main_code,
																 @p_agreement_no			= @agreement_number,
																 @p_collateral_no			= @coll_number,
																 @p_asset_no				= @asset_number,
																 @p_request_to_thirdparty_type				= @thirdparty_type,
							                                     @p_cre_date				= @p_mod_date,             
																 @p_cre_by					= @p_mod_by,                       
																 @p_cre_ip_address			= @p_mod_ip_address,       
																 @p_mod_date				= @p_mod_date,              
																 @p_mod_by					= @p_mod_by,                       
																 @p_mod_ip_address			= @p_mod_ip_address  
							
							update  dbo.document_main
							set		document_status			= @document_status
									,mutation_type			= @movement_type
									,mutation_location		= @movement_location
									,mutation_from			= @document_movement_from
									,mutation_to			= @document_movement_to
									,mutation_by			= @movement_by_emp_name
									,mutation_date			= @movement_date
									,branch_code			= @movement_to_branch_code
									,branch_name			= @movement_to_branch_name
									,mutation_return_date	= @return_date
									,last_mutation_type		= @mutation_type
									,last_mutation_date		= @mutation_date
									--,last_locker_position	= @mutation_location
									--,last_locker_code		= @mutation_locker
									--,last_drawer_code		= @mutation_drawer
									--,last_row_code			= @mutation_row
									,mod_date				= @p_mod_date
									,mod_by					= @p_mod_by
									,mod_ip_address			= @p_mod_ip_address
							where	code					= @document_main_code
						END
					end
					else iF ( @movement_location = 'DEPARTMENT')
					BEGIN
                    
						set @document_movement_from = @branch_name
						SET @document_movement_to	= @movement_to_dept_name
                
						
							exec dbo.xsp_document_request_insert @p_code					= '',                           
							                                     @p_branch_code				= @branch_code,     
							                                     @p_branch_name				= @branch_name,     
							                                     @p_request_type			= 'RETURN',                   
							                                     @p_request_location		= @movement_location,           
							                                     @p_request_from			= NULL,                 
							                                     @p_request_to				= NULL,                     
							                                     @p_request_to_client_name	= NULL,         
							                                     @p_request_to_branch_code	= NULL,        
							                                     @p_request_to_branch_name	= NULL,        
							                                     @p_request_from_dept_code	= @movement_to_dept_code,         
							                                     @p_request_from_dept_name	= @movement_to_dept_name,         
							                                     @p_request_to_dept_code	= NULL,         
							                                     @p_request_to_dept_name	= NULL,         
							                                     @p_request_by				= @p_mod_by,                  
							                                     @p_request_status			= 'HOLD',              
							                                     @p_request_date			= @return_date,
							                                     @p_remarks					= @remarks,
																 @p_document_code			= @document_main_code,
																 @p_agreement_no			= @agreement_number,
																 @p_collateral_no			= @coll_number,
																 @p_asset_no				= @asset_number,
																 @p_request_to_thirdparty_type				= @thirdparty_type,
							                                     @p_cre_date				= @p_mod_date,             
																 @p_cre_by					= @p_mod_by,                       
																 @p_cre_ip_address			= @p_mod_ip_address,       
																 @p_mod_date				= @p_mod_date,              
																 @p_mod_by					= @p_mod_by,                       
																 @p_mod_ip_address			= @p_mod_ip_address  
							
						update  dbo.document_main
						set		document_status			= @document_status
								,mutation_type			= @movement_type
								,mutation_location		= @movement_location
								,mutation_from			= @document_movement_from
								,mutation_to			= @document_movement_to
								,mutation_by			= @movement_by_emp_name
								,mutation_date			= @movement_date
								,mutation_return_date	= @return_date
								,last_mutation_type		= @mutation_type
								,last_mutation_date		= @mutation_date
								--,last_locker_position	= @mutation_location
								--,last_locker_code		= @mutation_locker
								--,last_drawer_code		= @mutation_drawer
								--,last_row_code			= @mutation_row
								,mod_date				= @p_mod_date
								,mod_by					= @p_mod_by
								,mod_ip_address			= @p_mod_ip_address
						where	code					= @document_main_code

					end
					else iF ( @movement_location = 'THIRD PARTY')
					begin
						
						set @document_movement_from = @branch_name
						SET @document_movement_to	= @movement_to

					 
							exec dbo.xsp_document_request_insert @p_code					= '',                           
							                                     @p_branch_code				= @branch_code,     
							                                     @p_branch_name				= @branch_name,     
							                                     @p_request_type			= 'RETURN',                   
							                                     @p_request_location		= @movement_location   ,
							                                     @p_request_from			= @document_movement_to,                 
							                                     @p_request_to				= @document_movement_from,                     
							                                     @p_request_to_client_name	= NULL,         
							                                     @p_request_to_branch_code	= NULL,        
							                                     @p_request_to_branch_name	= NULL,        
							                                     @p_request_from_dept_code	= @movement_to_dept_code,         
							                                     @p_request_from_dept_name	= @movement_to_dept_name,         
							                                     @p_request_to_dept_code	= NULL,         
							                                     @p_request_to_dept_name	= NULL,         
							                                     @p_request_by				= @p_mod_by,                  
							                                     @p_request_status			= 'HOLD',              
							                                     @p_request_date			= @return_date,
							                                     @p_remarks					= @remarks,
																 @p_document_code			= @document_main_code,
																 @p_agreement_no			= @agreement_number,
																 @p_collateral_no			= @coll_number,
																 @p_asset_no				= @asset_number,
																 @p_request_to_thirdparty_type				= @thirdparty_type,
							                                     @p_cre_date				= @p_mod_date,             
																 @p_cre_by					= @p_mod_by,                       
																 @p_cre_ip_address			= @p_mod_ip_address,       
																 @p_mod_date				= @p_mod_date,              
																 @p_mod_by					= @p_mod_by,                       
																 @p_mod_ip_address			= @p_mod_ip_address 

						
						update  dbo.document_main
						set		document_status			= @document_status
								,mutation_type			= @movement_type
								,mutation_location		= @movement_location
								,mutation_from			= @document_movement_from
								,mutation_to			= @document_movement_to
								,mutation_by			= @movement_by_emp_name
								,mutation_date			= @movement_date
								,mutation_return_date	= @return_date
								,last_mutation_type		= @mutation_type
								,last_mutation_date		= @mutation_date
								,borrow_thirdparty_type	= @thirdparty_type
								--,last_locker_position	= @mutation_location
								--,last_locker_code		= @mutation_locker
								--,last_drawer_code		= @mutation_drawer
								--,last_row_code			= @mutation_row
								,mod_date				= @p_mod_date
								,mod_by					= @p_mod_by
								,mod_ip_address			= @p_mod_ip_address
						where	code					= @document_main_code

					end
              
				end
				else if ( @movement_type = 'RETURN')
				begin
					--SET @movement_remark =  @movement_remark
					if @is_reject = '1'
					begin
						set @document_status		= 'ON BORROW'
						set @history_movement_type	= @movement_type+ ' - REJECT'
						set @movement_remark		= @movement_receive_remark 																			
					end
					else
					begin
						set @document_status		= 'ON HAND'
						set @history_movement_type	= @movement_type
					end

					set @return_date	= null
					set @movement_status = 'POST'

                	if ( @movement_location = 'BRANCH')
					begin
						set @document_movement_from = @branch_name
						set @document_movement_to	= @movement_to_branch_name
						set @movement_remark		=  @movement_receive_remark


						-- if is reject = 0
						if @is_reject = '0'
						begin
							update  dbo.document_main
							set		document_status			= @document_status
									,mutation_type			= @movement_type
									,mutation_location		= @movement_location
									,mutation_from			= @document_movement_from
									,mutation_to			= @document_movement_to
									,mutation_by			= @movement_by_emp_name
									,mutation_date			= @movement_date
									,branch_code			= @movement_to_branch_code
									,branch_name			= @movement_to_branch_name
									,mutation_return_date	= @return_date
									,last_mutation_type		= @mutation_type
									,last_mutation_date		= @mutation_date
									--,last_locker_position	= @mutation_location
									--,last_locker_code		= @mutation_locker
									--,last_drawer_code		= @mutation_drawer
									--,last_row_code			= @mutation_row
									,mod_date				= @p_mod_date
									,mod_by					= @p_mod_by
									,mod_ip_address			= @p_mod_ip_address
							where	code					= @document_main_code
						end
                        else
						begin
							-- if reject = 1
							update  dbo.document_main
							set		document_status			= @document_status
								
									,mod_date				= @p_mod_date
									,mod_by					= @p_mod_by
									,mod_ip_address			= @p_mod_ip_address
							where	code					= @document_main_code	

							-- update ke document request
							update dbo.document_request set request_status	= 'HOLD'
															,mod_date		= @p_mod_date
															,mod_by			= @p_mod_by
															,mod_ip_address	= @p_mod_ip_address
							where code = @document_request_code 
					  end

					end
					else if ( @movement_location = 'DEPARTMENT')
					begin
						set @document_movement_from = @movement_from_dept_name
						SET @document_movement_to	= @branch_name

						
						update  dbo.document_main
						set		document_status			= @document_status
								,mutation_type			= @movement_type
								,mutation_location		= @movement_location
								,mutation_from			= @document_movement_from
								,mutation_to			= @document_movement_to
								,mutation_by			= @movement_by_emp_name
								,mutation_date			= @movement_date
								,mutation_return_date	= @return_date
								,last_mutation_type		= @mutation_type
								,last_mutation_date		= @mutation_date
								--,last_locker_position	= @mutation_
								--,last_locker_code		= @mutation_locker
								--,last_drawer_code		= @mutation_drawer
								--,last_row_code		= @mutation_row
								,mod_date				= @p_mod_date
								,mod_by					= @p_mod_by
								,mod_ip_address			= @p_mod_ip_address
						where	code					= @document_main_code

					end
					else if ( @movement_location = 'THIRD PARTY')
					begin
                
						set @document_movement_from = @movement_from
						SET @document_movement_to	= @branch_name


						
						update  dbo.document_main
						set		document_status			= @document_status
								,mutation_type			= @movement_type
								,mutation_location		= @movement_location
								,mutation_from			= @document_movement_from
								,mutation_to			= @document_movement_to
								,mutation_by			= @movement_by_emp_name
								,mutation_date			= @movement_date
								,mutation_return_date	= @return_date
								,last_mutation_type		= @mutation_type
								,last_mutation_date		= @mutation_date
								,borrow_thirdparty_type	= null
								--,last_locker_position	= @mutation_location
								--,last_locker_code		= @mutation_locker
								--,last_drawer_code		= @mutation_drawer
								--,last_row_code			= @mutation_row
								,mod_date				= @p_mod_date
								,mod_by					= @p_mod_by
								,mod_ip_address			= @p_mod_ip_address
						where	code					= @document_main_code

					end

				end
                else if ( @movement_type = 'RELEASE')
				BEGIN
                
						
						set @movement_status		= 'POST'
						set @document_status		= 'ON CLIENT'
						set @document_movement_from = @branch_name
						set @document_movement_to	= @movement_to_client_name
						set @movement_remark		= 'Release ' + @movement_remark
						SET @history_movement_type	= @movement_type

						update  dbo.document_main
						set		document_status			= 'RELEASE'
								,mutation_type			= 'RELEASE'
							    ,mutation_location		= 'CLIENT'
							    ,mutation_from			= 'BRANCH'		
							    ,mutation_to			= @movement_to_client_name
							    ,mutation_date			= @movement_date
								,release_customer_date	= @movement_date
							    ,mutation_return_date	= NULL
								,mod_date				= @p_mod_date
								,mod_by					= @p_mod_by
								,mod_ip_address			= @p_mod_ip_address
						where	code = @document_main_code
						 
						-- if exist in document request maka di cancel
						update	dbo.document_request
						set		request_status  = 'CANCEL'
						where	document_code = @document_main_code 
						and		request_status = 'HOLD'



				END
				EXEC dbo.xsp_document_history_insert @p_id = 0,                             
				                                     @p_document_code = @document_main_code,           
				                                     @p_document_status = @document_status,       
				                                     @p_movement_type = @history_movement_type,           
				                                     @p_movement_location = @movement_location,   
				                                     @p_movement_from = @document_movement_from,  
				                                     @p_movement_to = @document_movement_to,      
				                                     @p_movement_by = @movement_by_emp_name,      
				                                     @p_movement_date = @movement_date,       
				                                     @p_movement_return_date = @return_date,  
				                                     @p_locker_position = 'OUT LOCKER',           
				                                     @p_locker_code = null,                       
				                                     @p_drawer_code = null,                       
				                                     @p_row_code = null,                          
				                                     @p_remarks = @movement_remark,               
				                                     @p_cre_date = @p_mod_date,             
				                                     @p_cre_by = @p_mod_by,                       
				                                     @p_cre_ip_address = @p_mod_ip_address,       
				                                     @p_mod_date =@p_mod_date,              
				                                     @p_mod_by = @p_mod_by,                       
				                                     @p_mod_ip_address = @p_mod_ip_address        
				
						--IF @@ERROR > 0
						--BEGIN
						--	close cursor_movement
						--	deallocate cursor_movement
						--END
			PRINT 'yy'
                    
					fetch next from cursor_movement into
						@document_main_code
						,@is_reject		
						,@remarks		
						,@agreement_no		
						,@collateral_no		
						,@asset_no		
						,@doc_expired_date	
						,@document_type
						,@document_code
						,@document_request_code
				end
				close cursor_movement
				deallocate cursor_movement
		
			PRINT 'xxx'
            
			update	dbo.document_movement
			set		movement_status = @movement_status
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;
		end
	end try
	begin catch
    
			
			if cursor_status('global','cursor_movement') >= -1
			 begin
			  if cursor_status('global','cursor_movement') > -1
			   begin
				close cursor_movement
			   end
			 deallocate cursor_movement
			END
            
			declare  @error int
			set  @error = @@error
		 
			if ( @error = 2627)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_exist();
			end ;
			if (len(@msg) <> 0)
			begin
				set @msg = 'V' + ';' + @msg ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();
			end ;
	
			raiserror(@msg, 16, -1) ;
	
			return ; 
		 end catch ;
end ;
