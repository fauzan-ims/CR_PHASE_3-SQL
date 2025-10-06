--created by, Bilal at 30/06/2023 

CREATE PROCEDURE dbo.xsp_rpt_monitoring_bpkb
(
	@p_user_id			nvarchar(max)
	,@p_from_date		datetime
	,@p_to_date			datetime
    ,@p_is_condition	nvarchar(1) --(+) Untuk Kondisi Excel Data Only
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin

	delete dbo.rpt_monitoring_bpkb
	where user_id = @p_user_id 

	declare	@msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_image			nvarchar(250)
			,@report_title			nvarchar(250)
			,@agreement_no			nvarchar(50)
		    ,@seq					int
		    ,@customer_name			nvarchar(250)
		    ,@object_leased			nvarchar(250)
		    ,@year					nvarchar(4)
		    ,@chassis_no			nvarchar(50)
		    ,@engine_no				nvarchar(50)
		    ,@plat_no				nvarchar(50)
		    ,@spbpkb_date			datetime
		    ,@spbpkb_no				nvarchar(50)
		    ,@now					datetime
		    ,@aging					int
		    ,@monthly				int
		    ,@dealer				nvarchar(250)
		    ,@no_telp				nvarchar(20)
		    ,@nama_pic				nvarchar(50)
		    ,@bast_spbpkb			datetime
		    ,@created				datetime
			,@system_date			date = cast(dbo.xfn_get_system_date() as date) ;

	begin try

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select @report_company = value
		from dbo.sys_global_param 
		where code = 'COMP2';

		set	@report_title = 'Report Monitoring BPKB';

		insert into dbo.rpt_monitoring_bpkb
		(
		    user_id
		    ,filter_from_date
		    ,filter_to_date
		    ,report_company
		    ,report_title
		    ,report_image
		    ,agreement_no
		    ,seq
		    ,customer_name
		    ,object_leased
		    ,year
		    ,chassis_no
		    ,engine_no
		    ,plat_no
		    ,spbpkb_date
		    ,spbpkb_no
		    ,now
		    ,aging
		    ,monthly
		    ,dealer
		    ,no_telp
		    ,nama_pic
		    ,bast_spbpkb
		    ,created
			,is_condition
			,bpkb_received_date
			,area_bbn
			,bast_date
			--
		    ,cre_date
		    ,cre_by
		    ,cre_ip_address
		    ,mod_date
		    ,mod_by
		    ,mod_ip_address
		)
		
		select	distinct @p_user_id
				,@p_from_date
				,@p_to_date
				,@report_company
				,@report_title
				,@report_image
				,case
					when ass.rental_status='IN USE' then isnull(ass.agreement_external_no,'-')
					else 'UNIT '+ass.status
				end
				,''--,((row_number() over (partition by ass.agreement_no order by  ass.agreement_no) - 1) % 9999) + 1 -- untuk nyari brpa byk asset nya utk masing2 kontrak 
				,case
					when ass.rental_status='IN USE' then isnull(ass.client_name,'-')
					else 'UNIT '+ass.status
				end
				,ass.item_name
				,fam.asset_year 
				,fam.reff_no_2 
				,fam.reff_no_3 
				,fam.reff_no_1 
				,rr.cover_note_date
				,rr.cover_note_no
				,@system_date
				,isnull(datediff(day,ass.purchase_date,@system_date),'0')
				,cast(isnull(cast(datediff(day,ass.purchase_date,@system_date) as decimal(9,6)),'0')/cast(30 as decimal(9,6)) as decimal(9,6))
				,rr.vendor_name--fam.vendor_name
				,rr.vendor_pic_area_phone_no+'-'+rr.vendor_pic_phone_no--fam.vendor_pic_area_phone_no +'-' +fam.vendor_pic_phone_no
				,rr.vendor_pic_name--fam.vendor_pic_name
				,null
				,@system_date
				,@p_is_condition
				,null
				,''--asat.bbn_location_description
				,ass.purchase_date--bast_date.bast_date--asat.handover_bast_date
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	ifinams.dbo.asset ass
				inner join dbo.fixed_asset_main fam on (fam.asset_no =ass.CODE)
				inner join dbo.replacement_request_detail rrd on (rrd.asset_no = fam.ASSET_NO)
				inner join dbo.replacement_request rr on (rr.id = rrd.replacement_request_id)
				--left join dbo.replacement rpl on (rpl.code = rrd.replacement_code)
				--left join dbo.REPLACEMENT_DETAIL rde on (rde.REPLACEMENT_CODE = rpl.CODE)
				left join ifinopl.dbo.agreement_asset asat on (asat.agreement_no = ass.agreement_no)
				--outer apply (
				--	select	grn.receive_date 'bast_date'
				--	from	ifinams.dbo.asset ast
				--			inner join ifinproc.dbo.good_receipt_note grn on grn.purchase_order_code = ast.po_no
				--	where	ast.code = ass.code
				--)bast_date
		where   cast(rr.cover_note_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
				and isnull(rr.cover_note_no,'')<>''
				--and isnull(rde.type,'')<>'REPLACE'
				and rrd.status = 'HOLD'
				and rr.status = 'HOLD';
				--and ass.STATUS <> 'SOLD'

		if not exists (select * from dbo.rpt_monitoring_bpkb where user_id = @p_user_id)
		begin
				insert into dbo.rpt_monitoring_bpkb
				(
				    user_id
				    ,filter_from_date
				    ,filter_to_date
				    ,report_company
				    ,report_title
				    ,report_image
				    ,agreement_no
				    ,seq
				    ,customer_name
				    ,object_leased
				    ,year
				    ,chassis_no
				    ,engine_no
				    ,plat_no
				    ,spbpkb_date
				    ,spbpkb_no
				    ,now
				    ,aging
				    ,monthly
				    ,dealer
				    ,no_telp
				    ,nama_pic
				    ,bast_spbpkb
				    ,created
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
				    ,@p_from_date
				    ,@p_to_date
				    ,@report_company
				    ,@report_title
				    ,@report_image
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
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,@p_is_condition
				    ,@p_cre_date		
					,@p_cre_by			
					,@p_cre_ip_address	
					,@p_mod_date		
					,@p_mod_by									 
					,@p_mod_ip_address	
				 )
		END

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
			end;
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
END
