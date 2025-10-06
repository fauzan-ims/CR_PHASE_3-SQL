CREATE PROCEDURE dbo.xsp_master_collector_insert
(
	@p_code							nvarchar(50) = '' output
	,@p_collector_name				nvarchar(250)
	,@p_supervisor_collector_code	nvarchar(50)=''
	,@p_collector_emp_code			nvarchar(50)
	,@p_collector_emp_name			nvarchar(250)
	,@p_max_load_agreement			int
	,@p_max_load_daily_agreement	int
	,@p_is_active					nvarchar(1)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
BEGIN

	declare @msg					nvarchar(max)
			,@year					nvarchar(2)
			,@month					nvarchar(2)
			,@code					nvarchar(50)
			,@spv_emp_code			nvarchar(50);

		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		declare @p_unique_code nvarchar(50) ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @p_code output
													,@p_branch_code			 = ''
													,@p_sys_document_code	 = N''
													,@p_custom_prefix		 = 'MCO'
													,@p_year				 = @year
													,@p_month				 = @month
													,@p_table_name			 = 'MASTER_COLLECTOR'
													,@p_run_number_length	 = 6
													,@p_delimiter			 = '.'
													,@p_run_number_only		 = N'0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin TRY
		
		select	@spv_emp_code = collector_emp_code
		from	dbo.master_collector 
		where	code = @p_supervisor_collector_code

		if exists
		(
			select	1
			from	master_collector
			where	collector_name = @p_collector_name
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
		)
		begin
			set @msg = 'Employee already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if(@spv_emp_code = @p_collector_emp_code)
		begin
			
			set @msg = 'Supervisor must be different. Please select another collector' ;

			raiserror(@msg, 16, -1) ;

        end

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
        
		insert into master_collector
		(
			code
			,collector_name
			,supervisor_collector_code
			,collector_emp_code
			,collector_emp_name
			,max_load_agreement
			,max_load_daily_agreement
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
		(	
			@p_code
			,UPPER(@p_collector_name)
			,@p_supervisor_collector_code
			,@p_collector_emp_code
			,@p_collector_emp_name
			,@p_max_load_agreement
			,@p_max_load_daily_agreement
			,@p_is_active
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
