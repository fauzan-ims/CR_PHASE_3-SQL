CREATE PROCEDURE dbo.xsp_asset_depreciation_return_journal
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@status				nvarchar(25)
			,@net_book_value_comm	decimal(18,2)
			,@net_book_value_fiscal	decimal(18,2)
			,@depre_amount_comm		decimal(18,2)
			,@depre_amount_fiscal	decimal(18,2)
			,@code					nvarchar(50)
			,@orig_price			decimal(18,2)
			,@depre_date			datetime ;

	begin try
		
		
		 
		
		select ''
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
