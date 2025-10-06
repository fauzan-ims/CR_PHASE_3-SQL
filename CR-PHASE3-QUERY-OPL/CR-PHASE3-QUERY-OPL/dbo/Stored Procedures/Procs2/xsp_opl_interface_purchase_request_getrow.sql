
CREATE PROCEDURE dbo.xsp_opl_interface_purchase_request_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
		   ,branch_code
		   ,branch_name
		   ,request_date
		   ,request_status
		   ,description
		   ,fa_category_code
		   ,fa_category_name
		   ,fa_merk_code
		   ,fa_merk_name
		   ,fa_model_code
		   ,fa_model_name
		   ,fa_type_code
		   ,fa_type_name
		   ,result_fa_code
		   ,result_fa_name
		   ,result_date 
		   ,job_status
		   ,failed_remarks
	from	opl_interface_purchase_request 
	where	code = @p_code ;
end ;
