---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[xsp_master_machinery_model_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mvm.code
			,machinery_merk_code
			,mv.description 'machinery_merk_name'
			,machinery_subcategory_code
			,mvs.description 'machinery_subcategory_name'
			,mmc.code 'machinery_category_code'
			,mmc.description 'machinery_category_name'
			,mvm.description
			,mvm.is_active
	from	master_machinery_model mvm
			inner join dbo.master_machinery_merk mv on (mv.code			 = mvm.machinery_merk_code)
			inner join dbo.master_machinery_subcategory mvs on (mvs.code = mvm.machinery_subcategory_code)
			inner join dbo.master_machinery_category mmc on (mmc.code	 = mvs.machinery_category_code)
	where	mvm.code = @p_code ;
end ;

