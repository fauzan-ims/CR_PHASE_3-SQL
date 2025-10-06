--created by, Rian at 16/05/2023 

CREATE procedure dbo.xsp_area_blacklist_history_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,area_blacklist_code
			,source
			,history_date
			,history_remarks
	from	area_blacklist_history
	where	id = @p_id ;
end ;
