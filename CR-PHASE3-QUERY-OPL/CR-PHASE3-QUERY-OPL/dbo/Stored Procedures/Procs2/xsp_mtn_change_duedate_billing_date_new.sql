CREATE PROCEDURE dbo.xsp_mtn_change_duedate_billing_date_new

(
	 @p_agreement_no nvarchar(50)
	,@p_mod_by nvarchar(50)
	,@p_remark nvarchar(4000)
)
as
begin
	declare @msg				nvarchar(max)
			,@agreement_no		nvarchar(50) = replace(@p_agreement_no, '/', '.')
			,@mod_date			datetime = dbo.xfn_get_system_date()
			,@p_mod_ip_adress	nvarchar(20) = @p_mod_by

	begin transaction;
	begin try

		--SELECT 'BEFORE',DUE_DATE,BILLING_DATE,DESCRIPTION,BILLING_AMOUNT from dbo.AGREEMENT_ASSET_AMORTIZATION where AGREEMENT_NO = @agreement_no
		
		update dbo.AGREEMENT_ASSET_AMORTIZATION
		set DUE_DATE = replace(DUE_DATE,day(DUE_DATE),day(eomonth(DUE_DATE)))
			,BILLING_DATE = replace(BILLING_DATE,day(BILLING_DATE),day(eomonth(BILLING_DATE)))
			,MOD_DATE = @mod_date
			,MOD_BY = @p_mod_by
			,MOD_IP_ADDRESS = @p_mod_by
		where AGREEMENT_NO = @agreement_no

		update AGREEMENT_ASSET_AMORTIZATION
		SET		DESCRIPTION = 'Billing ke ' + CAST(artz.BILLING_NO AS NVARCHAR(2)) + ' dari Periode ' + CONVERT(NVARCHAR(10), period.period_date, 103) + ' sampai dengan ' + CONVERT(NVARCHAR(10), period.period_due_date, 103)
		FROM	dbo.AGREEMENT_ASSET aast
				INNER JOIN dbo.AGREEMENT_ASSET_AMORTIZATION artz ON artz.AGREEMENT_NO = aast.AGREEMENT_NO AND aast.ASSET_NO = artz.ASSET_NO
				inner join dbo.agreement_main am on (am.agreement_no = artz.agreement_no)
				outer apply
				(
					select	billing_no
							,case am.first_payment_type
								 when 'ARR' then DATEADD(DAY, 1,period_date)-- + 1
								 else period_date
							 end 'period_date'
							 ,aa.period_due_date
					from	dbo.xfn_due_date_period(artz.asset_no, cast(artz.billing_no as int)) aa
					where	artz.asset_no = aast.asset_no
					and		aa.billing_no = artz.billing_no
				) period
		where	 artz.AGREEMENT_NO = @agreement_no --AND artz.BILLING_NO IN (19,18,17,16)

		--SELECT 'AFTER',cast(DUE_DATE as date)'DUE_DATE',cast(BILLING_DATE as date)'BILLING_DATE',DESCRIPTION,BILLING_AMOUNT from dbo.AGREEMENT_ASSET_AMORTIZATION where AGREEMENT_NO = @agreement_no

		--insert mtn log data
		begin
			insert into dbo.MTN_DATA_DSF_LOG
			(
				MAINTENANCE_NAME
				,REMARK
				,TABEL_UTAMA
				,REFF_1
				,REFF_2
				,REFF_3
				,CRE_DATE
				,CRE_BY
			)
			values
			(	'MAINTENANCE CHANGE DUEDATE DAN BILLING DATE'
				,@p_remark
				,'INVOICE'
				,@agreement_no
				,null	-- REFF_2 - nvarchar(50)
				,null				-- REFF_3 - nvarchar(50)
				,@mod_date
				,@p_mod_by
			);
		end;

		if @@error = 0
		begin
			select	'SUCCESS';
			commit transaction;
		end;
		else
		begin
			select	'GAGAL';
			rollback transaction;
		end;
	end try
	begin catch

		rollback transaction;

		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg;
		end;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message();
			end;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message();
			end;
		end;

		raiserror(@msg, 16, -1);

		return;
	end catch;
end;
