CREATE PROCEDURE dbo.xsp_spaf_claim_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg nvarchar(max)
			,@spaf_claim_code	nvarchar(50)
			,@amount			decimal(18,2)

	begin try
		select @spaf_claim_code = spaf_claim_code 
		from dbo.spaf_claim_detail
		where id = @p_id

		delete	spaf_claim_detail
		where	id = @p_id ;

		select @amount  = sum(claim_amount) 
		from dbo.spaf_claim_detail
		where spaf_claim_code = @spaf_claim_code

		update dbo.spaf_claim
		set total_claim_amount = isnull(@amount,0)
		where code = @spaf_claim_code
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
