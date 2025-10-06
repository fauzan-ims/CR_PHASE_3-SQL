CREATE PROCEDURE dbo.xsp_rpt_payment_voucher
(
	@p_user_id				nvarchar(50)
	,@p_pv_no				nvarchar(50)
)
as
begin

	delete	dbo.rpt_payment_voucher
	where	user_id = @p_user_id

	declare		@report_company			nvarchar(250)
			    ,@report_title			nvarchar(250)
			    ,@report_image			nvarchar(250)
			    ,@voucher_no			nvarchar(50)
			    ,@bank_name				nvarchar(250)
			    ,@amount				decimal(18,2)
			    ,@rate					decimal(18,6)
			    ,@transaction_date		datetime
			    ,@value_date			datetime
			    ,@paid_to				nvarchar(50)
			    ,@in_base_curr			nvarchar(3)
			    ,@allocation			nvarchar(250)
			    ,@currency				nvarchar(3)
			    ,@orig_amount			decimal(18,2)
			    ,@rate_orig				decimal(18,2)
			    ,@base_amount			decimal(18,2)
			    ,@department			nvarchar(250)
                --
				,@datetimenow			DATETIME
                ,@branch_bank_code		nvarchar(50)


		set	@report_title = 'Payment Voucher'

		set @datetimeNow = getdate();

		select	@report_company = value 
		from	dbo.sys_global_param
		where	code = 'COMP2'				
	 
		select	@report_image = value 
		from	dbo.sys_global_param
		where	code = 'IMGDSF'

		DECLARE c_payment_voucher CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
		SELECT  pv.code
				--,isnull(pv.to_bank_name,'-')
				,ISNULL(pv.payment_orig_amount,0)
				,ISNULL(pv.payment_exch_rate,0)
				,pv.payment_transaction_date
				,pv.payment_value_date
				,ISNULL(pv.to_bank_account_name,'-')
				--,isnull(curn,'-')
				,ISNULL(gl.gl_link_name,'-')
				,ISNULL(pvd.orig_currency_code,'-')
				,ISNULL(pvd.orig_amount,0)
				,ISNULL(pvd.exch_rate,0)
				,ISNULL(pvd.base_amount,0)
				,ISNULL(pvd.department_name,'-')
				,pv.branch_bank_code
		FROM	dbo.payment_voucher pv WITH(NOLOCK) 
				INNER JOIN dbo.payment_voucher_detail pvd WITH(NOLOCK) ON (pvd.payment_voucher_code = pv.code)
				INNER JOIN dbo.journal_gl_link gl ON (gl.code=pvd.gl_link_code)
		WHERE	pv.code = @p_pv_no

		OPEN	c_payment_voucher
		FETCH   c_payment_voucher
		INTO	@voucher_no
				--,@bank_name			
				,@amount			
				,@rate				
				,@transaction_date	
				,@value_date		
				,@paid_to			
				--,@in_base_curr		
				,@allocation		
				,@currency			
				,@orig_amount		
				,@rate_orig			
				,@base_amount		
				,@department	
				,@branch_bank_code		

		WHILE @@fetch_status = 0
		BEGIN 

			select	@bank_name				= sbb.bank_account_no + ' - '+ sbb.bank_account_name  + ' - '+  isnull(sb.description,'-')
			from	ifinsys.dbo.sys_branch_bank sbb with(nolock)
					inner join ifinsys.dbo.sys_bank sb with(nolock) on (sb.code = sbb.master_bank_code)
			where	sbb.code = @branch_bank_code

			select @in_base_curr = code
			from ifinsys.dbo.sys_currency 
			where base_currency ='1'

			/*insert into table*/
			INSERT INTO dbo.rpt_payment_voucher
			        ( 
					  user_id 
					  ,pv_no
			          ,report_company 
			          ,report_title 
			          ,report_image 
			          ,voucher_no 
			          ,bank_name 
			          ,amount 
			          ,rate 
			          ,transaction_date 
			          ,value_date 
			          ,paid_to 
			          ,in_base_curr 
			          ,allocation 
			          ,currency 
			          ,orig_amount 
			          ,rate_orig 
			          ,base_amount 
			          ,department 
			          ,cre_by 
			          ,cre_date 
			          ,cre_ip_address 
			          ,mod_by 
			          ,mod_date 
			          ,mod_ip_address
			        )
			values  ( 
					  @p_user_id 
					  ,@p_pv_no
			          ,@report_company
			          ,@report_title 
			          ,@report_image 
			          ,@voucher_no
			          ,@bank_name
			          ,@amount 
			          ,@rate 
			          ,@transaction_date
			          ,@value_date
			          ,@paid_to 
			          ,@in_base_curr 
			          ,@allocation
			          ,@currency 
			          ,@orig_amount 
			          ,@rate_orig 
			          ,@base_amount
			          ,@department 
			          ,@p_user_id
					  ,@datetimenow
					  ,'127.0.0.1'
					  ,@p_user_id 							 
					  ,@datetimenow
					  ,'127.0.0.1'
			        )

		fetch   c_payment_voucher
		into	@voucher_no
				--,@bank_name			
				,@amount			
				,@rate				
				,@transaction_date	
				,@value_date		
				,@paid_to			
				--,@in_base_curr		
				,@allocation		
				,@currency			
				,@orig_amount		
				,@rate_orig			
				,@base_amount		
				,@department
				,@branch_bank_code

		end
  
		close	 c_payment_voucher
		deallocate	c_payment_voucher 
		
		if not exists (select * from dbo.rpt_payment_voucher where user_id = @p_user_id)
		begin

				insert into dbo.rpt_payment_voucher
			        ( 
					  user_id 
					  ,pv_no
			          ,report_company 
			          ,report_title 
			          ,report_image 
			          ,voucher_no 
			          ,bank_name 
			          ,amount 
			          ,rate 
			          ,transaction_date 
			          ,value_date 
			          ,paid_to 
			          ,in_base_curr 
			          ,allocation 
			          ,currency 
			          ,orig_amount 
			          ,rate_orig 
			          ,base_amount 
			          ,department 
			          ,cre_by 
			          ,cre_date 
			          ,cre_ip_address 
			          ,mod_by 
			          ,mod_date 
			          ,mod_ip_address
			        )
			values  ( 
					  @p_user_id 
					  ,@p_pv_no
			          ,@report_company
			          ,@report_title 
			          ,@report_image 
			          ,'none'
			          ,''
			          ,0 
			          ,0 
			          ,isnull(@transaction_date,'')
			          ,isnull(@value_date,'')
			          ,'' 
			          ,'' 
			          ,''
			          ,'' 
			          ,0 
			          ,0 
			          ,0
			          ,'' 
			          ,@p_user_id
					  ,@datetimenow
					  ,'127.0.0.1'
					  ,@p_user_id 							 
					  ,@datetimenow
					  ,'127.0.0.1'
			        )

		end

end
