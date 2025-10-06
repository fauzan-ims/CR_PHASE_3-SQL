CREATE PROCEDURE dbo.xsp_sys_todo_insert
(
	@p_code			   nvarchar(50) output
	,@p_todo_name	   nvarchar(250)
	,@p_link_address   nvarchar(250)
	,@p_query		   nvarchar(250)
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
	declare @year	   nvarchar(4)
			,@month	   nvarchar(2)
			,@msg	   nvarchar(max);
	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output -- nvarchar(50)
												,@p_branch_code = N'' -- nvarchar(10)
												,@p_sys_document_code = N'' -- nvarchar(10)
												,@p_custom_prefix = N'STD' -- nvarchar(10)
												,@p_year = @year -- nvarchar(2)
												,@p_month = @month -- nvarchar(2)
												,@p_table_name = N'SYS_TODO' -- nvarchar(100)
												,@p_run_number_length = 6 -- int
												,@p_delimiter = N'.' -- nvarchar(1)
												,@p_run_number_only = N'0' ; -- nvarchar(1)

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		insert into dbo.sys_todo
		(
			code
			,todo_name
			,link_address
			,query
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
		(	@p_code
			,@p_todo_name
			,@p_link_address
			,@p_query
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
