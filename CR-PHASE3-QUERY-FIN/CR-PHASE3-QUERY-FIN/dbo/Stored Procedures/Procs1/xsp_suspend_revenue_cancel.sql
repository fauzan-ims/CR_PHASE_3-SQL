CREATE PROCEDURE dbo.xsp_suspend_revenue_cancel
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
	declare	@msg				nvarchar(max)
			,@suspend_code		nvarchar(50)

	begin try
	
		if exists (select 1 from dbo.suspend_revenue where code = @p_code and revenue_status <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			declare cur_suspend_revenue_detail cursor fast_forward read_only for
			
			select	suspend_code	
			from	dbo.suspend_revenue_detail 
			where	suspend_revenue_code	= @p_code

			open cur_suspend_revenue_detail
			
			fetch next from cur_suspend_revenue_detail 
			into	@suspend_code

			while @@fetch_status = 0
			begin
				
				update	dbo.suspend_main
				set		transaction_code	= null
						,transaction_name	= null
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code				= @suspend_code

				fetch next from cur_suspend_revenue_detail 
					into	@suspend_code
				
				end
			close cur_suspend_revenue_detail
			deallocate cur_suspend_revenue_detail

			update	dbo.suspend_revenue
			set		revenue_status		= 'CANCEL'
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


