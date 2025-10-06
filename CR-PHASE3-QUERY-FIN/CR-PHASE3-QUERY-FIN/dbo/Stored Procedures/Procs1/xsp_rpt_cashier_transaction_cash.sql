CREATE PROCEDURE dbo.xsp_rpt_cashier_transaction_cash
(
	@p_user_id				nvarchar(50)
	,@p_open_no				nvarchar(50)
)
as
begin

	delete	dbo.rpt_cashier_transaction_cash
	where	user_id = @p_user_id

	declare		@report_company			nvarchar(250)
			    ,@report_title			nvarchar(250)
			    ,@report_image			nvarchar(250)
			    ,@cashier_code			nvarchar(50)
			    ,@cashier_date			datetime
			    ,@cashier_name			nvarchar(50)
			    ,@transaction_date		datetime
			    ,@transaction_no		nvarchar(50)
			    ,@transaction_remark	nvarchar(4000)
			    ,@agreement_no			nvarchar(50)
			    ,@client_name			nvarchar(50)
			    ,@debit_amount			decimal(18,2)
			    ,@credit_amount			decimal(18,2)
			    ,@balance_amount		decimal(18,2)
			    ,@beginning_balance		decimal(18,2)
			    ,@ending_balance		decimal(18,2)
                --
				,@datetimenow			datetime


		set	@report_title = 'Daily Cashier Transaction'

		set @datetimeNow = getdate();

		select	@report_company = value 
		from	dbo.sys_global_param
		where	code = 'COMP2'				
	 
		select	@report_image = value 
		from	dbo.sys_global_param
		where	code = 'IMGDSF'

		declare c_cashier_transaction cursor local fast_forward read_only for
		select  isnull(cm.code,'-')
				,cm.cashier_open_date
				,isnull(cm.employee_name,'-')
				,isnull(ct.cashier_trx_date,'1900-01-01')
				,isnull(ct.code,'-')
				,isnull(ct.cashier_remarks,'-')
				,isnull(ct.agreement_no,'-')
				,isnull(am.client_name,'-')
				,isnull(cm.cashier_db_amount,0)
				,isnull(cm.cashier_cr_amount,0)
				,isnull(cm.cashier_open_amount,0)
				,isnull(cm.cashier_close_amount,0)
		from	dbo.cashier_main cm with(nolock) 
				left join dbo.cashier_receipt_allocated cra with(nolock) on (cra.cashier_code = cm.code and cra.receipt_status = 'USED')		
				left join dbo.cashier_transaction ct with(nolock) on (ct.code = cra.receipt_use_trx_code)
				left join dbo.agreement_main am with(nolock) on (am.agreement_no = ct.agreement_no)
		where	cm.code = @p_open_no

		open	c_cashier_transaction
		fetch   c_cashier_transaction
		into	@cashier_code
				,@cashier_date
				,@cashier_name
				,@transaction_date	
				,@transaction_no	
				,@transaction_remark
				,@agreement_no	
				,@client_name
				,@debit_amount		
				,@credit_amount		
				,@beginning_balance	
				,@ending_balance		

		while @@fetch_status = 0
		begin 

			set @balance_amount = @beginning_balance + @debit_amount - @credit_amount

			/*insert into table*/
			insert into dbo.rpt_cashier_transaction_cash
			        ( 
					  user_id 
			          ,report_company 
			          ,report_title 
			          ,report_image 
			          ,cashier_code 
			          ,cashier_date 
			          ,cashier_name 
			          ,transaction_date 
			          ,transaction_no 
			          ,transaction_remark 
			          ,agreement_no 
			          ,client_name 
			          ,debit_amount 
			          ,credit_amount 
			          ,balance_amount 
			          ,beginning_balance 
			          ,ending_balance 
			          ,cre_date 
			          ,cre_by 
			          ,cre_ip_address 
			          ,mod_date 
			          ,mod_by 
			          ,mod_ip_address
			        )
			values  ( 
					  @p_user_id
			          ,@report_company 
			          ,@report_title
			          ,@report_image
			          ,@cashier_code
			          ,@cashier_date
			          ,@cashier_name
			          ,@transaction_date
			          ,@transaction_no 
			          ,@transaction_remark 
			          ,@agreement_no 
			          ,@client_name 
			          ,@debit_amount 
			          ,@credit_amount
			          ,@balance_amount 
			          ,@beginning_balance 
			          ,@ending_balance
					  ,@datetimenow
			          ,@p_user_id
					  ,'127.0.0.1'
					  ,@datetimenow
					  ,@p_user_id 							 
					  ,'127.0.0.1'
			        )

		fetch   c_cashier_transaction
		into	@cashier_code
				,@cashier_date
				,@cashier_name
				,@transaction_date	
				,@transaction_no	
				,@transaction_remark
				,@agreement_no	
				,@client_name
				,@debit_amount		
				,@credit_amount		
				,@beginning_balance	
				,@ending_balance


		end
  
		close	 c_cashier_transaction
		deallocate	c_cashier_transaction 
		
		if not exists (select * from dbo.rpt_cashier_transaction_cash where user_id = @p_user_id)
		begin

				insert into dbo.rpt_cashier_transaction_cash
			        ( 
					  user_id 
			          ,report_company 
			          ,report_title 
			          ,report_image 
			          ,cashier_code 
			          ,cashier_date 
			          ,cashier_name 
			          ,transaction_date 
			          ,transaction_no 
			          ,transaction_remark 
			          ,agreement_no 
			          ,client_name 
			          ,debit_amount 
			          ,credit_amount 
			          ,balance_amount 
			          ,beginning_balance 
			          ,ending_balance 
			          ,cre_date 
			          ,cre_by 
			          ,cre_ip_address 
			          ,mod_date 
			          ,mod_by 
			          ,mod_ip_address
			        )
			values  ( 
					  @p_user_id
			          ,@report_company 
			          ,@report_title
			          ,@report_image
			          ,'none'
			          ,isnull(@cashier_date,'-')
			          ,''
			          ,isnull(@transaction_date,'1900-01-01')
			          ,'' 
			          ,'' 
			          ,'' 
			          ,'' 
			          ,0 
			          ,0
			          ,0 
			          ,0 
			          ,0
					  ,@datetimenow
			          ,@p_user_id
					  ,'127.0.0.1'
					  ,@datetimenow
					  ,@p_user_id 							 
					  ,'127.0.0.1'
			        )

		end

end
