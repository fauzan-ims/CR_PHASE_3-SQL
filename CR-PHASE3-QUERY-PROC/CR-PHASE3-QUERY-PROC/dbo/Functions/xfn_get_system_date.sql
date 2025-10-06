CREATE FUNCTION [dbo].[xfn_get_system_date]
()
returns datetime
as
begin
	declare @date_string datetime 

	SELECT @date_string = VALUE FROM [dbo].sys_global_param
	where CODE = 'SYSDATE'

    return @date_string;

end


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_get_system_date] TO [ims-raffyanda]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_get_system_date] TO [sabilla.larrasati]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_get_system_date] TO [eddy.rakhman]
    AS [dbo];

