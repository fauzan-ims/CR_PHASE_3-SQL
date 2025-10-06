CREATE PROCEDURE dbo.xsp_master_depre_category_commercial_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,company_code
			,description
			,method_type
			,usefull
			,rate
			,is_active
	from	master_depre_category_commercial
	where	code = @p_code ;
end ;
