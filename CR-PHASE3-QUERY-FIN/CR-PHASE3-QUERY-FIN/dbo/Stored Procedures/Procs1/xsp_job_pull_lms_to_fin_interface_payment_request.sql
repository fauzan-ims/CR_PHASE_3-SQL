CREATE PROCEDURE dbo.xsp_job_pull_lms_to_fin_interface_payment_request
	@p_last_id_from_job bigint
	,@p_last_id			bigint = 0 output
	,@p_number_rows		int	   = 0 output
as
declare @msg				   nvarchar(max)
		,@payment_request_code nvarchar(50)
		,@id_interface		   bigint ; --cursor;

begin try
	--get agreement no
	declare curr_pull cursor for
	select		id
				,code
	from		ifinlms.dbo.lms_interface_payment_request
	where		id				   > @p_last_id_from_job
				and payment_status = 'HOLD'
	order by	id asc offset 0 rows fetch next 10 rows only ;

	open curr_pull ;

	fetch next from curr_pull
	into @id_interface
		 ,@payment_request_code ;

	while @@fetch_status = 0
	begin
		insert into dbo.fin_interface_payment_request
		(
			code
			,branch_code
			,branch_name
			,payment_branch_code
			,payment_branch_name
			,payment_source
			,payment_request_date
			,payment_source_no
			,payment_status
			,payment_currency_code
			,payment_amount
			,payment_remarks
			,to_bank_account_name
			,to_bank_name
			,to_bank_account_no
			,process_date
			,process_reff_no
			,process_reff_name
			,manual_upload_status
			,manual_upload_remarks
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	code
				,branch_code
				,branch_name
				,branch_code
				,branch_name
				,payment_source
				,payment_request_date
				,payment_source_no
				,payment_status
				,payment_currency_code
				,payment_amount
				,payment_remarks
				,to_bank_account_name
				,to_bank_name
				,to_bank_account_no
				,process_date
				,process_reff_no
				,process_reff_name
				,null
				,null
				--
				,getdate()
				,'job'
				,'127.0.0.1'
				,getdate()
				,'job'
				,'127.0.0.1'
		from	ifinlms.dbo.lms_interface_payment_request lipr
		where	id = @id_interface ;

		insert into dbo.fin_interface_payment_request_detail
		(
			payment_request_code
			,branch_code
			,branch_name
			,gl_link_code
			,agreement_no
			,facility_code
			,facility_name
			,purpose_loan_code
			,purpose_loan_name
			,purpose_loan_detail_code
			,purpose_loan_detail_name
			,orig_currency_code
			,orig_amount
			,division_code
			,division_name
			,department_code
			,department_name
			,remarks
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	payment_request_code
				,branch_code
				,branch_name
				,gl_link_code
				,agreement_no
				,facility_code
				,facility_name
				,purpose_loan_code
				,purpose_loan_name
				,purpose_loan_detail_code
				,purpose_loan_detail_name
				,orig_currency_code
				,orig_amount
				,division_code
				,division_name
				,department_code
				,department_name
				,remarks
				--
				,getdate()
				,'job'
				,'127.0.0.1'
				,getdate()
				,'job'
				,'127.0.0.1'
		from	ifinlms.dbo.lms_interface_payment_request_detail liprd
		where	liprd.payment_request_code = @payment_request_code ;

		fetch next from curr_pull
		into @id_interface
			 ,@payment_request_code ;
	end ;

	close curr_pull ;
	deallocate curr_pull ;

	set @p_number_rows = @@rowcount ;

	-- START for set last id job
	set @p_last_id = @id_interface ;

	if (isnull(@p_last_id, 0) = 0)
	begin
		if exists
		(
			select	1
			from	fin_interface_payment_request
			where	id > @p_last_id_from_job
		)
		begin
			select	@p_last_id = min(id) - 1
			from	fin_interface_payment_request
			where	id > @p_last_id_from_job ;
		end ;
		else
		begin
			set @p_last_id = @p_last_id_from_job ;
		end ;
	end ;
--END for set last id job
end try
begin catch
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
