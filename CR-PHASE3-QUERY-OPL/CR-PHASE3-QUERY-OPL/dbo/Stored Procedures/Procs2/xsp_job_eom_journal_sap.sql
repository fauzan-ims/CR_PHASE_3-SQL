/*
exec xsp_job_eom_journal_sap
*/
-- Louis Rabu, 25 Oktober 2023 19.28.12 --
CREATE procedure dbo.xsp_job_eom_journal_sap
as
begin
	declare @msg	   nvarchar(max)
			,@eod_date datetime = dbo.xfn_get_system_date() ;

	begin try
		if (day(dateadd(day, 1, @eod_date)) = 1)
		begin
			exec dbo.xsp_rpt_ext_interest_expense_insert ;

			exec dbo.xsp_rpt_ext_other_operational_income_insert ;

			exec dbo.xsp_rpt_ext_revenue_insert ;

			exec dbo.xsp_rpt_ext_overdue_insert ;

			exec dbo.xsp_rpt_ext_write_off_insert ;

			exec dbo.xsp_rpt_ext_agreement_main_insert ;

			exec dbo.xsp_rpt_ext_agreement_asset_insert ;
		end ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;There is an error.' + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
