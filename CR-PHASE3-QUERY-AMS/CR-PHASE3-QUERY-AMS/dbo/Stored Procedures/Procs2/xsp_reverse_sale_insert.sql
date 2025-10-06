CREATE PROCEDURE dbo.xsp_reverse_sale_insert
(
	@p_code						nvarchar(50)	output
	,@p_company_code			nvarchar(50)
	,@p_sale_code				nvarchar(50)
	,@p_sale_date				datetime
	,@p_reverse_sale_date		datetime
	,@p_reason_reverse_code		nvarchar(50)
	,@p_description				nvarchar(4000)
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_location_code			nvarchar(50)
	,@p_location_name			nvarchar(250)
	,@p_to_bank_account_no		nvarchar(50)
	,@p_to_bank_account_name	nvarchar(250)
	,@p_to_bank_code			nvarchar(50)
	,@p_to_bank_name			nvarchar(250)
	,@p_buyer					nvarchar(250)
	,@p_buyer_phone_no			nvarchar(50)
	,@p_sale_amount				decimal(18, 2)
	,@p_remark					nvarchar(4000)
	,@p_status					nvarchar(20)
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
			,@year		nvarchar(4)
			,@month		nvarchar(2)
			,@code		nvarchar(50)
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid	int 
			,@max_day	int

	begin try

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	-- Asqal 12-Oct-2022 ket : for WOM to control back date based on setting (+) ====
	set @is_valid = dbo.xfn_date_validation(@p_reverse_sale_date)
	select @max_day = cast(value as int) from dbo.sys_global_param where code = 'MDT'

	if @is_valid = 0
	begin
		set @msg = 'The maximum back date input transaction is ' + cast(@max_day as char(2)) + ' in each month';
		raiserror(@msg ,16,-1);	    
	end

	else if (@p_reverse_sale_date > dbo.xfn_get_system_date() )
	begin
		set @msg = 'The Reversal Sell Date entered must not exceed the date in the system';
		raiserror(@msg ,16,-1);	    
	end
		
	-- Arga 06-Nov-2022 ket : request wom back date only for register aset (+)
	if datediff(month,@p_reverse_sale_date,dbo.xfn_get_system_date()) > 0
	begin
		set @msg = 'Back date transactions are not allowed for this transaction';
		raiserror(@msg ,16,-1);	 
	end
	-- End of additional control ===================================================

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
												,@p_branch_code			 = @p_branch_code
												,@p_sys_document_code	 = ''
												,@p_custom_prefix		 = 'RS'
												,@p_year				 = @year
												,@p_month				 = @month
												,@p_table_name			 = 'REVERSE_SALE'
												,@p_run_number_length	 = 5
												,@p_delimiter			= '.'
												,@p_run_number_only		 = '0' ;

	
		insert into reverse_sale
		(
			code
			,company_code
			,sale_code
			,sale_date
			,reverse_sale_date
			,reason_reverse_code
			,description
			,branch_code
			,branch_name
			,location_code
			,location_name
			,to_bank_account_no
			,to_bank_account_name
			,to_bank_code
			,to_bank_name
			,buyer
			,buyer_phone_no
			,sale_amount
			,remark
			,status
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
			,@p_company_code
			,@p_sale_code
			,@p_sale_date
			,@p_reverse_sale_date
			,@p_reason_reverse_code
			,@p_description
			,@p_branch_code
			,@p_branch_name
			,@p_location_code
			,@p_location_name
			,@p_to_bank_account_no
			,@p_to_bank_account_name
			,@p_to_bank_code
			,@p_to_bank_name
			,@p_buyer
			,@p_buyer_phone_no
			,@p_sale_amount
			,@p_remark
			,@p_status
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) set @p_code = @code;
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
