create PROCEDURE dbo.xsp_repossession_pricing_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,transaction_status
			,transaction_date
			,transaction_remarks
	from	repossession_pricing
	where	code = @p_code ;
end ;
