CREATE PROCEDURE dbo.xsp_document_movement_to_document_main
(
	@p_document_main_code		 nvarchar(50)   = '' output
	,@p_branch_code				 nvarchar(50)
	,@p_branch_name				 nvarchar(250)
	,@p_movement_date			 datetime
	,@p_movement_by_emp_name	 nvarchar(250)
	,@p_document_movement_to	 nvarchar(50)
	,@p_document_movement_from	 nvarchar(50)
	,@p_document_type			 nvarchar(50)
	,@p_asset_no				 nvarchar(50)
	,@p_asset_name				 nvarchar(250)
	,@p_custody_branch_code		 nvarchar(50)
	,@p_custody_branch_name		 nvarchar(250) 
	,@p_cover_note_no			 nvarchar(50)
	,@p_cover_note_date			 datetime
	,@p_cover_note_exp_date		 datetime
	,@p_vendor_code				 nvarchar(50)	= null
	,@p_vendor_name				 nvarchar(250)	= null
	,@p_vendor_address			 nvarchar(4000)	= null
	,@p_vendor_pic_name			 nvarchar(250)	= null
	,@p_vendor_pic_area_phone_no nvarchar(4)	= null
	,@p_vendor_pic_phone_no		 nvarchar(15)	= null
	,@p_file_name				 nvarchar(250)  = null
	,@p_file_paths				 nvarchar(250)  = null
	,@p_asset_type				 nvarchar(50)
	,@p_document_date			 datetime		= null
	,@p_document_description	 nvarchar(4000) = null
	,@p_doc_no					 nvarchar(50)   = null
	,@p_doc_name				 nvarchar(250)  = null
	,@p_expired_date			 datetime 	    = null
	--							 
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg							  nvarchar(max)
			,@replacement_request_id		  bigint
			,@document_main_suplementary_code nvarchar(50) 
			,@document_main_type			  nvarchar(20)
			,@total_asset					  int = 0

	begin try   
		if(@p_document_type = 'COVER NOTE')
		begin
			set @p_document_type = 'COVERNOTE'
		end
		
		if (@p_document_type <> 'COVERNOTE')
		begin
			if (@p_asset_type = 'VHCL')
			begin
				set @document_main_type = 'BPKB'
			end
			else
			begin
				set @document_main_type = 'INVOICE'
			end
			
			--membentuk document main dengan type SUPPLEMENTARY
			exec dbo.xsp_document_main_insert @p_code						= @p_document_main_code output
												,@p_branch_code				= @p_branch_code
												,@p_branch_name				= @p_branch_name
												,@p_custody_branch_code		= @p_custody_branch_code
												,@p_custody_branch_name		= @p_custody_branch_name
												,@p_document_type			= @document_main_type 
												,@p_asset_no				= @p_asset_no
												,@p_asset_name				= @p_asset_name
												,@p_locker_position			= 'OUT LOCKER'
												,@p_locker_code				= null
												,@p_drawer_code				= null
												,@p_row_code				= null
												,@p_document_status			= 'ON HAND'
												,@p_mutation_type			= 'ENTRY'
												,@p_mutation_location		= @p_document_movement_to
												,@p_mutation_from			= @p_document_movement_from
												,@p_mutation_to				= @p_document_movement_to
												,@p_mutation_by				= @p_movement_by_emp_name
												,@p_mutation_date			= @p_movement_date
												,@p_mutation_return_date	= null
												,@p_last_mutation_type		= null
												,@p_last_mutation_date		= null
												,@p_last_locker_position	= null
												,@p_last_locker_code		= null
												,@p_last_drawer_code		= null
												,@p_last_row_code			= null
												,@p_borrow_thirdparty_type	= null
												,@p_first_receive_date		= @p_movement_date
												,@p_release_customer_date	= null
												---
												,@p_cre_date				= @p_mod_date
												,@p_cre_by					= @p_mod_by
												,@p_cre_ip_address			= @p_mod_ip_address
												,@p_mod_date				= @p_mod_date
												,@p_mod_by					= @p_mod_by
												,@p_mod_ip_address			= @p_mod_ip_address ;
			
			--membentuk document detail sesuai document type
			exec dbo.xsp_document_detail_insert @p_id					 = 0 
												,@p_document_code		 = @p_document_main_code
												,@p_document_name		 = @document_main_type
												,@p_document_type		 = @document_main_type
												,@p_document_date		 = @p_document_date			
												,@p_document_description = @p_document_description	
												,@p_file_name			 = @p_file_name				
												,@p_paths				 = @p_file_paths
												,@p_doc_no				 = @p_doc_no	
												,@p_doc_name			 = @p_doc_name 
												,@p_expired_date		 = @p_expired_date
												---
												,@p_cre_date			 = @p_mod_date
												,@p_cre_by				 = @p_mod_by
												,@p_cre_ip_address		 = @p_mod_ip_address
												,@p_mod_date			 = @p_mod_date
												,@p_mod_by				 = @p_mod_by
												,@p_mod_ip_address		 = @p_mod_ip_address ; 
				
			if (@p_asset_type = 'VHCL')
			begin
				--membentuk document main dengan type SUPPLEMENTARY
				exec dbo.xsp_document_main_insert @p_code						= @document_main_suplementary_code output
													,@p_branch_code				= @p_branch_code
													,@p_branch_name				= @p_branch_name
													,@p_custody_branch_code		= @p_custody_branch_code
													,@p_custody_branch_name		= @p_custody_branch_name
													,@p_document_type			= 'SUPPLEMENTARY' 
													,@p_asset_no				= @p_asset_no
													,@p_asset_name				= @p_asset_name
													,@p_locker_position			= 'OUT LOCKER'
													,@p_locker_code				= null
													,@p_drawer_code				= null
													,@p_row_code				= null
													,@p_document_status			= 'ON HAND'
													,@p_mutation_type			= 'ENTRY'
													,@p_mutation_location		= @p_document_movement_to
													,@p_mutation_from			= @p_document_movement_from
													,@p_mutation_to				= @p_document_movement_to
													,@p_mutation_by				= @p_movement_by_emp_name
													,@p_mutation_date			= @p_movement_date
													,@p_mutation_return_date	= null
													,@p_last_mutation_type		= null
													,@p_last_mutation_date		= null
													,@p_last_locker_position	= null
													,@p_last_locker_code		= null
													,@p_last_drawer_code		= null
													,@p_last_row_code			= null
													,@p_borrow_thirdparty_type	= null
													,@p_first_receive_date		= @p_movement_date
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
													,@p_document_date		 = @p_document_date			
													,@p_document_description = @p_document_description	
													,@p_file_name			 = @p_file_name				
													,@p_paths				 = @p_file_paths
													,@p_doc_no				 = @p_doc_no	
													,@p_doc_name			 = @p_doc_name 
													,@p_expired_date		 = @p_expired_date
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
													,@p_document_date		 = @p_document_date			
													,@p_document_description = @p_document_description	
													,@p_file_name			 = @p_file_name				
													,@p_paths				 = @p_file_paths
													,@p_doc_no				 = @p_doc_no	
													,@p_doc_name			 = @p_doc_name 
													,@p_expired_date		 = @p_expired_date
													---
													,@p_cre_date			 = @p_mod_date
													,@p_cre_by				 = @p_mod_by
													,@p_cre_ip_address		 = @p_mod_ip_address
													,@p_mod_date			 = @p_mod_date
													,@p_mod_by				 = @p_mod_by
													,@p_mod_ip_address		 = @p_mod_ip_address ;  

					exec dbo.xsp_document_history_insert @p_id						= 0
														 ,@p_document_code			= @document_main_suplementary_code
														 ,@p_document_status		= 'ON HAND'
														 ,@p_movement_type			= 'RECEIVED'
														 ,@p_movement_location		= 'ENTRY'
														 ,@p_movement_from			= null
														 ,@p_movement_to			= null
														 ,@p_movement_by			= null
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
			end
		end ;
		else
		begin   
			if not exists
			(
				select	1
				from	dbo.replacement_request
				where	cover_note_no = @p_cover_note_no
						and status = 'HOLD'
			)
			begin  
				exec dbo.xsp_replacement_request_insert @p_id						= @replacement_request_id output
														,@p_branch_code				= @p_branch_code			
														,@p_branch_name				= @p_branch_name			
														,@p_cover_note_no			= @p_cover_note_no		
														,@p_cover_note_date			= @p_cover_note_date		
														,@p_cover_note_exp_date		= @p_cover_note_exp_date 
														,@p_vendor_code				= @p_vendor_code				 
														,@p_vendor_name				= @p_vendor_name				 
														,@p_vendor_address			= @p_vendor_address			 
														,@p_vendor_pic_name			= @p_vendor_pic_name			 
														,@p_vendor_pic_area_phone_no= @p_vendor_pic_area_phone_no 
														,@p_vendor_pic_phone_no		= @p_vendor_pic_phone_no		 
														,@p_document_name			= N'COVERNOTE'
														,@p_count_asset				= 0
														,@p_received_asset			= 0
														,@p_extend_count			= 0
														,@p_file_name				= @p_file_name	
														,@p_paths					= @p_file_paths		
														,@p_status					= N'HOLD'
														,@p_remarks					= null
														,@p_replacement_code		= null
														,@p_cre_date				= @p_mod_date
														,@p_cre_by					= @p_mod_by
														,@p_cre_ip_address			= @p_mod_ip_address
														,@p_mod_date				= @p_mod_date
														,@p_mod_by					= @p_mod_by
														,@p_mod_ip_address			= @p_mod_ip_address
														
			end ;
			else
			begin
				select	@replacement_request_id = id
				from	dbo.replacement_request
				where	cover_note_no = @p_cover_note_no
			end

			update	dbo.replacement_request
			set		replacement_code = null
			where	id = @replacement_request_id

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
			values
			(	@replacement_request_id
				,@p_asset_no
				,N'HOLD'
				,null
				,null
				--
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;

			select	@total_asset = count(1)
			from	dbo.replacement_request_detail
			where	replacement_request_id = @replacement_request_id ;

			update	dbo.replacement_request
			set		count_asset = @total_asset
			where	id = @replacement_request_id ;
		end ;
	end try
	begin catch
		if cursor_status('global', 'currMovementDetail') >= -1
		begin
			if cursor_status('global', 'currMovementDetail') > -1
			begin
				close currMovementDetail ;
			end ;

			deallocate currMovementDetail ;
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


