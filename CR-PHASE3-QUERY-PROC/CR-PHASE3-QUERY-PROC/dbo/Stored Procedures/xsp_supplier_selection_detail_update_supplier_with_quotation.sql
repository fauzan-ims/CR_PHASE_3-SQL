CREATE PROCEDURE [dbo].[xsp_supplier_selection_detail_update_supplier_with_quotation]
(
	 @p_id						bigint
	,@p_supplier_code			nvarchar(50)
	,@p_supplier_name			nvarchar(250)
	,@p_supplier_address		nvarchar(250)
	,@p_supplier_npwp			nvarchar(20)	= null
	,@p_amount					decimal(18,2)	= 0
	,@p_discount_amount			decimal(18,2)	= 0
	,@p_quantity				int
	,@p_tax_code				nvarchar(50)
	,@p_tax_name				nvarchar(250)
	,@p_ppn_pct					decimal(9,6)	= 0
	,@p_pph_pct					decimal(9,6)	= 0
	,@p_unit_available_status	nvarchar(50)	= ''
	,@p_offering				nvarchar(4000)	= null
	,@p_indent_days				int				= 0
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@pph_amount	decimal(18,2)
			,@ppn_amount	decimal(18,2)
			,@total_amount	decimal(18,2)

	begin try


		set @ppn_amount = cast(round(isnull(@p_ppn_pct / 100 * ((@p_amount - @p_discount_amount) * @p_quantity),0),0) as bigint) ;
		set @pph_amount = cast(round(isnull(@p_pph_pct / 100 * ((@p_amount - @p_discount_amount) * @p_quantity),0),0) as bigint) ;
		set @total_amount = round(((@p_amount - @p_discount_amount) * @p_quantity),0)

		update	supplier_selection_detail
		set		supplier_code			= @p_supplier_code
				,supplier_name			= @p_supplier_name
				,supplier_address		= @p_supplier_address
				,supplier_npwp			= @p_supplier_npwp
				,amount					= @p_amount
				,quotation_amount		= @p_amount
				--,total_amount			= (@p_amount - @p_discount_amount) * @p_quantity
				,total_amount			= @total_amount
				,discount_amount		= @p_discount_amount
				,tax_code				= @p_tax_code
				,tax_name				= @p_tax_name
				,ppn_amount				= @ppn_amount
				,pph_amount				= @pph_amount
				,ppn_pct				= @p_ppn_pct
				,pph_pct				= @p_pph_pct
				,unit_available_status	= @p_unit_available_status
				,offering				= @p_offering
				,indent_days			= @p_indent_days
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id	= @p_id

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
