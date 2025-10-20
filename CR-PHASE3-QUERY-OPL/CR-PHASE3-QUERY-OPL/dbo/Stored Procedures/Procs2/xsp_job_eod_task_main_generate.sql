/*
exec xsp_job_eod_task_main_generate
*/
-- Louis Jumat, 17 Februari 2023 16.03.50 -- 
CREATE PROCEDURE dbo.xsp_job_eod_task_main_generate
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
			,@payment_promise_date			 datetime
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
				,ind.marketing_code
				,ind.marketing_name
				,isnull(ind.client_name,inv.client_name)		-- ambil client name dr top 1 agreement, karna tulisan client name banyak yang beda tp 1 code
		from	dbo.invoice inv
				outer apply (	select	top 1 am.marketing_name, am.marketing_code, am.client_name
								from	dbo.invoice_detail invd 
										inner join dbo.agreement_main am on am.agreement_no = invd.agreement_no
								where	am.client_no = inv.client_no
								order by am.agreement_date desc
							) ind
		where	inv.invoice_status = 'POST'
		and		cast(inv.invoice_due_date as date) < cast(@system_date as date)
		and		inv.client_no not in (select client_no from dbo.task_main where desk_status in ('NEW','HOLD') or cast(task_date as date) = cast(@system_date as date))
		and		inv.client_no not in (select client_no from dbo.deskcoll_main where cast(result_promise_date as date) = cast(@system_date as date) and desk_status = 'POST')

		open	c_main
		fetch	c_main
		into	@client_no
				,@deskcoll_staff_code
				,@deskcoll_staff_name
				,@client_name

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
				,@deskcoll_staff_code
				,@deskcoll_staff_name
				,@client_name


		end
        close c_main
		deallocate c_main
		
		-- insert untuk tab Promise
		declare cursor_name cursor fast_forward read_only for
		select	a.client_no
				,a.client_name
				,b.result_promise_date
				,a.desk_collector_code
				,a.deskcoll_staff_name
		from	dbo.task_main				 a
				inner join dbo.deskcoll_main b on a.deskcoll_main_id = b.id
		where	a.desk_status = 'POST'
		and		isnull(b.result_promise_date,'') <> ''
		and		cast(b.result_promise_date as date) = cast(@system_date as date)
		and		a.client_no not in (select client_no from dbo.task_main where desk_status IN ('NEW','HOLD') or cast(task_date as date) = cast(@system_date as date))
		and		a.client_no not in (select client_no from dbo.deskcoll_main where desk_status IN ('NEW','HOLD') or cast(task_date as date) = cast(@system_date as date))

		open cursor_name
		fetch next from cursor_name 
		into @client_no
			,@client_name
			,@payment_promise_date
			,@deskcoll_staff_code
			,@deskcoll_staff_name
		
		while @@fetch_status = 0
		begin
			if(@payment_promise_date = @system_date)
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
												,@p_promise_date				= @payment_promise_date
					
			end
		    
		
		    fetch next from cursor_name 
			into @client_no
				,@client_name
				,@payment_promise_date
				,@deskcoll_staff_code
				,@deskcoll_staff_name
		end
		
		close cursor_name
		deallocate cursor_name

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