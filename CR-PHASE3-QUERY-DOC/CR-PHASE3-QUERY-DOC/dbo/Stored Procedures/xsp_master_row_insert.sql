CREATE PROCEDURE dbo.xsp_master_row_insert
(
	@p_code			   nvarchar(50)
	,@p_row_name	   nvarchar(50)
	,@p_drawer_code	   nvarchar(50)
	,@p_is_active	   nvarchar(1)
	--,@p_locker_code	   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@rows_count_drw int = 0
			,@rows_count_lock int = 0
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

		insert into master_row
		(
			code
			,row_name
			,drawer_code
			,is_active
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	upper(@p_code)
			,upper(@p_row_name)
			,@p_drawer_code
			,@p_is_active
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		-- region update is_active pada master_drawer
		select	@rows_count_drw = count(1)
		from	master_row
		where	is_active = '1'
		and		drawer_code = @p_drawer_code ;

		if @rows_count_drw > 0
		begin
			update	master_drawer
			set		is_active = '1'
			where	code = @p_drawer_code;
		end
		else
		BEGIN
			update	master_drawer
			set		is_active = '0'
			where	code = @p_drawer_code;
		END

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

		-- end region update is_active pada master_drawer
		 
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
