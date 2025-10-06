CREATE FUNCTION dbo.xfn_get_personal_age
(
	@p_reff_no	nvarchar(50) = null
)
returns decimal(18,2)
as
begin
	declare @value	int = 0

		begin
			
			select	@value = reff_name 
			from	dbo.application_external_data
			where	reff_value = '99999'

		end
	
    return @value;

end
