

CREATE function dbo.xfn_get_system_encryptbypassphrase
(
	@p_temp_reff varchar(max)
)
returns varbinary(max)
as
begin
	declare @encryptbypassphrase varbinary(max) ;

	set @encryptbypassphrase = encryptbypassphrase(dbo.xfn_get_system_key(), @p_temp_reff, 1, '') ;

	return @encryptbypassphrase ;
end ;
