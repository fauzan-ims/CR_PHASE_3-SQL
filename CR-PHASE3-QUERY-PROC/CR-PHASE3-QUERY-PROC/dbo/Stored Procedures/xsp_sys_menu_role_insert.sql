CREATE PROCEDURE dbo.xsp_sys_menu_role_insert
(
	@p_role_code	   nvarchar(50) output
	,@p_menu_code	   nvarchar(50)
	,@p_role_name	   nvarchar(250)
	,@p_role_access	   nvarchar(1)
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
	declare @rows_number int
			,@msg		 nvarchar(max) ;

	set @rows_number =
	isnull((
		select	cast(max(substring(ROLE_CODE, 2, 7)) as integer) + 1
		from	dbo.SYS_MENU_ROLE
		where	MENU_CODE = @p_menu_code
	),0) ;
	 
	set @p_role_code = convert(nvarchar(10), (
												 select substring('0000000', len(@rows_number), len('0000000') - len(@rows_number))
											 ) + convert(nvarchar(10), @rows_number)
							  ) ;
	set @p_role_code = 'R' + substring(@p_menu_code, 2, 8) + @p_role_code + @p_role_access ;

	begin try
		if exists
		(
			select	1
			from	sys_menu_role
			where	menu_code = @p_menu_code and role_name = @p_role_name
		)
		begin
			set @msg = 'Name already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		insert into sys_menu_role
		(
			menu_code
			,role_code
			,role_name
			,role_access
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_menu_code
			,@p_role_code
			,upper(@p_role_name)
			,@p_role_access

			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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
