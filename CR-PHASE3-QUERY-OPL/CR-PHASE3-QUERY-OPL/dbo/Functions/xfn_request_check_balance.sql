
CREATE function dbo.xfn_request_check_balance
(
	@p_request_type	 nvarchar(20)
	,@p_request_code nvarchar(50)
	,@p_process_code nvarchar(50)
)
returns nvarchar(250)
as
begin
	declare @output nvarchar(250) ;

	if (@p_request_type = 'ET') --- ganti ke type transaction (WO/ET/RS)
	begin
		if ((
				select	sum(total.balance)
				from
						(
							select	sum(   case mtp.debet_or_credit
											   when 'CREDIT' then case et.transaction_code
																	  when 'SCDP' then abs(rv.total_amount) * -1
																	  else abs(et.transaction_amount) * -1
																  end
											   else case et.transaction_code
														when 'SCDP' then abs(rv.total_amount)
														else abs(et.transaction_amount)
													end
										   end
									   ) + sum(et.disc_amount) 'balance'
							from	dbo.et_transaction et
									inner join dbo.master_transaction_parameter mtp on (mtp.transaction_code = et.transaction_code)
									inner join dbo.master_transaction mt on (mt.code = et.transaction_code)
									outer apply
							(
								select	total_amount
								from	dbo.et_transaction
								where	et_code				 = @p_request_code
										and transaction_code = 'RSDV'
							) rv
							where	et.et_code			 = @p_request_code
									and mtp.process_code = @p_process_code
									and mtp.is_journal	 = '1'
							union
							select	et_amount 'balance'
							from	dbo.et_main
							where	code = @p_request_code
						) as total
			) <> 0
		   )
		begin
			set @output = 'Journal Is Not Balance' ;
		end ;
	end ;
	else if (@p_request_type = 'WRITE OFF') --- ganti ke type transaction (WO/ET/RS)
	begin
		if ((
				select	sum(   case mtp.debet_or_credit
								   when 'CREDIT' then case wot.transaction_code
														  when 'SCDP' then abs(rv.transaction_amount) * -1
														  else abs(wot.transaction_amount) * -1
													  end
								   else case wot.transaction_code
											when 'SCDP' then abs(rv.transaction_amount)
											else abs(wot.transaction_amount)
										end
							   end
						   ) 'balance'
				from	dbo.write_off_transaction wot
						inner join dbo.master_transaction_parameter mtp on (mtp.transaction_code = wot.transaction_code)
						inner join dbo.write_off_main wm on (wm.code = wot.wo_code)
						outer apply
				(
					select	transaction_amount
					from	dbo.write_off_transaction
					where	wo_code				 = @p_request_code
							and transaction_code = 'RSDV'
				) rv
				where	wm.code				 = @p_request_code
						and mtp.process_code = @p_process_code
						and mtp.is_journal	 = '1'
			) <> 0
		   )
		begin
			set @output = 'Journal Is Not Balance' ;
		end ;
	end ;

	return @output ;
end ;
