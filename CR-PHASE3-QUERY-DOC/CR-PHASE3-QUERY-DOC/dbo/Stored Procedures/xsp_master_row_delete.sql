CREATE PROCEDURE dbo.xsp_master_row_delete
(
	@p_code nvarchar(50)
)
as
begin
	declare @msg nvarchar(max)  
			,@rows_count_drw int = 0
			,@drawer_code nvarchar(50)
			,@locker_code nvarchar(50)

	begin try
    
		select	@drawer_code = drawer_code 
		from	master_row   
		where	code = @p_code ;

		delete master_row
		where	code = @p_code ;

		-- region update is_active pada master_drawer
		select	@rows_count_drw = count(1)
		from	master_row
		where	is_active = '1'
		and		drawer_code = @drawer_code ;

		if @rows_count_drw > 0
			update	master_drawer
			set		is_active	= '1'
			where	code		= @drawer_code;
		else
			update	master_drawer
			set		is_active	= '0'
			where	code		= @drawer_code;
		

		select	@locker_code	= locker_code
		from	dbo.master_drawer
		where	code			= @drawer_code

		if exists (
			select	1
			from	dbo.master_drawer
			where	locker_code = @locker_code
			and		is_active = '1')
		begin
			update	dbo.master_locker
			set		is_active = '1'
			where	code = @locker_code;

		end
		else
		begin
			update	dbo.master_locker
			set		is_active = '0'
			where	code = @locker_code;
		end
        
		-- end region update is_active pada master_drawer
		 

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
