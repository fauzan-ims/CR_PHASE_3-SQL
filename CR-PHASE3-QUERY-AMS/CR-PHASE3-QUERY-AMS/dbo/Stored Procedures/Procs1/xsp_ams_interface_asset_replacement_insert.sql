CREATE procedure [dbo].[xsp_ams_interface_asset_replacement_insert]
(
	@p_code			   nvarchar(50) output
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	,@p_date		   datetime
	,@p_agreement_no   nvarchar(50)
	,@p_remark		   nvarchar(4000)
	,@p_status		   nvarchar(50)
	,@p_job_status	   nvarchar(50)
	,@p_failed_remark  nvarchar(4000)
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
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'AIAR'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'AMS_INTERFACE_ASSET_REPLACEMENT'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0'
												,@p_specified_column = '' ;

	begin try
		insert into dbo.ams_interface_asset_replacement
		(
			code
			,agreement_no
			,date
			,branch_code
			,branch_name
			,remark
			,status
			,job_status
			,failed_remark
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
			,@p_agreement_no
			,@p_date
			,@p_branch_code
			,@p_branch_name
			,@p_remark
			,@p_status
			,@p_job_status
			,@p_failed_remark
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
