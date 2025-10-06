CREATE PROCEDURE dbo.xsp_due_date_change_main_insert
(
	@p_code			   nvarchar(50) = '' output
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_change_status			nvarchar(10)
	,@p_change_date				datetime
	,@p_change_remarks			nvarchar(4000)
	,@p_agreement_no			nvarchar(50)
	,@p_billing_type			nvarchar(15)
	,@p_billing_mode			nvarchar(15)
	,@p_is_prorate				nvarchar(15)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
	,@p_billing_mode_date		int = 0
)
as
begin
	declare @msg			  nvarchar(max)
			,@opl_status	  nvarchar(20)
			,@year			  nvarchar(2)
			,@month			  nvarchar(2)
			,@code			  nvarchar(50)
			,@change_exp_date datetime ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
												,@p_branch_code			= @p_branch_code
												,@p_sys_document_code	= N''
												,@p_custom_prefix		= 'DCM'
												,@p_year				= @year
												,@p_month				= @month
												,@p_table_name			= 'DUE_DATE_CHANGE_MAIN'
												,@p_run_number_length	= 6
												,@p_delimiter			= '.'
												,@p_run_number_only		= N'0' ;

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

			set @msg = 'Agreement already in use at ' + @opl_status ;

			raiserror(@msg, 16, 1) ;
		end ;

		--if (@p_change_date < dbo.xfn_get_system_date())
		--begin
		--	set @msg = dbo.xfn_get_msg_err_must_be_greater_or_equal_than('Date','System Date');
		--	raiserror(@msg,16,1) ;
		--end
	
		if (@p_billing_mode in ('BEFORE DUE','BY DATE'))
		begin
			if(@p_billing_mode_date <= 0)
			begin
				set @msg = 'Date Cannot Be 0'
				raiserror (@msg, 16, -1)
			end
		
			if(@p_billing_mode_date > 31)
			begin
				set @msg = 'Date Cannot Be More Than 31'
				raiserror (@msg, 16, -1)
			end
		end

		select	@change_exp_date = dateadd(day, cast(value as int), @p_change_date)
		from	dbo.sys_global_param
		where	code = 'EXPOPL' ;

		insert into due_date_change_main
		(
			code
			,branch_code
			,branch_name
			,change_status
			,change_date
			,change_exp_date
			,change_remarks
			,agreement_no
			,billing_type
			,billing_mode
			,is_prorate	
			,billing_mode_date
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
			,@p_branch_code
			,@p_branch_name
			,@p_change_status
			,@p_change_date
			,@change_exp_date
			,@p_change_remarks
			,@p_agreement_no
			,@p_billing_type
			,@p_billing_mode
			,@p_is_prorate	
			,@p_billing_mode_date
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		insert into dbo.due_date_change_detail
		(
			due_date_change_code
			,asset_no
			,os_rental_amount
			,old_due_date_day
			,new_due_date_day
			,at_installment_no
			,is_change
			,billing_mode_date
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
			--
			,old_billing_date		
			,new_billing_date		
			,is_change_billing_date	
			,billing_mode			
			,prorate		
			,date_for_billing		
		)
		select	@code
				,aa.asset_no
				,dbo.xfn_agreement_get_all_os_principal(@p_agreement_no, @p_change_date, aa.asset_no)
				,null
				,null
				,null
				,'0'
				,@p_billing_mode_date
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				--
				,null
				,null
				,'0'
				,aa.billing_mode
				,aa.prorate
				,aa.billing_mode_date
		from	dbo.agreement_asset aa
		where	aa.agreement_no = @p_agreement_no 
				and aa.asset_status = 'RENTED'
				and aa.asset_no  not in
							(
								select	ddcd.asset_no
								from	dbo.due_date_change_detail ddcd
										inner join dbo.due_date_change_main ddcm on (ddcd.due_date_change_code = ddcm.code)
								where	ddcd.is_change = '1'
										and change_status not in
										(
											'CANCEL', 'REJECT', 'EXPIRED'
										)
							)

		--insert amortization OLD and New
		insert into dbo.due_date_change_amortization_history
		(
			due_date_change_code
			,installment_no
			,asset_no
			,due_date
			,billing_date
			,billing_amount
			,description
			,old_or_new
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@code
				,aaa.billing_no
				,aaa.asset_no
				,aaa.due_date
				,aaa.billing_date
				,aaa.billing_amount
				,aaa.description
				,'OLD'
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.agreement_asset_amortization aaa
				inner join dbo.agreement_asset aa on (aa.asset_no = aaa.asset_no)
		where	aaa.agreement_no	= @p_agreement_no
				and aa.asset_status = 'RENTED'
				and aa.asset_no  not in
							(
								select	ddcd.asset_no
								from	dbo.due_date_change_detail ddcd
										inner join dbo.due_date_change_main ddcm on (ddcd.due_date_change_code = ddcm.code)
								where	ddcd.is_change = '1'
										and change_status not in
										(
											'CANCEL', 'REJECT', 'EXPIRED'
										)
							)
		--insert into dbo.due_date_change_amortization_history
		--(
		--	due_date_change_code
		--	,installment_no
		--	,asset_no
		--	,due_date
		--	,billing_date
		--	,billing_amount
		--	,description
		--	,old_or_new
		--	--
		--	,cre_date
		--	,cre_by
		--	,cre_ip_address
		--	,mod_date
		--	,mod_by
		--	,mod_ip_address
		--)
		--select	due_date_change_code
		--		,installment_no
		--		,asset_no
		--		,due_date
		--		,billing_date
		--		,billing_amount
		--		,description
		--		,'NEW'
		--		--
		--		,@p_cre_date
		--		,@p_cre_by
		--		,@p_cre_ip_address
		--		,@p_mod_date
		--		,@p_mod_by
		--		,@p_mod_ip_address
		--from	dbo.due_date_change_amortization_history
		--where	due_date_change_code = @code ;


		--exec dbo.xsp_due_date_change_main_transaction_generate @p_code				= @code
		--													   ,@p_mod_date			= @p_mod_date
		--													   ,@p_mod_by			= @p_mod_by
		--													   ,@p_mod_ip_address	= @p_mod_ip_address ;

		exec dbo.xsp_agreement_main_update_opl_status @p_agreement_no = @p_agreement_no
													  ,@p_status = N'CHANGE DUE DATE' ;

		set @p_code = @code ;

	-- update opl status
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
