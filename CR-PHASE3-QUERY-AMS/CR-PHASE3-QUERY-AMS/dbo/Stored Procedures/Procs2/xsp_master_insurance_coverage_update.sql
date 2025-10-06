CREATE PROCEDURE dbo.xsp_master_insurance_coverage_update
(
	@p_code			   nvarchar(50)
	,@p_insurance_code nvarchar(50)
	,@p_coverage_code  nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists (select 1 from master_insurance_coverage WHERE code <> @p_code and insurance_code = @p_insurance_code AND coverage_code = @p_coverage_code )
		begin
			SET @msg = 'Name already exist';
			raiserror(@msg, 16, -1) ;
		end
		update	master_insurance_coverage
		set		insurance_code	= @p_insurance_code
				,coverage_code	= @p_coverage_code
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code ;
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




