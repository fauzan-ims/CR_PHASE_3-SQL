CREATE PROCEDURE [dbo].[xsp_sys_job_tasklist_insert]
(
	@p_code			   nvarchar(50) output
	,@p_type		   nvarchar(20)
	,@p_description	   nvarchar(250)
	,@p_sp_name		   nvarchar(250)
	,@p_order_no	   int
	,@p_is_active	   nvarchar(1)
	,@p_row_to_process int
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
			,@count int 
			,@year	nvarchar(4)
			,@month nvarchar(2);

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = ''
												,@p_sys_document_code = ''
												,@p_custom_prefix = 'SJT'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'SYS_JOB_TASKLIST'
												,@p_run_number_length = 5
												,@p_run_number_only = '0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		select	@count = count(code)
		from	dbo.sys_job_tasklist
		where	type = 'EOD' ;

		if @p_type = 'EOD'
		begin
			set @p_order_no = @count + 1 ;
		end ;

		insert into dbo.sys_job_tasklist
		(
			code
			,type
			,description
			,sp_name
			,order_no
			,is_active
			,last_id
			,row_to_process
			,eod_status
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@p_type
			,@p_description
			,@p_sp_name
			,@p_order_no
			,@p_is_active
			,0
			,@p_row_to_process	
			,'NONE'	
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
