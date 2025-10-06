CREATE PROCEDURE [dbo].[xsp_cashier_transaction_for_reversal]
(
	@p_code				    nvarchar(50)
)
as
begin
	declare	@msg					nvarchar(max);

	begin try
		
		if exists (select 1 from cashier_transaction_detail where cashier_transaction_code = @p_code and transaction_code in ('OVDP','LRAP','INST'))
		begin
			select ct.agreement_no 
				   ,installment_no
			from   cashier_transaction ct
				   inner join dbo.cashier_transaction_detail ctd on (ct.code = ctd.cashier_transaction_code)
			where  ctd.cashier_transaction_code = @p_code
			group by ct.agreement_no,ctd.installment_no
		end
		else
		begin
			select code
			   ,doc_ref_code
			   ,transaction_code
			   ,is_received_request
			   ,crr.agreement_no --'agreement_cashier_received'
			   --,ct.agreement_no --'agreement_cashier_transaction'
			   ,orig_amount 'amount'
			   ,installment_no
		from   cashier_transaction ct
			   left join dbo.cashier_transaction_detail ctd on (ct.code = ctd.cashier_transaction_code)
			   outer apply (select doc_ref_code,agreement_no from cashier_received_request crr where crr.code = ctd.received_request_code) crr
		where  ct.code = @p_code
		end
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

end


