CREATE FUNCTION [dbo].[fn_generate_md5]
(	
	@p_pass	nvarchar(20)
)
returns nvarchar(20)
as
begin
	
	return convert(nvarchar(32), hashbytes('md5', @p_pass))

end


