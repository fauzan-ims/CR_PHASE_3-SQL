CREATE PROCEDURE dbo.xsp_document_movement_insert
(
	@p_code							nvarchar(50)   = '' output
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_movement_date				datetime
	,@p_movement_status				nvarchar(20)
	,@p_movement_type				nvarchar(20)
	,@p_movement_location			nvarchar(20)
	,@p_movement_from				nvarchar(50)   = null
	,@p_movement_to					nvarchar(50)   = null
	,@p_movement_to_agreement_no	nvarchar(250)  = null
	,@p_movement_to_client_name		nvarchar(250)  = null
	,@p_movement_to_branch_code		nvarchar(50)   = null
	,@p_movement_to_branch_name		nvarchar(250)  = null
	,@p_movement_from_dept_code		nvarchar(50)   = null
	,@p_movement_from_dept_name		nvarchar(250)  = null
	,@p_movement_to_dept_code		nvarchar(50)   = null
	,@p_movement_to_dept_name		nvarchar(250)  = null
	,@p_movement_by_emp_code		nvarchar(50)   = null
	,@p_movement_by_emp_name		nvarchar(250)  = null
	,@p_movement_courier_code		nvarchar(50)   = null
	,@p_movement_remarks			nvarchar(4000)
	,@p_receive_status				nvarchar(20)   = null
	,@p_receive_date				datetime	   = null
	,@p_receive_remark				nvarchar(4000) = null
	,@p_estimate_return_date		datetime	   = null
	,@p_received_by					nvarchar(1)	   = null
	,@p_received_id_no				nvarchar(50)   = null
	,@p_received_name				nvarchar(250)  = null
	,@p_movement_to_thirdparty_type nvarchar(50)   = null
	/*,@p_file_name					nvarchar(250)	= null
	,@p_paths						nvarchar(250)	= null*/
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'MTS'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'DOCUMENT_MOVEMENT'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		if (@p_movement_location = 'BORROW CLIENT')
		begin
			set @p_movement_to_branch_code = @p_branch_code
			set @p_movement_to_branch_name = @p_branch_name
		end
		if (@p_movement_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Date must be less or equal than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_receive_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Receive Date must be less or equal than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_estimate_return_date < @p_movement_date)
		begin
			set @msg = 'Estimate Return Date must be greater than or equal to Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		insert into document_movement
		(
			code
			,branch_code
			,branch_name
			,movement_date
			,movement_status
			,movement_type
			,movement_location
			,movement_from
			,movement_to
			,movement_to_agreement_no
			,movement_to_client_name
			,movement_to_branch_code
			,movement_to_branch_name
			,movement_from_dept_code
			,movement_from_dept_name
			,movement_to_dept_code
			,movement_to_dept_name
			,movement_by_emp_code
			,movement_by_emp_name
			,movement_courier_code
			,movement_remarks
			,receive_status
			,receive_date
			,receive_remark
			,estimate_return_date
			,received_by
			,received_id_no
			,received_name
			,movement_to_thirdparty_type
			/*,file_name
			,paths*/
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
			,@p_movement_date
			,@p_movement_status
			,@p_movement_type
			,@p_movement_location
			,isnull(@p_movement_from, isnull(@p_movement_to_branch_name, isnull(@p_movement_from_dept_name, @p_movement_to_client_name)))
			,upper(isnull(@p_movement_to, isnull(@p_movement_to_branch_name, isnull(@p_movement_from_dept_name, @p_movement_to_client_name))))
			,@p_movement_to_agreement_no
			,@p_movement_to_client_name
			,@p_movement_to_branch_code
			,@p_movement_to_branch_name
			,@p_movement_from_dept_code
			,@p_movement_from_dept_name
			,@p_movement_to_dept_code
			,@p_movement_to_dept_name
			,@p_movement_by_emp_code
			,@p_movement_by_emp_name
			,@p_movement_courier_code
			,@p_movement_remarks
			,@p_receive_status
			,@p_cre_date
			,@p_receive_remark
			,@p_estimate_return_date
			,@p_received_by
			,@p_received_id_no
			,@p_received_name
			,@p_movement_to_thirdparty_type
			/*,@p_file_name
			,@p_paths*/
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
