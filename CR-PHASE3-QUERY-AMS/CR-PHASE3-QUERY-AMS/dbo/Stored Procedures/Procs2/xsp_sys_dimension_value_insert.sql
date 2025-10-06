CREATE PROCEDURE dbo.xsp_sys_dimension_value_insert
(
	@p_code			   nvarchar(50) output
	,@p_dimension_code nvarchar(50)
	,@p_description	   nvarchar(250)
	,@p_value		   nvarchar(250)
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

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @p_code output
												,@p_branch_code			= N''
												,@p_sys_document_code	= N''
												,@p_custom_prefix		= 'DV'
												,@p_year				= @year
												,@p_month				= @month
												,@p_table_name			= 'SYS_DIMENSION_VALUE'
												,@p_run_number_length	= 4
												,@p_delimiter			= ''
												,@p_run_number_only		= N'0' ;

	begin try
		if exists
		(
			select	1
			from	sys_dimension_value
			where	description		   = @p_description
					and dimension_code = @p_dimension_code
		)
		begin
			set @msg = 'Description already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		insert into sys_dimension_value
		(
			code
			,dimension_code
			,description
			,value
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
			,@p_dimension_code
			,upper(@p_description)
			,@p_value
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
