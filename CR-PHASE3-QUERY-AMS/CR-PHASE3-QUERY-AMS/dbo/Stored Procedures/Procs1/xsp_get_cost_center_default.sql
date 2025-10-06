
CREATE procedure [dbo].[xsp_get_cost_center_default]
(
	@p_gl_link_code			nvarchar(50)
	,@p_cost_center_code	nvarchar(50) output
	,@p_cost_center_name	nvarchar(250) output
)
as
begin
    
	select	@p_cost_center_code = '00'
			,@p_cost_center_name = 'Default'
	
end
