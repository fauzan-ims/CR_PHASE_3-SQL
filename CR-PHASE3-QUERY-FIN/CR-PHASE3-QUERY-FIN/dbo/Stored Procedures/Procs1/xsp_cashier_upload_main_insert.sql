CREATE PROCEDURE dbo.xsp_cashier_upload_main_insert
(
	@p_code				  nvarchar(50) output
	,@p_batch_no		  nvarchar(50) output
	,@p_fintech_code	  nvarchar(50)
	,@p_fintech_name	  nvarchar(250)
	,@p_value_date		  datetime
	,@p_trx_date		  datetime
	,@p_branch_bank_code  nvarchar(50)
	,@p_branch_bank_name  nvarchar(50)
	,@p_bank_gl_link_code nvarchar(50)
	,@p_status			  nvarchar(50)
	--
	,@p_cre_date		  datetime
	,@p_cre_by			  nvarchar(15)
	,@p_cre_ip_address	  nvarchar(15)
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin
	declare @year		 nvarchar(4)
			,@month		 nvarchar(2)
			,@msg		 nvarchar(max) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_batch_no output -- nvarchar(50)
												,@p_branch_code = N'' -- nvarchar(10)
												,@p_sys_document_code = N'CHU' -- nvarchar(10)
												,@p_custom_prefix = N'' -- nvarchar(10)
												,@p_year = @year -- nvarchar(2)
												,@p_month = @month -- nvarchar(2)
												,@p_table_name = N'CASHIER_UPLOAD_MAIN' -- nvarchar(100)
												,@p_run_number_length = 6 -- int
												,@p_delimiter = N'.' -- nvarchar(1)
												,@p_run_number_only = N'0' ; -- nvarchar(1)

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output -- nvarchar(50)
												,@p_branch_code = N'' -- nvarchar(10)
												,@p_sys_document_code = N'' -- nvarchar(10)
												,@p_custom_prefix = N'CHU' -- nvarchar(10)
												,@p_year = @year -- nvarchar(2)
												,@p_month = @month -- nvarchar(2)
												,@p_table_name = N'CASHIER_UPLOAD_MAIN' -- nvarchar(100)
												,@p_run_number_length = 6 -- int
												,@p_delimiter = N'.' -- nvarchar(1)
												,@p_run_number_only = N'0' ; -- nvarchar(1)

	begin try
		if(cast(@p_value_date as date) > cast(dbo.xfn_get_system_date() as date))
		begin
			set @msg = 'Value Date must be less or equal then System Date' ;

			raiserror(@msg, 16, -1) ;
		end

		insert into cashier_upload_main
		(
			code
			,batch_no
			,fintech_code
			,fintech_name
			,value_date
			,trx_date
			,branch_bank_code
			,branch_bank_name
			,bank_gl_link_code
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
		(	@p_code
			,@p_batch_no
			,@p_fintech_code
			,@p_fintech_name
			,@p_value_date
			,@p_trx_date
			,@p_branch_bank_code
			,@p_branch_bank_name
			,@p_bank_gl_link_code
			,@p_status
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
