CREATE PROCEDURE dbo.xsp_asset_total_depre_amount
(
	@p_company_code nvarchar(50)
	,@p_code		nvarchar(50) = ''
	,@p_asset_no	nvarchar(50) = ''
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		select	total_depre_comm
		from	dbo.asset
		where	code			 = @p_asset_no
				and company_code = @p_company_code ;
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
