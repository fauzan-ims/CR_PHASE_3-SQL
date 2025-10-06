CREATE function dbo.xfn_upload_validation_maxlength
(
	@p_value					nvarchar(4000)
	,@p_maxlength				int
)
returns nvarchar(max)
as
begin
	
	declare @static_err nvarchar(max)

	if(len(@p_value) > @p_maxlength)
	begin
		set @static_err = 'must be lower than, ' + convert(nvarchar,@p_maxlength);
    end

    return @static_err

end

