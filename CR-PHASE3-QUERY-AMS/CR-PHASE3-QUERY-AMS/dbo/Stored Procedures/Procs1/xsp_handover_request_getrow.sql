
create procedure xsp_handover_request_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,type
			,status
			,date
			,handover_from
			,handover_to
			,fa_code
			,remark
			,handover_code
	from	handover_request
	where	code = @p_code ;
end ;
