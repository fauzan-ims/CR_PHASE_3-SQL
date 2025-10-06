CREATE PROCEDURE dbo.xsp_application_financial_analysis_income_update
(
	@p_id									bigint
	,@p_income_amount						decimal(18, 2)
	,@p_net_income_pct						decimal(9, 6)
	,@p_remarks								nvarchar(4000) = ''
	--
	,@p_mod_date							datetime
	,@p_mod_by								nvarchar(15)
	,@p_mod_ip_address						nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 
			,@application_no	nvarchar(50)
			,@net_income_amount	decimal(18, 2)

	set @net_income_amount = @p_income_amount * @p_net_income_pct / 100 
	if (@p_net_income_pct > 100)
	begin
	    set @msg = 'Net Income PCT must be less than 100';
		raiserror(@msg, 16,1)
	end

	if (@p_net_income_pct <= 0)
	begin
	    set @msg = 'Net Income PCT must be greater than 0';
		raiserror(@msg, 16,1)
	end

	begin try
		update	application_financial_analysis_income
		set		income_amount		= @p_income_amount
				,net_income_pct		= @p_net_income_pct
				,net_income_amount	= @net_income_amount
				,remarks			= @p_remarks
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;

		select	@application_no	= afa.application_no
		from	dbo.application_financial_analysis_income afi
				inner join dbo.application_financial_analysis afa on (afa.code = afi.application_financial_analysis_code)
		where	afi.id = @p_id

		exec dbo.xsp_application_financial_analysis_calculate @p_application_no		= @application_no
															  ,@p_mod_date			= @p_mod_date
															  ,@p_mod_by			= @p_mod_by
															  ,@p_mod_ip_address	= @p_mod_ip_address
		
		
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



