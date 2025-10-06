---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[xsp_master_he_type_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mmt.code
			,mmt.he_model_code
			,mmm.description	'he_model_name'
			,mmc.description	'he_category_name'
			,mms.description	'he_subcategory_name'
			,mmr.description	'he_merk_name'
			,mmc.code	'he_category_code'
			,mms.code	'he_subcategory_code'
			,mmr.code	'he_merk_code'
			,mmt.description
			,mmt.is_active
	from	master_he_type mmt
			inner join dbo.master_he_model mmm on (mmm.code = mmt.he_model_code)
			inner join dbo.master_he_merk mmr on (mmr.code = mmm.he_merk_code)
			inner join dbo.master_he_subcategory mms on (mms.code = mmm.he_subcategory_code)
			inner join dbo.master_he_category mmc on (mmc.code = mms.he_category_code)
	where	mmt.code = @p_code ;
end ;


