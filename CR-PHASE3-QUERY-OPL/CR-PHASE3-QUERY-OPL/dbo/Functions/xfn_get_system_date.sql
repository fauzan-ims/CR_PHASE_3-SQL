CREATE FUNCTION dbo.xfn_get_system_date
()
returns datetime
as
begin
	declare @date_string datetime 

	SELECT @date_string = CAST(VALUE AS DATETIME) FROM [dbo].[SYS_GLOBAL_PARAM]
	WHERE CODE = 'SYSDATE'

    return @date_string;

end

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_get_system_date] TO [dsf_lina]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_get_system_date] TO [aryo.budi]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_get_system_date] TO [ims-raffyanda]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_get_system_date] TO [eddy.rakhman]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_get_system_date] TO [bsi-miki.maulana]
    AS [dbo];

