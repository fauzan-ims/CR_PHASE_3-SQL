CREATE FUNCTION dbo.xfn_get_msg_err_code_already_exist
()
returns nvarchar(max)
--WITH ENCRYPTION|SCHEMABINDING, ...
as
begin
	
	declare @static_err nvarchar(max)

	set @static_err = 'Code already exist';

    return @static_err

end


