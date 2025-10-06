CREATE PROCEDURE dbo.xsp_application_main_insert
(
	@p_application_no							nvarchar(50)	output
	,@p_application_status						nvarchar(10)
	,@p_level_status							nvarchar(20)
	,@p_application_remarks						nvarchar(4000)
	,@p_marketing_code							nvarchar(50)
	,@p_marketing_name							nvarchar(250)
	,@p_branch_code								nvarchar(50)	= null
	,@p_branch_name								nvarchar(250)	= null
	,@p_branch_region_code						nvarchar(50)	= null
 	,@p_branch_region_name						nvarchar(250)	= null
	,@p_application_date						datetime
	,@p_facility_code							nvarchar(50)
	,@p_currency_code							nvarchar(3)
	,@p_periode									int
	,@p_billing_type							nvarchar(50)
	,@p_first_payment_type						nvarchar(3)
	,@p_is_purchase_requirement_after_lease		nvarchar(1)
	,@p_lease_option							nvarchar(10)
	,@p_credit_term								int
	,@p_client_name								nvarchar(250)
	,@p_client_phone_area						nvarchar(4)
	,@p_client_phone_no							nvarchar(15)
	,@p_client_address							nvarchar(4000)
	,@p_client_email							nvarchar(250)
	,@p_client_code								nvarchar(50)	= null
	--
	,@p_cre_date								datetime
	,@p_cre_by									nvarchar(15)
	,@p_cre_ip_address							nvarchar(15)
	,@p_mod_date								datetime
	,@p_mod_by									nvarchar(15)
	,@p_mod_ip_address							nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@years							nvarchar(4)
			,@month							nvarchar(2)
			,@code							nvarchar(50)
			,@application_external_no		nvarchar(50)
			,@temp_branch_code				nvarchar(50)		= right(@p_branch_code, 2)
			,@branch_region_code			nvarchar(50)		= @p_branch_code
			,@branch_region_name			nvarchar(250)		= @p_branch_name
			,@client_code					nvarchar(50)		= null
			,@golive_date					datetime			= null
			,@agreement_sign_date			datetime			= null
			,@first_installment_date		datetime			= null
			,@is_blacklist_area				nvarchar(1)			= '0'
			,@watchlist_status				nvarchar(10)		= '0'
			,@is_blacklist_job				nvarchar(1)			= '0'
			,@rounding_type					nvarchar(10)
			,@rounding_amount				decimal(18,2)
			,@multiplier					int


	--set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @years = cast(datepart(year, @p_cre_date) as nvarchar)
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_generate_application_no @p_unique_code			= @p_application_no output
										 ,@p_branch_code		= @temp_branch_code
										 ,@p_year				= @years
										 ,@p_month				= @month
										 ,@p_opl_code			= N'4'
										 ,@p_run_number_length	= 7
										 ,@p_delimiter			= N'.'
										 ,@p_type				= 'APPLICATION'

	set	@application_external_no = replace(@p_application_no, '.', '/')
	--exec dbo.xsp_generate_application_no @p_unique_code = @application_external_no output
	--								 ,@p_branch_code = @p_branch_code
	--								 ,@p_year = @years
	--								 ,@p_month = @month
	--								 ,@p_opl_code = N'4'
	--								 ,@p_run_number_length = 7
	--								 ,@p_delimiter = N'/'
	
	
	begin try

	 	exec dbo.xsp_master_rounding_get_amount @p_application_no	= @p_application_no
 												,@p_rounding_type	= @rounding_type output
 												,@p_rounding_amount = @rounding_amount output 
												,@p_currency_code	= @p_currency_code
												,@p_facility_code	= @p_facility_code
 
 		if (@p_application_date > dbo.xfn_get_system_date())
 		begin
 			set @msg = 'Application Date must be less or equal than System Date' ;
 
 			raiserror(@msg, 16, -1) ;
 		end ;
 
 		if (@p_periode <= 0)
 		begin
 			set @msg = 'Tenor must be greater than 0' ;
 
 			raiserror(@msg, 16, -1) ;
 		end
 
 		if not exists
 		(
 			select	1
 			from	dbo.master_rounding
 			where	currency_code = @p_currency_code
 		)
 		begin
 			set @msg = 'Please Setting Master Rounding for Currency : ' + ISNULL(@p_currency_code,'') ;
 
 			raiserror(@msg, 16, -1) ;
 		end ;
 
 		if ((
 				select	count(1)
 				from	dbo.application_asset
 				where	application_no = @p_application_no
 			) > 0
 		   )
 		begin
 			select	@p_first_payment_type = first_payment_type
 			from	dbo.application_main
 			where	application_no = @p_application_no ;
 		end ;

		select	@multiplier = multiplier
		from	dbo.master_billing_type
		where	code = @p_billing_type ;
			
		-- cek modulo tenor
		if (@p_periode % @multiplier <> 0)
		begin
			set @msg = 'Invalid combination Tenor and Schedule Type' ;

			raiserror(@msg, 18, 1) ;
		end ;
		else if (@p_periode < @multiplier)
		begin
			set @msg = 'Invalid combination Tenor and Schedule Type' ;

			raiserror(@msg, 18, 1) ;
		end ;

		if	@p_is_purchase_requirement_after_lease = 'T'
			set	@p_is_purchase_requirement_after_lease = '1'
		else
			set	@p_is_purchase_requirement_after_lease = '0'

		insert into application_main
			(
				application_no
				,branch_code
				,branch_name
				,application_date
				,application_status
				,level_status
				,application_external_no
				,application_remarks
				,branch_region_code
				,branch_region_name
				,marketing_code
				,marketing_name
				,client_code
				,facility_code
				,currency_code
				,golive_date
				,agreement_sign_date
				,first_installment_date
				,is_blacklist_area
				,watchlist_status
				,is_blacklist_job
				,return_count
				,periode
				,billing_type
				,first_payment_type
				,is_purchase_requirement_after_lease
				,lease_option
				,credit_term
				,client_name
				,client_phone_area
				,client_phone_no
				,client_email
				,client_address
				,round_type
				,round_amount
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@p_application_no
				,@p_branch_code
				,@p_branch_name
				,@p_application_date
				,@p_application_status
				,@p_level_status
				,@application_external_no
				,@p_application_remarks
				,@p_branch_region_code
				,@p_branch_region_name
				,@p_marketing_code
				,@p_marketing_name
				,isnull(@client_code, @p_client_code)
				,@p_facility_code
				,@p_currency_code
				,@golive_date
				,@agreement_sign_date
				,@first_installment_date
				,@is_blacklist_area
				,@watchlist_status
				,@is_blacklist_job
				,0
				,@p_periode
				,@p_billing_type
				,@p_first_payment_type
				,@p_is_purchase_requirement_after_lease
				,@p_lease_option
				,@p_credit_term
				,@p_client_name			
				,@p_client_phone_area	
				,@p_client_phone_no	
				,@p_client_email	
				,@p_client_address		
				,@rounding_type	
				,isnull(@rounding_amount, 0)
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;
			 
 			exec dbo.xsp_application_doc_generate @p_application_no		= @p_application_no
 													,@p_cre_date		= @p_mod_date
 													,@p_cre_by			= @p_mod_by
 													,@p_cre_ip_address	= @p_mod_ip_address
 													,@p_mod_date		= @p_mod_date
 													,@p_mod_by			= @p_mod_by
 													,@p_mod_ip_address	= @p_mod_ip_address ;
 
 			exec dbo.xsp_application_charges_generate @p_application_no		= @p_application_no
 													  ,@p_mod_date			= @p_mod_date
 													  ,@p_mod_by			= @p_mod_by
 													  ,@p_mod_ip_address	= @p_mod_ip_address ;
																	
			exec dbo.xsp_application_information_insert @p_application_no			= @p_application_no
														,@p_workflow_step			= 0 
														,@p_application_flow_code	= null
														,@p_screen_flow_code		= null
														,@p_is_refunded				= 1
														,@p_cre_date				= @p_cre_date
														,@p_cre_by					= @p_cre_by
														,@p_cre_ip_address			= @p_cre_ip_address
														,@p_mod_date				= @p_mod_date
														,@p_mod_by					= @p_mod_by
														,@p_mod_ip_address			= @p_mod_ip_address

			exec dbo.xsp_application_log_insert  @p_application_no		= @p_application_no
												,@p_log_date			= @p_cre_date
												,@p_log_description		= N'SIMULATION ENTRY' 
												,@p_cre_date			= @p_cre_date
												,@p_cre_by				= @p_cre_by
												,@p_cre_ip_address		= @p_cre_ip_address
												,@p_mod_date			= @p_mod_date
												,@p_mod_by				= @p_mod_by
												,@p_mod_ip_address		= @p_mod_ip_address
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









