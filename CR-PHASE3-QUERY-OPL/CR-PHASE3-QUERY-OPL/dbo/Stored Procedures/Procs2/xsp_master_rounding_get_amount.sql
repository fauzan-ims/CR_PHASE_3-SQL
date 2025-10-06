CREATE PROCEDURE dbo.xsp_master_rounding_get_amount
(
	@p_application_no	nvarchar(50)   = '' 
	,@p_rounding_type	nvarchar(10)   output
	,@p_rounding_amount decimal(18, 2) output
	,@p_currency_code	nvarchar(3)
	,@p_facility_code	nvarchar(50)
)
as
begin
	declare @msg			nvarchar(max)
			,@currency_code nvarchar(3)
			,@facility_code nvarchar(50) ;

	begin try
		select	@currency_code = currency_code
				,@facility_code = facility_code
		from	dbo.application_main
		where	application_no = @p_application_no ;

		if exists
		(
			select	1
			from	master_rounding_detail mrd
					inner join dbo.master_rounding mr on mr.code = mrd.rounding_code
			where	facility_code		 = @p_facility_code
					and mr.currency_code = @p_currency_code
		)
		begin
			select	@p_rounding_amount = mrd.rounding_amount
					,@p_rounding_type = mrd.rounding_type
			from	master_rounding_detail mrd
					inner join dbo.master_rounding mr on mr.code = mrd.rounding_code
			where	mr.currency_code	  = @p_currency_code
					and mrd.facility_code = @p_facility_code ;
		end ;
		else
		begin
			select	@p_rounding_amount = rounding_amount
					,@p_rounding_type = rounding_type
			from	dbo.master_rounding
			where	currency_code = @p_currency_code ;
		end ;

		if (@p_rounding_type is null)
		begin
			set @p_rounding_type = '' ;
		end ;

		if (@p_rounding_amount is null)
		begin
			set @p_rounding_amount = 0 ;
		end ;
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


