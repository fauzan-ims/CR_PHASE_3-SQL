
CREATE procedure [dbo].[xsp_master_scoring_getrow]
(
	@p_code nvarchar(50)
)
as
begin

	select	code
			,description
			,scoring_reff_type
			,scoring_reff_name
			,is_active
	FROM	dbo.master_scoring
	where	code = @p_code ;

end ;
