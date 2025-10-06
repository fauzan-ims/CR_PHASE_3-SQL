
create procedure xsp_mutation_detail_history_getrow
(
	@p_id			bigint
) as
begin

	select	id
			,mutation_code
			,asset_code
			,cost_center_code
			,cost_center_name
			,description
			,receive_date
			,remark_unpost
			,remark_return
			,file_name
			,path
			,status_received
	from	mutation_detail_history
	where	id	= @p_id
end
