CREATE PROCEDURE dbo.xsp_rpt_received_voucher
(
	@p_user_id				nvarchar(50)
	,@p_rv_no				nvarchar(50)
	--
	,@p_cre_by				nvarchar(15)
	,@p_cre_date			datetime
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_by				nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_ip_address		nvarchar(15)
)
as
begin

	delete	dbo.rpt_received_voucher
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
			    ,@received_from			nvarchar(50)
			    ,@in_base_curr			nvarchar(3)
			    ,@allocation			nvarchar(250)
			    ,@currency				nvarchar(3)
			    ,@orig_amount			decimal(18,2)
			    ,@rate_orig				decimal(18,2)
			    ,@base_amount			decimal(18,2)
			    ,@department			nvarchar(250)
                --
				,@datetimenow			datetime
                ,@branch_bank_code		nvarchar(50)


		set	@report_title = 'Received Voucher'

		set @datetimeNow = getdate();

		SELECT	@report_company = value 
		FROM	dbo.sys_global_param
		WHERE	code = 'COMP2'				
	 
		SELECT	@report_image = value 
		FROM	dbo.sys_global_param
		WHERE	code = 'IMGDSF'

		DECLARE c_received_voucher CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
		SELECT  rv.code
				,ISNULL(rv.received_orig_amount,0)
				,ISNULL(rv.received_exch_rate,0)
				,rv.received_transaction_date
				,rv.received_value_date
				,ISNULL(rv.received_from,'-')
				--,ISNULL(rv.received_orig_currency_code,'-')
				,ISNULL(gl.GL_LINK_NAME,'-')
				,ISNULL(rvd.orig_currency_code,'-')
				,ISNULL(rvd.orig_amount,0)
				,ISNULL(rvd.exch_rate,0)
				,ISNULL(rvd.base_amount,0)
				,ISNULL(rvd.department_name,'-')
				,ISNULL(rv.branch_bank_code,'-')
		FROM	dbo.received_voucher rv WITH(NOLOCK) 
				INNER JOIN dbo.received_voucher_detail rvd WITH(NOLOCK) ON (rvd.received_voucher_code = rv.code)
				INNER JOIN dbo.journal_gl_link gl ON (gl.code=rvd.gl_link_code)
		WHERE	rv.code = @p_rv_no

		OPEN	c_received_voucher
		FETCH   c_received_voucher
		INTO	@voucher_no		
				,@amount			
				,@rate				
				,@transaction_date	
				,@value_date		
				,@received_from			
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


			select	@bank_name				= sbb.BANK_ACCOUNT_NO + ' - '+ sbb.BANK_ACCOUNT_NAME  + ' - '+  ISNULL(sb.description,'-')
			from	ifinsys.dbo.sys_branch_bank sbb with(nolock)
					inner join ifinsys.dbo.sys_bank sb with(nolock) on (sb.code = sbb.master_bank_code)
			where	sbb.code = @branch_bank_code

			select @in_base_curr = code
			from ifinsys.dbo.sys_currency 
			where base_currency ='1'

			/*insert into table*/
			insert into dbo.rpt_received_voucher
			        ( 
					  user_id 
					  ,rv_no
			          ,report_company 
			          ,report_title 
			          ,report_image 
			          ,voucher_no 
			          ,bank_name 
			          ,amount 
			          ,rate 
			          ,transaction_date 
			          ,value_date 
			          ,received_from 
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
					  ,@p_rv_no
			          ,@report_company
			          ,@report_title
			          ,@report_image
			          ,@voucher_no 
			          ,@bank_name 
			          ,@amount 
			          ,@rate 
			          ,@transaction_date 
			          ,@value_date 
			          ,@received_from
			          ,@in_base_curr 
			          ,@allocation 
			          ,@currency 
			          ,@orig_amount
			          ,@rate_orig 
			          ,@base_amount
			          ,@department 
			          ,@p_cre_by			
					  ,@p_cre_date		
					  ,@p_cre_ip_address	
					  ,@p_mod_by			
					  ,@p_mod_date		
					  ,@p_mod_ip_address
			        )

		fetch   c_received_voucher
		into	@voucher_no		
				,@amount			
				,@rate				
				,@transaction_date	
				,@value_date		
				,@received_from			
				--,@in_base_curr		
				,@allocation		
				,@currency			
				,@orig_amount		
				,@rate_orig			
				,@base_amount		
				,@department
				,@branch_bank_code

		end
  
		close	 c_received_voucher
		deallocate	c_received_voucher 
		
		if not exists (select * from dbo.rpt_received_voucher where user_id = @p_user_id)
		begin

				insert into dbo.rpt_received_voucher
			        ( 
					  user_id 
					  ,rv_no
			          ,report_company 
			          ,report_title 
			          ,report_image 
			          ,voucher_no 
			          ,bank_name 
			          ,amount 
			          ,rate 
			          ,transaction_date 
			          ,value_date 
			          ,received_from 
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
					  ,@p_rv_no
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
			          ,@p_cre_by			
					  ,@p_cre_date		
					  ,@p_cre_ip_address	
					  ,@p_mod_by			
					  ,@p_mod_date		
					  ,@p_mod_ip_address	
			        )

		end

end
