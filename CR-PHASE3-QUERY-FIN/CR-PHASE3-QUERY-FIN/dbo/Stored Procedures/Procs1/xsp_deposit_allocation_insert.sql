CREATE PROCEDURE dbo.xsp_deposit_allocation_insert
(
	@p_code						 nvarchar(50)	output
	,@p_branch_code				 nvarchar(50)
	,@p_branch_name				 nvarchar(250)
	--,@p_cashier_code			 nvarchar(50)	= ''
	,@p_allocation_status		 nvarchar(10)
	,@p_allocation_trx_date		 datetime = null
	,@p_allocation_value_date	 datetime
	,@p_allocation_orig_amount	 decimal(18, 2) = 0
	,@p_allocation_currency_code nvarchar(3)
	,@p_allocation_exch_rate	 decimal(18, 6)
	,@p_allocation_base_amount	 decimal(18, 2) = 0
	,@p_allocationt_remarks		 nvarchar(4000)
	,@p_agreement_no			 nvarchar(50)
	,@p_deposit_code			 nvarchar(50)
	,@p_deposit_type			 nvarchar(15)
	,@p_deposit_amount			 decimal(18, 2)
	,@p_deposit_gl_link_code	 nvarchar(50) = null
	,@p_is_received_request		 nvarchar(1)
	--,@p_reversal_code			 nvarchar(50)
	--,@p_reversal_date			 datetime
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@transaction_code		nvarchar(50) 
			,@transaction_name		nvarchar(250) 
			,@year					nvarchar(2)
			,@month					nvarchar(2)
			,@deposit_type			nvarchar(15)
			,@code					nvarchar(50) 
			,@status				nvarchar(20);

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'DAN'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'DEPOSIT_ALLOCATION'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	--if @p_is_received_request = 'T'
	--	set @p_is_received_request = '1' ;
	--else
	--	set @p_is_received_request = '0' ;
	
	if(@p_deposit_type = 'INSTALLMENT')
	begin
	    select	@p_deposit_gl_link_code = gl_link_code 
		from	dbo.master_transaction
		where	code = 'DPINST'
	end  
	else if(@p_deposit_type = 'INSURANCE')
	begin
	    select	@p_deposit_gl_link_code = gl_link_code 
		from	dbo.master_transaction
		where	code = 'DPINSI'
	end  
	else
	begin
	    select	@p_deposit_gl_link_code = gl_link_code 
		from	dbo.master_transaction
		where	code = 'DPOTH'
	end 
	 
	begin try
		set @p_allocation_trx_date = dbo.xfn_get_system_date();
		
		if (@p_allocation_value_date > dbo.xfn_get_system_date()) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Value Date','System Date');
			raiserror(@msg ,16,-1)
		end

		if (isnull(@p_deposit_code, '') <> '')
		begin
			set @status = dbo.xfn_get_status(@p_deposit_code)
		end

		if @status is not null
		begin
			set @msg = 'This deposit already used in ' + @status;
			raiserror(@msg, 16, -1) ;
		end

		insert into deposit_allocation
		(
			code
			,branch_code
			,branch_name
			--,cashier_code
			,allocation_status
			,allocation_trx_date
			,allocation_value_date
			,allocation_orig_amount
			,allocation_currency_code
			,allocation_exch_rate
			,allocation_base_amount
			,allocationt_remarks
			,agreement_no
			,deposit_gl_link_code
			,deposit_code
			,deposit_type
			,deposit_amount
			,is_received_request
			,reversal_code
			,reversal_date
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
			--,@p_cashier_code
			,@p_allocation_status
			,@p_allocation_trx_date
			,@p_allocation_value_date
			,@p_allocation_orig_amount
			,@p_allocation_currency_code
			,@p_allocation_exch_rate
			,@p_allocation_base_amount
			,@p_allocationt_remarks
			,@p_agreement_no
			,@p_deposit_gl_link_code
			,@p_deposit_code
			,@p_deposit_type
			,@p_deposit_amount
			,@p_is_received_request
			,null
			,null
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

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

