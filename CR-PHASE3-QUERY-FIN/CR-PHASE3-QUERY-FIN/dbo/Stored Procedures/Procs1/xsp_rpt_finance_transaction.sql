CREATE PROCEDURE dbo.xsp_rpt_finance_transaction
(
	@p_user_id				nvarchar(50) 	
	,@p_transaction_type	nvarchar(50)
	,@p_gl_link_code		nvarchar(50)
	,@p_gl_link_name		nvarchar(50)
	,@p_from_date			datetime
	,@p_to_date				datetime
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(50)
	,@p_is_condition		nvarchar(1)
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
		delete	dbo.rpt_finance_transaction	
		where	user_id = @p_user_id

		declare @report_company			nvarchar(250)
				,@report_title			nvarchar(250)
				,@report_image			nvarchar(250) 
				,@date					datetime
				,@transaction_no		nvarchar(50)
				,@description			nvarchar(50)
				,@agreement_no			nvarchar(50)
				,@currency				nvarchar(3)
				,@rate					decimal(18,6)
				,@orig_amount			decimal(18,2)
				,@base_amounnt			decimal(18,2)
				,@filter_gl_link_name	nvarchar(250)
				,@branch_name			nvarchar(50)
				,@client_name			nvarchar(250)
				--
				,@datetimeNow			datetime
                ,@msg					nvarchar(max)

begin try

		if (@p_from_date > @p_to_date)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('From Date','To Date') ;

			raiserror(@msg, 16, -1) ;
		end

		set	@report_title = 'Report Finance Transaction'		

		set @datetimeNow = getdate();

		select	@report_company = value 
		from	dbo.sys_global_param
		where	code = 'COMP2'				
	 
		select	@report_image = value 
		from	dbo.sys_global_param
		where	code = 'IMGDSF'

		
			IF (@p_transaction_type ='PAYMENT VOUCHER')
			BEGIN
				/* declare main cursor */
				declare c_payment cursor local fast_forward read_only for 
				select	pv.payment_transaction_date
						,pv.code
						,isnull(pv.payment_remarks,'-')
						,'-'
						,isnull(pv.payment_orig_currency_code,'-')
						,isnull(pv.payment_exch_rate,0)
						,case when isnull(rrd.orig_amount_db,0) = 0 then isnull(rrd.orig_amount_cr,0) * -1 else isnull(rrd.orig_amount_db,0) end
						,case when isnull(rrd.base_amount_db,0) = 0 then isnull(rrd.base_amount_cr,0) * -1 else isnull(rrd.base_amount_db,0) end
						,rrd.gl_link_code--isnull(jgl.gl_link_name,rrd.gl_link_code)
						,pv.branch_name
				from	dbo.payment_voucher pv with(nolock)
						inner join dbo.fin_interface_journal_gl_link_transaction rtd on (rtd.transaction_code = pv.code)
						inner join dbo.fin_interface_journal_gl_link_transaction_detail rrd on (rrd.gl_link_transaction_code=rtd. code)
						--left join dbo.journal_gl_link jgl on (jgl.code=rrd.gl_link_code)
				where	cast(pv.payment_transaction_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
				and		(pv.branch_code = @p_branch_code or @p_branch_code = 'all')
				and		(pv.branch_gl_link_code = @p_gl_link_code or @p_gl_link_code = 'all')
				and		pv.payment_status ='PAID'
				--and		pv.branch_gl_link_code = @p_gl_link_code
			
				union
				select	pv.payment_transaction_date
						,pv.code
						,isnull(pv.payment_remarks,'-')
						,'-'
						,isnull(pv.payment_orig_currency_code,'-')
						,isnull(pv.payment_exch_rate,0)
						,case when isnull(rrd.orig_amount_db,0) = 0 then isnull(rrd.orig_amount_cr,0) * -1 else isnull(rrd.orig_amount_db,0) end
						,case when isnull(rrd.base_amount_db,0) = 0 then isnull(rrd.base_amount_cr,0) * -1 else isnull(rrd.base_amount_db,0) end
						,rrd.gl_link_code--isnull(jgl.gl_link_name,rrd.gl_link_code)
						,pv.branch_name
				from	dbo.payment_transaction pv with(nolock)
						inner join dbo.fin_interface_journal_gl_link_transaction rtd on (rtd.transaction_code = pv.code)
						inner join dbo.fin_interface_journal_gl_link_transaction_detail rrd on (rrd.gl_link_transaction_code=rtd. code)
						--left join dbo.journal_gl_link jgl with(nolock) on (jgl.code = rrd.gl_link_code)
				where	cast(pv.payment_transaction_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
				and		(pv.branch_code = @p_branch_code or @p_branch_code = 'ALL')
				and		(pv.bank_gl_link_code = @p_gl_link_code or @p_gl_link_code = 'all')
				and		pv.payment_status ='PAID' 
				--and		pv.bank_gl_link_code = @p_gl_link_code
			end
			else
			begin
				/* declare main cursor */
				declare c_payment cursor local fast_forward read_only for 
				select	rv.received_transaction_date
						,rv.code
						,isnull(rv.received_remarks,'-')
						,'-'
						,isnull(rv.received_orig_currency_code,'-')
						,isnull(rv.received_exch_rate,0)
						,case when isnull(rrd.orig_amount_db,0) = 0 then isnull(rrd.orig_amount_cr,0) * -1 else isnull(rrd.orig_amount_db,0) end
						,case when isnull(rrd.base_amount_db,0) = 0 then isnull(rrd.base_amount_cr,0) * -1 else isnull(rrd.base_amount_db,0) end
						,rrd.gl_link_code--isnull(jgl.gl_link_name,rrd.gl_link_code)
						,rv.branch_name
				from	dbo.received_voucher rv with(nolock)
						inner join dbo.fin_interface_journal_gl_link_transaction rtd on (rtd.transaction_code = rv.code)
						inner join dbo.fin_interface_journal_gl_link_transaction_detail rrd on (rrd.gl_link_transaction_code=rtd. code)
						--left join dbo.journal_gl_link jgl on (jgl.code=rrd.gl_link_code)
				where	cast(rv.received_transaction_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
				and		(rv.branch_code = @p_branch_code or @p_branch_code = 'all')
				and		(rv.branch_gl_link_code = @p_gl_link_code or @p_gl_link_code = 'all')
				and		rv.received_status ='PAID'

				union
				select	rv.received_transaction_date
						,rv.code
						,isnull(rv.received_remarks,'-')
						,'-'
						,isnull(rv.received_orig_currency_code,'-')
						,isnull(rv.received_exch_rate,0)
						,case when isnull(rrd.orig_amount_db,0) = 0 then isnull(rrd.orig_amount_cr,0) * -1 else isnull(rrd.orig_amount_db,0) end
						,case when isnull(rrd.base_amount_db,0) = 0 then isnull(rrd.base_amount_cr,0) * -1 else isnull(rrd.base_amount_db,0) end
						,rrd.gl_link_code--isnull(jgl.gl_link_name,rrd.gl_link_code)
						,rv.branch_name
				from	dbo.received_transaction rv with(nolock)
						inner join dbo.fin_interface_journal_gl_link_transaction rtd on (rtd.transaction_code = rv.code)
						inner join dbo.fin_interface_journal_gl_link_transaction_detail rrd on (rrd.gl_link_transaction_code=rtd. code)
						--left join dbo.journal_gl_link jgl with(nolock) on (jgl.code = rrd.gl_link_code)
				where	cast(rv.received_transaction_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
				and		(rv.branch_code = @p_branch_code or @p_branch_code = 'all')
				and		(rv.bank_gl_link_code = @p_gl_link_code or @p_gl_link_code = 'all')
				and		rv.received_status ='PAID'

					
				union
                
				select	rv.cashier_trx_date
						,rv.code
						,isnull(rv.cashier_remarks,'-')
						,isnull(rv.agreement_no,'-')
						,isnull(rv.cashier_currency_code,'-')
						,isnull(rv.cashier_exch_rate,0)
						,case when isnull(rrd.orig_amount_db,0) = 0 then isnull(rrd.orig_amount_cr,0) * -1 else isnull(rrd.orig_amount_db,0) end
						,case when isnull(rrd.base_amount_db,0) = 0 then isnull(rrd.base_amount_cr,0) * -1 else isnull(rrd.base_amount_db,0) end
						,rrd.gl_link_code--isnull(jgl.gl_link_name,rrd.gl_link_code)
						,rv.branch_name
				from	dbo.cashier_transaction rv with(nolock)
						inner join dbo.fin_interface_journal_gl_link_transaction rtd on (rtd.transaction_code = rv.code)
						inner join dbo.fin_interface_journal_gl_link_transaction_detail rrd on (rrd.gl_link_transaction_code=rtd. code)
						--left join dbo.journal_gl_link jgl with(nolock) on (jgl.code = rrd.gl_link_code)
				where	cast(rv.cashier_trx_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
				and		(rv.branch_code = @p_branch_code or @p_branch_code = 'all')
				and		(rv.bank_gl_link_code = @p_gl_link_code or @p_gl_link_code = 'all')
				and		rv.cashier_status ='PAID'

				--union
                
				--select	rv.allocation_trx_date
				--		,rv.code
				--		,isnull(rv.allocationt_remarks,'-')
				--		,isnull(rv.agreement_no,'-')
				--		,isnull(rv.allocation_currency_code,'-')
				--		,isnull(rv.allocation_exch_rate,0)
				--		,case when isnull(rrd.orig_amount_db,0) = 0 then isnull(rrd.orig_amount_cr,0) * -1 else isnull(rrd.orig_amount_db,0) end
				--		,case when isnull(rrd.base_amount_db,0) = 0 then isnull(rrd.base_amount_cr,0) * -1 else isnull(rrd.base_amount_db,0) end
				--		,isnull(jgl.gl_link_name,rrd.gl_link_code)
				--		,rv.branch_name
				--from	dbo.deposit_allocation rv with(nolock)
				--		inner join dbo.fin_interface_journal_gl_link_transaction rtd on (rtd.transaction_code = rv.code)
				--		inner join dbo.fin_interface_journal_gl_link_transaction_detail rrd on (rrd.gl_link_transaction_code=rtd. code)
				--		left join dbo.journal_gl_link jgl with(nolock) on (jgl.code = rrd.gl_link_code)
				--where	cast(rv.allocation_trx_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
				--and		(rv.branch_code = @p_branch_code or @p_branch_code = 'all')
				--and		(rrd.gl_link_code = @p_gl_link_code or @p_gl_link_code = 'all')
				--and		rv.allocation_status ='PAID'

				--union
                
				--select	rv.allocation_trx_date
				--		,rv.code
				--		,isnull(rv.allocationt_remarks,'-')
				--		,isnull(rv.agreement_no,'-')
				--		,isnull(rv.allocation_currency_code,'-')
				--		,isnull(rv.allocation_exch_rate,0)
				--		,case when isnull(rrd.orig_amount_db,0) = 0 then isnull(rrd.orig_amount_cr,0) * -1 else isnull(rrd.orig_amount_db,0) end
				--		,case when isnull(rrd.base_amount_db,0) = 0 then isnull(rrd.base_amount_cr,0) * -1 else isnull(rrd.base_amount_db,0) end
				--		,isnull(jgl.gl_link_name,rrd.gl_link_code)
				--		,rv.branch_name
				--from	dbo.suspend_allocation rv with(nolock)
				--		inner join dbo.fin_interface_journal_gl_link_transaction rtd on (rtd.transaction_code = rv.code)
				--		inner join dbo.fin_interface_journal_gl_link_transaction_detail rrd on (rrd.gl_link_transaction_code=rtd. code)
				--		left join dbo.journal_gl_link jgl with(nolock) on (jgl.code = rrd.gl_link_code)
				--where	cast(rv.allocation_trx_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
				--and		(rv.branch_code = @p_branch_code or @p_branch_code = 'all')
				--and		(rrd.gl_link_code = @p_gl_link_code or @p_gl_link_code = 'all')
				--and		rv.allocation_status ='PAID'
			end
				

			/* fetch record */
			open	c_payment
			fetch	c_payment
			into	@date				
					,@transaction_no
					,@description	
					,@agreement_no	
					,@currency		
					,@rate					
					,@orig_amount	
					,@base_amounnt	
					,@filter_gl_link_name
					,@branch_name

			while @@fetch_status = 0
			begin
			
					/* insert into table report */
					insert into dbo.rpt_finance_transaction
							( 
								user_id 
								,report_company 
								,report_title 
								,report_image 
								,filter_transcation_type 
								,filter_gl_link 
								,filter_gl_link_name
								,filter_from_date 
								,filter_to_date 
								,filter_branch_code 
								,filter_branch_name
								,date 
								,client_name
								,transaction_no 
								,description 
								,agreement_no 
								,currency 
								,rate 
								,orig_amount 
								,base_amounnt 
								,branch_name
								,gl_link_name
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
								,@p_transaction_type
								,@p_gl_link_code
								,@p_gl_link_name
								,@p_from_date
								,@p_to_date
								,@p_branch_code
								,@p_branch_name
								,@date
								,@client_name
								,@transaction_no
								,@description
								,@agreement_no 
								,@currency 
								,@rate 
								,@orig_amount 
								,@base_amounnt
								,@branch_name
								,@filter_gl_link_name
								,@p_is_condition
								,@p_cre_by			
								,@p_cre_date		
								,@p_cre_ip_address	
								,@p_mod_by									 
								,@p_mod_date		
								,@p_mod_ip_address	
							)

			/* fetch record berikutnya */
			fetch	c_payment
			into	@date				
					,@transaction_no
					,@description	
					,@agreement_no	
					,@currency		
					,@rate				
					,@orig_amount	
					,@base_amounnt	
					,@filter_gl_link_name
					,@branch_name

			end		
		
			/* tutup cursor */
			close		c_payment
			deallocate	c_payment
	
        
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


		if not exists (select * from dbo.rpt_finance_transaction where user_id = @p_user_id)
		begin

				insert into dbo.rpt_finance_transaction
				        ( 
						  user_id 
				          ,report_company 
				          ,report_title 
				          ,report_image 
				          ,filter_transcation_type 
				          ,filter_gl_link 
						  ,filter_gl_link_name
				          ,filter_from_date 
				          ,filter_to_date 
				          ,filter_branch_code 
						  ,filter_branch_name
				          ,date 
						  ,client_name
				          ,transaction_no 
				          ,description 
				          ,agreement_no 
				          ,currency 
				          ,rate 
				          ,orig_amount 
				          ,base_amounnt 
						  ,branch_name
						  ,gl_link_name
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
				          ,@p_transaction_type
				          ,@p_gl_link_code
						  ,@p_gl_link_name
				          ,@p_from_date
				          ,@p_to_date
				          ,@p_branch_code
						  ,@p_branch_name
				          ,null
						  ,''
				          ,''
				          ,''
				          ,'' 
				          ,'' 
				          ,null
				          ,null
				          ,NULL
                          ,''
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
