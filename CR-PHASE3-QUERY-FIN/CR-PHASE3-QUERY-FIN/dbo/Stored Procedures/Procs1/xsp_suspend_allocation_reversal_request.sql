CREATE PROCEDURE dbo.xsp_suspend_allocation_reversal_request
(
	@p_code				    nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg			    nvarchar(max)
			,@reversal_code		nvarchar(50)
			,@branch_code		nvarchar(50)
			,@branch_name		nvarchar(250)
			,@remark			nvarchar(4000)
			,@system_date		datetime = dbo.xfn_get_system_date()

	begin try

		if exists (
						select 1 from dbo.suspend_allocation_detail ctd
						inner join dbo.cashier_received_request crr on crr.code = ctd.received_request_code
						inner join ifinopl.dbo.agreement_main am on am.agreement_no = crr.agreement_no
						where crr.doc_ref_name = 'invoice send'
						and  am.agreement_status = 'terminate'
						and	ctd.suspend_allocation_code = @p_code
					)
		begin
		    raiserror('Cannot Reversal because Agreement Already Teminate',16,1)
			return
		end
        
		select @branch_code  = branch_code
			   ,@branch_name = branch_name
			   ,@remark		 = 'Reversal Suspend Allocation' + allocationt_remarks
		from dbo.suspend_allocation
		where code = @p_code

		exec dbo.xsp_reversal_main_insert @p_code				= @reversal_code output
		                                  ,@p_branch_code		= @branch_code
		                                  ,@p_branch_name		= @branch_name
		                                  ,@p_reversal_status	= 'HOLD'
		                                  ,@p_reversal_date		= @system_date
		                                  ,@p_reversal_remarks	= @remark
		                                  ,@p_source_reff_code	= @p_code
		                                  ,@p_source_reff_name	= 'Suspend Allocation'
		                                  ,@p_cre_date			= @p_cre_date		
		                                  ,@p_cre_by			= @p_cre_by			
		                                  ,@p_cre_ip_address	= @p_cre_ip_address	
		                                  ,@p_mod_date			= @p_mod_date		
		                                  ,@p_mod_by			= @p_mod_by			
		                                  ,@p_mod_ip_address	= @p_mod_ip_address	

		update	suspend_allocation
		set		allocation_status  = 'ON REVERSE'
				--
				,mod_date		= @p_mod_date		
				,mod_by			= @p_mod_by			
				,mod_ip_address	= @p_mod_ip_address	
		where	code			= @p_code
		
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

end

