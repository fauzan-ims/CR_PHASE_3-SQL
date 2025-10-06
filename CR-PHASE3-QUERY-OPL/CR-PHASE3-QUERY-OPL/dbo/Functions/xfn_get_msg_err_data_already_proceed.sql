CREATE FUNCTION dbo.xfn_get_msg_err_data_already_proceed
()
returns nvarchar(max)
--WITH ENCRYPTION|SCHEMABINDING, ...
as
begin
	
	declare @static_err nvarchar(max)

	set @static_err = 'Data already proceed';

    return @static_err

end

