--created, arif at 25-01-2023

CREATE PROCEDURE dbo.xsp_rpt_maturity
(
	@p_code			   nvarchar(50) --maturity_code
	,@p_user_id		   nvarchar(50)
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(50)
	,@p_cre_ip_address nvarchar(50)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(50)
	,@p_mod_ip_address nvarchar(50)
)
as
begin
	declare @msg			 nvarchar(max)
			,@report_company nvarchar(250)
			,@report_title	 nvarchar(250) = 'PERMOHONAN PENARIKAN BARANG'
			,@report_image	 nvarchar(250)
			,@invoice_no	 nvarchar(50)
			,@count			 nvarchar(50)
			,@terbilang		 nvarchar(4000)
			,@fa_code		 nvarchar(50)
			,@color			 nvarchar(50)
			,@phone			 nvarchar(50)
			,@min			 nvarchar(50)
			,@max			 nvarchar(50)
			,@agreemen_no	 nvarchar(50)
			,@asset_no		 nvarchar(50) ;

	delete dbo.rpt_maturity
	where	user_id = @p_user_id ;

	delete dbo.rpt_maturity_detail
	where	user_id = @p_user_id ;

	select	@report_company = value
	from	dbo.sys_global_param
	where	code = 'COMP' ;

	select	@report_image = value
	from	dbo.sys_global_param
	where	code = 'IMGDSF' ;

	select	@agreemen_no = AGREEMENT_NO
	from	dbo.MATURITY
	where	CODE = @p_code ;

	select	@asset_no = asset_no
	from	dbo.agreement_asset
	where	agreement_no = @agreemen_no ;

	set @count =
	(
		select	count(asset_no)
		from	dbo.maturity_detail
		where	maturity_code = @p_code
				and RESULT	  = 'STOP'
	) ;

	begin try
		insert into dbo.rpt_maturity
		(
			user_id
			,report_company
			,report_title
			,report_image
			,agreement_no
			,fa_code
			,fa_name
			,client_name
			,from_date
			,to_date
			,color
			,engine_no
			,chasis_no
			,plat_no
			,pickup_date
			,count_asset
			,terbilang_count_asset
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,am.agreement_external_no
				,aas.fa_code
				,fa_name
				,am.client_name
				,(
					 select max(due_date)
					 from	dbo.agreement_asset_amortization
					 where	asset_no = @asset_no
				 )
				,(
					 select min(due_date)
					 from	dbo.agreement_asset_amortization
					 where	asset_no = @asset_no
				 )
				,isnull(vh.colour, isnull(el.colour, isnull(he.colour, mh.colour))) 'color'
				,isnull(aas.replacement_fa_reff_no_02,aas.fa_reff_no_02)
				,isnull(aas.replacement_fa_reff_no_03,aas.fa_reff_no_03)
				,isnull(aas.replacement_fa_reff_no_01,aas.fa_reff_no_01)
				,md.pickup_date
				,@count
				,dbo.terbilang(@count)
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.maturity_detail md
				inner join agreement_asset aas on (md.ASSET_NO				= aas.ASSET_NO)
				left join dbo.agreement_asset_vehicle vh on (vh.asset_no	= aas.asset_no)
				left join dbo.agreement_asset_electronic el on (el.asset_no = aas.asset_no)
				left join dbo.agreement_asset_he he on (he.asset_no			= aas.asset_no)
				left join dbo.agreement_asset_machine mh on (mh.asset_no	= aas.asset_no)
				inner join dbo.agreement_main am on (am.agreement_no		= aas.agreement_no)
		where	md.maturity_code = @p_code
				and result		 = 'STOP' ;

		insert into dbo.rpt_maturity_detail
		(
			user_id
			,report_company
			,report_title
			,report_image
			,fa_code
			,deliver_to_name
			,deliver_to_phone
			,deliver_to_address
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select		@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,string_agg(fa_code, ',')
					,aas.deliver_to_name
					,aas.deliver_to_area_no + aas.deliver_to_phone_no
					,aas.deliver_to_address
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
		from		agreement_asset aas
					inner join dbo.maturity_detail md on (md.asset_no = aas.asset_no)
		where		md.maturity_code = @p_code
					and result		 = 'STOP'
		group by	deliver_to_name
					,deliver_to_area_no + deliver_to_phone_no
					,deliver_to_address ;
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
			set @msg = 'v' + ';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%v;%'
				   or	error_message() like '%e;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'e;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
