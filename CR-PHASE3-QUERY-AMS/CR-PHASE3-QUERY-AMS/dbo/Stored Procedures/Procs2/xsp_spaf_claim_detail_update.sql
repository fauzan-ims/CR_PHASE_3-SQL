CREATE PROCEDURE [dbo].[xsp_spaf_claim_detail_update]
(
	@p_id				bigint
	,@p_claim_amount	decimal(18, 2)
	,@p_ppn_amount		decimal(18,2)
	,@p_pph_amount		decimal(18,2)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max)
			,@code		nvarchar(50)
			,@ppn		bigint--decimal(18,2)
			,@pph		bigint--decimal(18,2)
			,@claim_amount	bigint

	begin try
		set @ppn = @p_ppn_amount
		set @pph =  @p_pph_amount
		set @claim_amount = @p_claim_amount

		update	spaf_claim_detail
		set		claim_amount		= @claim_amount
				,ppn_amount_detail	= @ppn
				,pph_amount_detail	= @pph
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;
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
