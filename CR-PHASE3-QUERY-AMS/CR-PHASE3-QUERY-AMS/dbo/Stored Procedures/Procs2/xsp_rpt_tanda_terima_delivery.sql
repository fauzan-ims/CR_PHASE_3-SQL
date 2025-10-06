--created by, Bilal at 04/07/2023 

CREATE procedure dbo.xsp_rpt_tanda_terima_delivery
(
	@p_user_id				nvarchar(max)
	,@p_register_no			nvarchar(50)
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

	delete dbo.rpt_tanda_terima_delivery
	where user_id = @p_user_id 

	declare @msg				 nvarchar(max)
			,@report_company	 nvarchar(250)
			,@report_image		 nvarchar(250)
			,@report_title		 nvarchar(250)
			,@dokumen_name		 nvarchar(250)
			,@object_lease		 nvarchar(250)
			,@year				 nvarchar(4)
			,@chassis_no		 nvarchar(50)
			,@engine_no			 nvarchar(50)
			,@police_no			 nvarchar(10)
			,@customer_name		 nvarchar(250)
			,@kota				 nvarchar(50)
			,@date				 datetime
			,@admin_renewal_name nvarchar(250)
			,@spv_name			 nvarchar(250)
			,@kontak_phone_no	 nvarchar(250)
			,@stnk				 nvarchar(4)
			,@keur				 nvarchar(4)
			,@nama_ket			 nvarchar(50);

	begin try

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;
		
		select	@kontak_phone_no = value
		from	dbo.sys_global_param
		where	code = 'KNTKPHNNO' ;
		
		select	@admin_renewal_name = sem.name
		from	ifinsys.dbo.sys_employee_main sem
				left join ifinsys.dbo.sys_user_main sum on sem.code = sum.code
		where	sum.code = @p_user_id ;

		select	top 1
				@stnk = N'STNK'
		from	dbo.register_detail rd
				inner join dbo.sys_general_subcode scd on rd.service_code = scd.code
		where	scd.description like '%STNK%'
				and rd.register_code = @p_register_no ;

		select	top 1
				@keur = N'KEUR'
		from	dbo.register_detail rd
				inner join dbo.sys_general_subcode scd on rd.service_code = scd.code
		where	scd.description like '%KEUR%'
				and rd.register_code = @p_register_no ;

		IF (@keur IS not null and @stnk IS NOT null)
		begin
			SELECT @nama_ket = 'STNK dan KEUR' ;
		END
		ELSE
		BEGIN
			SELECT @nama_ket = isnull(@stnk, @keur) ;
		end

		set	@report_title = 'Pengiriman '+@nama_ket

		if exists(select 1 from dbo.register_main
		where code = @p_register_no and isnull(stnk_no,'') <> '')
		begin
			set @dokumen_name = 'STNK'
		end
		else
		begin
			set @dokumen_name = 'KEUR'
		end

		insert into dbo.rpt_tanda_terima_delivery
		(
		    user_id
		    ,register_no
		    ,report_company
		    ,report_title
		    ,report_image
		    ,dokumen_name
		    ,object_lease
		    ,year
		    ,chassis_no
		    ,engine_no
		    ,police_no
		    ,customer_name
		    ,kota
		    ,date
		    ,admin_renewal_name
			,spv_name
			,kontak_phone_no
			,nama_ket
			--
		    ,cre_date
		    ,cre_by
		    ,cre_ip_address
		    ,mod_date
		    ,mod_by
		    ,mod_ip_address
		)
		select	@p_user_id
				,@p_register_no
				,@report_company
				,@report_title
				,@report_image
				,case 
					when rd.SERVICE_CODE like '%STNK%' or rd.SERVICE_CODE like '%PBSPSTN%' then 'STNK'
					when rd.SERVICE_CODE like '%KEUR%' then 'KEUR'
				end
				,ass.item_name
				,av.built_year
				,av.chassis_no
				,av.engine_no
				,av.plat_no
				--,av.chassis_no
				--,av.engine_no
				--,av.plat_no
				,case
					when ass.rental_status='IN USE' then ass.client_name
					else null
				end
				,'Jakarta'
				,dbo.xfn_get_system_date()
				,@admin_renewal_name
				,''
				,@kontak_phone_no
				,@nama_ket
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.register_main rm
				left join dbo.register_detail rd on (rd.REGISTER_CODE = rm.code and (rd.SERVICE_CODE like '%STNK%' or rd.SERVICE_CODE like '%PBSPSTN%' or rd.SERVICE_CODE like '%KEUR%'))
				left join dbo.asset ass on (ass.code			  = rm.fa_code)
				left join dbo.asset_vehicle av on (av.asset_code  = ass.code)
		where	rm.code = @p_register_no ;

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
