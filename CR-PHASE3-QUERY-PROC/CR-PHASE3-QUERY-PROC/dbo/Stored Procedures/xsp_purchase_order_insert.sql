CREATE PROCEDURE [dbo].[xsp_purchase_order_insert]
(
	 @p_code					nvarchar(50) output	
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
	,@p_order_type_code			nvarchar(50)
	,@p_total_amount			decimal(18, 2)	= 0
	,@p_ppn_amount				decimal(18, 2)	
	,@p_pph_amount				decimal(18, 2)	
	,@p_payment_by				nvarchar(20)	= ''
	,@p_receipt_by				nvarchar(20)	= ''
	,@p_is_termin				nvarchar(1)		= null
	,@p_unit_from				nvarchar(25)	
	,@p_flag_process			nvarchar(25)
	,@p_status					nvarchar(20)
	,@p_remark					nvarchar(4000)	= ''
	,@p_reff_no					nvarchar(50)	= ''
	,@p_requestor_code			nvarchar(50)	= ''
	,@p_requestor_name			nvarchar(250)	= ''
	,@p_eta_date				datetime		= ''
	,@p_supplier_address		nvarchar(4000)
	,@p_procurement_type		nvarchar(25)	= ''
	,@p_is_spesific_address		nvarchar(1)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@year	nvarchar(4)
			,@month nvarchar(2)
			,@code  nvarchar(50) ;

	if @p_is_termin = 'T'
		set @p_is_termin = '1'
	else
		set @p_is_termin = '0'

	--if @p_order_date < dbo.xfn_get_system_date()
	--begin
	--	set @msg = 'Order date must be greater or equal than system date.';
	--	raiserror(@msg, 16, -1) ;
	--end 

	begin try
		
		set @year = cast(datepart(year, @p_cre_date) as nvarchar) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_generate_auto_no_po @p_unique_code = @code output -- nvarchar(50)
										 ,@p_branch_code = @p_branch_code -- nvarchar(10)
										 ,@p_year = @year -- nvarchar(4)
										 ,@p_month = @month -- nvarchar(4)
										 ,@p_opl_code = N'' -- nvarchar(250)
										 ,@p_jkn = N'DSF' -- nvarchar(250)
										 ,@p_por = N'POR' -- nvarchar(250)
										 ,@p_run_number_length = 6 -- int
										 ,@p_delimiter = N'.' -- nvarchar(1)
										 ,@p_table_name = N'PURCHASE_ORDER' -- nvarchar(250)
										 ,@p_column_name = N'CODE' -- nvarchar(250)
		
		--exec dbo.xsp_get_next_unique_code_for_table_purchase_oder @p_unique_code			= @code output -- nvarchar(50)
		--														  ,@p_branch_code			= @p_company_code
		--														  ,@p_sys_document_code		= N''
		--														  ,@p_custom_prefix			= 'POR'
		--														  ,@p_year					= @year
		--														  ,@p_month					= @month
		--														  ,@p_table_name			= 'PURCHASE_ORDER'
		--														  ,@p_run_number_length		= 6
		--														  ,@p_delimiter				= '.'
		--														  ,@p_run_number_only		= N'0' ;

	insert into purchase_order
	(
		 code
		,company_code
		,order_date
		,supplier_code
		,supplier_name
		,supplier_address
		,branch_code
		,branch_name
		,division_code
		,division_name
		,department_code
		,department_name
		,payment_methode_code
		,payment_methode_name
		,currency_code
		,currency_name
		,order_type_code
		,total_amount
		,ppn_amount
		,pph_amount
		,payment_by
		,receipt_by
		,is_termin
		,unit_from
		,procurement_type
		,flag_process
		,status
		,remark
		,reff_no
		,requestor_code
		,requestor_name
		,eta_date
		,is_spesific_address
		--
		,cre_date
		,cre_by
		,cre_ip_address
		,mod_date
		,mod_by
		,mod_ip_address
	)
	values
	(
		@code
		,@p_company_code
		,dbo.xfn_get_system_date()
		,@p_supplier_code
		,@p_supplier_name
		,@p_supplier_address
		,@p_branch_code
		,@p_branch_name
		,@p_division_code
		,@p_division_name
		,@p_department_code
		,@p_department_name
		,@p_payment_methode_code
		,@p_payment_methode_name
		,@p_currency_code
		,@p_currency_name
		,@p_order_type_code
		,@p_total_amount
		,@p_ppn_amount
		,@p_pph_amount
		,@p_payment_by
		,@p_receipt_by
		,@p_is_termin
		,@p_unit_from
		,@p_procurement_type
		,@p_flag_process
		,@p_status
		,@p_remark
		,@p_reff_no
		,@p_requestor_code
		,@p_requestor_name
		,@p_eta_date
		,@p_is_spesific_address
		--
		,@p_cre_date
		,@p_cre_by
		,@p_cre_ip_address
		,@p_mod_date
		,@p_mod_by
		,@p_mod_ip_address
	)

	set @p_code = @code;

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



