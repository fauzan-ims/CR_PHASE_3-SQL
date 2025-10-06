CREATE PROCEDURE dbo.xsp_credit_note_update
(
	@p_code				 nvarchar(50)
	,@p_branch_code		 nvarchar(50)
	,@p_branch_name		 nvarchar(250)
	,@p_date			 datetime
	,@p_status			 nvarchar(10)
	,@p_remark			 nvarchar(4000)
	,@p_invoice_no		 nvarchar(50)
	,@p_currency_code	 nvarchar(3)	= ''
	,@p_billing_amount	 decimal(18, 2)
	,@p_discount_amount	 decimal(18, 2)
	,@p_ppn_pct			 decimal(9, 6)
	,@p_ppn_amount		 decimal(18, 2)
	,@p_pph_pct			 decimal(9, 6)
	,@p_pph_amount		 decimal(18, 2)
	,@p_total_amount	 decimal(18, 2)
	,@p_credit_amount	 decimal(18, 2)
	,@p_new_faktur_no	 nvarchar(50)	= ''
	,@p_new_ppn_amount	 int
	,@p_new_pph_amount	 int
	,@p_new_total_amount decimal(18, 2)
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg					 nvarchar(max)
			,@billing_to_faktur_type nvarchar(3) 
			,@total_credit_amount	 decimal(18, 2) 
			,@total_ppn_amount		 int
			,@total_pph_amount		 int
			,@total_total_amount	 decimal(18, 2)

	begin try
		if (@p_credit_amount > @p_billing_amount)
		begin
			set @msg = 'Credit Amount must bee less than Billing Amount.' ;

			raiserror(@msg, 16, 1) ;
		end ;

		--if (@p_credit_amount > 0)
		--begin
		--	select top 1
		--			@billing_to_faktur_type = aa.billing_to_faktur_type
		--	from	dbo.agreement_asset aa
		--			inner join dbo.invoice_detail id on (id.asset_no = aa.asset_no)
		--	where	id.invoice_no = @p_invoice_no ;

		--	set @p_new_ppn_amount = (@p_total_amount - @p_discount_amount - @p_credit_amount) * (@p_ppn_pct / 100) ;
		--	set @p_new_pph_amount = (@p_total_amount - @p_discount_amount - @p_credit_amount) * (@p_pph_pct / 100) ;

		--	-- WAPU
		--	if (@billing_to_faktur_type = '01')
		--	begin
		--		set @p_new_total_amount = @p_total_amount + @p_new_ppn_amount - @p_new_pph_amount - @p_credit_amount ;
		--	end ;
		--	-- NON WAPU
		--	else
		--	begin
		--		set @p_new_total_amount = @p_total_amount - @p_new_pph_amount - @p_credit_amount ;
		--	end ;
		--end ;
		--else
		--begin
		--	set @p_new_ppn_amount = 0 ;
		--	set @p_new_pph_amount = 0 ;
		--	set @p_new_total_amount = 0 ;
		--end ;

		if exists
		(
			select	1
			from	dbo.credit_note
			where	code		   = @p_code
					and invoice_no <> @p_invoice_no
		)
		begin
			delete dbo.credit_note_detail
			where	credit_note_code = @p_code ;
			
			insert into dbo.credit_note_detail
			(
				credit_note_code
				,invoice_no
				,invoice_detail_id
				,adjustment_amount
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	@p_code
					,invoice_no
					,id
					,0
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.invoice_detail
			where	invoice_no = @p_invoice_no ;
		end ;

		select	@total_credit_amount = isnull(sum(isnull(adjustment_amount, 0)), 0)
				,@total_ppn_amount = isnull(sum(isnull(new_ppn_amount, 0)), 0)
				,@total_pph_amount = isnull(sum(isnull(new_pph_amount, 0)), 0)
				,@total_total_amount = isnull(sum(isnull(new_total_amount, 0)), 0)
		from	dbo.credit_note_detail
		where	credit_note_code = @p_code ;
		 
		update	credit_note
		set		date					= @p_date
				,status					= @p_status
				,remark					= @p_remark
				,invoice_no				= @p_invoice_no
				,currency_code			= @p_currency_code
				,billing_amount			= @p_billing_amount
				,discount_amount		= @p_discount_amount
				,ppn_pct				= @p_ppn_pct
				,ppn_amount				= @p_ppn_amount
				,pph_pct				= @p_pph_pct
				,pph_amount				= @p_pph_amount
				,total_amount			= @p_total_amount
				,new_faktur_no			= @p_new_faktur_no
				,credit_amount			= @total_credit_amount
				,new_ppn_amount			= @total_ppn_amount
				,new_pph_amount			= @total_pph_amount
				,new_total_amount		= @total_total_amount 
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;
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
