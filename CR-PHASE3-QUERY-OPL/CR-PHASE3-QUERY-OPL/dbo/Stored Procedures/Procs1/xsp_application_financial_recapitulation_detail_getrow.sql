
CREATE PROCEDURE [dbo].[xsp_application_financial_recapitulation_detail_getrow]
(
	@p_id nvarchar(50)
)
as
begin
	select	id
			,financial_recapitulation_code
			,report_type
			,statement_code
			,statement_description
			,statement_parent_code
			,statement_from_value_amount
			,statement_to_value_amount
			,level_key
			,order_key
	from	application_financial_recapitulation_detail
	where	id = @p_id ;
end ;

