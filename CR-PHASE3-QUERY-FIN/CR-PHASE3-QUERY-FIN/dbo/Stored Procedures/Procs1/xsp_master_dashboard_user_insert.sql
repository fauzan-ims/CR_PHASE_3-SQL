CREATE PROCEDURE dbo.xsp_master_dashboard_user_insert
(
	@p_id			   bigint		= 0 output
	,@p_employee_code  nvarchar(50)
	,@p_employee_name  nvarchar(250)
	,@p_dashboard_code nvarchar(50) = null
	,@p_order_key	   int			= null
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
	declare @msg	nvarchar(max)
			,@count int ;

	begin try
		select	@count = count(employee_code)
		from	dbo.master_dashboard_user
		where	employee_code = @p_employee_code ;

		if exists
		(
			select	*
			from	dbo.master_dashboard_user
			where	employee_code = @p_employee_code
		) and isnull(@p_dashboard_code, '') = '' 
		begin
			set @msg = 'Employee is already exist';
			raiserror(@msg, 16, -1) ;

			return ;
		end ;

		if exists
		(
			select	*
			from	dbo.master_dashboard_user
			where	employee_code				   = @p_employee_code
					and isnull(dashboard_code, '') = ''
		)
		begin
			update	dbo.master_dashboard_user
			set		dashboard_code	= @p_dashboard_code
					,order_key		= @count
			where	employee_code				   = @p_employee_code
					and isnull(dashboard_code, '') = '' ;
		end ;
		else
		begin
			insert into master_dashboard_user
			(
				employee_code
				,employee_name
				,dashboard_code
				,order_key
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@p_employee_code
				,@p_employee_name
				,@p_dashboard_code
				,@count + 1
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;

			set @p_id = @@identity ;
		end ;
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
