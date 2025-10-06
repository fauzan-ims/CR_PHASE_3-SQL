CREATE PROCEDURE dbo.xsp_sys_report_insert
(
	@p_code			   nvarchar(50) output
	,@p_name		   nvarchar(250)
	,@p_report_type	   nvarchar(15)
	,@p_table_name	   nvarchar(250)
	,@p_sp_name		   nvarchar(250)
	,@p_screen_name	   nvarchar(250)
	,@p_rpt_name	   nvarchar(250)
	,@p_is_active	   nvarchar(1)
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
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = ''
												,@p_sys_document_code = ''
												,@p_custom_prefix = 'R'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'SYS_REPORT'
												,@p_run_number_length = 5
												,@p_delimiter = ''
												,@p_run_number_only = N'0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		if exists (select 1 from sys_report where name = @p_name)
		begin
			set @msg = 'Name already exist';
			raiserror(@msg, 16, -1) ;
		end

		if (right(@p_rpt_name, 4) <> '.rpt') 
		begin
			set @msg = 'Invalid Crystal Report Name';
			raiserror(@msg, 16, -1) ;
		end

		insert into dbo.sys_report
		(
			code
			,name
			,table_name
			,sp_name
			,screen_name
			,rpt_name
			,module_code
			,report_type
			,is_active
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_name
			,@p_table_name
			,@p_sp_name
			,@p_screen_name
			,@p_rpt_name
			,'EPROC'
			,@p_report_type
			,@p_is_active
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) set @p_code = @code ;
			
	

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

