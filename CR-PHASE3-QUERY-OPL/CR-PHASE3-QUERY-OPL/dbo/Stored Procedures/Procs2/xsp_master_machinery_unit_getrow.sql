---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure [dbo].[xsp_master_machinery_unit_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mvu.code
			,mvu.machinery_category_code
			,c.description 'machinery_category_name'
			,mvu.machinery_subcategory_code
			,s.description 'machinery_subcategory_name'
			,mvu.machinery_merk_code
			,m.description 'machinery_merk_name'
			,mvu.machinery_model_code
			,mo.description 'machinery_model_name'
			,mvu.machinery_type_code
			,t.description 'machinery_type_name'
			,machinery_name
			,mvu.description
			,mvu.is_active
	from	master_machinery_unit mvu
			inner join dbo.master_machinery_category c on (c.code	 = mvu.machinery_category_code)
			inner join dbo.master_machinery_subcategory s on (s.code = mvu.machinery_subcategory_code)
			inner join dbo.master_machinery_merk m on (m.code		 = mvu.machinery_merk_code)
			inner join dbo.master_machinery_model mo on (mo.code	 = mvu.machinery_model_code)
			inner join dbo.master_machinery_type t on (t.code		 = mvu.machinery_type_code)
	where	mvu.code = @p_code ;
end ;


