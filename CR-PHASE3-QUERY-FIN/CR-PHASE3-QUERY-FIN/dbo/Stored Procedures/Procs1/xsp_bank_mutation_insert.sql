CREATE PROCEDURE dbo.xsp_bank_mutation_insert
(
	@p_code					nvarchar(50) output
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_gl_link_code		nvarchar(50)
	,@p_branch_bank_code	nvarchar(50)
    ,@p_branch_bank_name	nvarchar(250)
	,@p_balance_amount		decimal(18, 2)
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
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	begin try
		if exists
		(
			select	1
			from	dbo.bank_mutation
			where	branch_code		 = @p_branch_code
					and branch_bank_code = @p_branch_bank_code
		)
		begin
			select	@code = code
			from	dbo.bank_mutation
			where	branch_code		 = @p_branch_code
					and branch_bank_code = @p_branch_bank_code ;

			update	dbo.bank_mutation
			set		balance_amount	= balance_amount + @p_balance_amount
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @code

		end ;
		else
		begin
			set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
			set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

			exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
														,@p_branch_code = @p_branch_code
														,@p_sys_document_code = N''
														,@p_custom_prefix = 'BKM'
														,@p_year = @year
														,@p_month = @month
														,@p_table_name = 'BANK_MUTATION'
														,@p_run_number_length = 6
														,@p_delimiter = '.'
														,@p_run_number_only = N'0' ;

			insert into bank_mutation
			(
				code
				,branch_code
				,branch_name
				,gl_link_code
				,branch_bank_code
				,branch_bank_name
				,balance_amount
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
				,@p_gl_link_code
				,@p_branch_bank_code
				,@p_branch_bank_name
				,@p_balance_amount
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;
		end ;

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

