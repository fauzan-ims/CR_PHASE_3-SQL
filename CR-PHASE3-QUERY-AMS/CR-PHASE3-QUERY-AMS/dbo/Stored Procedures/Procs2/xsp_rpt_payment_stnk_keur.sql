--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_payment_stnk_keur
(
	@p_user_id		 nvarchar(50)
	,@p_as_of_date	 datetime
    ,@p_is_condition nvarchar(1)
)
as
begin

	delete	rpt_payment_stnk_keur
	where	user_id = @p_user_id ;

	declare @msg			 nvarchar(max)
			,@report_company nvarchar(250)
			,@report_title	 nvarchar(250)
			,@report_image	 nvarchar(250)
			,@agreement_no	 nvarchar(50)
			,@client_name	 nvarchar(50)
			,@item_name		 nvarchar(50)
			,@plat_no		 nvarchar(50)
			,@jasa			 decimal(18, 2)
			,@keur			 nvarchar(50)
			,@other			 decimal(18, 2)
			,@pajak_stnk	 decimal(18, 2)
			,@penalty		 decimal(18, 2)
			,@pph			 decimal(18, 2)
			,@total			 decimal(18, 2)
			,@payment_status nvarchar(50)
			,@payment_date	 datetime ;

	begin try
		

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set @report_title = N'Report Payment STNK & Keur' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		begin
			insert into rpt_payment_stnk_keur
			(
				user_id
				,report_company
				,report_title
				,report_image
				,as_of_date
				,agreement_no
				,client_name
				,item_name
				,plat_no
				,jasa
				,keur
				,other
				,pajak_stnk
				,penalty
				,pph
				,total
				,payment_status
				,payment_date
				,is_condition
			)
			select @p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_as_of_date
					,ass.agreement_external_no
					,ass.client_name
					,ass.item_name
					,avh.plat_no
					,rm.realization_service_fee
					,case when rm.register_remarks like'%KEUR%' then rm.realization_actual_fee else null end
					,0
					,case when rm.register_remarks like'%STNK%' then rm.realization_actual_fee else null end
					,0
					,(rm.realization_service_tax_pph_pct / 100) * rm.realization_service_fee
					,rm.public_service_settlement_amount
					,rm.payment_status
					,rm.realization_date
					,@p_is_condition
			from dbo.asset ass
			left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
			left join dbo.register_main rm on (rm.fa_code = ass.code)
			where purchase_date <= @p_as_of_date
			and rm.payment_status = 'PAID'


			--select	@p_user_id
			--		,@report_company
			--		,@report_title
			--		,@report_image
			--		,@p_as_of_date
			--		--
			--		,agm.agreement_no
			--		,agm.client_name
			--		,ast.item_name
			--		,vhc.plat_no
			--		,isnull(jasa.jasa_fee, 0)	--@jasa				
			--		,@keur
			--		,@other
			--		,@pajak_stnk
			--		,@penalty
			--		,@pph
			--		,@total
			--		,@payment_status
			--		,@payment_date
			--from	dbo.work_order						 wor with (nolock)
			--		inner join dbo.maintenance			 mnt with (nolock) on (mnt.code = wor.maintenance_code)
			--		inner join dbo.asset				 ast with (nolock) on (ast.code = mnt.asset_code)
			--		inner join dbo.asset_vehicle		 vhc with (nolock) on (vhc.asset_code = ast.code)
			--		left join ifinopl.dbo.agreement_main agm with (nolock) on (agm.agreement_no = ast.agreement_no)
			--		outer apply
			--(
			--	select		wod3.work_order_code
			--				,sum(wod3.total_amount) 'jasa_fee'
			--	from		dbo.work_order_detail wod3 with (nolock)
			--	where		wod3.service_type		 = 'JASA'
			--				and wod3.work_order_code = wor.code
			--	group by	wod3.work_order_code
			--)											 jasa ;
		end ;

		select	agreement_no	'Agreement No'
				,client_name	'Client Name'
				,item_name		'Item Name'
				,plat_no		'Plat No'
				,jasa			'Jasa'
				,keur			'KEUR'
				,other			'Other'
				,pajak_stnk		'Pajak STNK'
				,penalty		'Penalty'
				,pph			'PPH'
				,total			'Total'
				,payment_status 'Payment Status'
				,payment_date	'Payment Date'
		from	dbo.rpt_payment_stnk_keur with (nolock)
		where	user_id = @p_user_id ;

		if not exists (select * from dbo.rpt_payment_stnk_keur where user_id = @p_user_id)
		begin
				insert into dbo.rpt_payment_stnk_keur
				(
				    user_id
				    ,report_company
				    ,report_title
				    ,report_image
				    ,as_of_date
				    ,agreement_no
				    ,client_name
				    ,item_name
				    ,plat_no
				    ,jasa
				    ,keur
				    ,other
				    ,pajak_stnk
				    ,penalty
				    ,pph
				    ,total
				    ,payment_status
				    ,payment_date
				    ,is_condition
				)
				values
				(   
					@p_user_id
				    ,@report_company
				    ,@report_title
				    ,@report_image
				    ,@p_as_of_date
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,@p_is_condition
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
