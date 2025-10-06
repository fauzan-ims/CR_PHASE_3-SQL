/*
	Created : Yunus Muslim, 19 Desember 2018
*/
CREATE PROCEDURE dbo.xsp_sys_lookup_getrow
(
	@p_code			nvarchar(50)
)as
begin

	select	code
			,sp_name
			,description
			,mod_date
	from	sys_lookup
	where	code = @p_code
end
