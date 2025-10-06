
CREATE procedure [dbo].[xsp_master_scoring_dimension_getrow]
(
	@p_id bigint
)
as
begin
	
	select	id
            ,scoring_code
            ,reff_item_code
            ,reff_item_name
            ,dimension_code
	from	master_scoring_dimension
	where	id = @p_id ;

end ;
