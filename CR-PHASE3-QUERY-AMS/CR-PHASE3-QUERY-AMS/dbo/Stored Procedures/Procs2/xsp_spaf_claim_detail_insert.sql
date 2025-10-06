CREATE PROCEDURE dbo.xsp_spaf_claim_detail_insert
(
	@p_id				bigint = 0 output
	,@p_spaf_claim_code nvarchar(50)
	,@p_spaf_asset_code	nvarchar(50)
	,@p_spaf_pct		decimal(9, 6)
	,@p_claim_amount	decimal(18, 2)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@total_amount	decimal(18,2)

	begin try
		insert into spaf_claim_detail
		(
			spaf_claim_code
			,spaf_asset_code
			,spaf_pct
			,claim_amount
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
			@p_spaf_claim_code
			,@p_spaf_asset_code
			,@p_spaf_pct
			,@p_claim_amount
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;

		select @total_amount = sum(claim_amount) 
		from dbo.spaf_claim_detail
		where spaf_claim_code = @p_spaf_claim_code

		update dbo.spaf_claim
		set total_claim_amount	= @total_amount
			--
			,cre_date			= @p_cre_date
			,cre_by				= @p_cre_by
			,cre_ip_address		= @p_cre_ip_address
			,mod_date			= @p_mod_date
			,mod_by				= @p_mod_by
			,mod_ip_address		= @p_mod_ip_address
		where code = @p_spaf_claim_code

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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
