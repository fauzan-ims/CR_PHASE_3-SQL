CREATE PROCEDURE dbo.xsp_rpt_pending_disbursement
(
	@p_user_id				nvarchar(50) 	
	,@p_from_date			datetime
	,@p_to_date				datetime
	,@p_branch_code			nvarchar(50)
	---
	,@p_cre_by				nvarchar(15)
	,@p_cre_date			datetime
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_by				nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_ip_address		nvarchar(15)
)
as
begin 
		delete	dbo.rpt_pending_disbursement	
		where	user_id = @p_user_id

		declare @report_company			nvarchar(250)
				,@report_title			nvarchar(250)
				,@report_image			nvarchar(250) 
				,@agreement_no			nvarchar(50)
				,@client_name			nvarchar(250)
				,@agreement_date		datetime
				,@to_bank_name			nvarchar(50)
				,@to_bank_account_name  nvarchar(50)
				,@to_bank_account_no	nvarchar(50)
				,@amount				decimal(18,2)

		set	@report_title = 'Report Pending Disbursement'

		select	@report_company = value 
		from	dbo.sys_global_param
		where	code = 'COMP2'				
	 
		select	@report_image = value 
		from	dbo.sys_global_param
		where	code = 'IMGDSF'

		/* declare main cursor */
		declare c_pending cursor local fast_forward read_only for 
		select	isnull(pyr.payment_source_no,'-')
				,substring(pyr.payment_remarks, charindex('for', pyr.payment_remarks, 1) + 4, len(pyr.payment_remarks))
				,pyr.payment_request_date
				,isnull(pyr.to_bank_name,'-')
				,isnull(pyr.to_bank_account_name,'-')
				,isnull(pyr.to_bank_account_no,'-')
				,isnull(pyr.payment_amount,0)
		from	dbo.payment_request pyr with(nolock)
		where	cast(pyr.payment_request_date as date) <= cast(@p_from_date as date)
		and		(pyr.branch_code = @p_branch_code or @p_branch_code = 'ALL')
		and		pyr.payment_status in ('HOLD','ON PROCESS')
		and		pyr.payment_source likE '%DISBURSEMENT%'

		/* fetch record */
		open	c_pending
		fetch	c_pending
		into	@agreement_no	
				,@client_name			
				,@agreement_date		
				,@to_bank_name			
				,@to_bank_account_name  
				,@to_bank_account_no	
				,@amount				

		while @@fetch_status = 0
		begin

				/* insert into table report */
				insert into dbo.rpt_pending_disbursement
				        ( 
						  user_id 
				          ,report_company 
				          ,report_title 
				          ,report_image 
				          ,filter_from_date
						  ,filter_to_date 
				          ,filter_branch_code 
				          ,agreement_no 
				          ,client_name 
				          ,agreement_date 
				          ,to_bank_name 
				          ,to_bank_account_name 
				          ,to_bank_account_no 
				          ,amount 
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
				          ,@agreement_no
				          ,@client_name 
				          ,@agreement_date 
				          ,@to_bank_name 
				          ,@to_bank_account_name
				          ,@to_bank_account_no
				          ,@amount
				          ,@p_cre_by			
						  ,@p_cre_date		
						  ,@p_cre_ip_address	
						  ,@p_mod_by									 
						  ,@p_mod_date		
						  ,@p_mod_ip_address	
				        )

		/* fetch record berikutnya */
		fetch	c_pending
		into	@agreement_no	
				,@client_name			
				,@agreement_date		
				,@to_bank_name			
				,@to_bank_account_name  
				,@to_bank_account_no	
				,@amount

		end		
		
		/* tutup cursor */
		close		c_pending
		deallocate	c_pending

		if not exists (select * from dbo.rpt_pending_disbursement where user_id = @p_user_id)
		begin

				insert into dbo.rpt_pending_disbursement
				        ( 
						  user_id 
				          ,report_company 
				          ,report_title 
				          ,report_image 
				          ,filter_from_date
						  ,filter_to_date 
				          ,filter_branch_code 
				          ,agreement_no 
				          ,client_name 
				          ,agreement_date 
				          ,to_bank_name 
				          ,to_bank_account_name 
				          ,to_bank_account_no 
				          ,amount 
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
				          ,'none'
				          ,'' 
				          ,isnull(@agreement_date,'') 
				          ,'' 
				          ,''
				          ,''
				          ,0
				          ,@p_cre_by			
						  ,@p_cre_date		
						  ,@p_cre_ip_address	
						  ,@p_mod_by								 
						  ,@p_mod_date		
						  ,@p_mod_ip_address	
				        )
		end

end
