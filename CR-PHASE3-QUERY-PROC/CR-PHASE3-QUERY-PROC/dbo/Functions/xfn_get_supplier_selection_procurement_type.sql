CREATE FUNCTION dbo.xfn_get_supplier_selection_procurement_type
(
	@p_code		 nvarchar(50)
)
returns nvarchar(50)
as
begin
	declare @procurement_type		nvarchar(50)
			,@unit_from				nvarchar(50)

	select @unit_from = prc.unit_from 
	from dbo.supplier_selection_detail ssd
	left join dbo.quotation_review_detail qrd on ssd.reff_no collate Latin1_General_CI_AS = qrd.quotation_review_code
	left join dbo.procurement prc on prc.code collate Latin1_General_CI_AS = isnull(qrd.reff_no, ssd.reff_no)
	where ssd.selection_code = @p_code
	
	if(@unit_from = 'BUY')
	begin
		select @procurement_type = isnull(isnull(pr.procurement_type, pr2.procurement_type),'PURCHASE') 
		from dbo.supplier_selection_detail ssd
		left join dbo.quotation_review_detail qrd on (qrd.id											 = ssd.quotation_detail_id)
		left join dbo.procurement prc on (prc.code collate latin1_general_ci_as							 = qrd.reff_no)
		left join dbo.procurement prc2 on (prc2.code													 = ssd.reff_no)
		left join dbo.procurement_request pr on (pr.code												 = prc.procurement_request_code)
		left join dbo.procurement_request pr2 on (pr2.code												 = prc2.procurement_request_code)
		where ssd.selection_code = @p_code
	end
	else
	begin
		set @procurement_type = 'MOBILISASI'
	end

	return @procurement_type

end ;
