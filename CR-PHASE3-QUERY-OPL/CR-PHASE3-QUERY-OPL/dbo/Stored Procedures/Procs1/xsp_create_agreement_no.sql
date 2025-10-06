--created by, Rian at 15/07/2023 

CREATE PROCEDURE dbo.xsp_create_agreement_no
(
	@p_code					nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
AS
BEGIN
	declare	@msg					nvarchar(max)
			,@year					nvarchar(4)
			,@month					nvarchar(2)
			,@client_code			nvarchar(50)
			,@branch_code			nvarchar(50)
			,@agreement_no			nvarchar(50)
			,@agreement_external_no	nvarchar(50)

	begin try

		set @year = cast(datepart(year, @p_mod_date) as nvarchar)
		set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

		if exists
		(
			select	1
			from	dbo.realization
			where	code						 = @p_code
					and isnull(agreement_no, '') = ''
		)
		begin 
			
			select	@client_code		= am.client_code
					,@branch_code		= right(am.branch_code, 2)
			from	dbo.realization rz
					inner join dbo.application_main am on (am.application_no = rz.application_no)
			where	code = @p_code ;

			-- get agreement no
			exec dbo.xsp_generate_application_no @p_unique_code			= @agreement_no output
												 ,@p_branch_code		= @branch_code
												 ,@p_year				= @year
												 ,@p_month				= @month
												 ,@p_opl_code			= N'4'
												 ,@p_run_number_length  = 7
												 ,@p_delimiter			= N'.' 
												 ,@p_type				= 'AGREEMENT'

			set @agreement_external_no = replace(@agreement_no, '.', '/')
	
			if (@agreement_no is null)
			begin
				set @msg = 'Failed generate Agreement No';
				raiserror(@msg, 16, 1) ;
			end ;
			
			-- update realization
			update	realization
			set		agreement_no			= @agreement_no
					,agreement_external_no  = @agreement_external_no
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_code ;
		end
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
END
