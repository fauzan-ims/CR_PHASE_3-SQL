/*
exec xsp_job_eod_task_main_generate
*/
-- Louis Jumat, 17 Februari 2023 16.03.50 -- 
CREATE PROCEDURE dbo.xsp_job_eod_task_main_generate_backup_29092025
as
begin

	declare @msg							 nvarchar(max)
			--
			,@id							 bigint
			,@agreement_no					 nvarchar(50)
			,@overdue_days					 int
			,@overdue_penalty_amount		 decimal(18, 2)
			,@overdue_installment_amount	 decimal(18, 2)
			,@outstanding_installment_amount decimal(18, 2)
			,@outstanding_deposit_amount	 decimal(18, 2)
			,@overdue_period				 int
			,@installment_due_date			 datetime
			,@last_paid_installment_no		 int
			,@payment_promise_date			 DATETIME
            --
			,@client_no						 nvarchar(50)
			,@client_name					 nvarchar(250)
			,@deskcoll_staff_code			 nvarchar(50)
			,@deskcoll_staff_name			 nvarchar(250)
			--
			,@system_date					 datetime	  = dbo.xfn_get_system_date()
			,@mod_date						 datetime	  = getdate()
			,@mod_by						 nvarchar(15) = 'EOD'
			,@mod_ip_address				 nvarchar(15) = 'SYSTEM' ;

	BEGIN TRY

		declare c_main	cursor local fast_forward for
		select	distinct inv.client_no
				,inv.client_name
				,ind.marketing_code
				,ind.marketing_name
		from	dbo.invoice inv
				outer apply (	select	top 1 am.marketing_name, am.marketing_code 
								from	dbo.invoice_detail invd 
										inner join dbo.agreement_main am on am.agreement_no = invd.agreement_no
								where	invd.invoice_no = inv.invoice_no
								order by am.agreement_date desc
							) ind
		where	inv.invoice_status = 'post'
		and		cast(inv.invoice_due_date as date) < cast(@system_date as date)
		and		inv.client_no not in (select client_no from dbo.task_main where desk_status IN ('NEW','HOLD'))

		open	c_main
		fetch	c_main
		into	@client_no
				,@client_name
				,@deskcoll_staff_code
				,@deskcoll_staff_name

		while @@fetch_status = 0
		begin
			
			exec dbo.xsp_task_main_insert @p_id								= 0
											,@p_task_date					= @system_date
											,@p_desk_collector_code			= @deskcoll_staff_code
											,@p_desk_collector_name			= @deskcoll_staff_name
											,@p_client_no					= @client_no
											,@p_client_name					= @client_name
											,@p_cre_date					= @mod_date			
											,@p_cre_by						= @mod_by			
											,@p_cre_ip_address				= @mod_ip_address	
											,@p_mod_date					= @mod_date			
											,@p_mod_by						= @mod_by			
											,@p_mod_ip_address				= @mod_ip_address
			

		fetch	c_main
		into	@client_no
				,@client_name
				,@deskcoll_staff_code
				,@deskcoll_staff_name

		end
        close c_main
		deallocate c_main

		
		--declare cursor_name cursor fast_forward read_only for
		--select	b.client_no
		--		,b.client_name
		--		,b.result_promise_date
		--from	dbo.task_main				 a
		--		inner join dbo.deskcoll_main b on a.deskcoll_main_id = b.id
		--where	a.desk_status = 'POST'
		--and isnull(b.result_promise_date,'') <> ''
		--open cursor_name
		
		--fetch next from cursor_name 
		--into @client_no
		--	,@client_name
		--	,@payment_promise_date
		
		--while @@fetch_status = 0
		--begin
		--	if(@payment_promise_date = dbo.xfn_get_system_date())
		--	begin
				
		--			exec dbo.xsp_task_main_insert @p_id									= 0
		--										  ,@p_task_date							= @system_date
		--										  ,@p_desk_collector_code				= ''
		--										  ,@p_deskcoll_main_id					= null
		--										  ,@p_field_collector_code				= null
		--										  ,@p_fieldcoll_main_code				= null
		--										  ,@p_agreement_no						= ''
		--										  ,@p_last_paid_installment_no			= ''
		--										  ,@p_installment_due_date				= null
		--										  ,@p_overdue_period					= 0
		--										  ,@p_overdue_days						= 0
		--										  ,@p_overdue_penalty_amount			= 0
		--										  ,@p_overdue_installment_amount		= 0
		--										  ,@p_outstanding_installment_amount	= 0
		--										  ,@p_outstanding_deposit_amount		= 0
		--										  ,@p_client_no							= @client_no
		--										  ,@p_client_name						= @client_name
		--										  ,@p_promise_date						= @payment_promise_date
		--										  ,@p_cre_date							= @mod_date			
		--										  ,@p_cre_by							= @mod_by			
		--										  ,@p_cre_ip_address					= @mod_ip_address	
		--										  ,@p_mod_date							= @mod_date			
		--										  ,@p_mod_by							= @mod_by			
		--										  ,@p_mod_ip_address					= @mod_ip_address
		--	end
		    
		
		--    fetch next from cursor_name 
		--	into @client_no
		--		,@client_name
		--		,@payment_promise_date
		--end
		
		--close cursor_name
		--deallocate cursor_name

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
end  
