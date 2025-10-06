CREATE PROCEDURE dbo.xsp_fin_interface_cashier_received_request_upload_post
(
	@p_cre_by				nvarchar(15)
)
as
begin

	declare		@msg							nvarchar(max)
				--
				,@branch_code					nvarchar(50)
				,@branch_name					nvarchar(250)
				,@request_currency_code			nvarchar(5)
				,@request_date					datetime
				,@request_amount				decimal(18, 2)
				,@request_remarks				nvarchar(4000)
				,@agreement_no					nvarchar(50)
				,@pdc_code						nvarchar(50)
				,@pdc_no						nvarchar(50)
				,@doc_ref_code					nvarchar(50)
				,@doc_ref_name					nvarchar(250)
				--
				,@cre_date						datetime
				,@cre_by						nvarchar(15)
				,@cre_ip_address				nvarchar(15)
				,@mod_date						DATETIME
				,@mod_by						nvarchar(15)
				,@mod_ip_address				nvarchar(15)

	begin try
		
		if exists	(
						select	1 
						from	core_upload_generic 
						where	table_name = 'FIN_INTERFACE_CASHIER_RECEIVED_REQUEST'
						and		status <> 'Ok'
						and     cre_by = @p_cre_by
					)
		begin
			
			set @msg = 'Invalid data upload, Please check data upload' ;

			raiserror(@msg, 16, -1) ;

        end
        
		declare c_upload_generic cursor for

		select	column_01
				,column_02
				,column_03
				,column_04
				,column_05
				,column_06
				,column_07
				,column_08
				,column_09
				,column_10
				,column_11
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address 
		from	dbo.core_upload_generic
		where	table_name = 'FIN_INTERFACE_CASHIER_RECEIVED_REQUEST'
		and		cre_by = @p_cre_by

		open	c_upload_generic
		fetch	c_upload_generic
		into	@branch_code				
				,@branch_name		
				,@request_currency_code	
				,@request_date			
				,@request_amount			
				,@request_remarks			
				,@agreement_no			
				,@pdc_code				
				,@pdc_no					
				,@doc_ref_code			
				,@doc_ref_name
				--
				,@cre_date			
				,@cre_by			
				,@cre_ip_address	
				,@mod_date		
				,@mod_by			
				,@mod_ip_address		

		WHILE @@fetch_status=0
		BEGIN
			
			EXEC	dbo.xsp_fin_interface_cashier_received_request_insert 
					@p_code = ''							
			        ,@p_branch_code = @branch_code					
			        ,@p_branch_name = @branch_name					
			        ,@p_request_status = 'HOLD'				
			        ,@p_request_currency_code = @request_currency_code			
			        ,@p_request_date = @request_date					
			        ,@p_request_amount = @request_amount					
			        ,@p_request_remarks = @request_remarks				
			        ,@p_agreement_no = @agreement_no					
			        ,@p_pdc_code = @pdc_code						
			        ,@p_pdc_no = @pdc_no							
			        ,@p_doc_ref_code = @doc_ref_code					
			        ,@p_doc_ref_name = @doc_ref_name					
			        ,@p_process_date = NULL					
			        ,@p_process_reff_no = NULL				
			        ,@p_process_reff_name =	NULL			
			        ,@p_manual_upload_status = 'MANUAL'
			        ,@p_manual_upload_remarks = 'OK'
					--
			        ,@p_cre_date = @cre_date
			        ,@p_cre_by = @cre_by
			        ,@p_cre_ip_address = @cre_ip_address
			        ,@p_mod_date = @mod_date
			        ,@p_mod_by = @mod_by
			        ,@p_mod_ip_address = @mod_ip_address
			

			fetch	c_upload_generic
			into	@branch_code				
					,@branch_name		
					,@request_currency_code	
					,@request_date			
					,@request_amount			
					,@request_remarks			
					,@agreement_no			
					,@pdc_code				
					,@pdc_no					
					,@doc_ref_code			
					,@doc_ref_name
					--
					,@cre_date			
					,@cre_by			
					,@cre_ip_address	
					,@mod_date		
					,@mod_by			
					,@mod_ip_address

        end
        close c_upload_generic
		deallocate c_upload_generic

		update	dbo.fin_interface_cashier_received_request
		set		manual_upload_status = 'MANUAL'
		where	manual_upload_remarks = 'OK' 
		and		cre_by = @p_cre_by

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

