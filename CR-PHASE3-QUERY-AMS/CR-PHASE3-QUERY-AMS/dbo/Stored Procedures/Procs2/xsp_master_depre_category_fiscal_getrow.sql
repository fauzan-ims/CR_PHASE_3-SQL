CREATE PROCEDURE dbo.xsp_master_depre_category_fiscal_getrow
(
	@p_code nvarchar(50)
,@p_company_code nvarchar(50)
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
	from	master_depre_category_fiscal
	where	code = @p_code 
			and company_code = @p_company_code ;
end ;
