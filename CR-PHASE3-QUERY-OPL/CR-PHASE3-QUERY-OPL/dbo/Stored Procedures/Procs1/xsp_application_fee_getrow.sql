CREATE procedure dbo.xsp_application_fee_getrow
(
	@p_id			   bigint
	,@p_application_no nvarchar(50)
)
as
begin
	declare @currency_code	  nvarchar(3)
			,@currency_status nvarchar(1) = '0' ;

	select	@currency_code = currency_code
	from	dbo.application_main
	where	application_no = @p_application_no ;

	if (@currency_code <>
	   (
		   select	currency_code
		   from		dbo.application_fee
		   where	id				   = @p_id
					and application_no = @p_application_no
	   )
	   )
	begin
		set @currency_status = '1' ;
	end ;

	select	af.id
			,af.application_no
			,af.fee_code
			,af.currency_code
			,af.default_fee_rate
			,af.default_fee_amount
			,af.fee_amount
			,af.remarks
			,af.is_calculated
			,af.is_fee_paid
			,mf.description 'fee_desc'
			,@currency_status 'currency_status'
	from	application_fee af
			left join dbo.master_fee mf on (mf.code					= af.fee_code)
			left join dbo.application_main am on (am.application_no = af.application_no)
	where	af.id				  = @p_id
			and af.application_no = @p_application_no ;
end ;
