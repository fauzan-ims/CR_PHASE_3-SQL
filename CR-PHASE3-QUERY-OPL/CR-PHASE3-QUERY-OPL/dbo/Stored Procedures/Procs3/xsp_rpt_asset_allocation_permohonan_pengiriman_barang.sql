--Created, Rian at 25/01/2023
CREATE PROCEDURE dbo.xsp_rpt_asset_allocation_permohonan_pengiriman_barang
(
	@p_user_id		   nvarchar(50)
	,@p_application_no nvarchar(50)
	,@p_asset_no	   nvarchar(50)
	,@p_count		   int = 0
	,@p_first_data	   int = 0
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(50)
	,@p_cre_ip_address nvarchar(50)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(50)
	,@p_mod_ip_address nvarchar(50)
)
as
begin
	declare @msg						nvarchar(max)
			,@count_asset				int
			,@terbilang_count_asset		nvarchar(250)
			,@asset_no					nvarchar(50)
			,@to_date					datetime
			,@from_date					datetime
			,@report_image				nvarchar(50)
			,@report_title				nvarchar(50)
			,@report_company			nvarchar(50) 
			,@application_externa_no	nvarchar(50);

	begin try


		--set report company
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP' ;

		--set report title
		set @report_title = 'PERMOHONAN PENGIRIMAN BARANG' ;

		--set report image
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGRPT' ;

		--set asset no, count asset
		select		@count_asset = count(ast.asset_no)
		from		dbo.application_asset ast
		where		ast.application_no	= @p_application_no
		and			ast.asset_no		= @p_asset_no

		select	@application_externa_no = application_external_no
		from	dbo.application_main
		where	application_no = @p_application_no

		--set to date and from date
		select	@from_date	= min(due_date)
				,@to_date	= max(due_date)
		from	dbo.application_amortization
		where	asset_no = @asset_no ;

		--set terbilang count asset
		select	@terbilang_count_asset = dbo.Terbilang(@p_count) ;

		--insert to table rpt_asset_allocation_permohonan_pengiriman_barang
		insert into dbo.rpt_asset_allocation_permohonan_pengiriman_barang
		(
			user_id
			,application_no
			,count_asset
			,terbilang_count_asset
			,client_name
			,fa_code
			,fa_name
			,from_date
			,to_date
			,color
			,engine_no
			,chasis_no
			,pickup_date
			,report_image
			,report_title
			,report_company
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@application_externa_no
				,@p_count
				,@terbilang_count_asset
				,aa.deliver_to_name
				,isnull(aa.fa_code, '')
				,isnull(aa.fa_name, '')
				,isnull((select min(due_date) from dbo.application_amortization where asset_no = @p_asset_no), null)
				,isnull((select max(due_date) from dbo.application_amortization where asset_no = @p_asset_no),null)
				,isnull(vh.colour,'')
				,isnull(aa.fa_reff_no_03, '')
				,isnull(aa.fa_reff_no_02, '')
				,isnull(aa.request_delivery_date, '')
				,@report_image
				,@report_title
				,@report_company
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.application_asset aa
				left join dbo.application_asset_vehicle vh on (vh.asset_no	  = aa.asset_no)
				left join dbo.application_asset_electronic el on (el.asset_no = aa.asset_no)
				left join dbo.application_asset_he he on (he.asset_no		  = aa.asset_no)
				left join dbo.application_asset_machine mh on (mh.asset_no	  = aa.asset_no)
		where	application_no	= @p_application_no 
		and		aa.asset_no		= @p_asset_no
		delete  rpt_asset_allocation_permohonan_pengiriman_barang_address where USER_ID = @p_user_id
		--insert to table rpt_asset_allocation_permohonan_pengiriman_barang_address
		insert into dbo.rpt_asset_allocation_permohonan_pengiriman_barang_address
		(
			user_id
			,fa_code
			,deliver_to_name
			,deliver_to_area
			,deliver_to_address
			,deliver_to_phone
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,string_agg(fa_code,',')
				,deliver_to_name
				,deliver_to_area_no
				,deliver_to_address
				,deliver_to_phone_no
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.application_asset
		where	application_no = @p_application_no
		and		fa_code	in (select fa_code from rpt_asset_allocation_permohonan_pengiriman_barang where user_id = @p_user_id)
		group by deliver_to_name
				,deliver_to_area_no
				,deliver_to_address
				,deliver_to_phone_no

		--update data di application asset
		update	dbo.application_asset
		set		is_asset_delivery_request_printed = '1'
		where	asset_no = @p_asset_no

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
end ;
