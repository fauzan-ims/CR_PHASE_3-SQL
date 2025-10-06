CREATE PROCEDURE dbo.xsp_application_main_update
 (
 	@p_application_no							nvarchar(50)
 	,@p_branch_code								nvarchar(50)	= null
 	,@p_branch_name								nvarchar(250)	= null
 	,@p_application_date						datetime		= null
 	,@p_application_status						nvarchar(10)	= null
 	,@p_level_status							nvarchar(20)	= null
 	,@p_application_external_no					nvarchar(50)	= null
 	,@p_application_remarks						nvarchar(4000)	= null
 	,@p_branch_region_code						nvarchar(50)	= null
 	,@p_branch_region_name						nvarchar(250)	= null
 	,@p_marketing_code							nvarchar(50)	= null
 	,@p_marketing_name							nvarchar(250)	= null
 	,@p_facility_code							nvarchar(50)	= null 
 	,@p_currency_code							nvarchar(3)		= null
 	,@p_periode									int				= 0
 	,@p_billing_type							nvarchar(50)	= null
 	,@p_first_payment_type						nvarchar(3)		= null
 	,@p_credit_term								int				= 0
 	,@p_is_purchase_requirement_after_lease		nvarchar(1)		= null
 	,@p_lease_option							nvarchar(10)	= null
	,@p_client_name								nvarchar(250)	= null
	,@p_client_phone_area						nvarchar(4)		= null
	,@p_client_phone_no							nvarchar(15)	= null
	,@p_client_address							nvarchar(4000)	= null
	,@p_client_email							nvarchar(250)	= null
 	--
 	,@p_mod_date								datetime
 	,@p_mod_by									nvarchar(15)
 	,@p_mod_ip_address							nvarchar(15)
 )
 as
 begin
 	declare @msg			  nvarchar(max)
 			,@rounding_type	  nvarchar(10)
 			,@rounding_amount decimal(18, 2) 
			,@rent_to_own	  nvarchar(1)
			,@currency_code	  nvarchar(3)
			,@facility_code	  nvarchar(50)
			,@multiplier	  int
			,@client_no		  nvarchar(50)
 
 	begin try

		if @p_is_purchase_requirement_after_lease = 'T'
 			set @p_is_purchase_requirement_after_lease = '1' ;
 		else
 			set @p_is_purchase_requirement_after_lease = '0' ;
 
 		if(isnull(@p_lease_option, '') = '')
 		begin
 			select	@p_lease_option = lease_option
 			from	dbo.application_main
 			where	application_no = @p_application_no
 		end
 
		set	@currency_code = @p_currency_code
		set	@facility_code = @p_facility_code

 		exec dbo.xsp_master_rounding_get_amount @p_application_no	= @p_application_no
 												,@p_rounding_type	= @rounding_type output
 												,@p_rounding_amount = @rounding_amount output 
												,@p_currency_code	= @currency_code
												,@p_facility_code	= @facility_code
 
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
 			set @msg = 'Please Setting Master Rounding for Currency : ' + @p_currency_code ;
 
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
 
 		update	application_main
 		set		branch_code								= @p_branch_code
 				,branch_name							= @p_branch_name
 				,application_date						= @p_application_date
 				,application_status						= @p_application_status
 				,level_status							= @p_level_status
 				,application_external_no				= @p_application_external_no
 				,application_remarks					= @p_application_remarks
 				,branch_region_code						= @p_branch_region_code
 				,branch_region_name						= @p_branch_region_name
 				,marketing_code							= @p_marketing_code
 				,marketing_name							= @p_marketing_name
 				,facility_code							= @p_facility_code
 				,currency_code							= @p_currency_code
 				,periode								= @p_periode
 				,billing_type							= @p_billing_type
 				,first_payment_type						= @p_first_payment_type
 				,credit_term							= @p_credit_term
 				,lease_option							= @p_lease_option
 				,is_purchase_requirement_after_lease	= @p_is_purchase_requirement_after_lease
 				,round_type								= @rounding_type
 				,round_amount							= @rounding_amount
				,client_name							= @p_client_name
				,client_phone_area						= @p_client_phone_area
				,client_phone_no						= @p_client_phone_no
				,client_address							= @p_client_address
				,client_email							= @p_client_email
 				--
 				,mod_date								= @p_mod_date
 				,mod_by									= @p_mod_by
 				,mod_ip_address							= @p_mod_ip_address
 		where	application_no							= @p_application_no ;
 		
 		if (@p_application_date is not null)
 		begin
 			if not exists
 			(
 				select	1
 				from	dbo.application_doc
 				where	application_no = @p_application_no
 			)
 			begin
 				exec dbo.xsp_application_doc_generate @p_application_no		= @p_application_no
 													  ,@p_cre_date			= @p_mod_date
 													  ,@p_cre_by			= @p_mod_by
 													  ,@p_cre_ip_address	= @p_mod_ip_address
 													  ,@p_mod_date			= @p_mod_date
 													  ,@p_mod_by			= @p_mod_by
 													  ,@p_mod_ip_address	= @p_mod_ip_address ;
 			end ;
 
 			if not exists
 			(
 				select	1
 				from	dbo.application_charges
 				where	application_no = @p_application_no
 			)
 			begin
 				exec dbo.xsp_application_charges_generate @p_application_no  = @p_application_no
 														  ,@p_mod_date		 = @p_mod_date
 														  ,@p_mod_by		 = @p_mod_by
 														  ,@p_mod_ip_address = @p_mod_ip_address ;
 			end ; 
 		end ;
 		
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
 
 
 
 
