CREATE procedure dbo.xsp_efam_interface_journal_getrows_detail_for_api_thirdparty
(
	@p_gl_link_transaction_code nvarchar(50)
	,@p_company_code			nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		declare @journal as table
		(
			id		bigint
			,amount decimal(18, 2)
		) ;

		insert into @journal
		(
			id
			,amount
		)
		select	id
				,0
		from	dbo.efam_interface_journal_gl_link_transaction_detail
		where	gl_link_transaction_code = @p_gl_link_transaction_code
				and base_amount_db		 = 0.00
				and base_amount_cr		 = 0.00 ;

		select	id
				,gl_link_transaction_code
				,company_code
				,isnull(branch_code, '') 'branch_code'
				,isnull(branch_name, '') 'branch_name'
				,isnull(cost_center_code, '') 'cost_center_code'
				,isnull(cost_center_name, '') 'cost_center_name'
				,isnull(gl_link_code, '') 'gl_link_code'
				,isnull(contra_gl_link_code, '') 'contra_gl_link_code'
				,isnull(agreement_no, '') 'agreement_no'
				,isnull(facility_code, '') 'facility_code'
				,isnull(facility_name, '') 'facility_name'
				,isnull(purpose_loan_code, '') 'purpose_loan_code'
				,isnull(purpose_loan_name, '') 'purpose_loan_name'
				,isnull(purpose_loan_detail_code, '') 'purpose_loan_detail_code'
				,isnull(purpose_loan_detail_name, '') 'purpose_loan_detail_name'
				,isnull(orig_currency_code, 0) 'orig_currency_code'
				,isnull(orig_amount_db, 0) 'orig_amount_db'
				,isnull(orig_amount_cr, 0) 'orig_amount_cr'
				,isnull(exch_rate, 0) 'exch_rate'
				----,isnull(base_amount_db, 0) 'base_amount_db'
				----,isnull(base_amount_cr, 0) 'base_amount_cr'
				,case base_amount_db
					 when 0 then 'C'
					 else 'D'
				 end 'd_c'
				,case cast(base_amount_db as nvarchar(25))
					 when '0.00' then cast(base_amount_cr as nvarchar(25))
					 else cast(base_amount_db as nvarchar(25))
				 end 'base_amount_db'
				,isnull(division_code, '') 'division_code'
				,isnull(division_name, '') 'division_name'
				,isnull(department_code, '') 'department_code'
				,isnull(department_name, '') 'department_name'
				,isnull(remarks, '') 'remarks'
		from	dbo.efam_interface_journal_gl_link_transaction_detail
		where	gl_link_transaction_code = @p_gl_link_transaction_code
				and company_code		 = @p_company_code
				and id not in
					(
						select	id
						from	@journal
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
