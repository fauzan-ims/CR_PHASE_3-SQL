--created by, Rian at 22/06/2023 

CREATE PROCEDURE dbo.xsp_rpt_pending_document
(
	@p_user_id				nvarchar(50)
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(50)
	,@p_marketing_code		nvarchar(50)
	,@p_marketing_name		nvarchar(250)
	,@p_as_of_date			datetime
    ,@p_is_condition		nvarchar(1)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin

	declare @temp table
	(
		application_no nvarchar(50)
	) ;

	insert into @temp
	(
		application_no
	)
	select	distinct application_no
	from	dbo.realization
	where	isnull(agreement_no, '') <> '';

	delete	dbo.rpt_pending_document
	where user_id	= @p_user_id

	delete	dbo.rpt_pending_document_detail
	where user_id	= @p_user_id

	declare	@msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_title			nvarchar(250)
			,@report_image			nvarchar(250)
			,@team					nvarchar(250)
			,@pic_mkt				nvarchar(250)
			,@customer_code			nvarchar(50)
			,@customer_name			nvarchar(250)
			,@no_kontrak_induk		nvarchar(50)
			,@target_date			datetime
			,@aging_date			int
			,@kontrak_pelaksana		nvarchar(50)
			,@estimate_target_date	datetime
			,@remark				nvarchar(4000)
			,@branch_name			nvarchar(250)
			,@marketing_name		nvarchar(250)
			,@system_date			date = cast(dbo.xfn_get_system_date() as date) ;

	begin try

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	code = 'IMGDSF' ;

		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set	@report_title = 'Report Pending Document'

		insert into dbo.rpt_pending_document
		(
			user_id
			,branch_code
			,as_of_date
			,report_company
			,report_title
			,report_image
			,team
			,pic_mkt
			,customer_code
			,customer_name
			,no_kontrak_induk
			,target_date
			,aging_date
			,branch_name
			,marketing_name
			,is_condition
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@p_branch_code
				,@p_as_of_date
				,@report_company
				,@report_title
				,@report_image
				,sem.name
				,am.marketing_name
				,am.client_code
				,am.client_name
				,ae.main_contract_no
				,am.golive_date
				,datediff(day,am.golive_date,@system_date)
				,am.branch_name
				,@marketing_name
				,@p_is_condition
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.application_main am
				inner join dbo.application_extention ae on (ae.application_no = am.application_no)
				left join ifinsys.dbo.sys_employee_main sem on (sem.code = am.marketing_code)
		where	am.application_status in ('GO LIVE', 'APPROVE')
		and		am.level_status	in ('ALLOCATION', 'REALIZATION', 'GO LIVE')
		and		sem.code = @p_marketing_code
		and		am.branch_code = case @p_branch_code
									when 'ALL' then am.branch_code
									else @p_branch_code
								end	
		and		cast(am.golive_date as date) <= cast(@p_as_of_date as date)
		and		am.application_no not in	(
												select	application_no
												from	@temp
											);

		insert into dbo.rpt_pending_document_detail
		(
			user_id
			,as_of_date
			,team
			,pic_mkt
			,customer_code
			,customer_name
			,kontrak_pelaksana
			,estimate_target_date
			,aging_date
			,remark
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		 select	@p_user_id
				,rz.date
				,sem.name
				,am.marketing_name
				,am.client_code
				,am.client_name
				,rz.agreement_external_no
				,rz.date
				,datediff(DAY,rz.date,@system_date)
				,rz.remark
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.realization rz
				left join dbo.application_main am on (am.application_no = rz.application_no)
				left join dbo.application_extention ae on (ae.application_no = rz.application_no)
				left join ifinsys.dbo.sys_employee_main sem on (sem.code = am.marketing_code)
		where	rz.status in ('ON PROCESS','VERIFICATION')
		and		sem.CODE = @p_marketing_code
		and		am.branch_code = case @p_branch_code
									when 'ALL' then am.branch_code
									else @p_branch_code
								end	
		and		cast(am.golive_date as date) <= cast(@p_as_of_date as date)

		if not exists (select 1 from dbo.rpt_pending_document where user_id = @p_user_id)
		begin
				insert into dbo.rpt_pending_document
				(
				    user_id
				    ,branch_code
				    ,as_of_date
				    ,report_company
				    ,report_title
				    ,report_image
				    ,team
				    ,pic_mkt
				    ,customer_code
				    ,customer_name
				    ,no_kontrak_induk
				    ,target_date
				    ,aging_date
				    ,branch_name
				    ,marketing_name
				    ,is_condition
				    ,cre_date
				    ,cre_by
				    ,cre_ip_address
				    ,mod_date
				    ,mod_by
				    ,mod_ip_address
				)
				values
				(   
					@p_user_id
				    ,@p_branch_code
				    ,@p_as_of_date
				    ,@report_company
					,@report_title
					,@report_image
				    ,''
				    ,''
				    ,''
				    ,''
				    ,''
				    ,null
				    ,null
				    ,@p_branch_name
				    ,@p_marketing_name
				    ,@p_is_condition
				    ,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				)
		end
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
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
END
