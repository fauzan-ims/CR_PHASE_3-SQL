CREATE function dbo.xfn_endorsement_premi_sell
(
	@p_endorsement_code nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @return_amount	  decimal(18, 2)
			,@remain_sell_old decimal(18, 2)
			,@remain_sell_new decimal(18, 2) ;

	select	@remain_sell_old = isnull(sum(remain_sell), 0)
	from	dbo.endorsement_period
	where	endorsement_code = @p_endorsement_code
			and old_or_new	 = 'OLD' ;

	select	@remain_sell_new = isnull(sum(remain_sell), 0)
	from	dbo.endorsement_period
	where	endorsement_code = @p_endorsement_code
			and old_or_new	 = 'NEW' ;

	set @return_amount = isnull(@remain_sell_new - @remain_sell_old, 0) ;

	return @return_amount ;
end ;
