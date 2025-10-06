CREATE PROCEDURE dbo.xsp_suspend_merger_reversal
(
	@p_code				nvarchar(50)
	--,@p_approval_reff		nvarchar(250)
	--,@p_approval_remark	nvarchar(4000)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg						nvarchar(max)
			,@suspend_code				nvarchar(50)
			,@first_suspend_no			nvarchar(50)
			,@merger_currency_code		nvarchar(3)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@suspend_amount			decimal(18, 2)
			,@amount					decimal(18, 2)
			,@merger_date				datetime
			,@index						bigint

	begin try
	
		if exists (select 1 from dbo.suspend_merger where code = @p_code and merger_status <> 'POST')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			
		--	CEK DULU SALDO SUSPEND NYA TIDAK  BERUBAH
			declare cur_suspend_merger_detail cursor fast_forward read_only for
			
			select	suspend_code
					,suspend_amount
			from	dbo.suspend_merger_detail
			where	suspend_merger_code = @p_code

			open cur_suspend_merger_detail
		
			fetch next from cur_suspend_merger_detail 
			into	@suspend_code
					,@suspend_amount

			while @@fetch_status = 0
			begin

				--if ((select remaining_amount from dbo.suspend_main where code = @suspend_code) <> @suspend_amount)
				--begin
				--	close cur_suspend_merger_detail
				--	deallocate cur_suspend_merger_detail
				--	set @msg = 'Please re-select Suspend NO '+ @suspend_code +', because amount already change';
				--	raiserror(@msg ,16,-1)
				--end

				fetch next from cur_suspend_merger_detail 
				into	@suspend_code
						,@suspend_amount
			
			end
			close cur_suspend_merger_detail
			deallocate cur_suspend_merger_detail
	
		--	MENGABUNGKAN 1 SUSPEND NO
			declare cur_suspend_merger_detail cursor fast_forward read_only for
			
			select	smd.suspend_code
					,smd.suspend_amount
					,sm.branch_code
					,sm.branch_name
					,sm.merger_date
					,sm.merger_currency_code
					,row_number() over(order by id asc) as row#
			from	dbo.suspend_merger_detail smd
					inner join dbo.suspend_merger sm on (sm.code = smd.suspend_merger_code)
			where	suspend_merger_code = @p_code

			open cur_suspend_merger_detail
		
			fetch next from cur_suspend_merger_detail 
			into	@suspend_code
					,@suspend_amount
					,@branch_code
					,@branch_name
					,@merger_date
					,@merger_currency_code
					,@index

			while @@fetch_status = 0
			begin

				if (@index = 1)
				begin
					set @first_suspend_no = @suspend_code
					if (
							(select suspend_amount from dbo.suspend_main where code = @first_suspend_no) < 
							(select sum(suspend_amount) from dbo.suspend_merger_detail where suspend_merger_code = @p_code)
						)
					begin
						close cur_suspend_merger_detail
						deallocate cur_suspend_merger_detail
						set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Total Suspend Amount','Suspend Amount');
						raiserror(@msg ,16,-1)
					end
				end
				else
				begin

				--- MENAMBAHKAN SUSPEND YANG SEDANG DILOOPING
				    update	dbo.suspend_main
					set		used_amount						= used_amount - @suspend_amount
							,remaining_amount				= remaining_amount + @suspend_amount
							,mod_date						= @p_mod_date
							,mod_by							= @p_mod_by
							,mod_ip_address					= @p_mod_ip_address
					where	code							= @suspend_code
					
					set @amount = abs(@suspend_amount);
					exec dbo.xsp_suspend_history_insert @p_id					= 0
														,@p_branch_code			= @branch_code
														,@p_branch_name			= @branch_name
														,@p_suspend_code		= @suspend_code
														,@p_transaction_date	= @p_cre_date
														,@p_orig_amount			= @amount
														,@p_orig_currency_code	= @merger_currency_code
														,@p_exch_rate			= 1
														,@p_base_amount			= @amount
														,@p_agreement_no		= null
														,@p_source_reff_code	= @p_code
														,@p_source_reff_name	= N'Suspend Merger'
														,@p_cre_date			= @p_cre_date		
														,@p_cre_by				= @p_cre_by			
														,@p_cre_ip_address		= @p_cre_ip_address
														,@p_mod_date			= @p_mod_date		
														,@p_mod_by				= @p_mod_by			
														,@p_mod_ip_address		= @p_mod_ip_address

				---	MENGURANGI KE NOMOR SUSPEND YANG PERTAMA
					update	dbo.suspend_main
					set		suspend_amount					= suspend_amount - @suspend_amount
							,remaining_amount				= remaining_amount - @suspend_amount
							,mod_date						= @p_mod_date
							,mod_by							= @p_mod_by
							,mod_ip_address					= @p_mod_ip_address
					where	code							= @first_suspend_no
					
					set @amount = @suspend_amount * -1;
					exec dbo.xsp_suspend_history_insert @p_id					= 0
														,@p_branch_code			= @branch_code
														,@p_branch_name			= @branch_name
														,@p_suspend_code		= @first_suspend_no
														,@p_transaction_date	= @merger_date
														,@p_orig_amount			= @amount
														,@p_orig_currency_code	= @merger_currency_code
														,@p_exch_rate			= 1
														,@p_base_amount			= 0
														,@p_agreement_no		= null
														,@p_source_reff_code	= @p_code
														,@p_source_reff_name	= N'Suspend Merger'
														,@p_cre_date			= @p_cre_date		
														,@p_cre_by				= @p_cre_by			
														,@p_cre_ip_address		= @p_cre_ip_address
														,@p_mod_date			= @p_mod_date		
														,@p_mod_by				= @p_mod_by			
														,@p_mod_ip_address		= @p_mod_ip_address
				
					update	dbo.suspend_main
					set		suspend_amount		= suspend_amount + @suspend_amount
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @suspend_code
				end

				fetch next from cur_suspend_merger_detail 
				into	@suspend_code
						,@suspend_amount
						,@branch_code
						,@branch_name
						,@merger_date
						,@merger_currency_code
						,@index
			
			end
			close cur_suspend_merger_detail
			deallocate cur_suspend_merger_detail

			update	dbo.suspend_merger
			set		merger_status		= 'REVERSE'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code
		end
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
