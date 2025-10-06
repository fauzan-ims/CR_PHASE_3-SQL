CREATE PROCEDURE dbo.xsp_warning_letter_insert_backupcrphase3
(
	@p_code			   NVARCHAR(50) = '' OUTPUT
	,@p_branch_code	   NVARCHAR(50)
	,@p_branch_name	   NVARCHAR(250)
	,@p_letter_status  NVARCHAR(20)
	,@p_letter_date	   DATETIME
	,@p_letter_no	   NVARCHAR(50) = '' OUTPUT
	,@p_letter_type	   NVARCHAR(10)
	,@p_agreement_no   NVARCHAR(50) =''
	,@p_generate_type  NVARCHAR(10) = 'MANUAL'
	,@p_client_no	   NVARCHAR(50)
	--
	,@p_cre_date	   DATETIME
	,@p_cre_by		   NVARCHAR(15)
	,@p_cre_ip_address NVARCHAR(15)
	,@p_mod_date	   DATETIME
	,@p_mod_by		   NVARCHAR(15)
	,@p_mod_ip_address NVARCHAR(15)
)
AS
BEGIN
	DECLARE @msg						 NVARCHAR(MAX)
			,@year						 NVARCHAR(2)
			,@month						 NVARCHAR(2)
			,@code						 NVARCHAR(50)
			,@installment_amount		 DECIMAL(18, 2)
			,@installment_no			 INT
			,@overdue_days				 INT
			,@overdue_penalty_amount	 DECIMAL(18, 2)
			,@overdue_installment_amount DECIMAL(18, 2)
			,@remark					 NVARCHAR(4000)
			,@agreement_external_no		 NVARCHAR(50)
			,@client_name				 NVARCHAR(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	

	exec dbo.xsp_get_next_unique_code_for_table @p_code output
												,@p_branch_code
												,''
												,'WL'
												,@year
												,@month
												,'WARNING_LETTER'
												,6
												,'.'
												,'0' ;

	if (@p_letter_type = 'SP1')
	begin
		--exec dbo.xsp_generate_auto_surat_no @p_unique_code				= @p_letter_no output
		--									,@p_branch_code				= ''
		--									,@p_year					= @year
		--									,@p_month					= @month
		--									,@p_opl_code				= N'SP-1/COLL-OPL'
		--									,@p_run_number_length		= 5
		--									,@p_delimiter				= N'/'
		--									,@p_table_name				= N'WARNING_LETTER'
		--									,@p_column_name				= N'letter_no' ;

		exec dbo.xsp_get_next_unique_code_for_table @p_letter_no output
													,@p_branch_code
													,''
													,'SP1'
													,@year
													,@month
													,'WARNING_LETTER'
													,6
													,'.'
													,'0'
													,'letter_no' ;
	end ;
	else if (@p_letter_type = 'SP2')
	begin
		--exec dbo.xsp_generate_auto_surat_no @p_unique_code				= @p_letter_no output
		--									,@p_branch_code				= ''
		--									,@p_year					= @year
		--									,@p_month					= @month
		--									,@p_opl_code				= N'SP-2/COLL-OPL'
		--									,@p_run_number_length		= 5
		--									,@p_delimiter				= N'/'
		--									,@p_table_name				= N'WARNING_LETTER'
		--									,@p_column_name				= N'letter_no' ;

		exec dbo.xsp_get_next_unique_code_for_table @p_letter_no output
													,@p_branch_code
													,''
													,'SP2'
													,@year
													,@month
													,'WARNING_LETTER'
													,6
													,'.'
													,'0'
													,'letter_no' ;
	end ;
	else if (@p_letter_type = 'SOMASI')
	begin
		--exec dbo.xsp_generate_auto_surat_no @p_unique_code				= @p_letter_no output
		--									,@p_branch_code				= ''
		--									,@p_year					= @year
		--									,@p_month					= @month
		--									,@p_opl_code				= N'SOMASI/COLL-OPL'
		--									,@p_run_number_length		= 5
		--									,@p_delimiter				= N'/'
		--									,@p_table_name				= N'WARNING_LETTER'
		--									,@p_column_name				= N'letter_no' ;

		exec dbo.xsp_get_next_unique_code_for_table @p_letter_no output
													,@p_branch_code
													,''
													,'SOMASI'
													,@year
													,@month
													,'WARNING_LETTER'
													,6
													,'.'
													,'0'
													,'letter_no' ;
	end ;

	begin try
		if (cast(@p_letter_date as date) <> cast(dbo.xfn_get_system_date() as date))
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_equal_to('Letter Date', 'System Date') ;
			raiserror(@msg, 16, -1) ;
		end ;


		--overdue_days
		set @overdue_days = dbo.[xfn_client_get_ovd_days](@p_client_no) ;

		--installment_no
		--select	@installment_no = last_paid_period + 1
		--from	dbo.agreement_information
		--where	agreement_no = @p_agreement_no ;
		select	@installment_no = max(last_paid_period) + 1
		from	dbo.agreement_information join dbo.AGREEMENT_MAIN on AGREEMENT_MAIN.AGREEMENT_NO = AGREEMENT_INFORMATION.AGREEMENT_NO
		where	CLIENT_NO = @p_client_no
		group by CLIENT_NO

		--installment_amount
		select	@installment_amount = sum(billing_amount)
		from	dbo.agreement_asset_amortization aam 
		join	dbo.AGREEMENT_MAIN on AGREEMENT_MAIN.AGREEMENT_NO = aam.AGREEMENT_NO
		where	CLIENT_NO   = @p_client_no
				and aam.billing_no = @installment_no ;

		set @overdue_penalty_amount = dbo.xfn_client_get_ovd_penalty(@p_client_no, dbo.xfn_get_system_date()) ; --overdue_penalty_amount
		set @overdue_installment_amount = dbo.xfn_client_get_ol_ar(@p_client_no, dbo.xfn_get_system_date()) ; -- overdue_installment_amount

		--select	@client_name = am.client_name
		--		,@agreement_external_no = am.agreement_external_no
		--from	dbo.agreement_main am
		--where	am.agreement_no = @p_agreement_no ;


		--if exists (
		--	select 1
		--	from dbo.warning_letter wl
		--	join dbo.agreement_main am on wl.agreement_no = am.agreement_no
		--	where am.agreement_external_no = @agreement_external_no
		--		and wl.letter_type = @p_letter_type
		--		and wl.letter_status <> 'CANCEL'
		--)
		--begin
		--	set @msg = N'Warning Letter already exists for Agreement External No: ' + isnull(@agreement_external_no, '-') ;
		--	raiserror(@msg, 16, -1) ;
		--end ;

		--if (@overdue_days < 0)
		--begin
		--	set @msg = 'Agreement is Not Due' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;
		--if (@p_generate_type <> 'SKT')
		--begin

		--	if exists
		--	(
		--		select	1
		--		from	warning_letter
		--		where	agreement_no		= @p_agreement_no
		--				and installment_no  = @installment_no
		--				and letter_type		= @p_letter_type
		--				and letter_status	<> 'CANCEL'
		--	)
		--	begin
		--		--set @msg = @p_letter_type + N' already for Agreement ' + isnull(@agreement_external_no, '') + N' - ' + @client_name + N' with Installment No ' + cast(@installment_no as nvarchar(10))	 ;
		--		if exists
		--	(
		--		select 1
		--		from warning_letter
		--		where agreement_no = @p_agreement_no
		--			and installment_no = @installment_no
		--			and letter_type = @p_letter_type
		--			and letter_status <> 'CANCEL'
		--	)
		--	begin
		--		declare @existing_letter_no nvarchar(50) = (
		--			select top 1 LETTER_NO
		--			from dbo.WARNING_LETTER
		--			where AGREEMENT_NO = @p_agreement_no
		--			order by letter_date desc
		--		);

		--		declare @existing_delivery_code nvarchar(50) = (
		--			select top 1 DELIVERY_CODE
		--			from dbo.WARNING_LETTER
		--			where AGREEMENT_NO = @p_agreement_no
		--			order by letter_date desc
		--		);

		--		set @msg = N'Please Done Delivery Settlement For SP No. ' + isnull(@existing_letter_no, '-') +
		--				   ' On Delivery Settlement No. ' + isnull(@existing_delivery_code, '-') ;

		--		raiserror(@msg, 16, -1);
		--	end ;



		--		raiserror(@msg, 16, -1) ;
		--	end ;
		--end ;



		set @remark = N'Warning Letter ' + @p_letter_type + N' for Installment No ' + cast(@installment_no as nvarchar(4)) ;

		insert into warning_letter
		(
			code
			,branch_code
			,branch_name
			,letter_status
			,letter_date
			,letter_no
			,letter_type
			,agreement_no
			,max_print_count
			,print_count
			,generate_type
			,installment_amount
			,overdue_days
			,overdue_penalty_amount
			,overdue_installment_amount
			,installment_no
			,client_no
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
			,@p_letter_status
			,@p_letter_date
			,@p_letter_no
			,@p_letter_type
			,'-'
			,1
			,0
			,@p_generate_type
			,isnull(@installment_amount,0)
			,@overdue_days
			,isnull(@overdue_penalty_amount,0)
			,isnull(@overdue_installment_amount,0)
			,@installment_no
			,@p_client_no
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


