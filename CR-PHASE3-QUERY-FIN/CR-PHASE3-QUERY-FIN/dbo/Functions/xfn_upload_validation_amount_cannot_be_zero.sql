CREATE function dbo.xfn_upload_validation_amount_cannot_be_zero
(
	@p_value					decimal(18,2)
)
returns nvarchar(max)
as
begin
	
	declare @static_err nvarchar(max)

	if @p_value <= 0
	begin
		set @static_err = 'must be greater than zero, ';
    end

    return @static_err

end



