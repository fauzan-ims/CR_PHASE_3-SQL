CREATE PROCEDURE dbo.xsp_application_document_contract_generate
(
	@p_application_no		nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@document_group_code	    nvarchar(50)
			,@document_contract_code	nvarchar(50);

	begin try
		delete  application_document_contract where application_no = @p_application_no
		
		exec dbo.xsp_dimension_get_data_match @p_code					= @document_group_code OUTPUT,      
		                                      @p_reff_tabel_dimension	= N'MASTER_DOCUMENT_CONTRACT_GROUP',
		                                      @p_reff_no				= @p_application_no,             
		                                      @p_reff_tabel_type		= 'DCAPPLICATION',
											  @p_reff_from_table		= 'APPLICATION_MAIN'	 

		declare cursor_generate_doc	cursor local fast_forward for
		
		--exec sp XSP_MASTER_DOCUMENT_GROUP_GET_BY_DIMENSION
		select	dgd.document_contract_code
		from	dbo.master_document_contract_group_detail dgd
		where	dgd.document_contract_group_code = @document_group_code

		open cursor_generate_doc
			fetch next from cursor_generate_doc  
			into	@document_contract_code

		while @@fetch_status = 0
			begin
				exec dbo.xsp_application_document_contract_insert @p_application_no				= @p_application_no
																  ,@p_document_contract_code	= @document_contract_code
																  ,@p_filename					= N'' 
																  ,@p_paths						= N'' 
																  ,@p_print_count				= 0 -- int
																  ,@p_last_print_date			= null
																  ,@p_last_print_by				= N'' 
																  ,@p_cre_date					= @p_mod_date		
																  ,@p_cre_by					= @p_mod_by			
																  ,@p_cre_ip_address			= @p_mod_ip_address
																  ,@p_mod_date					= @p_mod_date		
																  ,@p_mod_by					= @p_mod_by			
																  ,@p_mod_ip_address			= @p_mod_ip_address	
					
				fetch next from cursor_generate_doc  
						into	@document_contract_code

			end

			close cursor_generate_doc
			deallocate cursor_generate_doc	
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

