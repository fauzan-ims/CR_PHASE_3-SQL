CREATE PROCEDURE dbo.xsp_replacement_post
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg							  nvarchar(max)
			,@replacement_code				  nvarchar(50)
			,@collateral_no					  nvarchar(50)
			,@plafond_collateral_no			  nvarchar(50)
			,@type							  nvarchar(10)
			,@bpkb_no						  nvarchar(50)
			,@bpkb_date						  datetime
			,@bpkb_name						  nvarchar(250)
			,@bpkb_address					  nvarchar(4000)
			,@stnk_name						  nvarchar(250)
			,@stnk_exp_date					  datetime
			,@stnk_tax_date					  datetime
			,@cover_note_no					  nvarchar(50)
			,@cover_note_date				  datetime
			,@cover_note_exp_date			  datetime
			,@new_cover_note_no				  nvarchar(50)
			,@new_cover_note_date			  datetime
			,@new_cover_note_exp_date		  datetime
			,@branch_code					  nvarchar(50)
			,@branch_name					  nvarchar(250)
			,@asset_no						  nvarchar(50)
			,@asset_name					  nvarchar(250)
			,@asset_type					  nvarchar(50)
			,@plafond_no					  nvarchar(50)
			,@remarks						  nvarchar(4000)
			,@document_type					  nvarchar(10)
			,@document_name					  nvarchar(50)
			,@file_path						  nvarchar(4000)
			,@file_name						  nvarchar(4000)
			,@document_date					  datetime
			,@expired_date					  datetime
			,@extend_count					  int
			,@ext_count						  int
			,@remark						  nvarchar(4000)
			,@detail_id						  bigint
			,@client_name					  nvarchar(250)
			,@document_code					  nvarchar(50)
			,@new_file_name					  nvarchar(4000)
			,@new_file_paths				  nvarchar(4000)
			,@total_asset					  int
			,@document_main_code			  nvarchar(50)
			,@new_replacement_request_id	  bigint
			,@replacement_request_detail_id	  bigint
			,@document_main_suplementary_code nvarchar(50)
			,@received_asset				  int
			,@vendor_code					  nvarchar(50)	 = null
			,@vendor_name					  nvarchar(250)	 = null
			,@vendor_address				  nvarchar(4000) = null
			,@vendor_pic_name				  nvarchar(250)	 = null
			,@vendor_pic_area_phone_no		  nvarchar(4)	 = null
			,@vendor_pic_phone_no			  nvarchar(15)	 = null 
			,@employee_name					  nvarchar(50)
			,@request_id					bigint

	begin TRY

		select	@type = type 
		from	dbo.replacement 
		where	code = @p_code

		if (@type = 'REPLACE')
		begin
			if NOT EXISTS
			(
				select	1
				from	dbo.replacement_detail
				where	type = 'replace'
						and replacement_code = @p_code
			)
			begin
				set @msg = N'Please add type temporary detail before Post' ;

				raiserror(@msg, 16, -1) ;
			end 
		end

		select	@branch_code = rp.branch_code
				,@branch_name = rp.branch_name
				,@cover_note_no = rp.cover_note_no
				,@cover_note_date = rp.cover_note_date
				,@cover_note_exp_date = rp.cover_note_exp_date
				,@new_cover_note_no = new_cover_note_no
				,@new_cover_note_date = new_cover_note_date
				,@new_cover_note_exp_date = new_cover_note_exp_date
				,@extend_count = rr.extend_count + 1
				,@file_name = rp.file_name
				,@file_path = rp.paths
				,@vendor_code = vendor_code
				,@vendor_name = vendor_name
				,@vendor_address = vendor_address
				,@vendor_pic_name = vendor_pic_name
				,@vendor_pic_area_phone_no = vendor_pic_area_phone_no
				,@vendor_pic_phone_no = vendor_pic_phone_no
				,@request_id	= rr.id
		from	dbo.replacement rp
				left join dbo.replacement_request rr on ( rr.replacement_code = rp.code)
		where	code = @p_code ;

		if exists
		(
			select	1
			from	dbo.replacement
			where	code	   = @p_code
					and status = 'HOLD'
		)
		begin
			if exists
			(
				select	1
				from	dbo.replacement
				where	code	 = @p_code
						and type = 'EXTEND'
			)
			begin
				select @total_asset = count(1) from dbo.replacement_detail where replacement_code = @p_code
				
				exec dbo.xsp_replacement_request_insert @p_id						 = @new_replacement_request_id output
														,@p_branch_code				 = @branch_code
														,@p_branch_name				 = @branch_name
														,@p_cover_note_no			 = @new_cover_note_no		
														,@p_cover_note_date			 = @new_cover_note_date		
														,@p_cover_note_exp_date		 = @new_cover_note_exp_date
														,@p_vendor_code				 = @vendor_code				 
														,@p_vendor_name				 = @vendor_name				 
														,@p_vendor_address			 = @vendor_address			 
														,@p_vendor_pic_name			 = @vendor_pic_name			 
														,@p_vendor_pic_area_phone_no = @vendor_pic_area_phone_no 
														,@p_vendor_pic_phone_no		 = @vendor_pic_phone_no	
														,@p_document_name			 = N'COVERNOTE'
														,@p_count_asset				 = @total_asset
														,@p_received_asset			 = 0
														,@p_extend_count			 = @extend_count
														,@p_file_name				 = @file_name	
														,@p_paths					 = @file_path		
														,@p_status					 = N'HOLD'
														,@p_remarks					 = N''
														,@p_replacement_code		 = null
														,@p_cre_date				 = @p_mod_date
														,@p_cre_by					 = @p_mod_by
														,@p_cre_ip_address			 = @p_mod_ip_address
														,@p_mod_date				 = @p_mod_date
														,@p_mod_by					 = @p_mod_by
														,@p_mod_ip_address			 = @p_mod_ip_address ;

				-- insert to detail
				insert into dbo.replacement_request_detail
				(
					replacement_request_id
					,asset_no
					,status
					,replacement_code
					,document_main_code
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	@new_replacement_request_id
						,asset_no
						,'HOLD'
						,null
						,null
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.replacement_request_detail
				where	replacement_code = @p_code 
						and status = 'HOLD'

				--update replacement request 
				update	dbo.replacement_request
				set		status			 = 'EXTEND' -- Raffy 17/01/2024 Data extend ketika di post akan masuk temporary request dengan status EXTEND
						--				 
						,mod_date		 = @p_mod_date
						,mod_by			 = @p_mod_by
						,mod_ip_address	 = @p_mod_ip_address
				where	id = @request_id --cover_note_no	 = @cover_note_no ;
			end
			else
			begin
				declare currreplacementdetail cursor fast_forward read_only for 
				select	rd.asset_no
						,rd.type
						,rd.bpkb_no
						,rd.bpkb_date
						,rd.bpkb_name
						,rd.bpkb_address
						,rd.stnk_name
						,rd.stnk_exp_date
						,rd.stnk_tax_date
						,rd.file_name
						,rd.paths
						,fam.asset_name
						,fam.asset_type_code
						,rp.branch_code
						,rp.branch_name
						,rd.replacement_request_detail_id
				from	dbo.replacement_detail rd
						inner join dbo.replacement rp on (rp.code = rd.replacement_code)
						inner join dbo.fixed_asset_main fam on (fam.asset_no = rd.asset_no)
				where	rd.replacement_code = @p_code
						and rd.type = 'REPLACE'
			
				open currreplacementdetail
			
				fetch next from currreplacementdetail 
				into @asset_no
					 ,@type
					 ,@bpkb_no
					 ,@bpkb_date
					 ,@bpkb_name
					 ,@bpkb_address
					 ,@stnk_name
					 ,@stnk_exp_date
					 ,@stnk_tax_date
					 ,@file_name
					 ,@file_path
					 ,@asset_name
					 ,@asset_type
					 ,@branch_code
					 ,@branch_name
					 ,@replacement_request_detail_id
			
				while @@fetch_status = 0
				begin
			    
					--membentuk document main BPKB
					begin
						exec dbo.xsp_document_main_insert @p_code						= @document_main_code output
															,@p_branch_code				= @branch_code
															,@p_branch_name				= @branch_name
															,@p_custody_branch_code		= @branch_code
															,@p_custody_branch_name		= @branch_name
															,@p_document_type			= 'BPKB' 
															,@p_asset_no				= @asset_no
															,@p_asset_name				= @asset_name
															,@p_locker_position			= 'OUT LOCKER'
															,@p_locker_code				= null
															,@p_drawer_code				= null
															,@p_row_code				= null
															,@p_document_status			= 'ON HAND'
															,@p_mutation_type			= 'ENTRY'
															,@p_mutation_location		= N'BRANCH'
															,@p_mutation_from			= N'VENDOR'
															,@p_mutation_to				= N'BRANCH'
															,@p_mutation_by				= @p_mod_by
															,@p_mutation_date			= @p_mod_date
															,@p_mutation_return_date	= null
															,@p_last_mutation_type		= null
															,@p_last_mutation_date		= null
															,@p_last_locker_position	= null
															,@p_last_locker_code		= null
															,@p_last_drawer_code		= null
															,@p_last_row_code			= null
															,@p_borrow_thirdparty_type	= null
															,@p_first_receive_date		= @p_mod_date
															,@p_release_customer_date	= null
															---
															,@p_cre_date				= @p_mod_date
															,@p_cre_by					= @p_mod_by
															,@p_cre_ip_address			= @p_mod_ip_address
															,@p_mod_date				= @p_mod_date
															,@p_mod_by					= @p_mod_by
															,@p_mod_ip_address			= @p_mod_ip_address 
																	 
						if (isnull(@bpkb_no, '') <> '')
						begin
							--membentuk document detail BPKB
							exec dbo.xsp_document_detail_insert @p_id					 = 0 
																,@p_document_code		 = @document_main_code
																,@p_document_name		 = 'BPKB'
																,@p_document_type		 = 'BPKB'
																,@p_document_date		 = @bpkb_date			
																,@p_document_description = @bpkb_address	
																,@p_file_name			 = @file_name
																,@p_paths				 = @file_path
																,@p_doc_no				 = @bpkb_no	
																,@p_doc_name			 = @bpkb_name
																,@p_expired_date		 = null
																---
																,@p_cre_date			 = @p_mod_date
																,@p_cre_by				 = @p_mod_by
																,@p_cre_ip_address		 = @p_mod_ip_address
																,@p_mod_date			 = @p_mod_date
																,@p_mod_by				 = @p_mod_by
																,@p_mod_ip_address		 = @p_mod_ip_address ; 
						end
					
						--if (isnull(@stnk_name, '') <> '')
						--begin
						--	--membentuk document detail STNK
						--	exec dbo.xsp_document_detail_insert @p_id					 = 0 
						--										,@p_document_code		 = @document_main_code
						--										,@p_document_name		 = 'STNK'
						--										,@p_document_type		 = 'STNK'
						--										,@p_document_date		 = @stnk_tax_date			
						--										,@p_document_description = @stnk_name	
						--										,@p_file_name			 = null
						--										,@p_paths				 = null
						--										,@p_doc_no				 = null
						--										,@p_doc_name			 = @stnk_name 
						--										,@p_expired_date		 = @stnk_exp_date
						--										---
						--										,@p_cre_date			 = @p_mod_date
						--										,@p_cre_by				 = @p_mod_by
						--										,@p_cre_ip_address		 = @p_mod_ip_address
						--										,@p_mod_date			 = @p_mod_date
						--										,@p_mod_by				 = @p_mod_by
						--										,@p_mod_ip_address		 = @p_mod_ip_address ; 
															
						--end
					end

					--membentuk document main SUPPLEMENTARY
					exec dbo.xsp_document_main_insert @p_code						= @document_main_suplementary_code output
														,@p_branch_code				= @branch_code
														,@p_branch_name				= @branch_name
														,@p_custody_branch_code		= @branch_code
														,@p_custody_branch_name		= @branch_name
														,@p_document_type			= 'SUPPLEMENTARY' 
														,@p_asset_no				= @asset_no
														,@p_asset_name				= @asset_name
														,@p_locker_position			= 'OUT LOCKER'
														,@p_locker_code				= null
														,@p_drawer_code				= null
														,@p_row_code				= null
														,@p_document_status			= 'ON HAND'
														,@p_mutation_type			= 'ENTRY'
														,@p_mutation_location		= N'BRANCH'
														,@p_mutation_from			= N'VENDOR'
														,@p_mutation_to				= N'BRANCH'
														,@p_mutation_by				= @p_mod_by
														,@p_mutation_date			= @p_mod_date
														,@p_mutation_return_date	= null
														,@p_last_mutation_type		= null
														,@p_last_mutation_date		= null
														,@p_last_locker_position	= null
														,@p_last_locker_code		= null
														,@p_last_drawer_code		= null
														,@p_last_row_code			= null
														,@p_borrow_thirdparty_type	= null
														,@p_first_receive_date		= @p_mod_date
														,@p_release_customer_date	= null
														---
														,@p_cre_date				= @p_mod_date
														,@p_cre_by					= @p_mod_by
														,@p_cre_ip_address			= @p_mod_ip_address
														,@p_mod_date				= @p_mod_date
														,@p_mod_by					= @p_mod_by
														,@p_mod_ip_address			= @p_mod_ip_address ;
											
					--membentuk document detail dengan untuk type SUPPLEMENTARY
					exec dbo.xsp_document_detail_insert @p_id					 = 0 
														,@p_document_code		 = @document_main_suplementary_code
														,@p_document_name		 = 'FORM A/B/C'
														,@p_document_type		 = 'FORM A/B/C'
														,@p_document_date		 = null
														,@p_document_description = ''
														,@p_file_name			 = null	
														,@p_paths				 = null
														,@p_doc_no				 = null
														,@p_doc_name			 = null
														,@p_expired_date		 = null
														---
														,@p_cre_date			 = @p_mod_date
														,@p_cre_by				 = @p_mod_by
														,@p_cre_ip_address		 = @p_mod_ip_address
														,@p_mod_date			 = @p_mod_date
														,@p_mod_by				 = @p_mod_by
														,@p_mod_ip_address		 = @p_mod_ip_address ;  
													
					exec dbo.xsp_document_detail_insert @p_id					 = 0 
														,@p_document_code		 = @document_main_suplementary_code
														,@p_document_name		 = 'FAKTUR'
														,@p_document_type		 = 'FAKTUR'
														,@p_document_date		 = null
														,@p_document_description = ''
														,@p_file_name			 = null
														,@p_paths				 = null
														,@p_doc_no				 = null
														,@p_doc_name			 = null
														,@p_expired_date		 = null
														---
														,@p_cre_date			 = @p_mod_date
														,@p_cre_by				 = @p_mod_by
														,@p_cre_ip_address		 = @p_mod_ip_address
														,@p_mod_date			 = @p_mod_date
														,@p_mod_by				 = @p_mod_by
														,@p_mod_ip_address		 = @p_mod_ip_address ;    

					select	@employee_name = name
					from	ifinsys.dbo.sys_employee_main
					where	ifinsys.dbo.sys_employee_main.code = @p_mod_by

					exec dbo.xsp_document_history_insert @p_id						= 0
														 ,@p_document_code			= @document_main_code
														 ,@p_document_status		= 'ON HAND'
														 ,@p_movement_type			= 'RECEIVED'
														 ,@p_movement_location		= 'ENTRY'
														 ,@p_movement_from			= null
														 ,@p_movement_to			= null
														 ,@p_movement_by			= @employee_name
														 ,@p_movement_date			= null
														 ,@p_movement_return_date	= null
														 ,@p_locker_position		= 'OUT LOCKER'
														 ,@p_locker_code			= null
														 ,@p_drawer_code			= null
														 ,@p_row_code				= null
														 ,@p_remarks				= 'ENTRY'
														 ,@p_cre_date				= @p_mod_date
														 ,@p_cre_by					= @p_mod_by
														 ,@p_cre_ip_address			= @p_mod_ip_address
														 ,@p_mod_date				= @p_mod_date
														 ,@p_mod_by					= @p_mod_by
														 ,@p_mod_ip_address			= @p_mod_ip_address ; 

					exec dbo.xsp_document_history_insert @p_id						= 0
														 ,@p_document_code			= @document_main_suplementary_code
														 ,@p_document_status		= 'ON HAND'
														 ,@p_movement_type			= 'RECEIVED'
														 ,@p_movement_location		= 'ENTRY'
														 ,@p_movement_from			= null
														 ,@p_movement_to			= null
														 ,@p_movement_by			= @employee_name
														 ,@p_movement_date			= null
														 ,@p_movement_return_date	= null
														 ,@p_locker_position		= 'OUT LOCKER'
														 ,@p_locker_code			= null
														 ,@p_drawer_code			= null
														 ,@p_row_code				= null
														 ,@p_remarks				= 'ENTRY'
														 ,@p_cre_date				= @p_mod_date
														 ,@p_cre_by					= @p_mod_by
														 ,@p_cre_ip_address			= @p_mod_ip_address
														 ,@p_mod_date				= @p_mod_date
														 ,@p_mod_by					= @p_mod_by
														 ,@p_mod_ip_address			= @p_mod_ip_address ; 

					update	dbo.replacement_request_detail
					set		replacement_code	= @p_code
							,document_main_code = @document_main_code
							,status				= 'POST'
							--				 
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	id					= @replacement_request_detail_id ;
				
					fetch next from currreplacementdetail
					into @asset_no
						 ,@type
						 ,@bpkb_no
						 ,@bpkb_date
						 ,@bpkb_name
						 ,@bpkb_address
						 ,@stnk_name
						 ,@stnk_exp_date
						 ,@stnk_tax_date
						 ,@file_name
						 ,@file_path
						 ,@asset_name
						 ,@asset_type
						 ,@branch_code
						 ,@branch_name
						 ,@replacement_request_detail_id
				end
			
				close currreplacementdetail
				deallocate currreplacementdetail

				--select	@received_asset = count(1)
				--from	dbo.replacement_detail
				--where	replacement_code = @p_code
				--		and type		 = 'REPLACE'

				select	@received_asset = count(1)
				from	dbo.replacement_request_detail
				where	replacement_code = @p_code
				and		status = 'post'
			
				-- jika masih ada status detail yg belum di replace, update replacement_request, replacement_code jadi null
				if exists (	select 1 from dbo.replacement_request_detail
							where replacement_request_id = @request_id --replacement_code = @p_code (+)raffy 17/10/2024 agar jika dalam 1 covernote masih ada asset yang belum di replace, data nya masih muncul di menu temporary request
							and status <> 'POST')
				begin
						update	dbo.replacement_request
						set		replacement_code = null
								,received_asset	 = @received_asset
								--				 
								,mod_date		 = @p_mod_date
								,mod_by			 = @p_mod_by
								,mod_ip_address	 = @p_mod_ip_address
						where	id = @request_id 
				end
                else
				begin
				    update	dbo.replacement_request
					set		received_asset	 = @received_asset
							,mod_date		 = @p_mod_date
							,mod_by			 = @p_mod_by
							,mod_ip_address	 = @p_mod_ip_address
					where	id = @request_id
				end

			end
            
			--IF (@type = 'EXTEND')
			--BEGIN 
			--	UPDATE dbo.REPLACEMENT_REQUEST
			--	SET		REPLACEMENT_CODE = NULL 
			--	where	cover_note_no	 = @cover_note_no ; 
			--end
			
			update	dbo.replacement
			set		status			= 'POST' 
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;

		BEGIN
			/* declare main cursor */
		declare c_replacement_detail cursor local fast_forward read_only for 
		select	asset_no
				,bpkb_no
				,BPKB_NAME
				,BPKB_ADDRESS
		from	dbo.replacement_detail 
		where	replacement_code = @p_code
		and		type = 'REPLACE'

		/* fetch record */
		open	c_replacement_detail
		fetch	c_replacement_detail
		into	@asset_no
				,@bpkb_no
				,@bpkb_name
				,@bpkb_address
		WHILE @@fetch_status = 0
		begin

				/* Update into table asset */
				update	ifinams.dbo.asset_vehicle
				set		bpkb_no = @bpkb_no
						--(
						--	select	bpkb_no
						--	from	dbo.REPLACEMENT_DETAIL
						--	where	ASSET_NO = @asset_no
						--)
						,STNK_NAME = @bpkb_name
						 --(
							--select	BPKB_NAME
							--from	dbo.REPLACEMENT_DETAIL
							--where	ASSET_NO = @asset_no
						 --)
						 ,STNK_ADDRESS = @bpkb_address
						 --(
							--select	BPKB_ADDRESS
							--from	dbo.REPLACEMENT_DETAIL
							--where	ASSET_NO = @asset_no
						 --)
				where	asset_code = @asset_no

		/* fetch record berikutnya */
		fetch	c_replacement_detail
		into	@asset_no
				,@bpkb_no
				,@bpkb_name
				,@bpkb_address									
		end		
		
		/* tutup cursor */
		close		c_replacement_detail
		deallocate	c_replacement_detail
					
		END ;
		end ;
		else
		begin
			set @msg = 'Data already post' ;

			raiserror(@msg, 16, 1) ;
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
