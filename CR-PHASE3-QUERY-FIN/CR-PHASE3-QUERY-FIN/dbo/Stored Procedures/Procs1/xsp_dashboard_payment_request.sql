CREATE PROCEDURE dbo.xsp_dashboard_payment_request

AS
BEGIN
	declare	@msg	nvarchar(max)
	begin try
		select		prq.payment_source 'reff_name'
					--,prq.payment_amount
					,prq.count_payment_source 'total_data'
		from		(
						select distinct
									pr.payment_source
									,sum(pr.payment_amount) 'payment_amount'
									,count(payment_source) 'count_payment_source'
						from		payment_request pr
						where		pr.payment_status <> 'PAID'
						group by	pr.payment_source
					)prq
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
END
