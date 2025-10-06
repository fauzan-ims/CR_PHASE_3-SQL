CREATE function [dbo].[xfn_get_personal_houseownership]
(
	@p_reff_no nvarchar(50) = null
)
returns nvarchar(250)
as
begin
	declare @value nvarchar(250) = N'' ;

	begin
		select	@value = reff_value_string
		from	dbo.application_external_data
		where	reff_name = 'MrBuildingOwnershipCode' ;
	end ;

	return @value ;
end ;
