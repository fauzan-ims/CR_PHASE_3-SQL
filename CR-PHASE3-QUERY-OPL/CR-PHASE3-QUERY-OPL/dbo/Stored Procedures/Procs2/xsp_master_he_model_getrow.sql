---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[xsp_master_he_model_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mvm.code
			,he_merk_code
			,mv.description 'he_merk_name'
			,he_subcategory_code
			,mvs.description 'he_subcategory_name'
			,mmc.code 'he_category_code'
			,mmc.description 'he_category_name'
			,mvm.description
			,mvm.is_active
	from	master_he_model mvm
			inner join dbo.master_he_merk mv on (mv.code			 = mvm.he_merk_code)
			inner join dbo.master_he_subcategory mvs on (mvs.code = mvm.he_subcategory_code)
			inner join dbo.master_he_category mmc on (mmc.code	 = mvs.he_category_code)
	where	mvm.code = @p_code ;
end ;

