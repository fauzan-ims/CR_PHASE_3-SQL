---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure [dbo].[xsp_master_electronic_unit_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	u.code
			,u.electronic_category_code
			,c.description 'electronic_category_name'
			,u.electronic_subcategory_code
			,s.description 'electronic_subcategory_name'
			,u.electronic_merk_code
			,m.description 'electronic_merk_name'
			,u.electronic_model_code
			,mo.description 'electronic_model_name'
			,electronic_name
			,u.description
			,u.is_active
	from	master_electronic_unit u
			inner join dbo.master_electronic_category c on (c.code	  = u.electronic_category_code)
			inner join dbo.master_electronic_subcategory s on (s.code = u.electronic_subcategory_code)
			inner join dbo.master_electronic_merk m on (m.code		  = u.electronic_merk_code)
			inner join dbo.master_electronic_model mo on (mo.code	  = u.electronic_model_code)
	where	u.code = @p_code ;
end ;


