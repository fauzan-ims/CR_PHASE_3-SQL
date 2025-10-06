CREATE FUNCTION dbo.xfn_termination_main_deposit
(
	--@p_termination_code nvarchar(50)
	@p_termination_id		int
)
returns decimal(18, 2)
as
begin
	declare @return_amount				  decimal(18, 2)
			,@termination_approved_amount decimal(18, 2) ;

	--select	@termination_approved_amount = SUM(termination_approved_amount)
	--from	dbo.termination_main
	--where	code = @p_termination_code ;
	select	@termination_approved_amount = refund_amount
	from	dbo.termination_detail_asset
	where	id = @p_termination_id


	set @return_amount = isnull(@termination_approved_amount, 0) ;

	return @return_amount ;
end ;
