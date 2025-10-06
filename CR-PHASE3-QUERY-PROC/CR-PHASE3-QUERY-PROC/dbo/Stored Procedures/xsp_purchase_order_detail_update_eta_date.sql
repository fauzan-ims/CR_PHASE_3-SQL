CREATE PROCEDURE [dbo].[xsp_purchase_order_detail_update_eta_date]
(
	 @p_id					bigint
	 ,@p_eta_date			datetime
	 ,@p_eta_date_remark	nvarchar(4000) = null
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@old_eta_date	datetime
			,@reff_no		nvarchar(50)
			,@eta_date		datetime
			,@supplier_code	nvarchar(50)
			,@supplier_name	nvarchar(250)
			,@unit_from		nvarchar(25)
			,@id			bigint
			,@system_date	datetime
			,@po_code		nvarchar(50)
			
	begin try

		select	@old_eta_date = cast(eta_date as date)
		from	dbo.purchase_order_detail
		where	id = @p_id ;

		update	dbo.purchase_order_detail
		set		eta_date				= @p_eta_date
				,eta_date_remark		= @p_eta_date_remark
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id 

		if	(@old_eta_date <> cast(@p_eta_date as date))
		begin
			select	@reff_no			= isnull(pr.reff_no, pr2.reff_no)
					,@eta_date			= pod.eta_date
					,@supplier_code		= isnull(qrd.supplier_code, ssd.supplier_code)
					,@supplier_name		= isnull(qrd.supplier_name, ssd.supplier_name)
					,@unit_from			= isnull(prc.unit_from, prc2.unit_from)
					,@po_code			= pod.po_code
			from	dbo.purchase_order_detail pod 
					left join dbo.supplier_selection_detail ssd on (ssd.id											 = pod.supplier_selection_detail_id)
					left join dbo.quotation_review_detail qrd on (qrd.id											 = ssd.quotation_detail_id)
					left join dbo.procurement prc on (prc.code collate Latin1_General_CI_AS							 = qrd.reff_no)
					left join dbo.procurement prc2 on (prc2.code													 = ssd.reff_no)
					left join dbo.procurement_request pr on (pr.code												 = prc.procurement_request_code)
					left join dbo.procurement_request pr2 on (pr2.code												 = prc2.procurement_request_code)
			where	pod.id = @p_id

			if (isnull(@reff_no, '') <> '')
			begin
				set	@system_date = dbo.xfn_get_system_date()

				exec dbo.xsp_proc_interface_purchase_order_update_insert @p_id				= @id output
																		,@p_purchase_code	= @reff_no
																		,@p_po_code			= @po_code
																		,@p_eta_po_date		= @eta_date
																		,@p_supplier_code	= @supplier_code
																		,@p_supplier_name	= @supplier_name
																		,@p_unit_from		= @unit_from
																		,@p_settle_date		= @system_date
																		,@p_job_status		= 'HOLD'
																		,@p_failed_remarks	= N''
																		,@p_cre_date		= @p_mod_date
																		,@p_cre_by			= @p_mod_by
																		,@p_cre_ip_address	= @p_mod_ip_address
																		,@p_mod_date		= @p_mod_date
																		,@p_mod_by			= @p_mod_by
																		,@p_mod_ip_address	= @p_mod_ip_address
			end
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
end ;

