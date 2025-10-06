CREATE PROCEDURE dbo.xsp_billing_scheme_insert
(
	@p_code					nvarchar(50) output
	,@p_scheme_name			nvarchar(250)
	,@p_client_no			nvarchar(50)	= ''
	,@p_client_name			nvarchar(250)	= ''
	,@p_billing_mode		nvarchar(10)	= 'BY DATE'
	,@p_billing_mode_date	int				= 0
	,@p_is_active			nvarchar(1)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin

	declare @code			nvarchar(50)
			,@year			nvarchar(4)
			,@month			nvarchar(2)
			,@msg			nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1'
	else
		set @p_is_active = '0'

	begin try

	--if exists
	--(
	--	select	1
	--	from	dbo.billing_scheme
	--	where	client_no = @p_client_no
	--)
	--begin
	--	set	@msg = 'Client Already Exist'
	--	raiserror(@msg, 16, -1)
	--end
	
	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = N'BSC'
												,@p_year = @year 
												,@p_month = @month 
												,@p_table_name = N'BILLING_SCHEME' 
												,@p_run_number_length = 6 
												,@p_delimiter = '.'
												,@p_run_number_only = N'0'

	insert into billing_scheme
	(
		code
		,scheme_name
		,client_no
		,client_name
		,billing_mode
		,billing_mode_date
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
		@code
		,@p_scheme_name
		,@p_client_no
		,@p_client_name
		,@p_billing_mode
		,@p_billing_mode_date
		,@p_is_active
		--
		,@p_cre_date
		,@p_cre_by
		,@p_cre_ip_address
		,@p_mod_date
		,@p_mod_by
		,@p_mod_ip_address
	)
	set @p_code = @code ;
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
end
