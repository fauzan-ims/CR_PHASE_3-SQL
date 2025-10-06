CREATE PROCEDURE dbo.xsp_rpt_invoice_allocation
(
	@p_user_id				nvarchar(50)
	,@p_agreement_no		nvarchar(50)
)
as
begin

	delete	dbo.rpt_invoice_allocation
	where	user_id = @p_user_id

	declare		@report_company					 nvarchar(250)
			    ,@report_title					 nvarchar(250)
			    ,@report_image					 nvarchar(250)
				,@filter_date					 datetime
			    ,@received_no					 nvarchar(50)
			    ,@received_date					 datetime
			    ,@received_type					 nvarchar(250)
			    ,@received_from					 nvarchar(250)
			    ,@received_amount				 decimal(18,2)
			    ,@branch_name					 nvarchar(250)
			    ,@agreement_no				     nvarchar(50)
			    ,@plafond_name				     nvarchar(250)
			    ,@client_name					 nvarchar(250)
			    ,@remark						 nvarchar(4000)
			    ,@customer_name					 nvarchar(250)
			    ,@invoice_no					 nvarchar(50)
			    ,@invoice_date					 datetime
			    ,@invoice_due_date				 datetime
			    ,@invoice_net_amount			 decimal(18,2)
			    ,@invoice_balance_amount		 decimal(18,2)
			    ,@allocation_amount				 decimal(18,2)
                --
				,@datetimenow					 datetime


		set	@report_title = 'Invoice Allocation'

		set @datetimeNow = getdate();

		select	@report_company = value 
		from	dbo.sys_global_param
		where	code = 'COMP2'				
	 
		select	@report_image = value 
		from	dbo.sys_global_param
		where	code = 'IMGDSF'

		declare c_invoice_allocation cursor local fast_forward read_only for
		select  cti.invoice_date
				,isnull(ct.received_request_code,'-')
				,isnull(crr.request_date,'')
				,isnull(ct.received_from,'-')
				,isnull(cti.customer_name,'-')
				,isnull(ct.received_amount,0)
				,isnull(ct.branch_name,'-')
				,isnull(ct.agreement_no,'-')
				,''
				,isnull(am.client_name,'-')
				,isnull(ct.cashier_remarks,'-')
				,isnull(cti.customer_name,'-')
				,isnull(cti.invoice_no,'-')
				,cti.invoice_date
				,cti.invoice_due_date
				,isnull(cti.invoice_net_amount,0)
				,isnull(cti.invoice_balance_amount,0)
				,isnull(cti.allocation_amount,0)
		from	dbo.cashier_transaction_invoice cti with(nolock) 
				inner join dbo.cashier_transaction ct with(nolock) on (ct.code = cti.cashier_transaction_code)
				left join dbo.cashier_received_request crr with(nolock) on (crr.code = ct.received_request_code)
				left join dbo.agreement_main am with(nolock) on (am.agreement_no = ct.agreement_no)
		where	ct.agreement_no = @p_agreement_no

		open	c_invoice_allocation
		fetch   c_invoice_allocation
		into	@filter_date
				,@received_no	
				,@received_date	
				,@received_type	
				,@received_from	
				,@received_amount
				,@branch_name	
				,@agreement_no	
				,@plafond_name	
				,@client_name	
				,@remark		
				,@customer_name	
				,@invoice_no			
				,@invoice_date			
				,@invoice_due_date		
				,@invoice_net_amount	
				,@invoice_balance_amount
				,@allocation_amount						
				

		while @@fetch_status = 0
		begin 

			/*insert into table*/
			insert into dbo.rpt_invoice_allocation
			        ( 
					  user_id 
			          ,report_company 
			          ,report_title 
			          ,report_image 
			          ,filter_date 
			          ,received_no 
			          ,received_date 
			          ,received_type 
			          ,received_from 
			          ,received_amount 
			          ,branch_name 
			          ,agreement_no 
			          ,plafond_name 
			          ,client_name 
			          ,remark 
			          ,customer_name 
			          ,invoice_no 
			          ,invoice_date 
			          ,invoice_due_date 
			          ,invoice_net_amount 
			          ,invoice_balance_amount 
			          ,allocation_amount 
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
			          ,@filter_date 
			          ,@received_no 
			          ,@received_date
			          ,@received_type
			          ,@received_from
			          ,@received_amount
			          ,@branch_name 
			          ,@agreement_no
			          ,@plafond_name
			          ,@client_name 
			          ,@remark 
			          ,@customer_name
			          ,@invoice_no
			          ,@invoice_date
			          ,@invoice_due_date 
			          ,@invoice_net_amount 
			          ,@invoice_balance_amount 
			          ,@allocation_amount
			          ,@datetimenow
			          ,@p_user_id
					  ,'127.0.0.1'
					  ,@datetimenow
					  ,@p_user_id 							 
					  ,'127.0.0.1'
			        )

		fetch   c_invoice_allocation
		into	@filter_date
				,@received_no	
				,@received_date	
				,@received_type	
				,@received_from	
				,@received_amount
				,@branch_name	
				,@agreement_no	
				,@plafond_name	
				,@client_name	
				,@remark		
				,@customer_name	
				,@invoice_no			
				,@invoice_date			
				,@invoice_due_date		
				,@invoice_net_amount	
				,@invoice_balance_amount
				,@allocation_amount						

		end
  
		close	 c_invoice_allocation
		deallocate	c_invoice_allocation 
		
		if not exists (select * from dbo.rpt_invoice_allocation where user_id = @p_user_id)
		begin

				insert into dbo.rpt_invoice_allocation
			        ( 
					  user_id 
			          ,report_company 
			          ,report_title 
			          ,report_image 
			          ,filter_date 
			          ,received_no 
			          ,received_date 
			          ,received_type 
			          ,received_from 
			          ,received_amount 
			          ,branch_name 
			          ,agreement_no 
			          ,plafond_name 
			          ,client_name 
			          ,remark 
			          ,customer_name 
			          ,invoice_no 
			          ,invoice_date 
			          ,invoice_due_date 
			          ,invoice_net_amount 
			          ,invoice_balance_amount 
			          ,allocation_amount 
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
			          ,isnull(@filter_date,'') 
			          ,'' 
			          ,isnull(@received_date,'')
			          ,''
			          ,''
			          ,0
			          ,'' 
			          ,''
			          ,''
			          ,'' 
			          ,'' 
			          ,''
			          ,''
			          ,isnull(@invoice_date,'')
			          ,isnull(@invoice_due_date,'')
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
