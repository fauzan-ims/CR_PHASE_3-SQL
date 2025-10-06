
CREATE procedure [dbo].[xsp_invoice_delivery_insert]
(
	@p_code					   nvarchar(50) output
	,@p_branch_code			   nvarchar(50)
	,@p_branch_name			   nvarchar(250)
	,@p_status				   nvarchar(10)
	,@p_date				   datetime
	,@p_method				   nvarchar(10)
	,@p_employee_code		   nvarchar(50)	 = ''
	,@p_employee_name		   nvarchar(250) = ''
	,@p_external_pic_name	   nvarchar(250) = ''
	,@p_email				   nvarchar(250) = ''
	,@p_remark				   nvarchar(4000)
	-- Louis Rabu, 02 Juli 2025 10.17.37 -- 
	,@p_client_no			   nvarchar(50) 
	,@p_client_address		   nvarchar(4000)
	,@p_delivery_result		   nvarchar(10)
	,@p_delivery_received_date datetime		 = null	
	,@p_delivery_received_by   nvarchar(250) = null
	,@p_delivery_doc_reff_no   nvarchar(50)	 = null
	,@p_delivery_reject_date   datetime		 = null
	,@p_delivery_reason_code   nvarchar(50)	 = null
	-- Louis Rabu, 02 Juli 2025 10.17.37 -- 
	--
	,@p_cre_date			   datetime
	,@p_cre_by				   nvarchar(15)
	,@p_cre_ip_address		   nvarchar(15)
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(4)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = @p_branch_code
													,@p_sys_document_code = N''
													,@p_custom_prefix = N'ID'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = N'INVOICE_DELIVERY'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		insert into invoice_delivery
		(
			code
			,branch_code
			,branch_name
			,status
			,date
			,method
			,employee_code
			,employee_name
			,external_pic_name
			,email
			,remark
			-- Louis Rabu, 02 Juli 2025 10.16.42 -- 
			,client_no		
			,client_address
			,delivery_result		   
			,delivery_received_date 
			,delivery_received_by   
			,delivery_doc_reff_no   
			,delivery_reject_date   
			,delivery_reason_code  
			-- Louis Rabu, 02 Juli 2025 10.16.42 --  
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
			@code
			,@p_branch_code
			,@p_branch_name
			,@p_status
			,@p_date
			,@p_method
			,@p_employee_code
			,@p_employee_name
			,@p_external_pic_name
			,@p_email
			,@p_remark
			-- Louis Rabu, 02 Juli 2025 10.16.42 -- 
			,@p_client_no		
			,@p_client_address
			,@p_delivery_result		   
			,@p_delivery_received_date 
			,@p_delivery_received_by   
			,@p_delivery_doc_reff_no   
			,@p_delivery_reject_date   
			,@p_delivery_reason_code  
			-- Louis Rabu, 02 Juli 2025 10.16.42 --
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
