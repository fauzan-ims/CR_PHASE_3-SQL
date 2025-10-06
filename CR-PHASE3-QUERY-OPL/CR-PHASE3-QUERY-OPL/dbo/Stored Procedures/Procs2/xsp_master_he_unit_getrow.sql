---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure [dbo].[xsp_master_he_unit_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	u.code
			,u.he_category_code
			,c.description 'he_category_name'
			,u.he_subcategory_code
			,s.description 'he_subcategory_name'
			,u.he_merk_code
			,m.description 'he_merk_name'
			,u.he_model_code
			,mo.description 'he_model_name'
			,u.he_type_code
			,t.description 'he_type_name'
			,u.he_name
			,u.description
			,u.is_active
	from	master_he_unit u
			inner join dbo.master_he_category c on (c.code	  = u.he_category_code)
			inner join dbo.master_he_subcategory s on (s.code = u.he_subcategory_code)
			inner join dbo.master_he_merk m on (m.code		  = u.he_merk_code)
			inner join dbo.master_he_model mo on (mo.code	  = u.he_model_code)
			inner join dbo.master_he_type t on (t.code		  = u.he_type_code)
	where	u.code = @p_code ;
end ;


