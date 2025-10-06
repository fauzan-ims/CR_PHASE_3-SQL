CREATE PROCEDURE dbo.xsp_agreement_asset_insert
(
	@p_asset_no				  nvarchar(50)
	,@p_agreement_no		  nvarchar(50)
	,@p_asset_type_code		  nvarchar(50)
	,@p_asset_name			  nvarchar(250)
	,@p_asset_condition		  nvarchar(5)
	,@p_market_value		  decimal(9, 6)
	,@p_asset_year			  nvarchar(4)
	--
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin

	declare @msg nvarchar(max) ;

	begin try
		insert into agreement_asset
		(
			asset_no
			,agreement_no
			,asset_type_code
			,asset_name
			,asset_condition
			,market_value
			,asset_year
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_asset_no
			,@p_agreement_no
			,@p_asset_type_code
			,@p_asset_name
			,@p_asset_condition
			,@p_market_value
			,@p_asset_year
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
