CREATE PROCEDURE dbo.xsp_payment_request_proceed
(
	@p_code						 NVARCHAR(50)
	,@p_date_flag				 DATETIME	 = NULL
	--
	,@p_mod_date				 DATETIME
	,@p_mod_by					 NVARCHAR(15)
	,@p_mod_ip_address			 NVARCHAR(15)
)
AS
BEGIN
	declare @msg							nvarchar(max)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@code							nvarchar(50)
			,@payment_date					datetime
			,@payment_amount				decimal(18,2)
			,@payment_remark				nvarchar(4000)
			,@payment_source_no				nvarchar(50)
			,@orig_amount					decimal(18,2)
			,@to_bank_name					nvarchar(250)
			,@to_bank_account_name			nvarchar(50)
			,@to_bank_account_no			nvarchar(50)
			,@remark						nvarchar(4000)
			,@remarks						nvarchar(4000)
			,@payment_source				nvarchar(50)
			,@payment_to					nvarchar(250)
			

	begin try
		select @branch_code		= value
				,@branch_name	= description
		from dbo.sys_global_param
		where code = 'HO'

		select	@branch_code			= branch_code
				,@branch_name			= branch_name
				,@payment_date			= payment_request_date
				,@payment_amount		= payment_amount
				,@payment_remark		= ISNULL(payment_remarks,'')
				,@payment_source_no		= payment_source_no
				,@to_bank_account_name	= to_bank_account_name
				,@to_bank_account_no	= to_bank_account_no
				,@to_bank_name			= to_bank_name
				,@payment_source		= payment_source
				,@payment_to			= payment_to
		from dbo.payment_request 
		where code = @p_code

		if(right(@payment_amount,2) <> '00')
		BEGIN
			set @msg = 'Nominal is not allowed for process.' ;
			raiserror(@msg, 16, -1) ;
        end
		
		if exists(select 1 from dbo.payment_transaction where to_bank_account_no = @to_bank_account_no and to_bank_account_name = @to_bank_account_name and to_bank_name = @to_bank_name and payment_status = 'HOLD')
		begin
			select @code = code 
			from dbo.payment_transaction
			where to_bank_account_no = @to_bank_account_no and to_bank_account_name = @to_bank_account_name and to_bank_name = @to_bank_name and payment_status = 'HOLD'
		end
		else
		--if not exists (select 1 from dbo.payment_transaction where date_flag = @p_date_flag)
		begin
			exec dbo.xsp_payment_transaction_insert @p_code							= @code	output
													,@p_branch_code					= @branch_code
													,@p_branch_name					= @branch_name
													,@p_payment_transaction_date	= @p_mod_date--@payment_date
													,@p_payment_amount				= 0
													,@p_remark						= @payment_remark
													,@p_payment_status				= 'HOLD'
													,@p_to_bank_name				= @to_bank_name
													,@p_to_bank_account_no			= @to_bank_account_no
													,@p_to_bank_account_name		= @to_bank_account_name
													,@p_date_flag					= @p_date_flag
													,@p_cre_date					= @p_mod_date		
													,@p_cre_by						= @p_mod_by			
													,@p_cre_ip_address				= @p_mod_ip_address	
													,@p_mod_date					= @p_mod_date		
													,@p_mod_by						= @p_mod_by			
													,@p_mod_ip_address				= @p_mod_ip_address	
			
		end
		--else
		--begin
		--	select @code = code 
		--	from dbo.payment_transaction
		--	where date_flag = @p_date_flag
		--end
	
		exec dbo.xsp_payment_transaction_detail_insert @p_id							= 0
													   ,@p_payment_transaction_code		= @code
													   ,@p_payment_request_code			= @p_code
													   ,@p_orig_curr_code				= 'IDR'
													   ,@p_orig_amount					= @payment_amount
													   ,@p_exch_rate					= 1
													   ,@p_base_amount					= @payment_amount
													   ,@p_tax_amount					= 0
													   ,@p_cre_date						= @p_mod_date		
													   ,@p_cre_by						= @p_mod_by			
													   ,@p_cre_ip_address				= @p_mod_ip_address	
													   ,@p_mod_date						= @p_mod_date		
													   ,@p_mod_by						= @p_mod_by			
													   ,@p_mod_ip_address				= @p_mod_ip_address


		select @orig_amount = sum(orig_amount) 
		from dbo.payment_transaction_detail
		where payment_transaction_code =  @code

		if(@payment_source = 'WORK ORDER')
		begin

			select	@remark = stuff((
					  select	distinct
								',' + ISNULL(wo.invoice_no,'') + ' - ' + avh.plat_no
					  from		dbo.payment_transaction					  ptr
								inner join dbo.payment_transaction_detail ptrd on (ptr.code		 = ptrd.payment_transaction_code)
								inner join dbo.payment_request			  pr on (pr.code		 = ptrd.payment_request_code)
								inner join dbo.work_order				  wo on (wo.code		 = pr.payment_source_no)
								inner join dbo.maintenance				  mnt on (mnt.code		 = wo.maintenance_code)
								inner join dbo.asset_vehicle			  avh on (mnt.asset_code = avh.asset_code)
					  where		ptr.code = @code
					  for xml path('')
				  ), 1, 1, ''
				 ) ;

			set @remarks = 'Payment work order for : ' + @remark
		end
		else if (@payment_source = 'REALIZATION FOR PUBLIC SERVICE')
		begin
			select	@remark = stuff((
					  select	distinct
								', ' + avh.plat_no
					  from		dbo.payment_transaction					  ptr
								inner join dbo.payment_transaction_detail ptrd on (ptr.code		 = ptrd.payment_transaction_code)
								inner join dbo.payment_request			  pr on (pr.code		 = ptrd.payment_request_code)
								inner join dbo.register_main rmn on (rmn.code collate latin1_general_ci_as = pr.payment_source_no)
								inner join dbo.asset_vehicle			  avh on (rmn.fa_code = avh.asset_code)
					  where		ptr.code = @code
					  for xml path('')
				  ), 1, 1, ''
				 ) ;

			set @remarks = 'Payment Realization public service for : ' + @payment_to + ' - '  + @remark
		end
		else if (@payment_source = 'DP ORDER PUBLIC SERVICE')
		begin
			select	@remark = stuff((
					  select	distinct
								', ' + avh.plat_no
					  from		dbo.payment_transaction					  ptr
								inner join dbo.payment_transaction_detail ptrd on (ptr.code		 = ptrd.payment_transaction_code)
								inner join dbo.payment_request			  pr on (pr.code		 = ptrd.payment_request_code)
								inner join dbo.order_main om on (om.code collate latin1_general_ci_as = pr.payment_source_no)
								inner join dbo.order_detail od on (od.order_code = om.code)
								inner join dbo.register_main rmn on (rmn.code collate latin1_general_ci_as = od.register_code)
								inner join dbo.asset_vehicle			  avh on (rmn.fa_code = avh.asset_code)
					  where		ptr.code = @code
					  for xml path('')
				  ), 1, 1, ''
				 ) ;

			set @remarks = 'Payment DP order to bureau for : ' + @payment_to + ' - ' + @remark
		end
		else if (@payment_source = 'POLICY')
		begin
			select	@remark = stuff((
					  select	distinct
								', ' + ipm.policy_no
					  from		dbo.payment_transaction					  ptr
								inner join dbo.payment_transaction_detail ptrd on (ptr.code		 = ptrd.payment_transaction_code)
								inner join dbo.payment_request			  pr on (pr.code		 = ptrd.payment_request_code)
								inner join dbo.insurance_policy_main ipm on (ipm.code = pr.payment_source_no)
								--inner join dbo.insurance_policy_asset ipa on (ipm.code = ipa.policy_code)
								--inner join dbo.asset_vehicle			  avh on (ipa.fa_code = avh.asset_code)
					  where		ptr.code = @code
					  for xml path('')
				  ), 1, 1, ''
				 ) ;

			set @remarks = 'Payment policy insurance for : ' + ISNULL(@payment_to,'') + ' - '  + ISNULL(@remark,'')
		end

		update dbo.payment_transaction
		set		payment_amount	= @orig_amount
				,remark			= ISNULL(@remarks,'')
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @code ;

		if exists(select 1 from dbo.payment_request where code = @p_code and payment_status = 'HOLD')
		begin
			update	dbo.payment_request
			set		payment_status		= 'POST'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code ;
		end
		else
		begin
			set @msg = 'Data already Proceed.' ;
			raiserror(@msg, 16, -1) ;
		end ;

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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

