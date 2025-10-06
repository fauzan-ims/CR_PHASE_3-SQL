--created by, Rian at 09/06/2023 

CREATE procedure [dbo].[xsp_fin_interface_approval_request_approve]
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
		select	@reff_no = reff_no
				,@reff_name = reff_name
		from	fin_interface_approval_request
		where	code = @p_code ;

		if (@reff_name = 'DEPOSIT ALLOCATION')
		begin

			exec dbo.xsp_deposit_allocation_approve @p_code				= @reff_no
													--
													,@p_approval_reff	= 'Finance'
													,@p_approval_remark = N'Deposit Allocation Approved'
													,@p_mod_date		= @p_mod_date		
													,@p_mod_by			= @p_mod_by			
													,@p_mod_ip_address	= @p_mod_ip_address	
		end
		else if (@reff_name = 'DEPOSIT RELEASE')
		begin
			exec dbo.xsp_deposit_release_approve	@p_code = @reff_no
													,@p_approval_reff	= 'Finance'
													,@p_approval_remark = N'Deposit Release Approved'
													--
													,@p_mod_date		= @p_mod_date		
													,@p_mod_by			= @p_mod_by			
													,@p_mod_ip_address	= @p_mod_ip_address	
		end
		else if	(@reff_name = 'REVERSAL REQUEST')
		begin
			exec dbo.xsp_reversal_main_approve @p_code				= @reff_no
											   --
											   ,@p_approval_reff	= 'Finance'
											   ,@p_approval_remark	= N'Reversal Approved'
											   ,@p_mod_date			= @p_mod_date		
											   ,@p_mod_by			= @p_mod_by			
											   ,@p_mod_ip_address	= @p_mod_ip_address	
		end
		else if (@reff_name = 'RECONCILE')
		begin
			exec dbo.xsp_reconcile_main_approve @p_code				= @reff_no
												--
												,@p_approval_reff	= 'Finance'
												,@p_approval_remark	= N'Reconcile Approved'
												,@p_mod_date			= @p_mod_date		
												,@p_mod_by			= @p_mod_by			
												,@p_mod_ip_address	= @p_mod_ip_address	
		end
		else if (@reff_name = 'SUSPEND ALLOCATION')
		begin
			exec dbo.xsp_suspend_allocation_approve
													 @p_code			= @reff_no
													 --
													,@p_approval_reff	= 'Finance'
													,@p_approval_remark = N'Suspend Allocation Approved'
													,@p_mod_date		= @p_mod_date		
													,@p_mod_by			= @p_mod_by			
													,@p_mod_ip_address	= @p_mod_ip_address	
		end
		else if (@reff_name = 'SUSPEND RELEASE')
		begin
			exec dbo.xsp_suspend_release_approve	@p_code				= @reff_no
													,@p_approval_reff	= 'Finance'
													,@p_approval_remark = N'Suspend Release Approved'
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











