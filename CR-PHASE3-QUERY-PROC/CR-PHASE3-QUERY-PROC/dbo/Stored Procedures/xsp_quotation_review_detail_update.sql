CREATE PROCEDURE [dbo].[xsp_quotation_review_detail_update]
(
	@p_id								bigint
	,@p_reff_no							nvarchar(50)	= ''
	,@p_branch_code						nvarchar(50)
	,@p_branch_name						nvarchar(250)
	,@p_currency_code					nvarchar(20)
	,@p_currency_name					nvarchar(250)
	,@p_payment_methode_code			nvarchar(50)	= ''
	,@p_item_code						nvarchar(50)
	,@p_item_name						nvarchar(250)
	,@p_supplier_code					nvarchar(50)	= ''
	,@p_supplier_name					nvarchar(250)	= ''
	,@p_supplier_npwp					nvarchar(20)	= null
	,@p_tax_code						nvarchar(50)	= ''
	,@p_tax_name						nvarchar(250)	= ''
	,@p_ppn_pct							decimal(9,6)
	,@p_pph_pct							decimal(9,6)
	,@p_warranty_month					int
	,@p_warranty_part_month				int
	,@p_quantity						int
	,@p_approved_quantity				int
	,@p_uom_code						nvarchar(50)
	,@p_uom_name						nvarchar(250)
	,@p_price_amount					decimal(18, 2)
	,@p_discount_amount					decimal(18, 2)
	,@p_requestor_code					nvarchar(50)
	,@p_requestor_name					nvarchar(250)
	,@p_supplier_address				nvarchar(4000)	= ''
	,@p_unit_available_status			nvarchar(10)	= ''
	,@p_indent_days						int				= 0
	,@p_offering						nvarchar(4000)	= ''
	,@p_expired_date					datetime		= ''
	,@p_quotation_review_date			datetime		= ''
	,@p_nett_price						decimal(18,2)	= 0
	,@p_spesification					nvarchar(4000)
	--
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@total_amount	decimal(18,2)
			,@approved_qty	int
			,@nett_price	bigint

	begin try
		if (isnull(@p_unit_available_status, '') = '')
		begin
			set @msg = N'Please Insert Unit Stock.' ;
			raiserror(@msg, 16, -1) ;
		end ;

		if @p_indent_days <= 0 and @p_unit_available_status='INDENT'
		begin
			set @msg = 'Indent days must greater than 0.'
			raiserror (@msg, 16, 1)
		end ;

		select @approved_qty = approved_quantity 
		from dbo.quotation_review_detail
		where id = @p_id

		--set @total_amount	= ((@p_price_amount - @p_discount_amount) + cast(((@p_price_amount - @p_discount_amount) * @p_ppn_pct / 100) as bigint) - cast(((@p_price_amount - @p_discount_amount) * @p_pph_pct / 100) as bigint)) * @approved_qty
		--set @total_amount	= ((@p_price_amount - @p_discount_amount) + cast(((@p_price_amount - @p_discount_amount) * @p_ppn_pct / 100) as bigint) - round(((@p_price_amount - @p_discount_amount) * @p_pph_pct / 100),0)) * @approved_qty
		set @total_amount = (@p_quantity * @p_nett_price)
		SET @nett_price		= @p_nett_price

		set @total_amount = floor(@total_amount)

		if @p_nett_price < 0
		begin
			set @msg = 'Nett price must be greater than 0.'
			raiserror (@msg, 16, 1)
		end ;

		if @total_amount < 0
		begin
			set @msg = 'Total amount must be greater than 0.'
			raiserror (@msg, 16, 1)
		end ;

		--if not exists (select 1 from ifinbam.dbo.master_vendor where npwp = @p_supplier_npwp) -- (+) Ari 2023-12-12 ket : check vendor di master
		--begin
		--	set @msg = 'Vendor doesn`t exist. Please check Vendor in Master Vendor'
		--	raiserror(@msg, 16, -1)
		--end

		--IF @p_supplier_npwp IS NULL
		--BEGIN
		--	set @msg = 'This Vendor doesnt have NPWP no'
		--	raiserror(@msg, 16, -1)
  --      end
		
		update	quotation_review_detail
		set		
				--reff_no						= @p_reff_no
				--,branch_code				= @p_branch_code
				--,branch_name				= @p_branch_name
				--,currency_code				= @p_currency_code
				--,currency_name				= @p_currency_name
				--,payment_methode_code		= @p_payment_methode_code
				--,item_code					= @p_item_code
				--,item_name					= @p_item_name		
				--,supplier_code				= @p_supplier_code
				--,supplier_name				= @p_supplier_name
				--,supplier_npwp				= @p_supplier_npwp
				--,supplier_address			= @p_supplier_address
				--,tax_code					= @p_tax_code
				--,tax_name					= @p_tax_name
				--,ppn_pct					= @p_ppn_pct
				--,pph_pct					= @p_pph_pct
				--,warranty_month				= @p_warranty_month
				--,warranty_part_month		= @p_warranty_part_month
				--,quantity					= @p_quantity
				--,approved_quantity			= @p_approved_quantity
				--,uom_code					= @p_uom_code
				--,uom_name					= @p_uom_name
				--,price_amount				= @p_price_amount
				--,discount_amount			= @p_discount_amount
				--,requestor_code				= @p_requestor_code
				--,requestor_name				= @p_requestor_name
				--,unit_available_status		= @p_unit_available_status
				--,indent_days				= @p_indent_days
				--,offering					= @p_offering
				--,expired_date				= @p_expired_date
				--,total_amount				= @total_amount
				--,quotation_review_date		= @p_quotation_review_date
				--,nett_price					= @nett_price --@p_nett_price
				spesification				= @p_spesification
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		WHERE	id	= @p_id

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
