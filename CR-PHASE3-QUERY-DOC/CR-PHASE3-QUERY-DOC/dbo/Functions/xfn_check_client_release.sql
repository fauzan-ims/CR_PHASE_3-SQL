CREATE FUNCTION dbo.xfn_check_client_release
(
	@p_agreement_no nvarchar(50)
)
returns nvarchar(250)
as
begin
	declare @msg nvarchar(250) = '' ;

	if exists
	(
		select	1
		from	dbo.agreement_main
		where	agreement_no		   = @p_agreement_no
				and agreement_status   = 'GO LIVE'
				--and termination_status = 'WO ACC'
	)
	begin
		set @msg = 'Agreement can not be release' ;
	end ;

	return @msg ;
end ;
