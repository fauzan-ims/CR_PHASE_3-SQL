CREATE PROCEDURE dbo.xsp_rpt_ap_payment_request
(
	@p_user_id				nvarchar(50) 	
	,@p_from_date			datetime
	,@p_to_date				datetime
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(50)
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
		delete	dbo.rpt_ap_payment_request	
		where	user_id = @p_user_id

		declare @report_company			nvarchar(250)
				,@report_title			nvarchar(250)
				,@report_image			nvarchar(250) 
				,@transaction_no		nvarchar(50)
				,@ap_date				datetime
				,@ap_type				nvarchar(50)
				,@description			nvarchar(250)
				,@to_bank_name			nvarchar(50)
				,@to_bank_account_name  nvarchar(50)
				,@to_bank_account		nvarchar(50)
				,@amount				decimal(18,2)
				,@payment_status		nvarchar(50)
				,@payment_date			datetime
                ,@branch_name			nvarchar(50)
				,@date					datetime

		set	@report_title = 'Report AP Payment Request'

		select	@report_company = value 
		from	dbo.sys_global_param
		where	code = 'COMP2'				
	 
		select	@report_image = value 
		from	dbo.sys_global_param
		where	code = 'IMGDSF'

		/* declare main cursor */
		declare c_ap_payment cursor local fast_forward read_only for 
		select	ptr.code
				,ptr.payment_transaction_date
				,isnull(ptr.payment_type,'-')
				,isnull(ptr.payment_remarks,'-')
				,isnull(ptr.to_bank_name,'-')
				,isnull(ptr.to_bank_account_name,'-')
				,isnull(ptr.to_bank_account_no,'-')
				,isnull(ptr.payment_orig_amount,0)
				,isnull(ptr.payment_status,'-')
				,ptr.payment_value_date
				,ptr.branch_name
		from	dbo.payment_transaction ptr with(nolock)
		where	cast(ptr.payment_transaction_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
		and		(ptr.branch_code = @p_branch_code or @p_branch_code = 'ALL')

		/* fetch record */
		open	c_ap_payment
		fetch	c_ap_payment
		into	@transaction_no	
				,@ap_date				
				,@ap_type				
				,@description			
				,@to_bank_name			
				,@to_bank_account_name  
				,@to_bank_account		
				,@amount				
				,@payment_status		
				,@payment_date	
				,@branch_name		

		while @@fetch_status = 0
		begin

				/* insert into table report */
				insert into dbo.rpt_ap_payment_request
				        ( 
						  user_id 
				          ,report_company 
				          ,report_title 
				          ,report_image 
				          ,filter_from_date
						  ,filter_to_date 
				          ,filter_branch_code 
				          ,transaction_no 
						  ,date
				          ,ap_date 
				          ,ap_type 
				          ,description 
				          ,to_bank_name 
				          ,to_bank_account_name 
				          ,to_bank_account 
				          ,amount 
				          ,payment_status 
				          ,payment_date 
						  ,branch_name
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
				          ,@p_branch_code 
				          ,@transaction_no
						  ,@date
				          ,@ap_date 
				          ,@ap_type 
				          ,@description 
				          ,@to_bank_name
				          ,@to_bank_account_name
				          ,@to_bank_account 
				          ,@amount 
				          ,@payment_status
				          ,@payment_date
						  ,@p_branch_name
						  ,@p_is_condition
				          ,@p_cre_by
						  ,@p_cre_date
						  ,@p_cre_ip_address
						  ,@p_mod_by 							 
						  ,@p_mod_date
						  ,@p_mod_ip_address
				        )

		/* fetch record berikutnya */
		fetch	c_ap_payment
		into	@transaction_no	
				,@ap_date				
				,@ap_type				
				,@description			
				,@to_bank_name			
				,@to_bank_account_name  
				,@to_bank_account		
				,@amount				
				,@payment_status		
				,@payment_date
				,@branch_name

		end		
		
		/* tutup cursor */
		close		c_ap_payment
		deallocate	c_ap_payment

		if not exists (select * from dbo.rpt_ap_payment_request where user_id = @p_user_id)
		begin

				insert into dbo.rpt_ap_payment_request
				        ( 
						  user_id 
				          ,report_company 
				          ,report_title 
				          ,report_image 
				          ,filter_from_date
						  ,filter_to_date 
				          ,filter_branch_code 
				          ,transaction_no 
						  ,date
				          ,ap_date 
				          ,ap_type 
				          ,description 
				          ,to_bank_name 
				          ,to_bank_account_name 
				          ,to_bank_account 
				          ,amount 
				          ,payment_status 
				          ,payment_date 
						  ,branch_name
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
				          ,@p_branch_code 
				          ,null
						  ,null
				          ,null
				          ,null
				          ,null
				          ,null
				          ,null
				          ,null
				          ,null
				          ,null
				          ,null
						  ,@p_branch_name
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
