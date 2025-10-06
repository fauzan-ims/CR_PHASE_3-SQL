CREATE PROCEDURE dbo.xsp_credit_note_detail_update
(
	@p_id				  bigint 
	,@p_credit_note_code  nvarchar(50)
	,@p_invoice_no		  nvarchar(50)
	,@p_adjustment_amount decimal(18, 2) = 0
	--						 
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin
	declare @msg					 nvarchar(max)
			,@billing_to_faktur_type nvarchar(3)
			,@is_invoice_deduct_pph	 nvarchar(1)
			,@invoice_no			 nvarchar(50)
			,@total_credit_amount	 decimal(18, 2)
			,@total_ppn_amount		 decimal(18,2)
			,@total_pph_amount		 decimal(18,2)
			,@total_total_amount	 decimal(18, 2)
			,@new_rental_amount		 decimal(18, 2)
			,@new_ppn_amount		 decimal(18,2)
			,@new_pph_amount		 decimal(18,2)
			,@new_total_amount		 decimal(18, 2) ;
	 
	begin try 
		if (@p_adjustment_amount > --raffi 2024-07-12 :hilangkan = pada kondisi ini, dikarenakan nilai adjust diperbolehkan sama dengan billing (diskon full) 2322228
		   (
			   select	billing_amount
			   from		dbo.invoice_detail ivd
						inner join dbo.credit_note_detail cnd on (ivd.id = cnd.invoice_detail_id)
			   where	cnd.id = @p_id
		   )
		   )
		begin
			set @msg = 'Adjustment Amount must be less than Billing Amount' ;
			raiserror(@msg, 16, 1) ;
		end ;
		
		if (right(@p_adjustment_amount, 2) <> '00')--(+) raffy 2025/02/21 penambahan validasi agar tidak bisa input decimal dibelakang koma 
		begin
			set @msg = 'Cannot input amount after the decimal point ' ;
			raiserror(@msg, 16, 1) ;
		end

		select	@new_ppn_amount		= round((((ivd.billing_amount - ivd.discount_amount) - @p_adjustment_amount) * (cn.ppn_pct / 100)),0)
				,@new_pph_amount	= round((((ivd.billing_amount - ivd.discount_amount) - @p_adjustment_amount) * (cn.pph_pct / 100)),0)
				,@new_rental_amount = round(((ivd.billing_amount - ivd.discount_amount) - @p_adjustment_amount),0)
		from	dbo.credit_note_detail cnd
				inner join dbo.credit_note cn on (cn.code	 = cnd.credit_note_code)
				inner join dbo.invoice_detail ivd on (ivd.id = cnd.invoice_detail_id)
		where	credit_note_code = @p_credit_note_code 
		and		cnd.id					= @p_id ; -- Hari - 29.Aug.2023 05:29 PM --	penambahan where condition id
		
		select 	@billing_to_faktur_type = billing_to_faktur_type
				,@is_invoice_deduct_pph = is_invoice_deduct_pph
		from	dbo.invoice 
		where	invoice_no = @p_invoice_no ;

		-- WAPU
		if (@billing_to_faktur_type = '01')
		begin
			set @new_total_amount = @new_rental_amount + @new_ppn_amount ;
		end ;
		-- NON WAPU
		else
		begin
			set @new_total_amount = @new_rental_amount ;
		end ;

		--jika potong pph 
		if (@is_invoice_deduct_pph = '1')
		begin
			set @new_total_amount = @new_total_amount - @new_pph_amount
		end 

		if (@p_adjustment_amount = 0) -- raffi : 2322228
		begin
			set @new_rental_amount = 0
			set @new_ppn_amount	   = 0
			set @new_pph_amount	   = 0
			set @new_total_amount  = 0
		end

		update	credit_note_detail
		set		adjustment_amount	= @p_adjustment_amount 
				,new_rental_amount	= @new_rental_amount
				,new_ppn_amount		= @new_ppn_amount
				,new_pph_amount		= @new_pph_amount
				,new_total_amount	= @new_total_amount
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;

		if ((
				select	sum(adjustment_amount)
				from	dbo.credit_note_detail
				where	credit_note_code = @p_credit_note_code
			) <= 0
		   )
		begin
			set @msg = N'Adjustment Amount must be greater than 0' ;

			raiserror(@msg, 16, 1) ;
		end ; 

		select	@total_credit_amount	= isnull(sum(isnull(adjustment_amount, 0)), 0)
				,@total_ppn_amount		= isnull(sum(isnull(new_ppn_amount, 0)), 0)
				,@total_pph_amount		= isnull(sum(isnull(new_pph_amount, 0)), 0)
				,@total_total_amount	= isnull(sum(isnull(new_total_amount, 0)), 0)
		from	dbo.credit_note_detail
		where	credit_note_code = @p_credit_note_code ;

		update	dbo.credit_note
		set		credit_amount		= @total_credit_amount
				,new_ppn_amount		= @total_ppn_amount
				,new_pph_amount		= @total_pph_amount
				,new_total_amount	= @total_total_amount 
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_credit_note_code ;


		--2025/08/10 raffy cr fase 3
		if exists
		(
			select	1 
			from	dbo.agreement_asset_late_return
			where	credit_note_no = @p_credit_note_code
		)
		begin
			
			update	dbo.agreement_asset_late_return
			set		credit_amount	= crn.adjustment_amount
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			from	dbo.agreement_asset_late_return aalr
			inner join dbo.credit_note_detail crn on crn.credit_note_code = aalr.credit_note_no
			inner join dbo.invoice_detail ide on ide.id = crn.invoice_detail_id
			where	aalr.agreement_no	= ide.agreement_no
			and		aalr.asset_no		= ide.asset_no
			and		crn.credit_note_code = @p_credit_note_code

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
