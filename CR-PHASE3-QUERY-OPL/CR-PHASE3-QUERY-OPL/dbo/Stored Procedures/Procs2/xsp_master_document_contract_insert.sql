CREATE PROCEDURE dbo.xsp_master_document_contract_insert
(
	@p_code			   nvarchar(50)	 output
	,@p_description	   nvarchar(250)
	,@p_document_type  nvarchar(4)
	,@p_template_name  nvarchar(250) = ''
	,@p_rpt_name	   nvarchar(250) = ''
	,@p_sp_name		   nvarchar(250)
	,@p_table_name	   nvarchar(250)
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
	declare @msg				  nvarchar(max)
			,@year				  nvarchar(4)
			,@month				  nvarchar(2)
			,@batch_currency_code nvarchar(3) 
			,@code				  nvarchar(50);

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @code output
												,@p_branch_code = N''
												,@p_sys_document_code = N''
												,@p_custom_prefix = N'MDC'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = N'MASTER_DOCUMENT_CONTRACT'
												,@p_run_number_length = 6
												,@p_delimiter = N'.'
												,@p_run_number_only = N'0' ;

	begin try
		if exists
		(
			select	1
			from	master_document_contract
			where	description = @p_description
		)
		begin
			set @msg = 'Description already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		insert into master_document_contract
		(
			code
			,description
			,document_type
			,template_name
			,rpt_name
			,sp_name
			,table_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,upper(@p_description)
			,@p_document_type
			,lower(@p_template_name)
			,lower(@p_rpt_name)
			,lower(@p_sp_name)
			,upper(@p_table_name)
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

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
end ;

