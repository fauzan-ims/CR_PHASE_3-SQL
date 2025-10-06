create PROCEDURE dbo.xsp_proc_interface_approval_request_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select id
		  ,code
		  ,branch_code
		  ,branch_name
		  ,request_status
		  ,request_date
		  ,request_amount
		  ,request_remarks
		  ,reff_module_code
		  ,reff_no
		  ,reff_name
		  ,paths
		  ,approval_category_code
		  ,approval_status
		  ,expired_date
		  ,settle_date
		  ,job_status
		  ,failed_remarks
	from dbo.proc_interface_approval_request
	where	code = @p_code ;
end ;
