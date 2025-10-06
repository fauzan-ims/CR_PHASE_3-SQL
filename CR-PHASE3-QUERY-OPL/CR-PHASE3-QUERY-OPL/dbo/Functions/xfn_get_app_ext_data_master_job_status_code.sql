create function [dbo].[xfn_get_app_ext_data_master_job_status_code]
(
	@p_reff_no nvarchar(50) = null
)
returns nvarchar(250)
as
begin
	declare @string nvarchar(250) = '';

	select	@string = reff_value_string
	from	dbo.application_external_data
	where	application_no = @p_reff_no
			and remark	   = 'DataScoringPersonalObj'
			and reff_name  = 'MrJobStatCode' ;

	return @string ;
end ;