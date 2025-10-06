CREATE function dbo.xfn_upload_validation_cannot_be_empty
(
	@p_value					nvarchar(4000)
)
returns nvarchar(max)
as
begin
	
	declare @static_err nvarchar(max)

	if(len(@p_value) = 0)
	begin
		set @static_err = 'cannot be empty, ';
    end

    return @static_err

end



