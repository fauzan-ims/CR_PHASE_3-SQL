CREATE PROCEDURE dbo.xsp_credit_note_insert
(
	@p_code					nvarchar(50) output
	,@p_branch_code			nvarchar(50)		= ''
	,@p_invoice_no			nvarchar(50)		= ''
	,@p_branch_name			nvarchar(250)		= ''
	,@p_currency_code		nvarchar(3)			= ''
	,@p_ppn_amount			decimal(18,2)		= 0
	,@p_pph_amount			decimal(18,2)		= 0
	,@p_discount_amount		decimal(18,2)		= 0
	,@p_date				datetime			= ''
	,@p_status				nvarchar(10)		= ''
	,@p_remark				nvarchar(4000)		= ''
	,@p_ppn_pct				decimal(9, 6)		= 0
	,@p_pph_pct				decimal(9, 6)		= 0
	,@p_billing_amount		decimal(18, 2)		= 0
	,@p_total_amount		decimal(18, 2)		= 0
	,@p_credit_amount		decimal(18, 2)		= 0
	,@p_new_ppn_amount		int		= 0
	,@p_new_pph_amount		int		= 0
	,@p_new_total_amount	decimal(18, 2)		= 0
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
	declare @code					 nvarchar(50)
			,@year					 nvarchar(4)
			,@month					 nvarchar(2)
			,@msg					 nvarchar(max)
			,@new_faktur_no			 nvarchar(50) 
			,@faktur_no				 nvarchar(50)
			,@billing_to_faktur_type nvarchar(3);

	begin try
    
    if(@p_credit_amount > @p_billing_amount)
	begin
		set @msg = 'Credit Amount must bee less than Billing Amount.'
		raiserror(@msg, 16, 1) ;
	end
 
	select	@faktur_no = faktur_no
	from	dbo.invoice 
	where	invoice_no = @p_invoice_no

	if (isnull(@faktur_no, '') <> '')
	begin
		set @new_faktur_no = stuff(@faktur_no, 3, 1, '1') ;
	end ;

	 	 
	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = N'OPLDSF'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = N'CREDIT_NOTE'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0'
											
	insert into credit_note
	(
		code
		,branch_code
		,branch_name
		,date
		,status
		,remark
		,invoice_no
		,currency_code
		,billing_amount
		,discount_amount
		,ppn_pct
		,ppn_amount
		,pph_pct
		,pph_amount
		,total_amount
		,credit_amount
		,new_faktur_no
		,new_ppn_amount
		,new_pph_amount
		,new_total_amount
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
		,@p_date
		,@p_status
		,@p_remark
		,@p_invoice_no
		,@p_currency_code
		,@p_billing_amount
		,@p_discount_amount
		,@p_ppn_pct
		,@p_ppn_amount
		,@p_pph_pct
		,@p_pph_amount
		,@p_total_amount
		,0
		,@faktur_no--isnull(@new_faktur_no, '')
		,0
		,0
		,0
		--
		,@p_cre_date
		,@p_cre_by
		,@p_cre_ip_address
		,@p_mod_date
		,@p_mod_by
		,@p_mod_ip_address
	) ;

	insert into dbo.credit_note_detail
	(
		credit_note_code
		,invoice_no
		,invoice_detail_id
		,adjustment_amount
		,new_pph_amount
		,new_ppn_amount
		,new_rental_amount
		,new_total_amount
		--
		,cre_date
		,cre_by
		,cre_ip_address
		,mod_date
		,mod_by
		,mod_ip_address
	)
	select	@code
			,invoice_no
			,id
			,0
			,pph_amount
			,ppn_amount
			,billing_amount
			,total_amount
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
	from	dbo.invoice_detail
	where	invoice_no = @p_invoice_no ;

	if exists 
	(
		select	1 
		from	dbo.credit_note 
		where	invoice_no in 
		(
			select	invoice_no 
			from	dbo.agreement_asset_late_return
		)
	)
	begin
		--raffy (2025/08/07) cr fase 3
		update	dbo.agreement_asset_late_return
		set		credit_note_no	= @code
				,credit_amount	= 0
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	invoice_no		= @p_invoice_no
	end


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
