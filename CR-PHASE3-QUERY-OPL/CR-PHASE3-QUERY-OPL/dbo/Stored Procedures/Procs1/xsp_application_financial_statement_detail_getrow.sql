
CREATE PROCEDURE [dbo].[xsp_application_financial_statement_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,financial_statement_code
			,report_type
			,statement_code
			,statement_description
			,statement_parent_code
			,statement_value_amount
			,level_key
			,order_key
	from	application_financial_statement_detail
	where	id = @p_id ;
end ;

