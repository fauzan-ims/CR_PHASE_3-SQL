CREATE PROCEDURE dbo.xsp_application_asset_doc_generate
(
	@p_asset_no				nvarchar(50)
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
	declare @msg					nvarchar(max)
			,@document_group_code	nvarchar(50)
			,@general_doc_code		nvarchar(50)
			,@is_required			nvarchar(1)

	begin TRY
 
		exec dbo.xsp_dimension_get_data_match @p_code					= @document_group_code OUTPUT,     
		                                      @p_reff_tabel_dimension	= N'MASTER_DOCUMENT_GROUP', 
		                                      @p_reff_no				= @p_asset_no,             
		                                      @p_reff_tabel_type		= 'DGASSET',    
											  @p_reff_from_table		= 'APPLICATION_ASSET'
		
		declare generate_doc	cursor local fast_forward for
	
		select	dgd.general_doc_code
				,dgd.is_required
		from	dbo.master_document_group_detail dgd
		where	dgd.document_group_code	= @document_group_code

		open generate_doc
			fetch next from generate_doc  
			into	@general_doc_code
					,@is_required

		while @@fetch_status = 0
			begin
				if not exists (select 1 from dbo.application_asset_doc where asset_no = @p_asset_no and document_code = @general_doc_code) 
				begin
					exec dbo.xsp_application_asset_doc_insert @p_id					= 0 -- bigint
															  ,@p_asset_no			= @p_asset_no
															  ,@p_document_code		= @general_doc_code
															  ,@p_filename			= ''
															  ,@p_paths				= ''
															  ,@p_expired_date		= null
															  ,@p_promise_date		= null
															  ,@p_is_required		= @is_required
															  ,@p_cre_date			= @p_cre_date		
															  ,@p_cre_by			= @p_cre_by			
															  ,@p_cre_ip_address	= @p_cre_ip_address
															  ,@p_mod_date			= @p_mod_date		
															  ,@p_mod_by			= @p_mod_by			
															  ,@p_mod_ip_address	= @p_mod_ip_address	
					
					
				end
				else
				begin
					update	dbo.application_asset_doc
					set		is_required = @is_required
					where	asset_no	  = @p_asset_no
							and document_code = @general_doc_code ;
				end

				fetch next from generate_doc  
						into	@general_doc_code
								,@is_required
			end

			close generate_doc
			deallocate generate_doc	
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
end


