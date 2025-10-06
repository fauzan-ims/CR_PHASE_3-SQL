CREATE PROCEDURE dbo.xsp_job_pull_lms_to_fin_interface_cashier_received_request
	@p_last_id_from_job bigint
	,@p_last_id			bigint = 0 output
	,@p_number_rows		int	   = 0 output
as
declare @msg							nvarchar(max)
		,@cashier_received_request_code nvarchar(50)
		,@id_interface					bigint ; --cursor;

begin try
	--get agreement no
	declare curr_pull cursor for
	select		id
				,code
	from		ifinlms.dbo.lms_interface_cashier_received_request
	where		id				   > @p_last_id_from_job
				and request_status = 'HOLD'
	order by	id asc offset 0 rows fetch next 10 rows only ;

	open curr_pull ;

	fetch next from curr_pull
	into @id_interface
		 ,@cashier_received_request_code ;

	while @@fetch_status = 0
	begin
		insert into dbo.fin_interface_cashier_received_request
		(
			code
			,branch_code
			,branch_name
			,request_status
			,request_currency_code
			,request_date
			,request_amount
			,request_remarks
			,agreement_no
			,pdc_code
			,pdc_no
			,doc_ref_code
			,doc_ref_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	licrr.code
				,licrr.branch_code
				,licrr.branch_name
				,licrr.request_status
				,licrr.request_currency_code
				,licrr.request_date
				,licrr.request_amount
				,licrr.request_remarks
				,licrr.agreement_no
				,licrr.pdc_code
				,licrr.pdc_no
				,licrr.doc_ref_code
				,licrr.doc_ref_name
				--
				,getdate()
				,'job'
				,'127.0.0.1'
				,getdate()
				,'job'
				,'127.0.0.1'
		from	ifinlms.dbo.lms_interface_cashier_received_request licrr
		where	licrr.id = @id_interface ;

		insert into dbo.fin_interface_cashier_received_request_detail
		(
			cashier_received_request_code
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
		select	licrrd.cashier_received_request_code
				,licrrd.branch_code
				,licrrd.branch_name
				,licrrd.gl_link_code
				,licrrd.agreement_no
				,licrrd.facility_code
				,licrrd.facility_name
				,licrrd.purpose_loan_code
				,licrrd.purpose_loan_name
				,licrrd.purpose_loan_detail_code
				,licrrd.purpose_loan_detail_name
				,licrrd.orig_currency_code
				,licrrd.orig_amount
				,licrrd.division_code
				,licrrd.division_name
				,licrrd.department_code
				,licrrd.department_name
				,licrrd.remarks
				--
				,getdate()
				,'job'
				,'127.0.0.1'
				,getdate()
				,'job'
				,'127.0.0.1'
		from	ifinlms.dbo.lms_interface_cashier_received_request_detail licrrd
		where	licrrd.cashier_received_request_code = @cashier_received_request_code ;

		fetch next from curr_pull
		into @id_interface
			 ,@cashier_received_request_code ;
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
			from	ifinlms.dbo.lms_interface_cashier_received_request
			where	id > @p_last_id_from_job
		)
		begin
			select	@p_last_id = min(id) - 1
			from	ifinlms.dbo.lms_interface_cashier_received_request
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
