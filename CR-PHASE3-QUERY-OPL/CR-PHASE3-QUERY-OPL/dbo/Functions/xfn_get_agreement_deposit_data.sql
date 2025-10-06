CREATE FUNCTION dbo.xfn_get_agreement_deposit_data
(	
	@p_agreement_no			nvarchar(50)
	,@p_deposit_type		nvarchar(15)
)
returns decimal(18, 2)
as
begin
	
	declare	@deposit_amount	decimal(18, 2)

	select	@deposit_amount		= deposit_amount
	from	dbo.agreement_deposit_main with(nolock)
	where	agreement_no		= @p_agreement_no
	and		deposit_type		= @p_deposit_type

	return isnull(@deposit_amount,0)
	
end
