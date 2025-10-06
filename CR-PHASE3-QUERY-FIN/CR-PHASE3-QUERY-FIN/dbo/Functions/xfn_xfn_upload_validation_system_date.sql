CREATE FUNCTION dbo.xfn_xfn_upload_validation_system_date
(
	@p_value			datetime
	,@p_column			nvarchar(250)
)
returns nvarchar(max)
--WITH ENCRYPTION|SCHEMABINDING, ...value
as
begin
	
	declare @static_err nvarchar(max)

	if (cast(@p_value as date) > cast(dbo.xfn_get_system_date() as date))
	begin
		set @static_err = @p_column + ' must be less than System Date, ';
	end

    return @static_err

end


