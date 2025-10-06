
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_ap_invoice_registration_detail_insert]
(
	@p_id						bigint		 = 0 output
	,@p_invoice_register_code	nvarchar(50)	 = ''
	,@p_grn_code				nvarchar(50)	 = ''
	,@p_currency_code			nvarchar(50)	 = ''
	,@p_uom_code				nvarchar(50)	 = ''
	,@p_uom_name				nvarchar(250)	 = ''
	,@p_quantity				int			 = 0
	,@p_item_code				nvarchar(50)	 = ''
	,@p_item_name				nvarchar(250)	 = ''
	,@p_purchase_amount			decimal(18, 2) = 0
	,@p_total_amount			decimal(18, 2) = 0
	,@p_tax_code				nvarchar(50)	 = ''
	,@p_tax_name				nvarchar(250)	 = ''
	,@p_ppn						decimal(18, 2) = 0
	,@p_pph						decimal(18, 2) = 0
	,@p_shipping_fee			decimal(18, 2) = 0
	,@p_discount				decimal(18, 2) = 0
	,@p_branch_code				nvarchar(50)	 = ''
	,@p_branch_name				nvarchar(250)	 = ''
	,@p_division_code			nvarchar(50)	 = ''
	,@p_division_name			nvarchar(250)	 = ''
	,@p_department_code			nvarchar(50)	 = ''
	,@p_department_name			nvarchar(250)	 = ''
	,@p_purchase_order_id		bigint		 = 0
	,@p_spesification			nvarchar(4000)
	,@p_ppn_pct					decimal(9, 6)
	,@p_pph_pct					decimal(9, 6)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
	--
	,@p_grn_detail_id			int	= 0
)
as
begin
	declare @msg				  nvarchar(max);

	begin try
		insert into ap_invoice_registration_detail
		(
			invoice_register_code
			,grn_code
			,currency_code
			,uom_code
			,uom_name
			,quantity
			,item_code
			,item_name
			,purchase_amount
			,total_amount
			,tax_code
			,tax_name
			,ppn_pct
			,pph_pct
			,ppn
			,pph
			,shipping_fee
			,discount
			,branch_code
			,branch_name
			,division_code
			,division_name
			,department_code
			,department_name
			,purchase_order_id
			,spesification
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
			--
			,grn_detail_id
		)
		values
		(
			@p_invoice_register_code
			,@p_grn_code
			,@p_currency_code
			,@p_uom_code
			,@p_uom_name
			,@p_quantity
			,@p_item_code
			,@p_item_name
			,@p_purchase_amount
			,@p_total_amount
			,@p_tax_code
			,@p_tax_name
			,@p_ppn_pct
			,@p_pph_pct
			,@p_ppn
			,@p_pph
			,@p_shipping_fee
			,@p_discount
			,@p_branch_code
			,@p_branch_name
			,@p_division_code
			,@p_division_name
			,@p_department_code
			,@p_department_name
			,@p_purchase_order_id
			,@p_spesification
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
			--
			,@p_grn_detail_id
		) set @p_id = @@identity ;


		--update	dbo.ap_invoice_registration
		--set		unit_price = @p_purchase_amount
		--where	code = @p_invoice_register_code

		-- (+) Ari 2023-12-27 ket : total amount kirim ke header
		declare @total_amount_head	decimal(18,2)

		select	@total_amount_head = sum(isnull(total_amount,0)) 
		from	dbo.ap_invoice_registration_detail
		where	invoice_register_code = @p_invoice_register_code

		update	ap_invoice_registration
		set		invoice_amount	=	 @total_amount_head
		where	code = @p_invoice_register_code

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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
