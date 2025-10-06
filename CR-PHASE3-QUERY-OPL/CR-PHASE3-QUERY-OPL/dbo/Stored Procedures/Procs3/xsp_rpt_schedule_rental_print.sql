--created by, Rian at 03/02/2023 

CREATE PROCEDURE dbo.xsp_rpt_schedule_rental_print
(
	@p_user_id		   nvarchar(50)
	,@p_application_no nvarchar(50)
	--
	,@p_cre_date	   DATETIME
	,@p_cre_by		   NVARCHAR(15)
	,@p_cre_ip_address NVARCHAR(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg		   nvarchar(max)
			,@company_name nvarchar(50)
			,@report_title nvarchar(50)
			,@report_image nvarchar(50)

	begin try

		--delete table rpt
		delete dbo.rpt_schedule_rental
		where	user_id = @p_user_id ;

		--set company name
		select	@company_name = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		--set report title
		set @report_title = 'RENTAL SCHEDULE' ;

		--set report image
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		--insert table rpt
		insert into dbo.rpt_schedule_rental
		(
			user_id
			,report_title
			,report_image
			,report_company
			,application_no
			,client_name
			,asset_no
			,asset_name
			,installment_no
			,due_date
			,billing_date
			,billing_amount
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
				,@report_title
				,@report_image
				,@company_name
				,am.application_external_no
				,am.client_name
				,aam.asset_no
				,aas.asset_name
				,aam.installment_no
				,aam.due_date
				,aam.billing_date
				,aam.billing_amount
				,aam.description
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.application_amortization aam
				left join dbo.application_asset aas on (aas.asset_no	 = aam.asset_no)
				left join dbo.application_main am on (am.application_no = aam.application_no)
				left join dbo.client_main cm on (cm.code				 = am.client_code)
		where	aam.application_no = @p_application_no ;
		
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
