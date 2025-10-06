
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_grn_request_getrow]
(
	@p_final_grn_request_no nvarchar(50)
)
as
begin
	select	final_grn_request_no
			,application_no + isnull(procurement_request_code,'') 'application_no'
			,branch_code
			,branch_name
			,requestor_name
			,application_date
			,status
			,total_purchase_data
			,procurement_request_date
			,is_manual
			,client_name
	from	dbo.final_grn_request
	where	final_grn_request_no = @p_final_grn_request_no ;
end ;
