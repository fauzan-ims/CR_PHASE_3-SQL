CREATE PROCEDURE [dbo].[xsp_et_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,et_code
			,asset_no
			,OS_RENTAL_AMOUNT 
			,is_terminate
	from	et_detail
	where	id = @p_id ;
end ;

