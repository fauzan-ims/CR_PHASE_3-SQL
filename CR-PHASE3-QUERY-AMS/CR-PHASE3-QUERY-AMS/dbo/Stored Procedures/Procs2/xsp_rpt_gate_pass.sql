--Created, Aliv at 27-12-2022
CREATE PROCEDURE [dbo].[xsp_rpt_gate_pass]
(
	@p_code				nvarchar(50)
	,@p_user_id			nvarchar(50)
	,@p_cre_date		datetime
)
AS
BEGIN

	delete dbo.rpt_gate_pass
	where	user_id = @p_user_id ;

	delete dbo.rpt_gate_pass
	where	user_id = @p_user_id ;

	declare @msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_title			nvarchar(250)
			,@report_image			nvarchar(250)
			,@year					nvarchar(4)
			,@month					nvarchar(2)
			,@code					nvarchar(50)
			,@user					nvarchar(250) ;

	begin try
    set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
												,@p_branch_code			 = ''
												,@p_sys_document_code	 = ''
												,@p_custom_prefix		 = 'PASS'
												,@p_year				 = @year
												,@p_month				 = @month
												,@p_table_name			 = 'HANDOVER_ASSET'
												,@p_run_number_length	 = 5
												,@p_delimiter			 = '.'
												,@p_run_number_only		 = '0' 
												,@p_specified_column     = 'GATE_PASS_CODE';

		
		select @user = name 
		from ifinsys.dbo.sys_employee_main
		where code = @p_user_id

		update dbo.handover_asset 
		set gate_pass_code = @code 
		where code = @p_code
											
		SELECT	@report_company = VALUE
		FROM	dbo.SYS_GLOBAL_PARAM
		WHERE	CODE = 'COMP2' ;

		SET	@report_title = 'FORM PASS KELUAR KENDARAAN OPL';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		insert into dbo.rpt_gate_pass
		(
			gate_pass_code
			,user_id
			,report_company
			,report_title
			,report_image
			,branch_name
			,plat_no
			,type
			,colour
			,unit_status
			,km_in
			,km_out
			,date_out
			,agreement_no
			,delivery_to
			,kurir
			,requested_by
			,cre_date
		)
		select		top 1
					has.gate_pass_code
					,@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,has.branch_name
					,avh.plat_no
					,ass.item_name
					,avh.colour
					,ass.status
					,case
						 when isnull(ass.last_meter, '') = '' then '0'
						 else ass.last_meter
					 end
					,has.km
					,has.handover_date
					,isnull(ass.agreement_no, '-')
					,has.handover_address
					,has.handover_from
					,@user
					,@p_cre_date
		from		handover_asset has
					left join dbo.asset ass on (has.fa_code			   = ass.code)
					left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
		where		has.code = @p_code
		order by	has.gate_pass_code desc ;
		
	end try
	begin catch
		declare @error int ;

		SET @error = @@error ;

		IF (@error = 2627)
		BEGIN
			SET @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		END ;

		IF (LEN(@msg) <> 0)
		BEGIN
			SET @msg = 'V' + ';' + @msg ;
		END ;
		ELSE
		BEGIN
			SET @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + ERROR_MESSAGE() ;
		END ;

		RAISERROR(@msg, 16, -1) ;

		RETURN ;
	END CATCH ;
END ;

