CREATE FUNCTION dbo.xfn_get_msg_err_code_already_used
()
returns nvarchar(max)
--WITH ENCRYPTION|SCHEMABINDING, ...
as
begin
	
	declare @static_err nvarchar(max)

	set @static_err = 'The code has already been used in the transaction';

    return @static_err

end
