CREATE PROCEDURE [dbo].[xsp_ams_interface_approval_request_reject]
(
	@p_code				nvarchar(50)
	,@p_approval_status nvarchar(10) = 'REJECT'
	,@p_approval_code	nvarchar(50) = ''
	,@p_request_status  nvarchar(10) = 'REJECT'
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
BEGIN

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
			exec dbo.xsp_disposal_reject_from_approval @p_code				= @reff_no
													   ,@p_mod_date			= @p_mod_date		
													   ,@p_mod_by			= @p_mod_by			
													   ,@p_mod_ip_address	= @p_mod_ip_address	
		end
		else if (@reff_name = 'PAYMENT APPROVAL')
		begin
			exec dbo.xsp_payment_transaction_reject_from_approval @p_code				= @reff_no
																  ,@p_mod_date			= @p_mod_date		
																  ,@p_mod_by			= @p_mod_by			
																  ,@p_mod_ip_address	= @p_mod_ip_address
			
		end
		else if (@reff_name = 'SELL REQUEST APPROVAL')
		begin
			exec dbo.xsp_sale_reject_from_approval @p_code				= @reff_no
												   ,@p_mod_date			= @p_mod_date		
												   ,@p_mod_by			= @p_mod_by			
												   ,@p_mod_ip_address	= @p_mod_ip_address
			
		end
        else if (@reff_name = 'APPROVAL ASSET AS REPLACEMENT') -- (+) Ari 2023-11-24 ket : add reject from replacement
		begin
			exec dbo.xsp_asset_as_replacement_reject @p_code			= @reff_no
			                                         ,@p_mod_date		= @p_mod_date
			                                         ,@p_mod_by			= @p_mod_by
			                                         ,@p_mod_ip_address = @p_mod_ip_address
			
		end
		else if (@reff_name = 'MAINTENANCE APPROVAL')
		begin
			exec dbo.xsp_maintenance_approval_reject @p_code			= @reff_no
													 ,@p_mod_date		= @p_mod_date
													 ,@p_mod_by			= @p_mod_by
													 ,@p_mod_ip_address = @p_mod_ip_address
			
		end
		else if (@reff_name = 'WORK ORDER APPROVAL')
		begin
			exec dbo.xsp_work_order_approval_reject @p_code				= @reff_no
													,@p_mod_date		= @p_mod_date
													,@p_mod_by			= @p_mod_by
													,@p_mod_ip_address = @p_mod_ip_address
			
		END
        else if (@reff_name = 'REALIZATION APPROVAL')
		BEGIN
			PRINT @reff_no
			EXEC dbo.xsp_realization_after_reject @p_code				= @reff_no
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

