CREATE PROCEDURE dbo.xsp_fin_interface_payment_request_post
(
	@p_code					nvarchar(50)
	--
	,@p_cre_date 			datetime
	,@p_cre_by 				nvarchar(15)
	,@p_cre_ip_address 		nvarchar(15)
	,@p_mod_date 			datetime
	,@p_mod_by 				nvarchar(15)
	,@p_mod_ip_address 		nvarchar(15)
)
as
begin

	declare		@msg							nvarchar(max)
				--
				,@branch_code					nvarchar(50)
				,@branch_name					nvarchar(250)
				,@payment_branch_code			nvarchar(50)
				,@payment_branch_name			nvarchar(250)
				,@payment_source			    nvarchar(50)
				,@payment_request_date			datetime
				,@payment_source_no				nvarchar(50)
				,@payment_currency_code			nvarchar(3)
				,@payment_amount			    decimal(18, 2)
				,@payment_remarks			    nvarchar(4000)
				,@to_bank_account_name			nvarchar(250)
				,@to_bank_name					nvarchar(250)
				,@to_bank_account_no			nvarchar(50);

	begin try
		
		if exists	(
						select	1 
						from	core_upload_generic 
						where	table_name = 'FIN_INTERFACE_PAYMENT_REQUEST'
						and		status <> 'Ok'
						and     cre_by = @p_cre_by
					)
		begin
			
			set @msg = 'Invalid data upload, Please check data upload' ;

			raiserror(@msg, 16, -1) ;

        end
        
		declare c_core_upload_generic cursor for

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
				,column_12
				,column_13
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address 
		from	dbo.core_upload_generic
		where	table_name = 'FIN_INTERFACE_PAYMENT_REQUEST'
		and		cre_by = @p_cre_by

		open	c_core_upload_generic
		fetch	c_core_upload_generic
		into	@branch_code			
				,@branch_name			
				,@payment_branch_code	
				,@payment_branch_name	
				,@payment_source		
				,@payment_request_date	
				,@payment_source_no		
				,@payment_currency_code	
				,@payment_amount		
				,@payment_remarks		
				,@to_bank_account_name	
				,@to_bank_name			
				,@to_bank_account_no
				--
				,@p_cre_date			
				,@p_cre_by			
				,@p_cre_ip_address	
				,@p_mod_date		
				,@p_mod_by			
				,@p_mod_ip_address		

		while @@fetch_status=0
		begin
			
			exec	dbo.xsp_fin_interface_payment_request_insert 
					@p_code = ''
			        ,@p_branch_code = @branch_code
			        ,@p_branch_name = @branch_name
			        ,@p_payment_branch_code = @payment_branch_code
			        ,@p_payment_branch_name = @payment_branch_name
			        ,@p_payment_source = @payment_source
			        ,@p_payment_request_date = @payment_request_date
			        ,@p_payment_source_no = @payment_source_no
			        ,@p_payment_status = 'HOLD'
			        ,@p_payment_currency_code = @payment_currency_code
			        ,@p_payment_amount = @payment_amount
			        ,@p_payment_remarks = @payment_remarks
			        ,@p_to_bank_account_name = @to_bank_account_name
			        ,@p_to_bank_name = @to_bank_name
			        ,@p_to_bank_account_no = @to_bank_account_no
			        ,@p_process_date = NULL
			        ,@p_process_reff_no = NULL
			        ,@p_process_reff_name = NULL
			        ,@p_manual_upload_status = 'MANUAL'
			        ,@p_manual_upload_remarks = 'OK'
					--
			        ,@p_cre_date = @p_cre_date
					,@p_cre_by = @p_cre_by
					,@p_cre_ip_address = @p_cre_ip_address
					,@p_mod_date = @p_mod_date
					,@p_mod_by = @p_mod_by
					,@p_mod_ip_address = @p_mod_ip_address
			

			fetch	c_core_upload_generic
			into	@branch_code			
					,@branch_name			
					,@payment_branch_code	
					,@payment_branch_name	
					,@payment_source		
					,@payment_request_date	
					,@payment_source_no		
					,@payment_currency_code	
					,@payment_amount		
					,@payment_remarks		
					,@to_bank_account_name	
					,@to_bank_name			
					,@to_bank_account_no
					--
					,@p_cre_date			
					,@p_cre_by			
					,@p_cre_ip_address	
					,@p_mod_date		
					,@p_mod_by			
					,@p_mod_ip_address

        end
        close c_core_upload_generic
		deallocate c_core_upload_generic

		delete	dbo.core_upload_generic
		where	table_name = 'FIN_INTERFACE_PAYMENT_REQUEST'
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

end    
