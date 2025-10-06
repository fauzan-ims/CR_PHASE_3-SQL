CREATE procedure dbo.xsp_repossession_letter_collateral_getrow
(
	@p_id bigint
)
as
begin
	select	id
		   ,letter_code
		   ,asset_no
		   ,is_success_repo
	from	repossession_letter_collateral
	where	id = @p_id ;
end ;
