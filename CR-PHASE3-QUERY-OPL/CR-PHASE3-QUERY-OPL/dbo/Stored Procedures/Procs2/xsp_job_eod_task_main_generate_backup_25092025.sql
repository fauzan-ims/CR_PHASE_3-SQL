/*
exec xsp_job_eod_task_main_generate
*/
-- Louis Jumat, 17 Februari 2023 16.03.50 -- 
CREATE PROCEDURE dbo.xsp_job_eod_task_main_generate_backup_25092025
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
			,@deskcoll_staff_code			 nvarchar(50)
			,@payment_promise_date			 datetime
			,@client_no						 nvarchar(50)
			,@client_name					 nvarchar(250)
			--
			,@system_date					 datetime	  = dbo.xfn_get_system_date()
			,@mod_date						 datetime	  = getdate()
			,@mod_by						 nvarchar(15) = 'EOD'
			,@mod_ip_address				 NVARCHAR(15) = 'SYSTEM' ;

	BEGIN TRY
		
		-- insert ke history
		INSERT INTO dbo.task_history
		(
			task_date
			,desk_collector_code
			,deskcoll_main_id
			,field_collector_code
			,fieldcoll_main_code
			,agreement_no
			,last_paid_installment_no
			,installment_due_date
			,overdue_period
			,overdue_days
			,overdue_penalty_amount
			,overdue_installment_amount
			,outstanding_installment_amount
			,outstanding_deposit_amount
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	task_date
				,desk_collector_code
				,deskcoll_main_id
				,field_collector_code
				,fieldcoll_main_code
				,agreement_no
				,last_paid_installment_no
				,isnull(installment_due_date, null)
				,overdue_period
				,overdue_days
				,overdue_penalty_amount
				,overdue_installment_amount
				,outstanding_installment_amount
				,outstanding_deposit_amount
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
		from	dbo.task_main ;
		
		--delete	dbo.task_main

		declare c_main	cursor local fast_forward for
        -- ambil semua kontrak yang tidak ada janji bayar, jika janji bayar ambil yang sudah lewat
select		max(ai.agreement_no) agreement_no
				,max(ai.ovd_days) ovd_days
				,max(ai.ovd_penalty_amount) ovd_penalty_amount
				,max(ai.ovd_rental_amount) ovd_rental_amount
				,max(ai.os_rental_amount) os_rental_amount
				,max(ai.os_deposit_installment_amount) os_deposit_installment_amount
				,max(ai.ovd_period) ovd_period
				,max(ai.installment_due_date) installment_due_date
				,max(ai.last_paid_period) last_paid_period
				,max(ai.deskcoll_staff_code) deskcoll_staff_code
				,max(ai.payment_promise_date)
				,am.client_no
				,max(am.client_name) client_name
		from	dbo.agreement_information ai
				inner join dbo.agreement_main am on (am.agreement_no = ai.agreement_no)
				inner join dbo.master_facility mf on (mf.code		 = am.facility_code)
		where	am.agreement_status							  = 'GO LIVE'
				and ai.os_rental_amount						  > ai.os_deposit_installment_amount -- hanya kontrak yang memiliki nilai outstanding_installment besar dari nilai deposit nya
				and (
						cast(ai.payment_promise_date as date) <= cast(@system_date as date)
						or	ai.payment_promise_date is null
					) -- exclude yang janji bayar, task nya di generate saat janji nya sudah due
				and ai.ovd_days
				between mf.deskcoll_min * -1 and mf.deskcoll_max
				and exists
		(
			select	1
			from	dbo.agreement_invoice
			where	agreement_no = ai.agreement_no
		) 
		group by am.CLIENT_NO;


		open	c_main
		fetch	c_main
		into	@agreement_no
				,@overdue_days
				,@overdue_penalty_amount
				,@overdue_installment_amount
				,@outstanding_installment_amount
				,@outstanding_deposit_amount
				,@overdue_period
				,@installment_due_date
				,@last_paid_installment_no
				,@deskcoll_staff_code
				,@payment_promise_date
				,@client_no
				,@client_name

		while @@fetch_status = 0
		BEGIN
			
			--if (@payment_promise_date is not null) -- baca select dari cursor
			--begin
			--	update	dbo.agreement_main 
			--	set		payment_promise_date = null
			--	where	agreement_no = @agreement_no
			--end

			--if not exists (select 1 from dbo.task_main where client_no = @client_no and desk_status <> 'POST')
			begin
				exec dbo.xsp_task_main_insert @p_id									= 0
										  ,@p_task_date							= @system_date
										  ,@p_desk_collector_code				= @deskcoll_staff_code
										  ,@p_deskcoll_main_id					= null
										  ,@p_field_collector_code				= null
										  ,@p_fieldcoll_main_code				= null
										  ,@p_agreement_no						= @agreement_no
										  ,@p_last_paid_installment_no			= @last_paid_installment_no
										  ,@p_installment_due_date				= @installment_due_date
										  ,@p_overdue_period					= @overdue_period
										  ,@p_overdue_days						= @overdue_days
										  ,@p_overdue_penalty_amount			= @overdue_penalty_amount
										  ,@p_overdue_installment_amount		= @overdue_installment_amount
										  ,@p_outstanding_installment_amount	= @outstanding_installment_amount
										  ,@p_outstanding_deposit_amount		= @outstanding_deposit_amount
										  ,@p_client_no							= @client_no
										  ,@p_client_name						= @client_name
										  ,@p_promise_date						= null
										  ,@p_cre_date							= @mod_date			
										  ,@p_cre_by							= @mod_by			
										  ,@p_cre_ip_address					= @mod_ip_address	
										  ,@p_mod_date							= @mod_date			
										  ,@p_mod_by							= @mod_by			
										  ,@p_mod_ip_address					= @mod_ip_address
			end
			

			fetch	c_main
			into	@agreement_no
					,@overdue_days
					,@overdue_penalty_amount
					,@overdue_installment_amount
					,@outstanding_installment_amount
					,@outstanding_deposit_amount
					,@overdue_period
					,@installment_due_date
					,@last_paid_installment_no
					,@deskcoll_staff_code
					,@payment_promise_date
					,@client_no
					,@client_name

		end
        close c_main
		deallocate c_main

		
		declare cursor_name cursor fast_forward read_only for
		select	b.client_no
				,b.client_name
				,b.result_promise_date
		from	dbo.task_main				 a
				inner join dbo.deskcoll_main b on a.deskcoll_main_id = b.id
		where	a.desk_status = 'POST'
		and isnull(b.result_promise_date,'') <> ''
		open cursor_name
		
		fetch next from cursor_name 
		into @client_no
			,@client_name
			,@payment_promise_date
		
		while @@fetch_status = 0
		begin
			if(@payment_promise_date = dbo.xfn_get_system_date())
			begin
				
					exec dbo.xsp_task_main_insert @p_id									= 0
												  ,@p_task_date							= @system_date
												  ,@p_desk_collector_code				= ''
												  ,@p_deskcoll_main_id					= null
												  ,@p_field_collector_code				= null
												  ,@p_fieldcoll_main_code				= null
												  ,@p_agreement_no						= ''
												  ,@p_last_paid_installment_no			= ''
												  ,@p_installment_due_date				= null
												  ,@p_overdue_period					= 0
												  ,@p_overdue_days						= 0
												  ,@p_overdue_penalty_amount			= 0
												  ,@p_overdue_installment_amount		= 0
												  ,@p_outstanding_installment_amount	= 0
												  ,@p_outstanding_deposit_amount		= 0
												  ,@p_client_no							= @client_no
												  ,@p_client_name						= @client_name
												  ,@p_promise_date						= @payment_promise_date
												  ,@p_cre_date							= @mod_date			
												  ,@p_cre_by							= @mod_by			
												  ,@p_cre_ip_address					= @mod_ip_address	
												  ,@p_mod_date							= @mod_date			
												  ,@p_mod_by							= @mod_by			
												  ,@p_mod_ip_address					= @mod_ip_address
			end
		    
		
		    fetch next from cursor_name 
			into @client_no
				,@client_name
				,@payment_promise_date
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
