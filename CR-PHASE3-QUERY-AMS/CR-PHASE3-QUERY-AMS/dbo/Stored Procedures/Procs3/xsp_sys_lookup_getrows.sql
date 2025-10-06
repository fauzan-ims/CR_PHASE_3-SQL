/*
	Created : Yunus Muslim, 19 Desember 2018
*/
CREATE PROCEDURE [dbo].[xsp_sys_lookup_getrows]
(
	@p_keywords	nvarchar(50)
)as
begin

	select	code
			,sp_name
			,description
	from	sys_lookup
	where	(		
					code				like 	'%' + @p_keywords + '%'
				or	sp_name				like 	'%' + @p_keywords + '%'
				or	description			like	'%' + @p_keywords + '%'
			)							

end
