CREATE procedure [dbo].[xsp_billing_scheme_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	declare @total_detail int ;

	select	@total_detail = count(1)
	from	dbo.billing_scheme_detail
	where	scheme_code = @p_code ;

	select	code
			,scheme_name
			,client_no
			,client_name
			,billing_mode
			,billing_mode_date
			,is_active
			,@total_detail 'total_detail'
	from	billing_scheme
	where	code = @p_code ;
end ;
