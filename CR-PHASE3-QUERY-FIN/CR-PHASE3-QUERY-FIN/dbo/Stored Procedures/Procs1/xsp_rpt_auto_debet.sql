CREATE PROCEDURE dbo.xsp_rpt_auto_debet
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
		delete	dbo.rpt_auto_debet	
		where	user_id = @p_user_id

		declare @report_company			nvarchar(250)
				,@report_title			nvarchar(250)
				,@report_image			nvarchar(250) 
				,@agreement_no			nvarchar(50)
				,@client_name			nvarchar(250)
				,@due_date				datetime
				,@bank_name				nvarchar(50)
				,@bank_account_name		nvarchar(50)
				,@bank_account_no		nvarchar(50) 
				,@installment_amount	decimal(18,2)
				,@status_posting		nvarchar(50)
				,@tanggal_posting_bank  datetime
				,@keterangan			nvarchar(4000)
				--
                ,@branch_bank_code		nvarchar(50)

		set	@report_title = 'Report Auto Debet'	

		select	@report_company = value 
		from	dbo.sys_global_param
		where	code = 'COMP2'			
	 
		select	@report_image = value 
		from	dbo.sys_global_param
		where	code = 'IMGDSF'

		/* declare main cursor */
		declare c_auto_debet cursor local fast_forward read_only for 
		select	am.agreement_external_no
				,isnull(am.client_name,'-')
				,ct.cashier_value_date
				,isnull(ct.branch_bank_name,'-')
				,isnull(ct.cashier_orig_amount,0)
				,isnull(ct.cashier_status,'-')
				,ct.cashier_value_date
				,isnull(ct.cashier_remarks,'-')
				,isnull(ct.branch_bank_code,'-')
		from	dbo.cashier_transaction ct with(nolock)
				inner join dbo.agreement_main am with(nolock) on (am.agreement_no = ct.agreement_no)
		where	cast(ct.cashier_trx_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
		and		(ct.branch_code = @p_branch_code or @p_branch_code = 'ALL')
		and		ct.cashier_type = 'AUTODEBIT'
		and		ct.cashier_status = 'PAID'

		/* fetch record */
		open	c_auto_debet
		fetch	c_auto_debet
		into	@agreement_no				
				,@client_name			
				,@due_date					
				,@bank_account_name		
				,@installment_amount	
				,@status_posting		
				,@tanggal_posting_bank  
				,@keterangan	
				,@branch_bank_code		

		while @@fetch_status = 0
		begin

				select	@bank_name				= isnull(sb.description,'-')
						,@bank_account_no		= isnull(sbb.bank_account_no,'-')
				from	ifinsys.dbo.sys_branch_bank sbb with(nolock)
						inner join ifinsys.dbo.sys_bank sb with(nolock) on (sb.code = sbb.master_bank_code)
				where	sbb.code = @branch_bank_code

				/* insert into table report */
				insert into dbo.rpt_auto_debet
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
				          ,due_date 
				          ,bank_name 
				          ,bank_account_name 
				          ,bank_account_no 
				          ,installment_amount 
				          ,status_posting 
				          ,tanggal_posting_bank 
				          ,keterangan 
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
				          ,@due_date 
				          ,@bank_name
				          ,@bank_account_name 
				          ,@bank_account_no 
				          ,@installment_amount
				          ,@status_posting 
				          ,@tanggal_posting_bank
				          ,@keterangan
				          ,@p_cre_by			
						  ,@p_cre_date		
						  ,@p_cre_ip_address	
						  ,@p_mod_by								 
						  ,@p_mod_date		
						  ,@p_mod_ip_address	
				        )

		/* fetch record berikutnya */
		fetch	c_auto_debet
		into	@agreement_no				
				,@client_name			
				,@due_date				
				,@bank_account_name		
				,@installment_amount	
				,@status_posting		
				,@tanggal_posting_bank  
				,@keterangan
				,@branch_bank_code

		end		
		
		/* tutup cursor */
		close		c_auto_debet
		deallocate	c_auto_debet

		if not exists (select * from dbo.rpt_auto_debet where user_id = @p_user_id)
		begin

				insert into dbo.rpt_auto_debet
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
				          ,due_date 
				          ,bank_name 
				          ,bank_account_name 
				          ,bank_account_no 
				          ,installment_amount 
				          ,status_posting 
				          ,tanggal_posting_bank 
				          ,keterangan 
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
				          ,isnull(@due_date,'')
				          ,''
				          ,'' 
				          ,'' 
				          ,0
				          ,'' 
				          ,isnull(@tanggal_posting_bank,'')
				          ,''
				          ,@p_cre_by			
						  ,@p_cre_date		
						  ,@p_cre_ip_address	
						  ,@p_mod_by								 
						  ,@p_mod_date		
						  ,@p_mod_ip_address	
				        )
		end

end
