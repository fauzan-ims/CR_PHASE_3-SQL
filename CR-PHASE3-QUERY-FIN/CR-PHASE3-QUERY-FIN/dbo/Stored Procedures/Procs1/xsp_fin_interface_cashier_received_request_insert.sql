/*
	declare @p_code nvarchar(50) ;

	exec dbo.xsp_fin_interface_cashier_received_request_insert @p_code						= @p_code output -- nvarchar(50)
															   ,@p_branch_code				= N'0001' 
															   ,@p_branch_name				= N'BATU CEPER' 
															   ,@p_request_status			= N'HOLD' 
															   ,@p_request_currency_code	= N'IDR' 
															   ,@p_request_date				= '2021-04-19'
															   ,@p_request_amount			= 1275000 
															   ,@p_request_remarks			= N'TEST IFINFIN' 
															   ,@p_agreement_no				= N'0000.AGR.2009.000201' 
															   ,@p_pdc_code					= N'PDC012' 
															   ,@p_pdc_no					= N'PDC012' 
															   ,@p_doc_ref_code				= N'IFIN0001' 
															   ,@p_doc_ref_name				= N'IFINFIN' 
															   ,@p_process_date				= null
															   ,@p_process_reff_no			= null
															   ,@p_process_reff_name		= null
															   ,@p_manual_upload_status		= null
															   ,@p_manual_upload_remarks	= null
															   ,@p_cre_date					= '2021-04-19'
															   ,@p_cre_by					= 'fadlan'
															   ,@p_cre_ip_address			= '127.1.1.1'
															   ,@p_mod_date					= '2021-04-19'
															   ,@p_mod_by					= 'fadlan'
															   ,@p_mod_ip_address			= '127.1.1.1'
	
	
	declare @p_id bigint ;
	
	exec dbo.xsp_fin_interface_cashier_received_request_detail_insert @p_id								= @p_id output -- bigint
																	  ,@p_cashier_received_request_code = @p_code
																	  ,@p_branch_code					= N'0001' 
																	  ,@p_branch_name					= N'Batu Ceper' 
																	  ,@p_gl_link_code					= N'EXP0000006' 
																	  ,@p_agreement_no					= N'0000.AGR.2009.000201' 
																	  ,@p_facility_code					= N'FA001' 
																	  ,@p_facility_name					= N'Faciity 1' 
																	  ,@p_purpose_loan_code				= N'PL001' 
																	  ,@p_purpose_loan_name				= N'Data 1' 
																	  ,@p_purpose_loan_detail_code		= N'PLD001' 
																	  ,@p_purpose_loan_detail_name		= N'Data detail 1' 
																	  ,@p_orig_currency_code			= N'IDR' 
																	  ,@p_orig_amount					= 1275000
																	  ,@p_division_code					= N'DEV001' 
																	  ,@p_division_name					= N'Devision 1' 
																	  ,@p_department_code				= N'DEP001' 
																	  ,@p_department_name				= N'Department 1' 
																	  ,@p_remarks						= N'Test Ifinfin' 
																	  ,@p_cre_date						= '2021-04-19' 
																	  ,@p_cre_by						= N'fadlan' 
																	  ,@p_cre_ip_address				= N'127.1.1.1' 
																	  ,@p_mod_date						= '2021-04-19' 
																	  ,@p_mod_by						= N'fadlan' 
																	  ,@p_mod_ip_address				= N'127.1.1.1' 
	 
	select * from dbo.FIN_INTERFACE_CASHIER_RECEIVED_REQUEST where cre_by ='fadlan'
	select * from dbo.FIN_INTERFACE_CASHIER_RECEIVED_REQUEST_DETAIL where cre_by ='fadlan'


*/

