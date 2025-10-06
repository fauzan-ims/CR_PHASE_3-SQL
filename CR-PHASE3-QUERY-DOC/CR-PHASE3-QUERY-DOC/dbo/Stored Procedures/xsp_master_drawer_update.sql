CREATE PROCEDURE dbo.xsp_master_drawer_update
(
	@p_code			   nvarchar(50)
	,@p_drawer_name	   nvarchar(50)
	,@p_locker_code	   nvarchar(50)
	,@p_is_active	   nvarchar(1)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@rows_count int = 0;

	select	@rows_count = count(1)
	from	master_row
	where	is_active = '1'
	and		drawer_code = @p_code ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;


	begin try

		if exists (select 1 from master_drawer
					 where code <> @p_code
					 and drawer_name = @p_drawer_name
					 and locker_code = @p_locker_code)
		begin
			set @msg = 'name already exist';
    		raiserror(@msg, 16, -1) ;
		end;

		update	master_drawer
		set		drawer_name		= upper(@p_drawer_name)
				,locker_code	= @p_locker_code
				,is_active		= @p_is_active
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code ;

		-- region update is_active pada master_locker
		select	@rows_count = count(1)
		from	master_drawer
		where	is_active = '1'
		and		locker_code = @p_locker_code ;

		if @rows_count > 0
			update	master_locker
			set		is_active = '1'
			where	code = @p_locker_code;
		else
			update	master_locker
			set		is_active = '0'
			where	code = @p_locker_code;
		-- end region update is_active pada master_locker

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
