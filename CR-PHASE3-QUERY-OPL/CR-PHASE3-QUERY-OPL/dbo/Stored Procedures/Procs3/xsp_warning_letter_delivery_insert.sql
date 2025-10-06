CREATE PROCEDURE [dbo].[xsp_warning_letter_delivery_insert]
(
	@p_code							NVARCHAR(50) OUTPUT
	,@p_branch_code					NVARCHAR(50)
	,@p_branch_name					NVARCHAR(250)
	,@p_delivery_status				NVARCHAR(10)
	,@p_delivery_date				DATETIME
	,@p_delivery_courier_type		NVARCHAR(10) = ''
	,@p_delivery_courier_code		NVARCHAR(50)  = NULL
	,@p_delivery_collector_code		NVARCHAR(50)  = NULL
	,@p_delivery_collector_name		nvarchar(250) = null
	,@p_delivery_remarks			nvarchar(4000)
	,@p_client_no					NVARCHAR(50)
	,@p_client_name					NVARCHAR(150)
	,@p_delivery_address			NVARCHAR(4000) = NULL
	,@p_delivery_to_name			NVARCHAR(250)  = NULL
	,@p_client_phone_no				NVARCHAR(50)   = NULL
	,@p_client_npwp					NVARCHAR(50)   = NULL
	,@p_client_email				NVARCHAR(50)
	,@p_letter_date					DATETIME
	,@p_letter_type					NVARCHAR(50)
	,@p_generate_type				NVARCHAR(50)
	,@p_overdue_days				BIGINT			= NULL
	,@p_total_overdue_amount		DECIMAL(18,2)	= NULL
	,@p_total_agreement				BIGINT			= NULL
	,@p_total_asset					BIGINT			= NULL
	,@p_total_monthly_rental_amount	DECIMAL(18,2)	= NULL
	,@p_last_print_by				NVARCHAR(50)
	,@p_print_count					BIGINT
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	set @p_delivery_date = dbo.xfn_get_system_date() ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'WLD'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'WARNING_LETTER_DELIVERY'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0';

	begin try
		insert into WARNING_LETTER_DELIVERY
		(
			code
			,branch_code
			,branch_name
			,delivery_status
			,delivery_date
			,delivery_courier_type
			,delivery_courier_code
			,delivery_collector_code
			,delivery_collector_name
			,delivery_remarks
			,CLIENT_NO
			,CLIENT_NAME
			,delivery_address	
			,delivery_to_name	
			,client_phone_no	
			,client_npwp		
			,client_email		
			,letter_date		
			,letter_type		
			,generate_type		
			,overdue_days		
			,total_overdue_amount	
			,total_agreement	
			,total_asset		
			,total_monthly_rental_amount	
			,last_print_by	
			,print_count
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
			,@p_delivery_status
			,@p_delivery_date
			,@p_delivery_courier_type
			,@p_delivery_courier_code
			,@p_delivery_collector_code
			,@p_delivery_collector_name
			,@p_delivery_remarks
			,@p_client_no					
			,@p_client_name					
			,@p_delivery_address			
			,@p_delivery_to_name			
			,@p_client_phone_no				
			,@p_client_npwp					
			,@p_client_email				
			,@p_letter_date					
			,@p_letter_type					
			,@p_generate_type				
			,@p_overdue_days				
			,@p_total_overdue_amount		
			,@p_total_agreement				
			,@p_total_asset					
			,@p_total_monthly_rental_amount	
			,@p_last_print_by				
			,@p_print_count					
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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
