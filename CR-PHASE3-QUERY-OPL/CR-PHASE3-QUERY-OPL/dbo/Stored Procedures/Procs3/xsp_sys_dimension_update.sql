CREATE PROCEDURE dbo.xsp_sys_dimension_update
(
	@p_code			   nvarchar(50)
	,@p_description	   nvarchar(250)
	,@p_table_name	   nvarchar(50)	 = null
	,@p_column_name	   nvarchar(50)	 = null
	,@p_primary_column nvarchar(50)	 = null
	,@p_function_name  nvarchar(250) = null
	,@p_is_active	   nvarchar(1)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		if exists
		(
			select	1
			from	sys_dimension
			where	description = @p_description
					and code	<> @p_code
		)
		begin
			set @msg = 'Description already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	sys_dimension
		set		description		= upper(@p_description)
				,table_name		= upper(@p_table_name)
				,column_name	= upper(@p_column_name)
				,primary_column = upper(@p_primary_column)
				,function_name	= upper(@p_function_name)
				,is_active		= @p_is_active
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code ;
	end try
	Begin catch
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
