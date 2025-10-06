
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_rpt_cancel_invoice_insert]
(
	@p_user_id nvarchar(15)
	,@p_branch_code nvarchar(50)
	,@p_branch_name nvarchar(250)
	,@p_from_date datetime 
	,@p_to_date datetime 
	,@p_is_condition nvarchar(1)
)
as
begin
	declare @msg			nvarchar(max)
			,@report_company	nvarchar(250)
			,@report_image		nvarchar(250)
			,@report_title		nvarchar(250);

	delete	dbo.RPT_CANCEL_INVOICE
	WHERE USER_ID = @p_user_id

	begin try

		select	@report_image = VALUE
		from	dbo.SYS_GLOBAL_PARAM
		where CODE = 'IMGDSF';

		select	@report_company = VALUE
		from	dbo.SYS_GLOBAL_PARAM
		where CODE = 'COMP2';

		set @report_title = N'Report Cancel Invoice';

		insert into dbo.RPT_CANCEL_INVOICE
		(
			USER_ID
			,AS_OF_DATE
			,BRANCH_CODE
			,REPORT_COMPANY
			,REPORT_IMAGE
			,REPORT_TITLE
			,BRANCH_NAME
			,IS_CONDITION
			,INVOICE_NO
			,FAKTUR_NO
			,NEW_INVOICE_DATE
			,CANCEL_DATE
			,CLIENT_NO
			,NPWP_NO
			,CLIENT_NAME
			,INVOICE_TYPE
			,DESCRIPTION
			,STATUS
			,RENTAL_AMOUNT
			,TOTAL_PPN_AMOUNT
			,REASON
			,REMARK
			,POSTED_BY
			,CANCEL_BY
		)
		select	distinct
				@p_user_id
				,@p_to_date-- + ' sampai ' + @p_to_date
				,@p_branch_code
				,@report_company
				,@report_image
				,@report_title
				,@p_branch_name
				,@p_is_condition
				,i.INVOICE_EXTERNAL_NO
				,i.FAKTUR_NO
				,cast(i.INVOICE_DATE as date)
				,cast(i.MOD_DATE as date)
				,am.CLIENT_NO
				,i.CLIENT_NPWP
				,i.CLIENT_NAME
				,i.INVOICE_TYPE
				,am.DESCRIPTION
				,case isnull(oicr.INVOICE_NO, '')
					when '' then 'NEW'
					else 'POST'
				end
				,i.total_billing_amount
				,i.total_ppn_amount
				,i.invoice_name
				,oicr.process_reff_name
				,semcp.posting_by
				,ISNULL(sem.cancel_by,semcc.CANCEL_BY_CASHIER)
		from	dbo.invoice i
				outer apply
					(
						select	TOP 1 am.CLIENT_NO
								,am.CLIENT_NAME
								,idee.DESCRIPTION
						from	dbo.INVOICE_DETAIL idee
								inner join dbo.AGREEMENT_MAIN am on am.AGREEMENT_NO = idee.AGREEMENT_NO
						where idee.INVOICE_NO = i.INVOICE_NO
						ORDER BY am.MOD_DATE DESC
					) am
				left join dbo.opl_interface_cashier_received_request oicr on oicr.invoice_no = i.invoice_no 
				outer apply 
					(
						SELECT	sem.NAME 'CANCEL_BY'
						FROM	IFINSYS.dbo.SYS_EMPLOYEE_MAIN sem 
						WHERE	sem.CODE = ISNULL(i.CANCEL_BY,i.MOD_BY)
					)sem
				outer apply 
					(
						SELECT	sem.NAME 'CANCEL_BY_CASHIER'
						FROM	IFINSYS.dbo.SYS_EMPLOYEE_MAIN sem 
								left join ifinfin.dbo.cashier_received_request crr on sem.code = crr.mod_by
						WHERE	crr.invoice_no = i.invoice_no
					)semcc
				OUTER APPLY 
				(
					SELECT	sem.NAME 'POSTING_BY'
					FROM	IFINSYS.dbo.SYS_EMPLOYEE_MAIN sem
					WHERE	sem.CODE = ISNULL(i.POSTING_BY,oicr.CRE_BY)
				)semcp
		where	i.INVOICE_STATUS = 'CANCEL'
		and		cast(i.MOD_DATE as date) BETWEEN cast(@p_from_date as date) AND cast(@p_to_date as date)
		and		i.BRANCH_CODE	= case @p_branch_code
									when 'ALL' then i.BRANCH_CODE
									else @p_branch_code
								end;
	end try
	begin catch
		declare @error int;

		set @error = @@error;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist();
		end;

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