CREATE PROCEDURE [dbo].[xsp_fin_interface_cashier_received_request_insert]
(
	@p_code									nvarchar(50) output
	,@p_branch_code							nvarchar(50)
	,@p_branch_name							nvarchar(250)
	,@p_request_status						nvarchar(10)
	,@p_request_currency_code				nvarchar(5)
	,@p_request_date						datetime
	,@p_request_amount						decimal(18, 2)
	,@p_request_remarks						nvarchar(4000)
	,@p_agreement_no						nvarchar(50)
	,@p_client_no							nvarchar(50)	 = null -- Louis Rabu, 25 Juni 2025 10.52.37 -- 
	,@p_client_name							nvarchar(250)	 = null -- Louis Rabu, 25 Juni 2025 10.52.37 -- 
	,@p_pdc_code							nvarchar(50)
	,@p_pdc_no								nvarchar(50)
	,@p_doc_ref_code						nvarchar(50)
	,@p_doc_ref_name						nvarchar(250)
	,@p_process_date						datetime
	,@p_process_reff_no						nvarchar(50)
	,@p_process_reff_name					nvarchar(250)
	,@p_manual_upload_status				nvarchar(10)
	,@p_manual_upload_remarks				nvarchar(4000)
	--
	,@p_cre_date 							datetime
	,@p_cre_by 								nvarchar(15)
	,@p_cre_ip_address 						nvarchar(15)
	,@p_mod_date 							datetime
	,@p_mod_by 								nvarchar(15)
	,@p_mod_ip_address 						nvarchar(15)
)
as
BEGIN

	declare @year					nvarchar(4)
			,@month					nvarchar(2)
			,@msg					nvarchar(max)
			,@count					int;
		
	if(isnull(@p_code,'') = '')
	begin
		
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;
	
		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output -- nvarchar(50)
													,@p_branch_code = @p_branch_code
													,@p_sys_document_code = N'' -- nvarchar(10)
													,@p_custom_prefix = N'ICR' -- nvarchar(10)
													,@p_year = @year -- nvarchar(2)
													,@p_month = @month -- nvarchar(2)
													,@p_table_name = N'FIN_INTERFACE_CASHIER_RECEIVED_REQUEST' -- nvarchar(100)
													,@p_run_number_length = 5 -- int
													,@p_delimiter = N'.' -- nvarchar(1)
													,@p_run_number_only = N'0' -- nvarchar(1)

    end

	


	begin try
		
		insert into dbo.fin_interface_cashier_received_request
		(
		    code
		    ,branch_code
		    ,branch_name
		    ,request_status
		    ,request_currency_code
		    ,request_date
		    ,request_amount
		    ,request_remarks
		    ,agreement_no
			,client_no	-- Louis Rabu, 25 Juni 2025 10.52.37 -- 
			,client_name -- Louis Rabu, 25 Juni 2025 10.52.37 -- 
		    ,pdc_code
		    ,pdc_no
		    ,doc_ref_code
		    ,doc_ref_name
		    ,process_date
		    ,process_reff_no
		    ,process_reff_name
		    ,manual_upload_status
			,manual_upload_remarks
			--
		    ,cre_date
		    ,cre_by
		    ,cre_ip_address
		    ,mod_date
		    ,mod_by
		    ,mod_ip_address
		)
		values
		(   
			@p_code
		    ,@p_branch_code
		    ,@p_branch_name
		    ,@p_request_status
		    ,@p_request_currency_code
		    ,@p_request_date
		    ,@p_request_amount
		    ,@p_request_remarks
		    ,@p_agreement_no
			,@p_client_no	-- Louis Rabu, 25 Juni 2025 10.52.37 -- 
			,@p_client_name -- Louis Rabu, 25 Juni 2025 10.52.37 -- 
		    ,@p_pdc_code
		    ,@p_pdc_no
		    ,@p_doc_ref_code
		    ,@p_doc_ref_name
		    ,@p_process_date
		    ,@p_process_reff_no
		    ,@p_process_reff_name
		    ,@p_manual_upload_status
			,@p_manual_upload_remarks
			--
		    ,@p_cre_date
		    ,@p_cre_by
		    ,@p_cre_ip_address
		    ,@p_mod_date
		    ,@p_mod_by
		    ,@p_mod_ip_address
		)

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
