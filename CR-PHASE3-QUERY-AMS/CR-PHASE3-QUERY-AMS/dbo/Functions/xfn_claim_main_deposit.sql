create function dbo.xfn_claim_main_deposit
(
	@p_claim_code nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @return_amount decimal(18, 2)
			,@claim_amount decimal(18, 2) ;

	select	@claim_amount = claim_amount
	from	dbo.claim_main
	where	code = @p_claim_code ;

	set @return_amount = isnull(@claim_amount, 0) ;

	return @return_amount ;
end ;
