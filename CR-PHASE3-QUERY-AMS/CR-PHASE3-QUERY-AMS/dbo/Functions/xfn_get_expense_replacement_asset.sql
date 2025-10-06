CREATE function dbo.xfn_get_expense_replacement_asset
(
	@p_asset_code nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @amount decimal(18, 2) ;

	select	@amount = sum(ael.expense_amount)
	from	ifinopl.dbo.agreement_asset_replacement_history aarh
			inner join ifinopl.dbo.agreement_asset			aga on (aga.asset_no				  = aarh.asset_no)
			inner join ifinopl.dbo.asset_replacement		arl on (arl.agreement_no			  = aga.agreement_no)
			inner join ifinopl.dbo.asset_replacement_detail arld on (
																		arld.replacement_code	  = arl.code
																		and aarh.replacement_code = arld.replacement_code
																	)
			inner join dbo.asset_expense_ledger				ael on (ael.asset_code				  = arld.new_fa_code)
	where	aga.fa_code = @p_asset_code
			and ael.date
			between cast(arld.new_handover_out_date as date) and isnull(cast(arld.new_handover_in_date as date), cast(dbo.xfn_get_system_date() as date)) ;

	return @amount ;
end ;
