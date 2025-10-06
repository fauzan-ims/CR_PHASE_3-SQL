CREATE PROCEDURE dbo.xsp_cashier_main_insert
(
	@p_code						nvarchar(50) output
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_cashier_status			nvarchar(10)
	,@p_cashier_open_date		datetime
	,@p_cashier_innitial_amount	decimal(18, 2) 
	,@p_cashier_open_amount		decimal(18, 2) = 0
	,@p_employee_code			nvarchar(50)
	,@p_employee_name			nvarchar(250)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@year					nvarchar(2)
			,@month					nvarchar(2)
			,@code					nvarchar(50)
			,@code_close			nvarchar(50)
			,@receipt_code			nvarchar(50)
			,@cashier_close_amount	decimal(18,2)
			,@cashier_open_date		datetime
			,@p_id					bigint ;

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		declare @p_unique_code nvarchar(50) ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = @p_branch_code
													,@p_sys_document_code = N''
													,@p_custom_prefix = 'CHR'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'CASHIER_MAIN'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;


		select		top 1 
					@p_cashier_open_amount	= cashier_close_amount
					,@code_close			= code
					,@cashier_open_date		= cashier_open_date
		from		dbo.cashier_main
		where		employee_code = @p_employee_code
					and	cashier_status = 'CLOSE'
					and branch_code = @p_branch_code
		order by	cashier_close_date desc	
					,mod_date desc

		set @cashier_close_amount = @p_cashier_open_amount + isnull(@p_cashier_innitial_amount,0)
		if (@p_cashier_open_date > dbo.xfn_get_system_date()) 
			begin
				set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Date','System Date');
				raiserror(@msg ,16,-1)
			end
		
		if	(@p_cashier_innitial_amount < 0)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_or_equal_than('Innitial Amount','0');
			raiserror(@msg ,16,-1)
		end

		if (@p_cashier_open_date < @cashier_open_date) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_or_equal_than('Date','Previous Open Date');
			raiserror(@msg ,16,-1)
		end

		if  exists (select 1 from dbo.cashier_main where employee_code = @p_employee_code and cashier_status in ('HOLD','OPEN')) 
			begin
				set @msg = 'Cashier already open date';
				raiserror(@msg ,16,-1)
			end

		insert into cashier_main
		(
			code
			,branch_code
			,branch_name
			,cashier_status
			,cashier_open_date
			,cashier_close_date
			,cashier_innitial_amount
			,cashier_open_amount
			,cashier_db_amount
			,cashier_cr_amount
			,cashier_close_amount
			,employee_code
			,employee_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_branch_code
			,@p_branch_name
			,@p_cashier_status
			,@p_cashier_open_date
			,null
			,@p_cashier_innitial_amount
			,isnull(@p_cashier_open_amount,0)
			,0
			,0
			,isnull(@cashier_close_amount,0)
			,@p_employee_code
			,@p_employee_name
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		insert into dbo.cashier_banknote_and_coin
		(
			cashier_code
			,banknote_code
			,quantity
			,total_amount
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@code
				,code
				,0
				,0
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.master_banknote_and_coin
		where	is_active = '1' 
		order by value_amount asc;

		declare cur_cashier_receipt_allocated	cursor fast_forward read_only for
			
			select	receipt_code
			from	dbo.cashier_receipt_allocated cra
					inner join dbo.receipt_main rm on (rm.code = cra.receipt_code)
			where	cra.cashier_code	= @code_close
					and	rm.receipt_status	= 'NEW'
					and	isnull(rm.cashier_code,'') = ''

			open cur_cashier_receipt_allocated
		
			fetch next from cur_cashier_receipt_allocated 
			into	@receipt_code

			while @@fetch_status = 0
			begin
				
				exec dbo.xsp_cashier_receipt_allocated_insert @p_id					= 0
															  ,@p_cashier_code		= @code
															  ,@p_receipt_code		= @receipt_code
															  ,@p_cre_date			= @p_cre_date		
															  ,@p_cre_by			= @p_cre_by			
															  ,@p_cre_ip_address	= @p_cre_ip_address	
															  ,@p_mod_date			= @p_mod_date		
															  ,@p_mod_by			= @p_mod_by			
															  ,@p_mod_ip_address	= @p_mod_ip_address	
				
				
				 
				update	dbo.receipt_main
				set		cashier_code	= @code
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	code			= @receipt_code

				fetch next from cur_cashier_receipt_allocated 
				into	@receipt_code
			
			end
			close cur_cashier_receipt_allocated
			deallocate cur_cashier_receipt_allocated

		--insert dbo.cashier_receipt_allocated
		--(
		--	cashier_code
		--	,receipt_code
		--	,receipt_status
		--	,receipt_use_date
		--	,receipt_use_trx_code
		--	,cre_date
		--	,cre_by
		--	,cre_ip_address
		--	,mod_date
		--	,mod_by
		--	,mod_ip_address
		--)
		--select	@code
		--		,cra.receipt_code
		--		,cra.receipt_status
		--		,cra.receipt_use_date
		--		,cra.receipt_use_trx_code
		--		,@p_cre_date
		--		,@p_cre_by
		--		,@p_cre_ip_address
		--		,@p_mod_date
		--		,@p_mod_by
		--		,@p_mod_ip_address
		--from	dbo.cashier_receipt_allocated cra
		--		inner join dbo.receipt_main rm on (rm.code = cra.receipt_code)
		--where	cra.cashier_code = @code_close
		--		and cra.receipt_status = 'NEW'
		--		and isnull(rm.cashier_code,'') = ''
		--		--and rm.code in (select crad.receipt_code from dbo.cashier_receipt_allocated crad where crad.cashier_code = @code_close);

		set @p_code = @code ;
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
end ;
