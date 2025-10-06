--created by, Bilal at 04/07/2023 

CREATE PROCEDURE dbo.xsp_rpt_monitoring
(
	@p_user_id				nvarchar(max)
	,@p_asset_no			nvarchar(50)
	,@p_document_type		NVARCHAR(50)
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

	delete dbo.rpt_monitoring
	where user_id = @p_user_id 

	declare	@msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_image			nvarchar(250)
			,@report_title			nvarchar(250)
			,@branch_name			nvarchar(250)
		    ,@asset_no				nvarchar(50)
		    ,@asset_desc			nvarchar(250)
		    ,@plat_no				nvarchar(10)
		    ,@chassis_no			nvarchar(50)
		    ,@engine_no				nvarchar(50)
		    ,@document_type			nvarchar(50)
		    ,@document_exp_date		datetime
		    ,@rental_status			nvarchar(50)
		    ,@aging_days			int

	begin try

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set	@report_title = 'Report Status Pengajuan Biro Jasa'

		insert into dbo.rpt_monitoring
		(
		    user_id
		    ,filter_asset_no
		    ,report_company
		    ,report_title
		    ,report_image
		    ,branch_name
		    ,asset_no
		    ,asset_desc
		    ,plat_no
		    ,chassis_no
		    ,engine_no
		    ,document_type
		    ,document_exp_date
		    ,rental_status
		    ,aging_days
			--
		    ,cre_date
		    ,cre_by
		    ,cre_ip_address
		    ,mod_date
		    ,mod_by
		    ,mod_ip_address
		)
		
		SELECT	@p_user_id
		    ,@p_asset_no
		    ,@report_company
		    ,@report_title
		    ,@report_image
		    ,aa.branch_name 
		    ,aa.CODE
		    ,aa.item_name
		    ,av.plat_no
		    ,av.chassis_no
		    ,av.engine_no 
		    ,@p_document_type
		    ,CASE WHEN @p_document_type ='STNK' THEN av.stnk_expired_date ELSE av.KEUR_EXPIRED_DATE END 
		    ,aa.rental_status
		    ,CASE WHEN @p_document_type ='STNK' THEN ISNULL(datediff(day,av.stnk_expired_date,(dbo.xfn_get_system_date())),0) ELSE ISNULL(datediff(day,av.KEUR_EXPIRED_DATE,(dbo.xfn_get_system_date())),0)  end
			--
		    ,@p_cre_date		
			,@p_cre_by			
			,@p_cre_ip_address	
			,@p_mod_date		
			,@p_mod_by			
			,@p_mod_ip_address
		from dbo.asset aa 
			inner join dbo.asset_vehicle av on (av.asset_code = aa.code)
		where  aa.code not in ( 
									select	rm.fa_code from dbo.register_main rm 
									where	rm.register_status not in ('paid','cancel')
								)
		and aa.status not in ('sold','disposed')
		AND		aa.CODE = @p_asset_no


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
