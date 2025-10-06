--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_kontrak_overdue
(
	@p_user_id		 nvarchar(50)
	,@p_branch_code	 nvarchar(50)
	,@p_branch_name	 nvarchar(50)
	,@p_as_at_date	 datetime
	,@p_is_condition nvarchar(1)
)
as
begin
	delete dbo.rpt_kontrak_overdue
	where	user_id = @p_user_id ;

	declare @msg						nvarchar(max)
			,@report_company			nvarchar(250)
			,@report_title				nvarchar(250)
			,@report_image				nvarchar(250)
			,@agreement_no				nvarchar(50)
			,@client_name				nvarchar(50)
			,@periode					int
			,@overdue_days				int
			,@overdue_rental_amount		decimal(18, 2)
			,@outstanding_rental_amount decimal(18, 2)
			,@outstanding_periode		int
			,@overdue_date				datetime
			,@overdue_invoice_amount	decimal(18, 2)
			,@rental_amount				decimal(18, 2) ;

	begin try
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set @report_title = 'Report Kontrak Overdue' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		begin
			insert into rpt_kontrak_overdue
			(
				user_id
				,report_company
				,report_title
				,report_image
				,branch_code
				,branch_name
				,as_of_date
				,agreement_no
				,client_name
				,periode
				,overdue_days
				,overdue_rental_amount
				,outstanding_rental_amount
				,outstanding_periode
				,overdue_date
				,overdue_invoice_amount
				,rental_amount
				,is_condition
			)
			select	@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_branch_code
					,@p_branch_name
					,@p_as_at_date
					,am.agreement_external_no
					,agi.client_name
					,agi.ovd_period
					,agi.ovd_days
					,agi.ovd_rental_amount
					,agi.os_rental_amount
					,agi.os_period
					,agi.installment_due_date
					,agi.ovd_rental_amount
					,agi.ovd_penalty_amount
					,@p_is_condition
			from	dbo.agreement_aging agi
					inner join dbo.agreement_main am on (am.agreement_no = agi.agreement_no)
			where	agi.branch_code				 = case @p_branch_code
												   when 'ALL' then agi.branch_code
												   else @p_branch_code
											   end
					and cast(agi.aging_date as date) = cast(@p_as_at_date as date);

			if not exists
			(
				select	1
				from	dbo.rpt_kontrak_overdue
				where	user_id = @p_user_id
			)
			begin
				insert into dbo.rpt_kontrak_overdue
				(
					user_id
					,report_company
					,report_title
					,report_image
					,branch_code
					,branch_name
					,as_of_date
					,agreement_no
					,client_name
					,periode
					,overdue_days
					,overdue_rental_amount
					,outstanding_rental_amount
					,outstanding_periode
					,overdue_date
					,overdue_invoice_amount
					,rental_amount
					,is_condition
				)
				values
				(	@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_branch_code
					,@p_branch_name
					,@p_as_at_date
					,''
					,''
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null 
					,@p_is_condition
				) ;
			end ; 
		end ;
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
