create function dbo.xfn_get_system_key ()
returns nvarchar(max)
as
begin
	declare @passpharsekey nvarchar(max) = 'IMS' ;

	return @passpharsekey ;
end ;

