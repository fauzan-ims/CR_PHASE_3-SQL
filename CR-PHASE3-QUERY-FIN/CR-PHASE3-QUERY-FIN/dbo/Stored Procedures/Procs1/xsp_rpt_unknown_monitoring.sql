CREATE PROCEDURE dbo.xsp_rpt_unknown_monitoring
(
	@p_user_id				nvarchar(50) 	
	,@p_from_date			datetime
	,@p_to_date				datetime
	,@p_bank_code			nvarchar(50) = 'ALL'
	,@p_account_no			nvarchar(50) = 'ALL'
	,@p_is_condition		nvarchar(1)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin 
		delete	dbo.rpt_unknown_monitoring	
		where	user_id = @p_user_id

		declare @report_company				nvarchar(250)
				,@report_title				nvarchar(250)
				,@report_image				nvarchar(250) 
				,@type_transaction			nvarchar(250)
				,@opening_balance			decimal(18,2)
				,@transaction_date			datetime
				,@transaction_no			nvarchar(50)
				,@bank_name					nvarchar(50)
				,@account_no				nvarchar(50) 
				,@currency					nvarchar(3)
				,@transaction_amount		decimal(18,2)
				,@note						nvarchar(4000)
				--
				,@datetimeNow				datetime
                ,@msg						nvarchar(max)
				,@source_reff_no			nvarchar(50)
				,@source_reff_name			nvarchar(50)
				,@filter_bank_account_name	nvarchar(50)

begin try

		if (@p_from_date > @p_to_date)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('From Date','To Date') ;

			raiserror(@msg, 16, -1) ;
		end

		set	@report_title = 'Report Unknown Monitoring'		

		set @datetimeNow = getdate();

		select	@report_company = value 
		from	dbo.sys_global_param
		where	code = 'COMP2'				
	 
		select	@report_image = value 
		from	dbo.sys_global_param
		where	code = 'IMGDSF'

		/* declare main cursor */
		declare c_unknown cursor local fast_forward read_only for 
		select	''
				,0
				,isnull(ssh.source_reff_code,'-')
				,isnull(ssh.orig_currency_code,'-')
				,isnull(ssh.orig_amount,0)
				,isnull(cht.cashier_remarks,'-')
				,ssm.suspend_date--ssh.transaction_date
				,isnull(sbb.bank_account_no, '')
				,isnull(sbb.bank_account_no + ' - ' + sbb.bank_account_name, '')
				,isnull(syb.description,'-')
		from	dbo.suspend_main ssm with(nolock)
				inner join dbo.suspend_history ssh with(nolock) on (ssh.suspend_code = ssm.code)
				left join dbo.cashier_transaction cht with(nolock) on (cht.code = ssh.source_reff_code)
				left join ifinsys.dbo.sys_branch_bank sbb with(nolock) on (sbb.code = cht.branch_bank_code) 
				left join ifinsys.dbo.sys_bank syb on (syb.code = sbb.master_bank_code)
		where	cast(ssh.transaction_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date) --CAST(ssm.suspend_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
		and		ssh.source_reff_name in ('CASHIER', 'MIGRASI')
		and		(sbb.bank_account_no = @p_account_no or @p_account_no = 'ALL')
		and		(syb.code = @p_bank_code or @p_bank_code = 'ALL')

  -- 		union

		--select	'SUSPEND ALLOCATION'
		--		,0
		--		,isnull(spa.code,'-')
		--		,isnull(spa.allocation_currency_code,'-')
		--		,isnull(spa.allocation_orig_amount,0)
		--		,isnull(spa.allocationt_remarks,'-')
		--		,spa.allocation_trx_date
		--		,''
		--		,''
		--		,''
		--from	dbo.suspend_allocation spa with(nolock)
		--		inner join dbo.suspend_history sph on (sph.source_reff_code = spa.code)
		--where	cast(spa.allocation_trx_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date) --CAST(ssm.suspend_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
		--and		sph.source_reff_name = 'SUSPEND ALLOCATION'
		--and		@p_bank_code = 'ALL'
		--and		@p_account_no = 'ALL'

		--union

		--select	'SUSPEND MERGER'
		--		,0
		--		,isnull(spm.code,'-')
		--		,isnull(spm.merger_currency_code,'-')
		--		,isnull(spm.merger_amount,0)
		--		,isnull(spm.merger_remarks,'-')
		--		,spm.merger_date
		--		,''
		--		,''
		--		,''
		--from	dbo.suspend_merger spm with(nolock)
		--		inner join dbo.suspend_history sph on (sph.source_reff_code = spm.code)
		--where	cast(spm.merger_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date) --CAST(ssm.suspend_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
		--and		sph.source_reff_name = 'SUSPEND MERGER'
		--and		@p_bank_code = 'ALL'
		--and		@p_account_no = 'ALL'

		--union

		--select	'SUSPEND RELEASE'
		--		,0
		--		,isnull(spr.code,'-')
		--		,isnull(spr.suspend_currency_code,'-')
		--		,isnull(spr.release_amount,0)
		--		,isnull(spr.release_remarks,'-')
		--		,spr.release_date
		--		,sbb.bank_account_no
		--		,spr.release_bank_account_no
		--		,isnull(syb.description,'-')
		--from	dbo.suspend_release spr with(nolock)
		--		inner join dbo.suspend_history sph on (sph.source_reff_code = spr.code)
		--		inner join ifinsys.dbo.sys_branch_bank sbb with(nolock) on (sbb.code = spr.release_bank_account_no) 
		--		left join ifinsys.dbo.sys_bank syb on (syb.code = sbb.master_bank_code)
		--where	cast(spr.release_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date) --CAST(ssm.suspend_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
		--and		sph.source_reff_name = 'SUSPEND RELEASE'
		--and		(spr.release_bank_account_no = @p_account_no and @p_account_no = 'ALL')
		--and		(syb.code = @p_bank_code or @p_bank_code = 'ALL')

		--union

		--select	'SUSPEND REVENUE'
		--		,0
		--		,isnull(spv.code,'-')
		--		,isnull(spv.currency_code,'-')
		--		,isnull(spv.revenue_amount,0)
		--		,isnull(spv.revenue_remarks,'-')
		--		,spv.revenue_date
		--		,''
		--		,''
		--		,''
		--from	dbo.suspend_revenue spv with(nolock)
		--		inner join dbo.suspend_history sph on (sph.source_reff_code = spv.code)
		--where	cast(spv.revenue_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date) --CAST(ssm.suspend_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
		--and		sph.source_reff_name = 'SUSPEND REVENUE'
		--and		@p_bank_code = 'ALL'
		--and		@p_account_no = 'ALL'

		/* fetch record */
		open	c_unknown
		fetch	c_unknown
		into	@type_transaction
				,@opening_balance
				,@transaction_no		
				,@currency			
				,@transaction_amount 
				,@note				
				,@transaction_date	
				,@account_no	
				,@filter_bank_account_name
				,@bank_name

		while @@fetch_status = 0
		begin

				--select	@bank_name	= isnull(description,'-')
				--from	ifinsys.dbo.sys_bank with(nolock)
				--where	(code = @p_bank_code or @p_bank_code = 'ALL')
				--and		is_active = '1'

				--select	@account_no = isnull(bank_account_name,'-')
				--		,@filter_bank_account_name = isnull(bank_account_name,'-')
				--from	ifinsys.dbo.sys_branch_bank with(nolock)
				--where	(bank_account_no = @p_account_no or @p_account_no = 'ALL')
				--and		is_active = '1'

				--SET @filter_bank_account_name = ''

				/* insert into table report */
				insert into dbo.rpt_unknown_monitoring
				        ( 
						  user_id 
				          ,report_company 
				          ,report_title 
				          ,report_image 
				          ,filter_from_period 
				          ,filter_to_period 
				          ,filter_bank_code 
				          ,filter_bank_account_no 
				          ,type_transaction 
				          ,opening_balance 
				          ,transaction_date 
				          ,transaction_no 
				          ,bank_name 
				          ,account_no 
				          ,currency 
				          ,transaction_amount 
				          ,note 
						  ,is_condition
				          ,cre_by 
				          ,cre_date 
				          ,cre_ip_address 
				          ,mod_by 
				          ,mod_date 
				          ,mod_ip_address
				        )
				values  ( 
						  @p_user_id
				          ,@report_company
				          ,@report_title 
				          ,@report_image 
				          ,@p_from_date
				          ,@p_to_date 
				          ,@p_bank_code 
				          ,@filter_bank_account_name
				          ,@type_transaction
				          ,@opening_balance 
				          ,@transaction_date
				          ,@transaction_no
				          ,@bank_name
				          ,@account_no
				          ,@currency
				          ,@transaction_amount
				          ,@note
						  ,@p_is_condition
				          ,@p_cre_by
						  ,@p_cre_date
						  ,@p_cre_ip_address
						  ,@p_mod_by 							 
						  ,@p_mod_date
						  ,@p_mod_ip_address
				        )

		/* fetch record berikutnya */
		fetch	c_unknown
		into	@type_transaction
				,@opening_balance
				,@transaction_no		
				,@currency			
				,@transaction_amount 
				,@note				
				,@transaction_date	
				,@account_no	
				,@filter_bank_account_name	
				,@bank_name	

		end		
		
		/* tutup cursor */
		close		c_unknown
		deallocate	c_unknown

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

		if not exists (select * from dbo.rpt_unknown_monitoring where user_id = @p_user_id)
		begin

				insert into dbo.rpt_unknown_monitoring
				        ( 
						  user_id 
				          ,report_company 
				          ,report_title 
				          ,report_image 
				          ,filter_from_period 
				          ,filter_to_period 
				          ,filter_bank_code 
				          ,filter_bank_account_no 
				          ,type_transaction 
				          ,opening_balance 
				          ,transaction_date 
				          ,transaction_no 
				          ,bank_name 
				          ,account_no 
				          ,currency 
				          ,transaction_amount 
				          ,note 
						  ,is_condition
				          ,cre_by 
				          ,cre_date 
				          ,cre_ip_address 
				          ,mod_by 
				          ,mod_date 
				          ,mod_ip_address
				        )
				values  ( 
						  @p_user_id
				          ,@report_company
				          ,@report_title 
				          ,@report_image 
				          ,@p_from_date
				          ,@p_to_date 
				          ,@p_bank_code 
				          ,''
				          ,''
				          ,null
				          ,null
				          ,null
				          ,''
				          ,''
				          ,''
				          ,null
				          ,''
						  ,@p_is_condition
				          ,@p_cre_by
						  ,@p_cre_date
						  ,@p_cre_ip_address
						  ,@p_mod_by 							 
						  ,@p_mod_date
						  ,@p_mod_ip_address
				        )


		end


end
