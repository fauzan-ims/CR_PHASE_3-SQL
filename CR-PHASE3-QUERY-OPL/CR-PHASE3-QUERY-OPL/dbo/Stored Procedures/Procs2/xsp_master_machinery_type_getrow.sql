---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[xsp_master_machinery_type_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mmt.code
			,mmt.machinery_model_code
			,mmm.description	'machinery_model_name'
			,mmc.description	'machinery_category_name'
			,mms.description	'machinery_subcategory_name'
			,mmr.description	'machinery_merk_name'
			,mmc.code	'machinery_category_code'
			,mms.code	'machinery_subcategory_code'
			,mmr.code	'machinery_merk_code'
			,mmt.description
			,mmt.is_active
	from	master_machinery_type mmt
			inner join dbo.master_machinery_model mmm on (mmm.code = mmt.machinery_model_code)
			inner join dbo.master_machinery_merk mmr on (mmr.code = mmm.machinery_merk_code)
			inner join dbo.master_machinery_subcategory mms on (mms.code = mmm.machinery_subcategory_code)
			inner join dbo.master_machinery_category mmc on (mmc.code = mms.machinery_category_code)
	where	mmt.code = @p_code ;
end ;


