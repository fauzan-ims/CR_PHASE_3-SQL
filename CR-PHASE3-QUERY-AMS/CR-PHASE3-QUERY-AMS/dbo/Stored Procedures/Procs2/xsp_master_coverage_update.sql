CREATE PROCEDURE dbo.xsp_master_coverage_update
(
	@p_code					nvarchar(50)
	,@p_coverage_name		nvarchar(250)
	,@p_coverage_short_name nvarchar(250)
	,@p_is_main_coverage	nvarchar(1)
	,@p_insurance_type		nvarchar(10)
	,@p_currency_code		nvarchar(50)
	,@p_is_active			nvarchar(1)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	if @p_is_main_coverage = 'T'
		set @p_is_main_coverage = '1' ;
	else
		set @p_is_main_coverage = '0' ;

	begin try
		if exists (select 1 from master_coverage WHERE code <> @p_code and coverage_name = @p_coverage_name)
		begin
    		SET @msg = 'Description already exist';
    		raiserror(@msg, 16, -1) ;
		END
        
		if exists (select 1 from master_coverage WHERE code <> @p_code and coverage_short_name = @p_coverage_short_name)
		begin
    		SET @msg = 'Short Description already exist';
    		raiserror(@msg, 16, -1) ;
		END
        
		update	master_coverage
		set		coverage_name			= upper(@p_coverage_name)
				,coverage_short_name	= upper(@p_coverage_short_name)
				,is_main_coverage		= @p_is_main_coverage
				,insurance_type			= @p_insurance_type
				,currency_code			= @p_currency_code
				,is_active				= @p_is_active
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;
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


