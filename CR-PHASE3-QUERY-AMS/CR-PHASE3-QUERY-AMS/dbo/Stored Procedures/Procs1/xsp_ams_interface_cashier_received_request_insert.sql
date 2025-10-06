CREATE PROCEDURE dbo.xsp_ams_interface_cashier_received_request_insert
(
	@p_code					  nvarchar(50) output
	,@p_branch_code			  nvarchar(50)
	,@p_branch_name			  nvarchar(250)
	,@p_request_status		  nvarchar(10)
	,@p_request_currency_code nvarchar(5)
	,@p_request_date		  datetime
	,@p_request_amount		  decimal(18, 2)	= 0
	,@p_request_remarks		  nvarchar(4000)
	,@p_fa_code				  nvarchar(50)
	,@p_pdc_code			  nvarchar(50)
	,@p_pdc_no				  nvarchar(50)
	,@p_doc_ref_code		  nvarchar(50)
	,@p_doc_ref_name		  nvarchar(250)
	,@p_process_date		  datetime
	,@p_process_reff_no		  nvarchar(50)
	,@p_process_reff_name	  nvarchar(250)
	--
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	begin try

		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		declare @p_unique_code nvarchar(50) ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = @p_branch_code
													,@p_sys_document_code = N''
													,@p_custom_prefix = 'CRR'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		insert into ams_interface_cashier_received_request
		(
			code
			,branch_code
			,branch_name
			,request_status
			,request_currency_code
			,request_date
			,request_amount
			,request_remarks
			,fa_code
			,pdc_code
			,pdc_no
			,doc_ref_code
			,doc_ref_name
			,process_date
			,process_reff_no
			,process_reff_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_branch_code
			,@p_branch_name
			,@p_request_status
			,@p_request_currency_code
			,@p_request_date
			,@p_request_amount
			,@p_request_remarks
			,@p_fa_code
			,@p_pdc_code
			,@p_pdc_no
			,@p_doc_ref_code
			,@p_doc_ref_name
			,@p_process_date
			,@p_process_reff_no
			,@p_process_reff_name
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @code ;
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
