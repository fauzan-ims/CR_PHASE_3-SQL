CREATE PROCEDURE dbo.xsp_waived_obligation_insert
(
	@p_code				  nvarchar(50) output
	,@p_branch_code		  nvarchar(50)
	,@p_branch_name		  nvarchar(250)
	,@p_agreement_no	  nvarchar(50)
	,@p_waived_status	  nvarchar(10)
	,@p_waived_date		  datetime
	,@p_waived_amount	  decimal(18, 2)
	,@p_waived_remarks	  nvarchar(4000)
	,@p_obligation_amount decimal(18, 2)
	--
	,@p_cre_date		  datetime
	,@p_cre_by			  nvarchar(15)
	,@p_cre_ip_address	  nvarchar(15)
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
BEGIN

	declare @msg				nvarchar(max) 
			,@opl_status		nvarchar(15)
			,@year				nvarchar(2)
			,@month				nvarchar(2)  ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;
	
	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output 
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N'' 
												,@p_custom_prefix = 'OPLWOB'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'WAIVED_OBLIGATION'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0'
	begin try

		if not exists
		(
			select	1
			from	dbo.agreement_main
			where	agreement_no			   = @p_agreement_no
					and isnull(opl_status, '') = ''
		)
		begin
			select	@opl_status = opl_status
			from	dbo.agreement_main
			where	agreement_no = @p_agreement_no ;

			set @msg = N'Agreement : ' + @p_agreement_no + N' already in use at ' + @opl_status ;

			raiserror(@msg, 16, 1) ;
		end ;
		
		if (@p_waived_date <> dbo.xfn_get_system_date())
		begin
			set @msg = 'Date must be same with System Date';
			raiserror(@msg, 16, -1) ;
		end

		insert into waived_obligation
		(
			code
			,branch_code
			,branch_name
			,agreement_no
			,waived_status
			,waived_date
			,waived_amount
			,waived_remarks
			,obligation_amount
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
			,@p_branch_code
			,@p_branch_name
			,@p_agreement_no
			,@p_waived_status
			,@p_waived_date
			,@p_waived_amount
			,@p_waived_remarks
			,@p_obligation_amount
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		-- update lms status
		exec dbo.xsp_agreement_main_update_opl_status @p_agreement_no = @p_agreement_no
													  ,@p_status = N'WAIVE' ;
		 
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

