CREATE PROCEDURE dbo.xsp_master_auction_branch_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,auction_code
			,branch_code
			,branch_name
	from	master_auction_branch
	where	id = @p_id ;
end ;
