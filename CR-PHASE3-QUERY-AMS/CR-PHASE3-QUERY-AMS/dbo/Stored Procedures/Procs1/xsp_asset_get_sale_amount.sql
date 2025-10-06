CREATE PROCEDURE dbo.xsp_asset_get_sale_amount
(
	@p_company_code nvarchar(50)
	,@p_code		nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		select	sld.sell_request_amount--sale_value
		from	dbo.sale_detail sld
				inner join dbo.sale sle on sle.code = sld.sale_code
		--inner join dbo.sale_bidding sbd on--de
		where	asset_code			 = @p_asset_no
				and sale_code		 = @p_code
				and sle.company_code = @p_company_code ;
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
