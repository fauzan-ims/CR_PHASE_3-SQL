CREATE PROCEDURE dbo.xsp_sys_document_group_insert
(
	@p_code			   nvarchar(50) output
	,@p_company_code   nvarchar(50) = 'DSF'
	,@p_description	   nvarchar(4000)
	,@p_type_code	   nvarchar(50)
	,@p_dim_count	   nvarchar(2)
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
	declare @year	nvarchar(4)
			,@month nvarchar(2)
			,@msg	nvarchar(max)
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
												,@p_branch_code			 = ''
												,@p_sys_document_code	 = ''
												,@p_custom_prefix		 = 'G'
												,@p_year				 = @year
												,@p_month				 = @month
												,@p_table_name			 = 'SYS_DOCUMENT_GROUP'
												,@p_run_number_length	 = 5
												,@p_delimiter			= ''
												,@p_run_number_only		 = '0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try

		if exists
		(
			select	1
			from	dbo.sys_document_group
			where	description			 = @p_description
					and company_code = @p_company_code
		)
		begin
			set @msg = 'Description already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;
		insert into sys_document_group
		(
			code
			,company_code
			,description
			,type_code
			,dim_count
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
		(	@code
			,@p_company_code
			,@p_description
			,@p_type_code
			,@p_dim_count
			,@p_is_active
			--
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
