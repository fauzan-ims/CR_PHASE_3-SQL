CREATE PROCEDURE dbo.xsp_sppa_main_insert
(
	@p_code				 nvarchar(50) OUTPUT
	,@p_sppa_branch_code nvarchar(50)
	,@p_sppa_branch_name nvarchar(250)
	,@p_sppa_date		 datetime
	,@p_sppa_status		 nvarchar(10)
	,@p_sppa_remarks	 nvarchar(4000)
	,@p_insurance_code	 nvarchar(50)
	,@p_insurance_type	 nvarchar(10)
	--,@p_file_name		 nvarchar(250)
	--,@p_paths			 nvarchar(250)
	--
	,@p_cre_date		 datetime
	,@p_cre_by			 nvarchar(15)
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	--declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = @p_sppa_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'AMSSM'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'SPPA_MAIN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		insert into SPPA_MAIN
		(
			code
			,sppa_branch_code
			,sppa_branch_name
			,sppa_date
			,sppa_status
			,sppa_remarks
			,insurance_code
			,insurance_type
			--,file_name
			--,paths
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
			,@p_sppa_branch_code
			,@p_sppa_branch_name
			,@p_sppa_date
			,@p_sppa_status
			,@p_sppa_remarks
			,@p_insurance_code
			,@p_insurance_type
			--,@p_file_name
			--,@p_paths
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
	end try
	Begin catch
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

