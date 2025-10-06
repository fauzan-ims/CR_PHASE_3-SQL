CREATE FUNCTION dbo.xfn_get_msg_err_must_be_greater_or_equal_than
(
	@p_columna		nvarchar(250)
	,@p_columnb		nvarchar(250)
)
returns nvarchar(max)
--WITH ENCRYPTION|SCHEMABINDING, ...
as
begin
	
	declare @static_err nvarchar(max)

	set @static_err = @p_columnA + ' must be greater than or equal to ' + @p_columnB;

    return @static_err

end



