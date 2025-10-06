---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[xsp_master_electronic_model_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mvm.code
			,electronic_merk_code
			,mv.description 'electronic_merk_name'
			,electronic_subcategory_code
			,mvs.description 'electronic_subcategory_name'
			,mmc.code 'electronic_category_code'
			,mmc.description 'electronic_category_name'
			,mvm.description
			,mvm.is_active
	from	master_electronic_model mvm
			inner join dbo.master_electronic_merk mv on (mv.code			 = mvm.electronic_merk_code)
			inner join dbo.master_electronic_subcategory mvs on (mvs.code = mvm.electronic_subcategory_code)
			inner join dbo.master_electronic_category mmc on (mmc.code	 = mvs.electronic_category_code)
	where	mvm.code = @p_code ;
end ;

