CREATE PROCEDURE dbo.xsp_reprint_receipt_insert
(
	@p_code					nvarchar(50) output
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_reprint_status		nvarchar(10)
	,@p_reprint_date		datetime
	,@p_reprint_reason_code nvarchar(50)
	,@p_reprint_remarks		nvarchar(4000)
	,@p_cashier_type		nvarchar(10)
	,@p_cashier_code		nvarchar(50)
	,@p_old_receipt_code	nvarchar(50)
	,@p_new_receipt_code	nvarchar(50)
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
	declare @msg			nvarchar(max)
			,@year			nvarchar(2)
			,@month			nvarchar(2)
			,@code			nvarchar(50);

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		declare @p_unique_code nvarchar(50) ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = @p_branch_code
													,@p_sys_document_code = N''
													,@p_custom_prefix = 'RPR'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'REPRINT_RECEIPT'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		if (@p_reprint_date > dbo.xfn_get_system_date()) 
				begin
					set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Date','System Date');
					raiserror(@msg ,16,-1)
				end

		insert into reprint_receipt
		(
			code
			,branch_code
			,branch_name
			,reprint_status
			,reprint_date
			,reprint_reason_code
			,reprint_remarks
			,cashier_type
			,cashier_code
			,old_receipt_code
			,new_receipt_code
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
			,@p_reprint_status
			,@p_reprint_date
			,@p_reprint_reason_code
			,@p_reprint_remarks
			,@p_cashier_type
			,@p_cashier_code
			,@p_old_receipt_code
			,@p_new_receipt_code
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

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
