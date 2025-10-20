CREATE PROCEDURE dbo.xsp_deskcoll_main_insert
(
	@p_id							   bigint = 0 output
	,@p_id_task_main				   bigint 
	--,@p_desk_date					   datetime
	--,@p_desk_collector_code			   nvarchar(50)
	--,@p_agreement_no				   nvarchar(50)
	--,@p_last_paid_installment_no	   nvarchar(50)
	--,@p_installment_due_date		   datetime
	--,@p_overdue_period				   int
	--,@p_overdue_days				   int
	--,@p_overdue_penalty_amount		   decimal(18, 2)
	--,@p_overdue_installment_amount	   decimal(18, 2)
	--,@p_outstanding_installment_amount decimal(18, 2)
	--,@p_outstanding_deposit_amount	   decimal(18, 2)
	--,@p_result_code					   nvarchar(50)
	--,@p_result_detail_code			   nvarchar(50)
	--,@p_result_remarks				   nvarchar(400)
	--,@p_result_promise_date			   datetime
	--
	,@p_cre_date					   datetime
	,@p_cre_by						   nvarchar(15)
	,@p_cre_ip_address				   nvarchar(15)
	,@p_mod_date					   datetime
	,@p_mod_by						   nvarchar(15)
	,@p_mod_ip_address				   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@p_desk_date					   datetime
			,@p_desk_collector_code			   nvarchar(50)
			,@p_agreement_no				   nvarchar(50)
			,@p_last_paid_installment_no	   nvarchar(50)
			,@p_installment_due_date		   datetime
			,@p_overdue_period				   int
			,@p_overdue_days				   int
			,@p_overdue_penalty_amount		   decimal(18, 2)
			,@p_overdue_installment_amount	   decimal(18, 2)
			,@p_outstanding_installment_amount decimal(18, 2)
			,@p_outstanding_deposit_amount	   decimal(18, 2)
			,@p_client_no						nvarchar(50)
			,@p_client_name						nvarchar(250)
			,@invoice_no						nvarchar(50)
			,@max_billing_date					datetime
			,@max_billing_due_date				datetime
			,@max_ovd							int
			,@invoice_type						nvarchar(50)
			,@total_billing_amount				decimal(18,2)
			,@total_ppn_amount					decimal(18,2)
			,@total_pph_amount					decimal(18,2)
			,@total_asset_no					int
			,@total_agreement_no				int
			,@total_monthly_rental				decimal(18,2)
			,@promise_date						datetime
            ,@deskcoll_staff_name				nvarchar(250)

	select	@p_desk_date						= task_date
			,@p_desk_collector_code				= desk_collector_code
			,@p_agreement_no					= agreement_no
			,@p_last_paid_installment_no		= last_paid_installment_no
			,@p_installment_due_date			= installment_due_date
			,@p_overdue_period					= overdue_period
			,@p_overdue_days					= overdue_days
			,@p_overdue_penalty_amount			= overdue_penalty_amount
			,@p_overdue_installment_amount		= overdue_installment_amount
			,@p_outstanding_installment_amount  = outstanding_installment_amount
			,@p_outstanding_deposit_amount		= outstanding_deposit_amount
			,@p_client_no						= client_no
			,@p_client_name						= client_name
			,@promise_date						= promise_date
			,@deskcoll_staff_name				= deskcoll_staff_name
	from	dbo.task_main
	where	id									= @p_id_task_main;

	begin try
		
			insert into deskcoll_main
			(
				desk_date
				,desk_collector_code
				,agreement_no
				,last_paid_installment_no
				,installment_due_date
				,overdue_period
				,overdue_days
				,overdue_penalty_amount
				,overdue_installment_amount
				,outstanding_installment_amount
				,outstanding_deposit_amount
				,desk_status
				,client_no
				,client_name
				,result_promise_date
				,deskcoll_staff_name
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@p_desk_date
				,@p_cre_by--@p_desk_collector_code
				,''
				,@p_last_paid_installment_no
				,@p_installment_due_date
				,@p_overdue_period
				,@p_overdue_days
				,@p_overdue_penalty_amount
				,@p_overdue_installment_amount
				,@p_outstanding_installment_amount
				,@p_outstanding_deposit_amount
				,'HOLD'
				,@p_client_no
				,@p_client_name
				,@promise_date
				,@deskcoll_staff_name
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;
	
			set		@p_id = @@identity ;

			update	dbo.task_main 
			set		deskcoll_main_id = @p_id 
					,desk_status	 = 'HOLD'
			where	id				 = @p_id_task_main

		
		declare curr_inv cursor fast_forward read_only for

		select	inv.invoice_no
				,inv.invoice_type
				,inv.new_invoice_date
				,inv.invoice_due_date
				,datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
		from	dbo.invoice inv
		where	inv.invoice_status = 'POST'
		and		inv.client_no = @p_client_no

		open curr_inv
		
		fetch next from curr_inv 
		into @invoice_no
			,@invoice_type
			,@max_billing_date
			,@max_billing_due_date
			,@max_ovd
		
		while @@fetch_status = 0
		begin
			
			exec dbo.xsp_deskcoll_invoice_insert @p_id						= 0
												 ,@p_deskcoll_main_id		= @p_id
												 ,@p_invoice_no				= @invoice_no
												 ,@p_invoice_type			= @invoice_type
												 ,@p_ovd_days				= @max_ovd
												 ,@p_billing_date			= @max_billing_date
												 ,@p_new_billing_date		= null
												 ,@p_billing_due_date		= @max_billing_due_date
												 ,@p_billing_amount			= 0
												 ,@p_ppn_amount				= 0
												 ,@p_pph_amount				= 0
												 ,@p_os_billing_amount		= 0
												 ,@p_os_ppn_amount			= 0
												 ,@p_os_pph_amount			= 0
												 ,@p_result_code			= ''
												 ,@p_remark					= ''
												 ,@p_cre_date				= @p_cre_date
												 ,@p_cre_by					= @p_cre_by
												 ,@p_cre_ip_address			= @p_cre_ip_address
												 ,@p_mod_date				= @p_mod_date
												 ,@p_mod_by					= @p_mod_by
												 ,@p_mod_ip_address			= @p_mod_ip_address
			
		    		
		    fetch next from curr_inv 
			into @invoice_no
				,@invoice_type
				,@max_billing_date
				,@max_billing_due_date
				,@max_ovd
		end
      
		
	end try
	Begin catch
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
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
end ;