CREATE PROCEDURE dbo.xsp_rpt_ext_agreement_main_insert 
as
begin
	declare @msg			   nvarchar(max)
			,@p_cre_date	   datetime		=	EOMONTH(DATEADD(MONTH, -1, dbo.xfn_get_system_date()))
			,@p_cre_by		   nvarchar(15) = 'job'
			,@p_cre_ip_address nvarchar(15) = 'job' 
			,@time				datetime = getdate()

	begin try
		/*
		base nya data agreement
		data ini membentuk sequence. sequence dipakai di tabel lain
		
		*/
		delete	dbo.rpt_ext_agreement_main where 1=1
		--where	cast(as_of as date) = cast(@p_cre_date as date) ; -- data selalu di cleanup

		insert into rpt_ext_agreement_main
		(
			agreement_id
			,go_live_date
			,end_contact_date
			,tenor
			,as_of
			,create_date
			,create_time
			,sequence
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)

		SELECT  am.agreement_external_no  
				,am.agreement_date --go_live_date
				,ai.maturity_date --end_contact_date
				,am.periode
				,@p_cre_date
				,cast(getdate() as date)
				,@time
				,asq.running_no
								--
				,getdate()
				,@p_cre_by
				,@p_cre_ip_address
				,getdate()
				,@p_cre_by
				,@p_cre_ip_address
		FROM  ifinopl.dbo.XXX_AGREEMENT_MAIN_AFTER_EOM_20250731 am 
		INNER JOIN ifinopl.dbo.agreement_squence_number_anaplan asq ON asq.agreement_external_no = am.agreement_external_no
		LEFT JOIN ifinopl.dbo.agreement_information ai ON ai.agreement_no = am.agreement_no
		WHERE (am.agreement_status = 'GO LIVE') OR (am.AGREEMENT_STATUS = 'TERMINATE' AND CAST(am.TERMINATION_DATE AS DATE) >= @p_cre_date)
		--and
		--am.AGREEMENT_EXTERNAL_NO IN ( N'0000039/4/01/11/2023', N'0000040/4/38/03/2023', N'0000045/4/38/04/2023',
  --                                      N'0000059/4/01/08/2014', N'0000061/4/38/06/2023', N'0000062/4/04/10/2020',
  --                                      N'0000064/4/04/10/2020', N'0000065/4/04/10/2020', N'0000070/4/38/07/2023',
  --                                      N'0000073/4/38/08/2023', N'0000119/4/38/10/2023', N'0000120/4/38/10/2023',
  --                                      N'0000121/4/38/11/2023', N'0000122/4/38/11/2023', N'0000313/4/10/03/2020',
  --                                      N'0000315/4/10/04/2020', N'0000320/4/01/07/2019', N'0000392/4/01/12/2019',
  --                                      N'0000789/4/08/10/2022', N'0001048/4/01/06/2022', N'0001176/4/08/10/2023',
  --                                      N'0001191/4/08/11/2023', N'0000016/4/16/02/2015', N'0000017/4/16/03/2015',
  --                                      N'0000018/4/34/08/2022', N'0000026/4/01/11/2023', N'0000105/4/38/09/2023',
  --                                      N'0000114/4/38/10/2023', N'0000117/4/38/10/2023', N'0000211/4/03/09/2023',
  --                                      N'0000215/4/10/05/2019', N'0000216/4/10/05/2019', N'0000217/4/10/05/2019',
  --                                      N'0000218/4/10/05/2019', N'0000220/4/10/05/2019', N'0000221/4/10/05/2019',
  --                                      N'0000234/4/10/07/2019', N'0000235/4/10/07/2019', N'0000237/4/10/07/2019',
  --                                      N'0000244/4/10/08/2019', N'0000245/4/10/08/2019', N'0000289/4/01/05/2019',
  --                                      N'0000291/4/10/12/2019', N'0000292/4/10/12/2019', N'0000303/4/10/12/2019',
  --                                      N'0000309/4/01/07/2019', N'0000528/4/01/08/2020', N'0000556/4/10/11/2022',
  --                                      N'0000557/4/10/11/2022', N'0000014/4/16/02/2015', N'0000015/4/16/02/2015',
  --                                      N'0000497/4/10/07/2022', N'0000881/4/01/11/2021', N'0001132/4/08/09/2023',
  --                                      N' 0000830/4/10/11/2023', N'0000004/4/11/10/2021', N'0000083/4/38/08/2023',
  --                                      N'0000085/4/38/08/2023', N'0000086/4/03/10/2021', N'0000097/4/38/09/2023',
  --                                      N'0000433/4/10/03/2022', N'0000827/4/10/11/2023', N'0000828/4/10/11/2023',
  --                                      N'0000829/4/10/11/2023', N'0000836/4/01/08/2021', N'0000837/4/01/08/2021',
  --                                      N'0001105/4/01/08/2022', N'0001461/4/01/08/2023', N'0001493/4/01/09/2023',
  --                                      N'0001506/4/01/09/2023', N'0001510/4/01/09/2023', N'0001554/4/01/11/2023',
  --                                      N'0001555/4/01/11/2023', N'0001557/4/01/11/2023', N'0001561/4/01/11/2023',
  --                                      N'0001562/4/01/11/2023 ', N'0001569/4/01/11/2023', N'0001570/4/01/11/2023',
  --                                      N'0001934/4/08/02/2024', N'0001935/4/08/02/2024', N'0002401/4/08/06/2024',
  --                                      N'0002825/4/08/09/2024', N'0002826/4/08/09/2024', N'0001417/4/01/07/2023',
  --                                      N'0001453/4/01/07/2023', N'0001454/4/01/07/2023', N'0001834/4/10/01/2024',
  --                                      N'0001910/4/38/02/2024', N'0002089/4/10/03/2024', N'0002177/4/08/04/2024',
  --                                      N'0002564/4/08/07/2024', N'0003115/4/08/10/2024', N'0001205/4/08/11/2023',
  --                                      N'0001206/4/08/11/2023', N'0001693/4/08/11/2023', N'0001723/4/10/01/2024',
  --                                      N'0002046/4/01/03/2024', N'0002873/4/08/09/2024', N'0002880/4/08/09/2024',
  --                                      N'0002883/4/08/09/2024', N'0002887/4/08/09/2024', N'0002889/4/08/09/2024',
  --                                      N'0002912/4/08/09/2024', N'0002916/4/08/09/2024', N'0002918/4/08/09/2024',
  --                                      N'0002926/4/08/09/2024', N'0002940/4/08/09/2024', N'0002941/4/08/09/2024',
  --                                      N'0002946/4/08/09/2024', N'0002962/4/08/09/2024', N'0002963/4/08/09/2024',
  --                                      N'0002972/4/08/09/2024', N'0003014/4/08/10/2024', N'0003025/4/08/10/2024',
  --                                      N'0003029/4/08/10/2024', N'0003033/4/08/10/2024', N'0003035/4/08/10/2024',
  --                                      N'0003052/4/08/10/2024', N'0003053/4/08/10/2024', N'0003064/4/08/10/2024','0003456/4/10/11/2024'
  --                                    );

		
		insert into rpt_ext_agreement_main
		(
			agreement_id
			,go_live_date
			,end_contact_date
			,tenor
			,as_of
			,create_date
			,create_time
			,sequence
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select  agreement_external_no,
			   null,
			   null,
			   0,
			   @p_cre_date,
			   cast(getdate() as date),
			   @time,
			   running_no,
			   --
			   getdate(),
			   @p_cre_by,
			   @p_cre_ip_address,
			   getdate(),
			   @p_cre_by,
			   @p_cre_ip_address
		from agreement_squence_number_anaplan
		where agreement_external_no in ( 'REPLACEMENT CAR', 'UNIT STOCK' );

		--select	am.agreement_no
		--		,am.agreement_date
		--		,aam.due_date
		--		,am.periode
		--		,@p_cre_date
		--		,cast(am.cre_date as date)
		--		,cast(am.cre_date as time)
		--		,am.agreement_no
		--		--
		--		,@p_cre_date
		--		,@p_cre_by
		--		,@p_cre_ip_address
		--		,@p_cre_date
		--		,@p_cre_by
		--		,@p_cre_ip_address
		--from	dbo.agreement_main am
		--		outer apply
		--(
		--	select	max(aam.due_date) 'due_date'
		--	from	dbo.agreement_asset_amortization aam
		--	where	aam.agreement_no = am.agreement_no
		--) aam ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = N'v' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'e;there is an error.' + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
