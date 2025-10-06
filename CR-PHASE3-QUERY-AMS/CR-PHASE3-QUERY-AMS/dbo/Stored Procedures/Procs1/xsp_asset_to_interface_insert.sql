CREATE PROCEDURE dbo.xsp_asset_to_interface_insert
(
	@p_asset_code			nvarchar(50)
	,@p_cover_note			nvarchar(50)	= ''
	,@p_cover_note_date		datetime		= null
	,@p_cover_exp_date		datetime		= null
	,@p_cover_file_name		nvarchar(250)	= ''
	,@p_cover_file_path		nvarchar(250)	= ''
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin 
	declare @msg							nvarchar(max)
			,@asset_code					nvarchar(50)
			,@asset_name					nvarchar(250)
			,@system_date					datetime
			,@document_pending_branch_code	nvarchar(50)
			,@document_pending_branch_name	nvarchar(250)
			,@document_pending_code			nvarchar(50)
			,@application_doc_document_code nvarchar(50)
			,@application_doc_document_name nvarchar(250)
			,@is_temporary					nvarchar(1)
			,@application_doc_file_name		nvarchar(250)
			,@application_doc_paths			nvarchar(250)
			,@application_doc_expired_date	datetime
			,@temporary_document_value		nvarchar(max)
			,@result						nvarchar(1)
			,@query							nvarchar(max)
			,@ParmDefinition				nvarchar(500) 
			,@document_type					nvarchar(50)
					

	begin try 
		set @system_date = dbo.xfn_get_system_date(); 
		
		-- interface document pending
		begin
					
			select	@temporary_document_value = isnull(value, '')
			from	dbo.sys_global_param
			where	code = 'DOCTEMP' ;
		   
			select	@document_pending_branch_code	= ass.branch_code
					,@document_pending_branch_name	= ass.branch_name
					,@asset_code					= ass.code
					,@asset_name					= ass.item_name
					,@document_type					= isnull(eia.document_type,'')
			from	dbo.asset ass
			left join dbo.efam_interface_asset eia on (ass.code = eia.code)
			where	ass.code							= @p_asset_code ;

		    -- insert application document to document pending header
			exec dbo.xsp_ams_interface_document_pending_insert @p_code						= @document_pending_code output
															   ,@p_branch_code				= @document_pending_branch_code
															   ,@p_branch_name				= @document_pending_branch_name
															   ,@p_initial_branch_code		= @document_pending_branch_code
															   ,@p_initial_branch_name		= @document_pending_branch_name
															   ,@p_document_type			= @document_type
															   ,@p_document_status			= 'HOLD'
															   ,@p_asset_no					= @asset_code
															   ,@p_asset_name				= @asset_name
															   ,@p_entry_date				= @system_date
															   ,@p_cover_note_no			= @p_cover_note
															   ,@p_cover_note_date			= @p_cover_note_date
															   ,@p_cover_note_exp_date		= @p_cover_exp_date
															   ,@p_file_name				= @p_cover_file_name
															   ,@p_file_path				= @p_cover_file_path
															   ,@p_cre_date					= @p_cre_date
															   ,@p_cre_by					= @p_cre_by
															   ,@p_cre_ip_address			= @p_cre_ip_address
															   ,@p_mod_date					= @p_mod_date
															   ,@p_mod_by					= @p_mod_by
															   ,@p_mod_ip_address			= @p_mod_ip_address ; 
			-- looping application document to document pending detail  
			declare currapplicationdoc cursor fast_forward read_only for 
			select	ad.document_code
					,sgd.document_name
					,ad.file_name
					,ad.file_path
					,null
			from	dbo.asset_document ad
					inner join dbo.sys_general_document sgd on (sgd.code = ad.document_code)
			where	ad.asset_code = @p_asset_code ;
			
			open currapplicationdoc
			
			fetch next from currapplicationdoc 
			into @application_doc_document_code
				 ,@application_doc_document_name
				 ,@application_doc_file_name		
				 ,@application_doc_paths			
				 ,@application_doc_expired_date

			while @@fetch_status = 0
			begin
			
				set @query = 'select @retvalOUT = 1 from dbo.sys_global_param where code = ''DOCTEMP'' and ''' + @application_doc_document_code + ''' in (' + @temporary_document_value + ')' ;
				set @ParmDefinition = N'@retvalOUT nvarchar(1) output' ;

				exec sp_executesql @query
								   ,@ParmDefinition
								   ,@retvalOUT = @result output ;

				if (isnull(@result, '0') <> '0')
				begin
					set @is_temporary = '1' ;
				end ;
				else
				begin
					set @is_temporary = '0' ;
				end ;

				set @result  = '0';

			    exec dbo.xsp_ams_interface_document_pending_detail_insert @p_document_pending_code	= @document_pending_code
			    														  ,@p_document_name			= @application_doc_document_name
			    														  ,@p_document_description  = '' 
			    														  ,@p_file_name				= @application_doc_file_name
			    														  ,@p_paths					= @application_doc_paths
			    														  ,@p_expired_date			= @application_doc_expired_date 
																		  ,@p_is_temporary			= @is_temporary
			    														  ,@p_cre_date				= @p_cre_date	   
			    														  ,@p_cre_by				= @p_cre_by		   
			    														  ,@p_cre_ip_address		= @p_cre_ip_address 
			    														  ,@p_mod_date				= @p_mod_date	   
			    														  ,@p_mod_by				= @p_mod_by		   
			    														  ,@p_mod_ip_address		= @p_mod_ip_address 
			    
			
			    fetch next from currapplicationdoc 
				into @application_doc_document_code
					 ,@application_doc_document_name
					 ,@application_doc_file_name		
					 ,@application_doc_paths			
					 ,@application_doc_expired_date
			end
			
			close currapplicationdoc
			deallocate currapplicationdoc 
		end
	
		-- interface asset
		insert into dbo.ams_interface_asset_main
		(
			asset_no
			,asset_type_code
			,asset_name
			,asset_condition
			,market_value
			,asset_value
			,doc_asset_no
			,asset_year
			,reff_no_1
			,reff_no_2
			,reff_no_3
			,vendor_code
			,vendor_name
			,vendor_address
			,vendor_pic_name 
			,vendor_pic_area_phone_no
			,vendor_pic_phone_no
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	code
				,type_code
				,item_name
				,condition
				,original_price
				,purchase_price
				,isnull(av.bpkb_no, isnull(am.invoice_no, isnull(ah.invoice_no, ae.serial_no)))
				,isnull(av.built_year, isnull(am.built_year, ''))
				,isnull(av.plat_no, isnull(ah.invoice_no, isnull(am.invoice_no, ae.serial_no)))
				,isnull(av.chassis_no, isnull(ah.chassis_no, isnull(am.chassis_no, ae.imei)))
				,isnull(av.engine_no, isnull(ah.engine_no, isnull(am.engine_no, ae.imei)))
				,vendor_code
				,vendor_name
				,'' --vendor_address
				,'' --vendor_pic_name
				,'' --vendor_pic_name 
				,'' --vendor_pic_phone_no
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.asset aa
				left join dbo.asset_vehicle av on (av.asset_code	= aa.code)
				left join dbo.asset_he ah on (ah.asset_code			= aa.code)
				left join dbo.asset_machine am on (am.asset_code	= aa.code)
				left join dbo.asset_electronic ae on (ae.asset_code = aa.code)
		where	code = @p_asset_code ;
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





