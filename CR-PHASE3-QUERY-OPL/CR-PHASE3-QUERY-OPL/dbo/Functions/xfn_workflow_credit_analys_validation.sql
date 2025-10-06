CREATE FUNCTION dbo.xfn_workflow_credit_analys_validation
(
	@p_reff_code nvarchar(50)
)
returns nvarchar(4000)
as
begin
	declare @result		  nvarchar(4000) = ''
			,@client_code nvarchar(50) ;

	if exists
	(
		select	1
		from	dbo.application_main
		where	application_no = @p_reff_code
	)
	begin
		select	@client_code = client_code
		from	dbo.application_main
		where	application_no = @p_reff_code ;

		if not exists
		(
			select	1
			from	dbo.workflow_input_result
			where	reff_code = @p_reff_code 
		)
		begin
			set @result = 'Please input Recommendation' ;
		end ;
		else if exists
		(
			select	1
			from	dbo.workflow_input_result
			where	reff_code				   = @p_reff_code
					and isnull(ca_remarks, '') = ''
					and cre_date			   >
					(
						select	max(cre_date)
						from	dbo.application_log
						where	application_no = @p_reff_code
					)
		)
		begin
			set @result = 'Please input Recommendation' ;
		end ;
		--else
		--begin
		--	if exists
		--	(
		--		select	1
		--		from	dbo.client_kyc ck
		--				inner join dbo.client_kyc_detail ckd on (ckd.client_code = ck.client_code)
		--		where	ck.client_code						 = @client_code 
		--				and isnull(remarks_pep, '')			 = ''
		--				and isnull(remarks_slik, '')		 = ''
		--				and isnull(remarks_dtto, '')		 = ''
		--				and isnull(remarks_proliferasi, '')	 = ''
		--				and isnull(remarks_npwp, '')		 = ''
		--				and isnull(remarks_dukcapil, '')	 = ''
		--				and isnull(remarks_jurisdiction, '') = ''
		--				and isnull(remarks, '')				 = ''
		--	)
		--	begin
		--		set @result = 'Client KYC Info is not Complete'; 
		--	end ;
		--end ;
	end ;
	else if exists
	(
		select	1
		from	dbo.drawdown_main
		where	drawdown_no = @p_reff_code
	)
	begin
		if exists
		(
			select	1
			from	dbo.workflow_input_result
			where	reff_code				   = @p_reff_code
					and isnull(ca_remarks, '') = ''
					and cre_date			   >
					(
						select	max(cre_date)
						from	dbo.drawdown_log
						where	drawdown_no = @p_reff_code
					)
		)
		begin
			set @result = 'Please input Recommendation' ;
		end ;
	end ; 

	return @result ;
end ;
