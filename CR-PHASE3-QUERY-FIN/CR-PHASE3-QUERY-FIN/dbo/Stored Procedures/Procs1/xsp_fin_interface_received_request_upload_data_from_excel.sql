CREATE PROCEDURE dbo.xsp_fin_interface_received_request_upload_data_from_excel
(
	@p_code										nvarchar(50)
	,@p_branch_code								nvarchar(50)=''
	,@p_branch_name								nvarchar(250)=''
	,@p_received_source							nvarchar(50)=''
	,@p_received_request_date					nvarchar(50)=''
	,@p_received_source_no						nvarchar(50)=''
    ,@p_received_currency_code					nvarchar(3)=''
	,@p_received_amount							nvarchar(50)=''
	,@p_received_remarks						nvarchar(4000)=''
	--
	,@p_cre_date								datetime
	,@p_cre_by									nvarchar(15)
	,@p_cre_ip_address							nvarchar(15)
	,@p_mod_date								datetime
	,@p_mod_by									nvarchar(15)
	,@p_mod_ip_address							nvarchar(15)
)
as
BEGIN
	
	declare @msg							nvarchar(max)
			,@msg_validation				nvarchar(max)=''
			,@error_count					bigint
            ,@primary_key					nvarchar(250)

	begin try
    
		SET @primary_key = NEWID()

		EXEC	dbo.xsp_core_upload_generic_insert 
				@p_table_name = 'FIN_INTERFACE_RECEIVED_REQUEST'                
		        ,@p_primary_key = @primary_key           
		        ,@p_column_01 = @p_branch_code              
		        ,@p_column_02 = @p_branch_name           
		        ,@p_column_03 = @p_received_source         
		        ,@p_column_04 = @p_received_request_date            
		        ,@p_column_05 = @p_received_source_no            
		        ,@p_column_06 = @p_received_currency_code           
		        ,@p_column_07 = @p_received_amount             
		        ,@p_column_08 = @p_received_remarks            
		        ,@p_status = ''                    
				--
		        ,@p_cre_date = @p_cre_date						
		        ,@p_cre_by = @p_cre_by							
		        ,@p_cre_ip_address = @p_cre_ip_address          
		        ,@p_mod_date = @p_mod_date						
		        ,@p_mod_by = @p_mod_by							
		        ,@p_mod_ip_address = @p_mod_ip_address
		
		delete	dbo.upload_error_log
		where	tabel_name			= 'FIN_INTERFACE_RECEIVED_REQUEST' 
		and		primary_column_name = @primary_key

		EXEC	dbo.xsp_manual_upload_validation
				--@id
				@primary_key				
				,@p_code				
				--
				,@p_cre_date				
				,@p_cre_by					
				,@p_cre_ip_address			
				,@p_mod_date				
				,@p_mod_by					
				,@p_mod_ip_address
		
		SET @error_count = 0

		select	@error_count		= count(id) 
		from	dbo.upload_error_log
		where	tabel_name			= 'FIN_INTERFACE_RECEIVED_REQUEST' 
		and		primary_column_name = @primary_key

		if(@error_count > 0)
		begin
			
			update	dbo.core_upload_generic
			set		status = 'Error : ' + convert(nvarchar,@error_count)
			where	table_name	= 'FIN_INTERFACE_RECEIVED_REQUEST' 
			and		primary_key	= @primary_key

        end
		else
		begin
			
			update	dbo.core_upload_generic
			set		status		= 'Ok'
			where	primary_key	= @primary_key

		END
		
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
