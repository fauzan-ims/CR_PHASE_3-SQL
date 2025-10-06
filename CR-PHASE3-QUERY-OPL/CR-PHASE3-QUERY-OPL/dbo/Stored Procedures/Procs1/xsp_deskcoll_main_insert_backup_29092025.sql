CREATE PROCEDURE dbo.xsp_deskcoll_main_insert_backup_29092025
(
	@p_id							   bigint = 0 output
	,@p_id_task_main				   bigint 
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

	begin try
		
			insert into deskcoll_main
			(
				client_no
				,client_name
				,desk_date
				,desk_collector_code
				,deskcoll_staff_name
				,desk_status
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	client_no
					,client_name
					,task_date
					,desk_collector_code
					,deskcoll_staff_name
					,'HOLD'
					,@p_cre_date		
					,@p_cre_by			
					,@p_cre_ip_address	
					,@p_mod_date		
					,@p_mod_by			
					,@p_mod_ip_address	
			from	dbo.task_main
			where	id = @p_id_task_main
	
			set		@p_id = @@identity ;

			update	dbo.task_main 
			set		deskcoll_main_id = @p_id 
					,desk_status	 = 'HOLD'
			where	id				 = @p_id_task_main


		declare @client_no					nvarchar(50)
				,@invoice_no				nvarchar(50)
				,@invoice_type				nvarchar(50)
				,@max_ovd					bigint
				,@max_billing_date			datetime
				,@max_billing_due_date		datetime
                ,@billing_amount			decimal(18,2)		
				,@ppn_amount				decimal(18,2)	
				,@pph_amount				decimal(18,2)	
				

		select	@client_no = client_no
		from	dbo.task_main 
		where	id				 = @p_id_task_main

		declare curr_inv cursor fast_forward read_only for
		select	inv.invoice_no
				,inv.invoice_type 
				,datediff(day,cast(inv.invoice_due_date as date), cast(dbo.xfn_get_system_date() as date))
				,inv.invoice_date
				,inv.invoice_due_date
				--
				,inv.total_billing_amount
				,inv.total_ppn_amount
				,inv.total_pph_amount
		from	dbo.invoice inv
		where	inv.invoice_status = 'post'
		and		cast(inv.invoice_due_date as date) < cast(dbo.xfn_get_system_date() as date)
		and		inv.client_no = @client_no

		open curr_inv
		fetch next from curr_inv 
		into @invoice_no
			,@invoice_type
			,@max_ovd
			,@max_billing_date
			,@max_billing_due_date
			--
			,@billing_amount			
			,@ppn_amount				
			,@pph_amount				
		
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
												 ,@p_billing_amount			= @billing_amount
												 ,@p_ppn_amount				= @ppn_amount	
												 ,@p_pph_amount				= @pph_amount	
												 ,@p_os_billing_amount		= @billing_amount
												 ,@p_os_ppn_amount			= @ppn_amount	
												 ,@p_os_pph_amount			= @pph_amount	
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
				,@max_ovd
				,@max_billing_date
				,@max_billing_due_date
				--
				,@billing_amount			
				,@ppn_amount				
				,@pph_amount	
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
