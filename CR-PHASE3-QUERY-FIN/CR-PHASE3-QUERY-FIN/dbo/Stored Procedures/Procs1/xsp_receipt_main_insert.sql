CREATE PROCEDURE dbo.xsp_receipt_main_insert
(
	@p_code				 nvarchar(50) output
	,@p_branch_code		 nvarchar(50)
	,@p_branch_name		 nvarchar(250)
	,@p_receipt_status	 nvarchar(10)
	,@p_receipt_use_date datetime = null
	,@p_receipt_no		 nvarchar(150)
	,@p_cashier_code	 nvarchar(50) = null
	,@p_max_print_count	 int
	,@p_print_count		 int
	--
	,@p_cre_date		 datetime
	,@p_cre_by			 nvarchar(15)
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'RCP'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'RECEIPT_MAIN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;
		
		set @p_code = @code
		insert into receipt_main
		(
			code
			,branch_code
			,branch_name
			,receipt_status
			,receipt_use_date
			,receipt_no
			,cashier_code
			,max_print_count
			,print_count
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@p_branch_code
			,@p_branch_name
			,@p_receipt_status
			,@p_receipt_use_date
			,@p_receipt_no
			,@p_cashier_code
			,@p_max_print_count
			,@p_print_count
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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
