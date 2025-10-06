
-- User Defined Function

-- User Defined Function

CREATE FUNCTION [dbo].[xfn_get_good_receipt_note_procurement_type]
(
	@p_code		 nvarchar(50)
)
returns nvarchar(50)
as
begin
	declare @procurement_type		nvarchar(50)


	select	@procurement_type = po.procurement_type
	from	dbo.good_receipt_note pr
			inner join dbo.purchase_order po on po.code = pr.purchase_order_code
	where	pr.code = @p_code

	return @procurement_type

end ;
