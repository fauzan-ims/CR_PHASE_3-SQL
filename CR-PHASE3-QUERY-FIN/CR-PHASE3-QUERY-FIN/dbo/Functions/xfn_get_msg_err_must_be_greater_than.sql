create function dbo.xfn_get_msg_err_must_be_greater_than
(
	@p_columnA		nvarchar(50)
	,@p_columnB		nvarchar(50)
)
returns nvarchar(max)
--WITH ENCRYPTION|SCHEMABINDING, ...
as
begin
	
	declare @static_err nvarchar(max)

	set @static_err = @p_columnA + ' must be greater than ' + @p_columnB;

    return @static_err

end
