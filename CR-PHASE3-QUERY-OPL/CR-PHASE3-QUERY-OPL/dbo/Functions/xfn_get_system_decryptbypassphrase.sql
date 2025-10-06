CREATE function dbo.xfn_get_system_decryptbypassphrase
(
	@p_temp_reff varbinary(max)
)
returns varchar(max)
as
begin
	declare @decryptbypassphrase varchar(max) ;

	set @decryptbypassphrase = convert(varchar, decryptbypassphrase(dbo.xfn_get_system_key(), @p_temp_reff, 1, '')) ;

	return @decryptbypassphrase ;
end ;
