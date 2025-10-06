CREATE FUNCTION dbo.xfn_get_msg_err_must_be_equal_to
(
	@p_columnA		nvarchar(250)
	,@p_columnB		nvarchar(250)
)
returns nvarchar(max)
--WITH ENCRYPTION|SCHEMABINDING, ...
as
begin
	
	declare @static_err nvarchar(max)

	set @static_err = @p_columnA + ' must be equal to ' + @p_columnB;

    return @static_err

end

