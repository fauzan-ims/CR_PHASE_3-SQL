
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_proc_interface_approval_request_approve]
(
	@p_code				nvarchar(50)
	,@p_approval_status nvarchar(10) = 'APPROVE'
	,@p_approval_code	nvarchar(50) = ''
	,@p_request_status  nvarchar(10) = 'APPROVE'
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max)
			,@reff_no	nvarchar(50)
			,@reff_name nvarchar(250) ;

	begin try
		select	@reff_no	= reff_no
				,@reff_name = reff_name
		from	dbo.proc_interface_approval_request
		where	code = @p_code ;

		if (@reff_name = 'PURCHASE ORDER APPROVAL')
		begin
			exec dbo.xsp_purchase_order_post @p_code			= @reff_no
											 ,@p_mod_date		= @p_mod_date		
											 ,@p_mod_by			= @p_mod_by			
											 ,@p_mod_ip_address = @p_mod_ip_address
		END
        else if (@reff_name = 'VERIFICATION APPROVAL') 
		BEGIN
			EXEC dbo.xsp_verification_approve @p_code				= @reff_no
			                                  ,@p_company_code		= 'DSF'
			                                  ,@p_mod_date			= @p_mod_date		
			                                  ,@p_mod_by				= @p_mod_by			
			                                  ,@p_mod_ip_address		= @p_mod_ip_address
		end
		else if (@reff_name = 'PAYMENT REQUEST APPROVAL')
		begin
			exec dbo.xsp_ap_payment_request_post @p_code			= @reff_no
												 ,@p_mod_date		= @p_mod_date		
												 ,@p_mod_by			= @p_mod_by			
												 ,@p_mod_ip_address = @p_mod_ip_address

		end
		else if (@reff_name = 'SUPPLIER SELECTION APPROVAL')
		begin
			exec dbo.xsp_supplier_selection_approve @p_code				= @reff_no
													 ,@p_mod_date		= @p_mod_date		
													 ,@p_mod_by			= @p_mod_by			
													 ,@p_mod_ip_address = @p_mod_ip_address
		end
		else if (@reff_name = 'PROCUREMENT REQUEST APPROVAL')
		begin
			exec dbo.xsp_procurement_request_approve @p_code			= @reff_no
													 ,@p_mod_date		= @p_mod_date		
													 ,@p_mod_by			= @p_mod_by			
													 ,@p_mod_ip_address = @p_mod_ip_address

		end
        else if (@reff_name = 'GOOD RECEIPT NOTE APPROVAL')
		begin

			exec dbo.xsp_good_receipt_note_proceed	@p_code			= @reff_no
													 ,@p_mod_date		= @p_mod_date		
													 ,@p_mod_by			= @p_mod_by			
													 ,@p_mod_ip_address = @p_mod_ip_address

		END
         else if (@reff_name = 'INVOICE REGISTRATION APPROVAL')
		begin
			EXEC dbo.xsp_ap_invoice_registration_post	@p_code				= @reff_no
														,@p_company_code	= 'DSF'
														,@p_mod_date		= @p_mod_date		
														,@p_mod_by			= @p_mod_by		
														,@p_mod_ip_address	= @p_mod_ip_address

		end
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



