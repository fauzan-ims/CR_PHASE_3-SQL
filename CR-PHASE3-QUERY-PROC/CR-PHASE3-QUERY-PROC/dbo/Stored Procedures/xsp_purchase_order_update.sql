CREATE PROCEDURE dbo.xsp_purchase_order_update
(
	@p_code						nvarchar(50)
	,@p_company_code			nvarchar(50)
	,@p_order_date				datetime
	,@p_supplier_code			nvarchar(50)
	,@p_supplier_name			nvarchar(250)
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_division_code			nvarchar(50)	= ''
	,@p_division_name			nvarchar(250)	= ''
	,@p_department_code			nvarchar(50)	= ''
	,@p_department_name			nvarchar(250)	= ''
	,@p_payment_methode_code	nvarchar(50)
	,@p_payment_methode_name	nvarchar(250)
	,@p_currency_code			nvarchar(20)
	,@p_currency_name			nvarchar(250)
	,@p_order_type_code			nvarchar(50)	= ''
	,@p_total_amount			decimal(18, 2) 
	,@p_ppn_amount				decimal(18, 2) 
	,@p_pph_amount				decimal(18, 2) 
	,@p_payment_by				nvarchar(20)	= ''
	,@p_receipt_by				nvarchar(20)	= ''
	,@p_is_termin				nvarchar(1)
	,@p_unit_from				nvarchar(25)	= ''
	,@p_status					nvarchar(20)
	,@p_remark					nvarchar(4000)	= ''
	,@p_eta_date				datetime
	,@p_supplier_address		nvarchar(4000)	= ''
	,@p_is_spesific_address		nvarchar(1)
	,@p_delivery_name			nvarchar(250)	= ''
	,@p_delivery_address		nvarchar(4000)	= ''
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_termin = 'T'
		set @p_is_termin = '1' ;
	else
		set @p_is_termin = '0' ;

	if @p_is_spesific_address = 'T'
		set @p_is_spesific_address = '1' ;
	else
		set @p_is_spesific_address = '0' ;

	if @p_order_date > dbo.xfn_get_system_date()
	begin
	
		set @msg = 'Order date must be lower or equal than system date.';
	
		raiserror(@msg, 16, -1) ;
	
	end   

	begin try
		if (@p_unit_from = '')
		begin
			select	@p_unit_from = unit_from
			from	dbo.purchase_order
			where	code = @p_code ;
		end ;

		if(@p_is_spesific_address = '0')
		begin
			set @p_delivery_name = ''
			set @p_delivery_address = ''
		end
		
		update	purchase_order
		set		company_code				= @p_company_code
				,order_date					= @p_order_date
				,supplier_code				= @p_supplier_code
				,supplier_name				= @p_supplier_name
				,branch_code				= @p_branch_code
				,branch_name				= @p_branch_name
				,division_code				= @p_division_code
				,division_name				= @p_division_name
				,department_code			= @p_department_code
				,department_name			= @p_department_name
				,payment_methode_code		= @p_payment_methode_code
				,payment_methode_name		= @p_payment_methode_name
				,currency_code				= @p_currency_code
				,currency_name				= @p_currency_name
				,order_type_code			= @p_order_type_code
				,total_amount				= @p_total_amount
				,ppn_amount					= @p_ppn_amount
				,pph_amount					= @p_pph_amount
				,payment_by					= @p_payment_by
				,receipt_by					= @p_receipt_by
				,is_termin					= @p_is_termin
				,unit_from					= @p_unit_from
				,status						= @p_status
				,remark						= @p_remark
				,eta_date					= @p_eta_date
				,supplier_address			= @p_supplier_address
				,is_spesific_address		= @p_is_spesific_address
				,delivery_name				= @p_delivery_name
				,delivery_address			= @p_delivery_address
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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
