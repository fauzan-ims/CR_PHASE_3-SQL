CREATE PROCEDURE [dbo].[xsp_master_coverage_insert]
(
	@p_code					nvarchar(50)
	,@p_coverage_name		nvarchar(250)
	,@p_coverage_short_name nvarchar(50)
	,@p_is_main_coverage	nvarchar(1)
	,@p_insurance_type		nvarchar(10)
	,@p_currency_code		nvarchar(50)
	,@p_is_active			nvarchar(1)
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
			,@month nvarchar(2);

	--set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	--set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	--declare @p_unique_code nvarchar(50) ;

	--exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
	--											,@p_branch_code = ''
	--											,@p_sys_document_code = N''
	--											,@p_custom_prefix = 'MC'
	--											,@p_year = @year
	--											,@p_month = @month
	--											,@p_table_name = 'MASTER_COVERAGE'
	--											,@p_run_number_length = 4
	--											,@p_delimiter = ''
	--											,@p_run_number_only = N'0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;


	if @p_is_main_coverage = 'T'
		set @p_is_main_coverage = '1' ;
	else
		set @p_is_main_coverage = '0' ;

	begin try
		if exists (select 1 from master_coverage where coverage_name = @p_coverage_name)
		begin
    		set @msg = 'Description already exist';
    		raiserror(@msg, 16, -1) ;
		end

		
		if exists (select 1 from master_coverage where coverage_short_name = @p_coverage_short_name)
		begin
    		SET @msg = 'Short Description already exist';
    		raiserror(@msg, 16, -1) ;
		end
        
		insert into master_coverage
		(
			code
			,coverage_name
			,coverage_short_name
			,is_main_coverage
			,insurance_type
			,currency_code
			,is_active
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
			,upper(@p_coverage_name)
			,upper(@p_coverage_short_name)
			,@p_is_main_coverage
			,@p_insurance_type
			,@p_currency_code
			,@p_is_active
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


