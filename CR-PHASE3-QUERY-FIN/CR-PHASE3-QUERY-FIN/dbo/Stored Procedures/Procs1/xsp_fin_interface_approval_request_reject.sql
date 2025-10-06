CREATE PROCEDURE [dbo].[xsp_fin_interface_approval_request_reject]
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
begin
	declare @msg		nvarchar(max)
			,@reff_no	nvarchar(50)
			,@reff_name nvarchar(250) ;

	begin try

		select	@reff_no = reff_no
				,@reff_name = reff_name
		from	fin_interface_approval_request
		where	code = @p_code ;

		if (@reff_name = 'DEPOSIT ALLOCATION')
		begin
			
			exec dbo.xsp_deposit_allocation_reject @p_code				= @reff_no
													--
												   ,@p_mod_date			= @p_mod_date		
												   ,@p_mod_by			= @p_mod_by			
												   ,@p_mod_ip_address	= @p_mod_ip_address	
		end
		else if (@reff_name = 'DEPOSIT RELEASE')
		begin
			exec dbo.xsp_deposit_release_reject @p_code				= @reff_no
												--
												,@p_mod_date		= @p_mod_date		
												,@p_mod_by			= @p_mod_by			
												,@p_mod_ip_address	= @p_mod_ip_address	
		end
		else if (@reff_name = 'REVERSAL REQUEST')
		begin
			exec dbo.xsp_reversal_main_reject	@p_code				= @reff_no
												--
												,@p_mod_date		= @p_mod_date		
												,@p_mod_by			= @p_mod_by			
												,@p_mod_ip_address	= @p_mod_ip_address	
		end
		else if (@reff_name = 'RECONCILE')
		begin
			exec dbo.xsp_reconcile_main_reject @p_code				= @reff_no
												--
											   ,@p_mod_date			= @p_mod_date		
											   ,@p_mod_by			= @p_mod_by			
											   ,@p_mod_ip_address	= @p_mod_ip_address	
		end
		else if (@reff_name = 'SUSPEND ALLOCATION')
		begin
			exec dbo.xsp_suspend_allocation_reject @p_code				= @reff_no
													--
												   ,@p_mod_date			= @p_mod_date		
												   ,@p_mod_by			= @p_mod_by			
												   ,@p_mod_ip_address	= @p_mod_ip_address	
		end
		else if (@reff_name = 'SUSPEND RELEASE')
		begin
			exec dbo.xsp_suspend_release_reject @p_code				= @reff_no
												--
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








