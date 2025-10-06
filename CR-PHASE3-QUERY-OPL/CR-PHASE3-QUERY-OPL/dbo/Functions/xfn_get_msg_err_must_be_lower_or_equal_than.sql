CREATE FUNCTION dbo.xfn_get_msg_err_must_be_lower_or_equal_than
(
	@p_columnA		nvarchar(250)
	,@p_columnB		nvarchar(250)
)
returns nvarchar(max)
--WITH ENCRYPTION|SCHEMABINDING, ...
as
begin
	
	declare @static_err nvarchar(max)

	set @static_err = @p_columnA + ' must be less than or equal than ' + @p_columnB;

    return @static_err

end




