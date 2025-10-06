
CREATE function dbo.xfn_get_app_ext_data_line_of_business
(
	@p_reff_no nvarchar(50) = null
)
returns nvarchar(30)
as
begin
	declare @nvarchar nvarchar(30) = N'' ;

	select	@nvarchar = case
							when no_of_client = 'MORE THAN 3' then '>3'
							else NO_OF_CLIENT
						end
	from	dbo.application_survey
	where	application_no = @p_reff_no ;

	return @nvarchar ;
end ;
