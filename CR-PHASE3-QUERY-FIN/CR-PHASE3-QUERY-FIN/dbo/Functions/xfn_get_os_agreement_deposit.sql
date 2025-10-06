create function dbo.xfn_get_os_agreement_deposit
(
	@p_agreement_no	nvarchar(50)
)
returns decimal(18,2)
as
begin

	declare @os_deposit decimal(18,2)

	select	@os_deposit = deposit_amount 
	from	ifinopl.dbo.agreement_deposit_main
	where	agreement_no = @p_agreement_no

	return @os_deposit

end
