CREATE FUNCTION dbo.xfn_get_msg_err_generic
()
returns nvarchar(max)
--WITH ENCRYPTION|SCHEMABINDING, ...
as
begin
	
	declare @static_err nvarchar(max)

	set @static_err = 'There is an error';

    return @static_err

end

