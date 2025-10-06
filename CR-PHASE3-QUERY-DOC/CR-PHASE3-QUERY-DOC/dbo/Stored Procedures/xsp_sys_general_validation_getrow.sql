CREATE procedure dbo.xsp_sys_general_validation_getrow
(
	@p_code		  nvarchar(50)
	,@p_is_active nvarchar(50) = 'ALL'
)
as
begin
	select	code
			,api_name
			,is_active
	from	sys_general_validation
	where	code		  = @p_code
			and is_active = case @p_is_active
								when 'ALL' then is_active
								else @p_is_active
							end ;
end ;
