--created by raffy 15/12/2023
CREATE FUNCTION dbo.xfn_document_movement_get_send_type
(
	@p_code	nvarchar(50) = null
)
returns nvarchar(250)
as
begin
	declare @value nvarchar(250) = ''
			,@movement_type		nvarchar(50)
			,@movement_location	nvarchar(50);

	select @movement_location	= movement_location
			,@movement_type		= movement_type
	from dbo.document_movement
	where code = @p_code

	IF (@movement_type = 'SEND') AND (@movement_location = 'CLIENT')
		begin
			set @value = 'RELEASE'
		end 
	IF (@movement_type = 'SEND') AND (@movement_location = 'BORROW CLIENT') OR (@movement_location = 'THIRD PARTY') OR (@movement_location = 'BRANCH') OR (@movement_location = 'DEPARTMENT')
		begin
			set @value = 'BORROW'
		end
	
    return @value;

end
