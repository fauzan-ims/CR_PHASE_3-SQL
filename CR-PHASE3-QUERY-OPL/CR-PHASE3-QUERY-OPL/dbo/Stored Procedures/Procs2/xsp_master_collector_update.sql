CREATE PROCEDURE dbo.xsp_master_collector_update
(
	@p_code							nvarchar(50)
	,@p_collector_name				nvarchar(250)
	,@p_supervisor_collector_code	nvarchar(50)='' 
	,@p_collector_emp_code			nvarchar(50) 
	,@p_collector_emp_name			nvarchar(250)
	,@p_max_load_agreement			int
	,@p_max_load_daily_agreement	int
	,@p_is_active					nvarchar(1)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
BEGIN

	declare @msg				nvarchar(max) 
			,@spv_emp_code		nvarchar(50);

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		
		select	@spv_emp_code = collector_emp_code
		from	dbo.master_collector 
		where	code = @p_supervisor_collector_code

		if exists
		(
			select	1
			from	master_collector
			where	code <> @p_code
			and		collector_name = @p_collector_name
		)
		begin
			set @msg = 'Name already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	master_collector
			where	collector_emp_code = @p_collector_emp_code
			and		code <> @p_code
		)
		begin
			set @msg = 'Employee already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if(@spv_emp_code = @p_collector_emp_code)
		begin
			
			set @msg = 'Supervisor must be different. Please select another collector' ;

			raiserror(@msg, 16, -1) ;

        END
        
		if(@p_max_load_agreement < 0)
		BEGIN
			
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Max Load Agreement per Month','0') ;

			raiserror(@msg, 16, -1) ;

        end

		if(@p_max_load_daily_agreement < 0)
		BEGIN
			
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Max Load Agreement per Daily','0') ;

			raiserror(@msg, 16, -1) ;

        END

		update	master_collector
		set		collector_name				= upper(@p_collector_name)
				,supervisor_collector_code	= @p_supervisor_collector_code
				,collector_emp_code			= @p_collector_emp_code
				,collector_emp_name			= @p_collector_emp_name
				,max_load_agreement			= @p_max_load_agreement
				,max_load_daily_agreement	= @p_max_load_daily_agreement
				,is_active					= @p_is_active
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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
