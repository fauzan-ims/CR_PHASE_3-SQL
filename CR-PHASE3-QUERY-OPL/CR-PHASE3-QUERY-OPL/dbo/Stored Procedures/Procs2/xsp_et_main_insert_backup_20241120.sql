--SELECT * FROM dbo.ET_MAIN 

--SELECT * FROM dbo.AGREEMENT_MAIN where AGREEMENT_NO IN
--(
--N'0000028.4.03.12.2020',
--N'0000030.4.03.01.2021',
--N'0000029.4.03.01.2021'
--)

create PROCEDURE dbo.xsp_et_main_insert_backup_20241120 
(
	@p_code			   nvarchar(50)	  = '' output
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	,@p_agreement_no   nvarchar(50)
	,@p_et_status	   nvarchar(10)
	,@p_et_date		   datetime
	,@p_et_amount	   decimal(18, 2) = 0
	,@p_et_remarks	   nvarchar(4000) = ''
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@et_exp_date			datetime
			,@year					nvarchar(2)
			,@month					nvarchar(2)
			,@code					nvarchar(50)
			,@opl_status			nvarchar(15)
			,@transaction_code		nvarchar(50)
			,@transaction_amount	decimal(18, 2)
			,@disc_pct				decimal(9, 6)
			,@disc_amount			decimal(18, 2)
			,@order_key				int
			,@is_amount_editable	nvarchar(1)
			,@is_discount_editable	nvarchar(1)
			,@is_transaction		nvarchar(1)
			,@total_amount			decimal(18, 2) 
			,@agreement_external_no	nvarchar(50)

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'OPLEM'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'ET_MAIN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		select	@et_exp_date = dateadd(day, cast(value as int), @p_et_date)
		from	dbo.sys_global_param
		where	code = 'EXPOPL' ;

		if not exists
		(
			select	1
			from	dbo.agreement_main
			where	agreement_no			   = @p_agreement_no
					and isnull(opl_status, '') = ''
		)
		begin
			select	@opl_status				= opl_status
					,@agreement_external_no = agreement_external_no
			from	dbo.agreement_main
			where	agreement_no = @p_agreement_no ;

			set @msg = N'Agreement : ' + @p_agreement_no + N' already in use at ' + @opl_status ;

			raiserror(@msg, 16, 1) ;
		end ;

		if exists
		(
			select	1
			from	et_main
			where	agreement_no = @p_agreement_no
					and et_status not in
		(
			'CANCEL', 'APPROVE', 'EXPIRED', 'REJECT'
		)
		)
		begin
			select	@p_et_status			= et.et_status
					,@agreement_external_no	= am.agreement_external_no
			from	et_main et
			inner join dbo.agreement_main am on (am.agreement_no = et.agreement_no)
			where	et.agreement_no = @p_agreement_no
					and et_status not in
			(
				'CANCEL', 'APPROVE', 'EXPIRED', 'REJECT'
			) ;

			set @msg = N'Agreement : ' + @p_agreement_no + N' already in transaction with Status : ' + @p_et_status ;

			raiserror(@msg, 16, -1) ;
		end ;
		  
		--if (@p_agreement_no not in ('0000870.4.08.12.2022','0001081.4.01.07.2022','0001034.4.01.05.2022','0002090.4.10.03.2024','0000942.4.01.12.2021','0001089.4.08.08.2023','0001090.4.08.08.2023','0001091.4.08.08.2023'
		--	,'0000599.4.01.01.2021','0000600.4.01.01.2021','0001829.4.10.01.2024','0001556.4.01.11.2023','0001784.4.10.01.2024','0000003.4.34.03.2021','0001183.4.08.10.2023','0001695.4.01.01.2024','0000128.4.03.02.2022'
		--	,'0001777.4.10.01.2024','0001203.4.01.12.2022','0002100.4.10.03.2024','0000125.4.03.02.2022','0002140.4.10.03.2024','0001058.4.08.07.2023','0000869.4.01.10.2021','0000038.4.38.03.2023','0001751.4.10.01.2024'
		--	,'0000220.4.03.09.2023')) --untuk data maintenance
		--begin
		--	if (@p_et_date < dbo.xfn_get_system_date())
		--	begin
		--		set @msg = dbo.xfn_get_msg_err_must_be_greater_or_equal_than('Date', 'System Date') ;

		--		raiserror(@msg, 16, 1) ;
		--	end ;
		--end

		IF (@p_agreement_no NOT IN ( '0000870.4.08.12.2022', '0001081.4.01.07.2022', '0001034.4.01.05.2022',
									 '0002090.4.10.03.2024', '0000942.4.01.12.2021', '0001089.4.08.08.2023',
									 '0001090.4.08.08.2023', '0001091.4.08.08.2023', '0000599.4.01.01.2021',
									 '0000600.4.01.01.2021', '0001829.4.10.01.2024', '0001556.4.01.11.2023',
									 '0001784.4.10.01.2024', '0000003.4.34.03.2021', '0001183.4.08.10.2023',
									 '0001695.4.01.01.2024', '0000128.4.03.02.2022', '0001777.4.10.01.2024',
									 '0001203.4.01.12.2022', '0002100.4.10.03.2024', '0000125.4.03.02.2022',
									 '0002140.4.10.03.2024', '0001058.4.08.07.2023', '0000869.4.01.10.2021',
									 '0000038.4.38.03.2023', '0001751.4.10.01.2024', '0000220.4.03.09.2023',
									 '0000008.4.11.12.2021', N'0000028.4.06.04.2022', N'0000029.4.06.04.2022',
									 N'0000060.4.03.08.2021', N'0000061.4.03.08.2021', N'0000062.4.03.08.2021',
									 N'0000063.4.03.09.2021', N'0000064.4.03.09.2021', N'0000065.4.03.09.2021',
									 N'0000066.4.03.10.2021', N'0000080.4.38.08.2023', N'0000081.4.38.08.2023',
									 N'0000112.4.38.09.2023', N'0000118.4.03.04.2022', N'0000119.4.03.03.2022',
									 N'0000120.4.03.04.2022', N'0000121.4.03.03.2022', N'0000122.4.03.04.2022',
									 N'0000130.4.03.04.2022', N'0000131.4.03.04.2022', N'0000132.4.03.06.2022',
									 N'0000133.4.03.06.2022', N'0000134.4.03.06.2022', N'0000208.4.03.08.2023',
									 N'0000212.4.03.08.2023', N'0000216.4.03.09.2023', N'0000227.4.03.09.2023',
									 N'0000228.4.03.09.2023', N'0001507.4.01.09.2023', N'0001688.4.01.12.2023',
									 N'0001773.4.08.01.2024', N'0001844.4.08.01.2024', N'0001900.4.08.02.2024',
									 N'0002183.4.10.04.2024', N'0002184.4.10.04.2024', N'0002185.4.10.04.2024',
									 N'0002186.4.10.04.2024', N'0002327.4.10.05.2024', N'0002332.4.08.05.2024',
									 '0002735.4.10.08.2024', '0002700.4.08.08.2024', '0000038.4.38.03.2023',
									 '0002825.4.08.09.2024', '0002826.4.08.09.2024', '0002883.4.08.09.2024',
									 '0002873.4.08.09.2024', '0002916.4.08.09.2024', '0002962.4.08.09.2024',
									 '0002926.4.08.09.2024', '0002880.4.08.09.2024', '0002918.4.08.09.2024',
									 '0002963.4.08.09.2024', '0003025.4.08.10.2024', '0002887.4.08.09.2024',
									 '0003064.4.08.10.2024', '0002889.4.08.09.2024', '0002940.4.08.09.2024',
									 '0003053.4.08.10.2024', '0002972.4.08.09.2024', '0003033.4.08.10.2024',
									 '0002941.4.08.09.2024', '0003014.4.08.10.2024', '0002946.4.08.09.2024',
									 '0003035.4.08.10.2024', '0003064.4.08.10.2024', '0003052.4.08.10.2024',
									 '0003029.4.08.10.2024', '0002937.4.08.09.2024', '0003093.4.08.10.2024',
									 '0002976.4.08.09.2024', '0002922.4.08.09.2024', '0002968.4.08.09.2024',
									 '0001416.4.01.07.2023', '0002437.4.10.06.2024', '0000238.4.10.07.2019',
									 '0000237.4.10.07.2019', '0002822.4.08.09.2024', '0002853.4.08.09.2024',
									 '0002865.4.08.09.2024', '0002867.4.08.09.2024', '0002870.4.08.09.2024',
									 '0002877.4.08.09.2024', '0002879.4.08.09.2024', '0002899.4.08.09.2024',
									 '0002902.4.08.09.2024', '0002912.4.08.09.2024', '0002921.4.08.09.2024',
									 '0002932.4.08.09.2024', '0002945.4.08.09.2024', '0002977.4.08.09.2024',
									 '0003000.4.08.10.2024', '0003001.4.08.10.2024', '0003003.4.08.10.2024',
									 '0003009.4.08.10.2024', '0003021.4.08.10.2024', '0003022.4.08.10.2024',
									 '0003030.4.08.10.2024', '0003038.4.08.10.2024', '0003042.4.08.10.2024',
									 '0003043.4.08.10.2024', '0003048.4.08.10.2024', '0003063.4.08.10.2024',
									 '0003078.4.08.10.2024', '0003079.4.08.10.2024', '0003085.4.08.10.2024',
									 '0003103.4.08.10.2024', '0003108.4.08.10.2024', '0003109.4.08.10.2024',
									 '0003111.4.08.10.2024', '0003115.4.08.10.2024', '0003128.4.08.10.2024',
									 '0003146.4.08.10.2024', '0003153.4.08.10.2024', '0003156.4.08.10.2024',
									 '0003163.4.08.10.2024', '0003167.4.08.10.2024', '0003169.4.08.10.2024',
									 '0003181.4.08.10.2024', '0003182.4.08.10.2024','0000771.4.10.09.2023','0000237.4.10.07.2019','0000238.4.10.07.2019','0000181.4.04.05.2023'
									 ,'0000181.4.04.05.2023'
								   )
		   ) --untuk data maintenance
		BEGIN
			IF (@p_et_date < dbo.xfn_get_system_date())
			BEGIN
				SET @msg = dbo.xfn_get_msg_err_must_be_greater_or_equal_than('Date', 'System Date');

				RAISERROR(@msg, 16, 1);
			END;
		END;

		insert into et_main
		(
			code
			,branch_code
			,branch_name
			,agreement_no
			,et_status
			,et_date
			,et_exp_date
			,et_amount
			,et_remarks
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@code
			,@p_branch_code
			,@p_branch_name
			,@p_agreement_no
			,@p_et_status
			,@p_et_date
			,@et_exp_date
			,@p_et_amount
			,@p_et_remarks
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		insert into dbo.et_detail
		(
			et_code
			,asset_no
			,os_rental_amount
			,is_terminate
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select		@code
					,aa.asset_no
					,dbo.xfn_agreement_get_all_os_principal(@p_agreement_no, @p_et_date, aa.asset_no)
					,'1'
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
		from		dbo.agreement_asset aa
		where		aa.agreement_no		= @p_agreement_no
					and aa.asset_status = 'RENTED'
		group by	aa.asset_no ;

		--insert to et_transaction
		exec dbo.xsp_et_transaction_generate @p_et_code			= @code
											 ,@p_agreement_no	= @p_agreement_no
											 ,@p_et_date		= @p_et_date
											 --
											 ,@p_cre_date		= @p_cre_date
											 ,@p_cre_by			= @p_cre_by
											 ,@p_cre_ip_address = @p_cre_ip_address
											 ,@p_mod_date		= @p_mod_date
											 ,@p_mod_by			= @p_mod_by
											 ,@p_mod_ip_address = @p_mod_ip_address ;

		select	@total_amount = isnull(sum(total_amount), 0)
		from	dbo.et_transaction
		where	et_code			   = @code
				and is_transaction = '1' ;

		update	dbo.et_main
		set		et_amount			= @total_amount
				--
				,@p_mod_date		= @p_mod_date
				,@p_mod_by			= @p_mod_by
				,@p_mod_ip_address	= @p_mod_ip_address
		where	code				= @code ;

		-- update opl status
		exec dbo.xsp_agreement_main_update_opl_status @p_agreement_no = @p_agreement_no
													  ,@p_status = N'ET' ;

		set @p_code = @code ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
