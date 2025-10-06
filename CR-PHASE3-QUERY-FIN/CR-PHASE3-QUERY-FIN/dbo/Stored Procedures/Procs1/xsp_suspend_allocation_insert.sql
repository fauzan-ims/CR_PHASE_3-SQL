CREATE PROCEDURE [dbo].[xsp_suspend_allocation_insert]
(
	@p_code						 nvarchar(50) output
	,@p_branch_code				 nvarchar(50)
	,@p_branch_name				 nvarchar(250)
	--,@p_cashier_code			 nvarchar(50) = ''
	,@p_allocation_status		 nvarchar(10)
	,@p_allocation_trx_date		 datetime = null
	,@p_allocation_value_date	 datetime
	,@p_allocation_orig_amount	 decimal(18, 2)
	,@p_allocation_currency_code nvarchar(3)
	,@p_allocation_exch_rate	 decimal(18, 6)
	,@p_allocation_base_amount	 decimal(18, 2) 
	,@p_allocationt_remarks		 nvarchar(4000)
	,@p_suspend_code			 nvarchar(50)
	,@p_suspend_amount			 decimal(18, 2)
	,@p_agreement_no			 nvarchar(50)
	,@p_suspend_gl_link_code	 nvarchar(50)  = null
	,@p_is_received_request		 nvarchar(1)
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
			,@code					nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'SPA'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'SUSPEND_ALLOCATION'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	--if @p_is_received_request = 'T'
	--	set @p_is_received_request = '1' ;
	--else
	--	set @p_is_received_request = '0' ;

	select	@p_suspend_gl_link_code	= mt.gl_link_code
	from	dbo.master_transaction mt
			inner join dbo.sys_global_param sgp on (sgp.value = mt.code)
	where	sgp.code = 'TRXSPND'

	begin try
		set @p_allocation_trx_date = dbo.xfn_get_system_date();

		if (@p_allocation_value_date > dbo.xfn_get_system_date()) 
				begin
					set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Value Date','System Date');
					raiserror(@msg ,16,-1)
				end
				
		--(+) louis 24/10/2023 penambahan validasi untuk check status suspend 
		if exists
		(
			select	1
			from	dbo.suspend_allocation
			where	agreement_no = @p_agreement_no
					and allocation_status not in
					(
						'APPROVE', 'REVERSE', 'REJECT', 'CANCEL'
					)
		)
		begin
			select	top 1 @transaction_code = code
					,@transaction_name = 'ALLOCATION'
			from	dbo.suspend_allocation
			where	agreement_no = @p_agreement_no
					and allocation_status not in
					(
						'APPROVE', 'REVERSE', 'REJECT', 'CANCEL'
					)

			set @msg = N'Suspend is in ' + @transaction_name + N', Transaction No : ' + @transaction_code ;

			raiserror(@msg, 16, -1) ;
		end ;

		insert into suspend_allocation
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
			,suspend_code
			,suspend_amount
			,agreement_no
			,suspend_gl_link_code
			,is_received_request
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
			,upper(@p_allocationt_remarks)
			,@p_suspend_code
			,@p_suspend_amount
			,@p_agreement_no
			,@p_suspend_gl_link_code
			,@p_is_received_request
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @code ;

		update	dbo.suspend_main
		set		transaction_code	= @p_code
				,transaction_name	= 'ALLOCATION'
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_suspend_code

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
