CREATE PROCEDURE dbo.xsp_reconcile_main_refresh
(
	@p_code					nvarchar(50)
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
	declare @msg							nvarchar(max) 
			,@branch_code					nvarchar(50)
			,@bank_gl_link_code				nvarchar(50)
			,@reff_no						nvarchar(50)
			,@source_reff_code				nvarchar(50)
			,@source_reff_name				nvarchar(250)
			,@balance_amount				decimal(18, 2)
			,@reconcile_to_value_date		datetime
			,@value_date					datetime
			,@reconcile_from_value_date		datetime
			,@cashier_remark				nvarchar(4000)
			,@payment_remark				nvarchar(4000)
			,@client_name					nvarchar(250)
			,@reconcile_remark				nvarchar(4000)
			,@remark						nvarchar(4000)
			,@agreement_external_no			nvarchar(50);

	select	@branch_code				= branch_code						
			,@reconcile_from_value_date	= reconcile_from_value_date
			,@reconcile_to_value_date	= reconcile_to_value_date
			,@bank_gl_link_code			= bank_gl_link_code 
	from	dbo.reconcile_main
	where	code	= @p_code

	begin try
		
		delete reconcile_transaction
		where	reconcile_code = @p_code
				and is_system  = '1' ;

		update	dbo.reconcile_main
		set		system_amount = 0
		where	code = @p_code;

		declare cur_bank_mutation_history cursor fast_forward read_only for
			
		select	bmh.orig_amount
				,bmh.source_reff_name
				,bmh.source_reff_code
				,bmh.value_date
				,isnull(ct.reff_no,'')
				,bmh.remarks --cashier_remarks
				,am.client_name
				,pt.payment_remarks
				,am.agreement_external_no
		from	dbo.bank_mutation_history bmh 
				inner join dbo.bank_mutation bm on (bm.code = bmh.bank_mutation_code)
				left join dbo.cashier_transaction ct on (ct.code = bmh.source_reff_code)
				left join dbo.agreement_main am on (am.agreement_no = ct.agreement_no)
				left join dbo.payment_transaction pt on (pt.CODE = bmh.source_reff_code)
		where	bm.branch_code			= @branch_code
				and	bm.gl_link_code		= @bank_gl_link_code	
				and	bmh.is_reconcile	= '0'
				and bmh.value_date between 	@reconcile_from_value_date and @reconcile_to_value_date
		ORDER BY bmh.ID asc

		open cur_bank_mutation_history
		
		fetch next from cur_bank_mutation_history 
		into	@balance_amount
				,@source_reff_name
				,@source_reff_code
				,@value_date
				,@reff_no
				,@cashier_remark
				,@client_name
				,@payment_remark
				,@agreement_external_no

		while @@fetch_status = 0
		begin
			

			set	@remark = isnull(@client_name, '') + ' ' + isnull(@agreement_external_no, '') + ' ' + isnull(@cashier_remark, @payment_remark)

			exec dbo.xsp_reconcile_transaction_insert @p_id							= 0
													  ,@p_reconcile_code			= @p_code
													  ,@p_transaction_source		= @source_reff_name --ini isi reff_name pada bmh
													  ,@p_transaction_no			= @source_reff_code -- ini ambil dari reff_code pada bmh
													  ,@p_transaction_reff_no		= @reff_no -- isi dengan @reff_no
													  ,@p_transaction_value_date	= @value_date
													  ,@p_transaction_amount		= @balance_amount
													  ,@p_is_system					= N'T' 
													  ,@p_is_reconcile				= N'F'
													  ,@p_remark					= @remark
													  ,@p_cre_date					= @p_cre_date		
													  ,@p_cre_by					= @p_cre_by			
													  ,@p_cre_ip_address			= @p_cre_ip_address
													  ,@p_mod_date					= @p_mod_date		
													  ,@p_mod_by					= @p_mod_by			
													  ,@p_mod_ip_address			= @p_mod_ip_address
			

		fetch next from cur_bank_mutation_history 
			into	@balance_amount
					,@source_reff_name
					,@source_reff_code
					,@value_date
					,@reff_no
					,@cashier_remark
					,@client_name
					,@payment_remark
					,@agreement_external_no

		end
		close cur_bank_mutation_history
		deallocate cur_bank_mutation_history

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
