CREATE procedure [dbo].[xsp_supplier_selection_getrow_for_object_info]
(
	@p_code nvarchar(50)
)
as
begin
	select	qrd.id					   'quotation_detail_id'
			,ssd.reff_no			   'quotation_code'
			,qrd.quotation_review_code 'quotation_review_code'
	from	dbo.supplier_selection_detail		  ssd
			left join dbo.quotation_review_detail qrd on (qrd.id = ssd.quotation_detail_id)
	where	ssd.selection_code = @p_code ;
end ;
