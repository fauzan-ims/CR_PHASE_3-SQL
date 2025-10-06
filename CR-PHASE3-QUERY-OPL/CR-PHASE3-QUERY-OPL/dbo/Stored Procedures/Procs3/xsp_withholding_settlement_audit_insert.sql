/*
declare @p_code nvarchar(50) ;

exec dbo.xsp_withholding_settlement_audit_insert @p_code = @p_code output -- nvarchar(50)
												 ,@p_branch_code = N'' -- nvarchar(50)
												 ,@p_branch_name = N'' -- nvarchar(250)
												 ,@p_date = '2023-06-02 09.09.14' -- datetime
												 ,@p_year = 0 -- int
												 ,@p_remark = N'' -- nvarchar(4000)
												 ,@p_status = N'' -- nvarchar(10)
												 ,@p_cre_date = '2023-06-02 09.09.14' -- datetime
												 ,@p_cre_by = N'' -- nvarchar(15)
												 ,@p_cre_ip_address = N'' -- nvarchar(15)
												 ,@p_mod_date = '2023-06-02 09.09.14' -- datetime
												 ,@p_mod_by = N'' -- nvarchar(15)
												 ,@p_mod_ip_address = N'' -- nvarchar(15)
*/
-- Louis Jumat, 02 Juni 2023 16.09.28 -- 
CREATE PROCEDURE dbo.xsp_withholding_settlement_audit_insert
(
	@p_code			   nvarchar(50) output
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	,@p_date		   datetime
	,@p_year		   int
	,@p_remark		   nvarchar(4000)
	,@p_status		   nvarchar(10)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @code	nvarchar(50)
			,@year	nvarchar(4)
			,@month nvarchar(2)
			,@msg	nvarchar(max) ;

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = @p_branch_code
													,@p_sys_document_code = N''
													,@p_custom_prefix = N'OPLWSA'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = N'WITHHOLDING_SETTLEMENT_AUDIT'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;
		if exists
		(
			select	1
			from	dbo.withholding_settlement_audit
			where	year = @p_year
					and status not in
		(
			'CANCEL', 'REJECT', 'APPROVE'
		)
		)
		begin
			set @msg = 'Combination already exists with Status : ' +
					   (
						   select	top 1 status
						   from		dbo.withholding_settlement_audit
						   where	year = @p_year
									and status not in
									(
										'CANCEL', 'REJECT', 'APPROVE'
									)
					   ) ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_year <> year(dbo.xfn_get_system_date()) - 1)
		begin
			set @msg = 'Year must be equal to ' + cast(year(dbo.xfn_get_system_date()) - 1 as nvarchar(4)) ;

			raiserror(@msg, 16, -1) ;
		end ;
		 
		insert into dbo.withholding_settlement_audit
		(
			code
			,branch_code
			,branch_name
			,date
			,year
			,remark
			,status
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
			,@p_date
			,@p_year
			,@p_remark
			,@p_status
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		update	dbo.invoice_pph
		set		audit_code			= @code
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	settlement_status					 = 'HOLD'
				and isnull(payment_reff_no, '') = ''
				and invoice_no in
					(
						select	invoice_no
						from	dbo.invoice
						where	year(invoice_date) = @p_year
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
