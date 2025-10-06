
CREATE FUNCTION dbo.xfn_get_msg_err_generic
()
returns nvarchar(max)
--WITH ENCRYPTION|SCHEMABINDING, ...
as
begin
	
	declare @static_err nvarchar(max)
	
	set @static_err = 'warning' ;

    return @static_err

end



