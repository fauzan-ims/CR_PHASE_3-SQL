CREATE FUNCTION [dbo].[xfn_get_personal_job]
(
	@p_reff_no	nvarchar(50) = null
)
returns nvarchar(250)
as
begin
	declare @value nvarchar(250) = ''

		begin
			
			select	@value = cpi.work_type_code
			from	dbo.application_main am
					inner join dbo.client_personal_work cpi on cpi.client_code = am.client_code
			where	am.application_no =  @p_reff_no

		end
	
    return @value;

end
