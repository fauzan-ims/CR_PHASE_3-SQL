CREATE PROCEDURE dbo.xsp_master_row_update
(
	@p_code			   nvarchar(50)
	,@p_row_name	   nvarchar(50)
	,@p_drawer_code	   nvarchar(50)
	,@p_is_active	   nvarchar(1)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@rows_count int = 0
			,@locker_code nvarchar(50);

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try

		if exists (select 1 from master_row 
				   where row_name = @p_row_name 
						and code <> @p_code 
						and drawer_code = @p_drawer_code)
		begin
			SET @msg = 'Name already exist';
    		raiserror(@msg, 16, -1) ;
		end;

		update	master_row
		set		row_name		= upper(@p_row_name)
				,drawer_code	= upper(@p_drawer_code)
				,is_active		= @p_is_active
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code ;


		select	@rows_count = count(1)
		from	master_row
		where	is_active = '1'
		and		drawer_code = @p_drawer_code ;

		if @rows_count > 0
			update	master_drawer
			set		is_active = '1'
			where	code = @p_drawer_code;
		else
			update	master_drawer
			set		is_active = '0'
			where	code = @p_drawer_code;
		
		select	@locker_code = locker_code
		from	dbo.master_drawer
		where	code = @p_drawer_code

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
