
CREATE procedure [dbo].[xsp_warning_letter__for_view_sp]

as
begin

		select		am.agreement_external_no 'agreement_no'
					,wl.branch_name 'branch'			
					,client_name 'client'				
					,wl.letter_no 'Sp no'
					,wl.letter_type 'letter type'
					,wl.overdue_days	'overdue days'	
					,wl.generate_type 'generate type'
					--wl.CODE
		from		dbo.warning_letter wl
		inner join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
		--group by am.AGREEMENT_EXTERNAL_NO
		order by wl.agreement_no,wl.letter_type asc
end ;
