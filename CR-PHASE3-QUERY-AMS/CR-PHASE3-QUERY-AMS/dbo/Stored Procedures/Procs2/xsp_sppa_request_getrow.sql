CREATE PROCEDURE [dbo].[xsp_sppa_request_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,register_code
			,register_date
			,register_status
	from	sppa_request
	where	code = @p_code ;
end ;

