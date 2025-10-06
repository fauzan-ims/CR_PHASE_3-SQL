CREATE PROCEDURE dbo.xsp_suspend_allocation_cancel
(
	@p_code				nvarchar(50)
	--,@p_approval_reff		nvarchar(250)
	--,@p_approval_remark	nvarchar(4000)
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
	declare	@msg						nvarchar(max)
			,@received_request_code		nvarchar(50)
			,@suspend_code				nvarchar(50)

	begin try
	
		if exists (select 1 from dbo.suspend_allocation where code = @p_code and allocation_status <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			
			declare cur_suspend_allocation_detail cursor fast_forward read_only for
			
			select	received_request_code
			from	dbo.suspend_allocation_detail
			where	suspend_allocation_code = @p_code

			open cur_suspend_allocation_detail
		
			fetch next from cur_suspend_allocation_detail 
			into	@received_request_code

			while @@fetch_status = 0
			begin

				if (isnull(@received_request_code,'') <> '')
				begin
					update cashier_received_request
					set		request_status		= 'HOLD'
							,process_date		= null
							,process_reff_code	= null
							,process_reff_name  = null
					where	code				= @received_request_code

					update dbo.fin_interface_cashier_received_request
					set		request_status			= 'HOLD'
							,process_date			= null
							,process_reff_no		= null
							,process_reff_name		= null
					where	code					= @received_request_code
				end

				fetch next from cur_suspend_allocation_detail 
				into	@received_request_code
			
			end
			close cur_suspend_allocation_detail
			deallocate cur_suspend_allocation_detail
			
			select	@suspend_code	= suspend_code
			from	dbo.suspend_allocation
			where	code			= @p_code

			update	dbo.suspend_main
			set		transaction_code	= null
					,transaction_name	= null
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @suspend_code
			
			update	dbo.suspend_allocation
			set		allocation_status	= 'CANCEL'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code
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

end


