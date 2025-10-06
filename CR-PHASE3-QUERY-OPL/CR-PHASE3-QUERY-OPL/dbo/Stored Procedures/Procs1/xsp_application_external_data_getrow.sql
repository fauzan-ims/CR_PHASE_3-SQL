create procedure dbo.xsp_application_external_data_getrow
(
	@p_id bigint
)
as
begin
	select	id
		   ,reff_name
		   ,reff_value
		   ,reff_value_datatype
		   ,reff_value_string
		   ,reff_value_number
		   ,remark
	from	dbo.application_external_data 
	where	id = @p_id;
end ;
