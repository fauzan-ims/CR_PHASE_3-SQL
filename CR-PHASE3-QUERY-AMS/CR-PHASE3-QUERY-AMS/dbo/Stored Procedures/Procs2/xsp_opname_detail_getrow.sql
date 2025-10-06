CREATE PROCEDURE dbo.xsp_opname_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,opname_code
			,asset_code
			,branch_code
			,branch_name
			,location_code
			,condition_code
			,km
			,date
	from	opname_detail
	where	id = @p_id ;
end ;
