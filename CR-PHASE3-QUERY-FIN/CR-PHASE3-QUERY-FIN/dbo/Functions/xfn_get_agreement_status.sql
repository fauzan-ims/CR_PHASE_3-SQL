create function dbo.xfn_get_agreement_status
(
	@p_agreement_no	nvarchar(50)
)
returns nvarchar(50)
as
begin

	declare @status			nvarchar(20)
			,@module_name   nvarchar(250)

	declare curr_getagreement cursor for

	select 	module_name
	from	dbo.master_transaction mt
			inner join journal_gl_link jgl on (jgl.code = mt.gl_link_code)
	where   gl_link_code = 'AGRE'

	open curr_getagreement	
	fetch next from curr_getagreement 
	into @module_name
		
	while @@fetch_status = 0
	begin
				
		exec @status = @module_name @p_agreement_no

		fetch next from curr_getagreement
		into @module_name

	end	

	return @status

end

