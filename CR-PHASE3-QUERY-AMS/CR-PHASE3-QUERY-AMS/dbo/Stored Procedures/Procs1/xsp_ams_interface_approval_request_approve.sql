CREATE PROCEDURE [dbo].[xsp_ams_interface_approval_request_approve]
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
		from	dbo.ams_interface_approval_request
		where	code = @p_code ;

		if (@reff_name = 'DISPOSAL APPROVAL')
		begin
			exec dbo.xsp_disposal_approve @p_code					= @reff_no
										  ,@p_approval_reff			= 'Disposal'
										  ,@p_approval_remark		= 'Disposal Approved'
										  ,@p_mod_date				= @p_mod_date		
										  ,@p_mod_by				= @p_mod_by			
										  ,@p_mod_ip_address		= @p_mod_ip_address
		end
		else if (@reff_name = 'SELL APPROVAL')
		begin
			exec dbo.xsp_sell_approve @p_code					= @reff_no
									  ,@p_approval_reff			= 'Sell'
									  ,@p_approval_remark		= 'Sell Approved'
									  ,@p_mod_date				= @p_mod_date		
									  ,@p_mod_by				= @p_mod_by			
									  ,@p_mod_ip_address		= @p_mod_ip_address
			
		end
		else if (@reff_name = 'SELL REQUEST APPROVAL')
		begin
			exec dbo.xsp_sell_request_approve @p_code				= @reff_no
											  ,@p_approval_reff		= 'Sell Request'
											  ,@p_approval_remark	= 'Sell Request Approved'
											  ,@p_mod_date			= @p_mod_date		
											  ,@p_mod_by			= @p_mod_by			
											  ,@p_mod_ip_address	= @p_mod_ip_address
			
		end
		else if (@reff_name = 'APPROVAL ASSET AS REPLACEMENT')
		begin
			exec dbo.xsp_asset_as_relacement_post @p_code				= @reff_no
												  ,@p_mod_date			= @p_mod_date		
												  ,@p_mod_by			= @p_mod_by			
												  ,@p_mod_ip_address	= @p_mod_ip_address
			
		end
		else if (@reff_name = 'APPROVAL ASSET AS STOCK')
		begin
			exec dbo.xsp_asset_as_stock_post @p_code				= @reff_no
											 ,@p_mod_date			= @p_mod_date		
											 ,@p_mod_by				= @p_mod_by			
											 ,@p_mod_ip_address		= @p_mod_ip_address
			
		end
		else if (@reff_name = 'PAYMENT APPROVAL')
		begin
			exec dbo.xsp_payment_transaction_approve @p_code				= @reff_no
													 ,@p_approval_reff		= 'Payment'
													 ,@p_approval_remark	= 'Payment Approve'
													 ,@p_mod_date			= @p_mod_date		
													 ,@p_mod_by				= @p_mod_by			
													 ,@p_mod_ip_address		= @p_mod_ip_address
			
		end
		else if (@reff_name = 'REALIZATION APPROVAL')
		begin
			exec dbo.xsp_realization_after_approved @p_code				= @reff_no
													,@p_mod_date		= @p_mod_date
													,@p_mod_by			= @p_mod_by
													,@p_mod_ip_address	= @p_mod_ip_address
			
		end
		else if	(@reff_name = 'WORK ORDER APPROVAL')
		begin
			--exec dbo.xsp_work_order_proceed @p_code				= @reff_no
			--								,@p_mod_date		= @p_mod_date
			--								,@p_mod_by			= @p_mod_by
			--								,@p_mod_ip_address	= @p_mod_ip_address

			exec dbo.xsp_work_order_post @p_code			= @reff_no
										 ,@p_mod_date		= @p_mod_date
										 ,@p_mod_by			= @p_mod_by
										 ,@p_mod_ip_address = @p_mod_ip_address
			
			
		end
		else if (@reff_name = 'INSURANCE APPROVAL')
		begin
			exec dbo.xsp_insurance_policy_main_proceed @p_code				= @reff_no
													   ,@p_mod_date			= @p_mod_date
													   ,@p_mod_by			= @p_mod_by
													   ,@p_mod_ip_address	= @p_mod_ip_address
			
		end
		else if (@reff_name = 'MAINTENANCE APPROVAL')
		begin
			exec dbo.xsp_maintenance_approve @p_code				= @reff_no
											 ,@p_mod_date			= @p_mod_date
											 ,@p_mod_by				= @p_mod_by
											 ,@p_mod_ip_address		= @p_mod_ip_address
			
		END
		else if (@reff_name = 'REALIZATION SUBCRIPTION GPS APPROVAL')
		begin
			EXEC dbo.xsp_realization_subcription_gps_after_approved @p_code				= @reff_no
																	,@p_mod_date		= @p_mod_date
																	,@p_mod_by			= @p_mod_by
																	,@p_mod_ip_address	= @p_mod_ip_address
													
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
end ;



