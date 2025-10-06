--created by, Rian at 24/05/2023 

CREATE procedure xsp_application_survey_customer_getrow
(
	@p_application_survey_code	nvarchar(50)
	,@p_id						bigint
)
as
begin
	select	id
		   ,application_survey_code
		   ,name
		   ,business
		   ,business_location
		   ,unit
		   ,additional_info
	from	dbo.application_survey_customer
	where	application_survey_code = @p_application_survey_code
			and id					= @p_id ;
end
