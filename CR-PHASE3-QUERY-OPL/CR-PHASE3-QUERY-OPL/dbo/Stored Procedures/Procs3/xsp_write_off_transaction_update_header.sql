/*
    alterd : Rinda, 16 Nopember 2020
*/
CREATE PROCEDURE dbo.xsp_write_off_transaction_update_header
(
	@p_wo_code			   nvarchar(50)
)
as
begin
	declare @msg				nvarchar(max)
			,@factoring_type	nvarchar(10)
			,@wo_type			nvarchar(10)
			,@tottal_amount		decimal(18, 2) ;

	select	@wo_type = wom.wo_type
	from	dbo.write_off_main wom
			inner join dbo.agreement_main am on (am.agreement_no = wom.agreement_no)
	where	wom.code = @p_wo_code ;

	begin try 
		select	@tottal_amount = sum(transaction_amount)
		from	dbo.write_off_transaction
		where	transaction_code in
				(	
					'DOUBFUL','OS_PRINC', 'OVD_PRINC', 'DPS_INSU', 'DPS_OTHR', 'DPS_INST'
				)
				and WO_CODE = @p_wo_code ;

		update	dbo.write_off_main
		set		wo_amount = isnull(@tottal_amount, 0)
		where	code = @p_wo_code ; 
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

