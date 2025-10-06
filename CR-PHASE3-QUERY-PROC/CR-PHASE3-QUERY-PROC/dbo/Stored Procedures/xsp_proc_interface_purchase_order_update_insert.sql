--created by, Rian at 30/05/2023 

CREATE procedure xsp_proc_interface_purchase_order_update_insert
(
	@p_id			   bigint output
	,@p_purchase_code  nvarchar(50)
	,@p_po_code		   nvarchar(50)
	,@p_eta_po_date	   datetime
	,@p_supplier_code  nvarchar(50)
	,@p_supplier_name  nvarchar(250)
	,@p_unit_from	   nvarchar(25)
	,@p_settle_date	   datetime
	,@p_job_status	   nvarchar(10)
	,@p_failed_remarks nvarchar(4000)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.proc_interface_purchase_order_update
		(
			purchase_code
			,po_code
			,eta_po_date
			,supplier_code
			,supplier_name
			,unit_from
			,settle_date
			,job_status
			,failed_remarks
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	
			@p_purchase_code
			,@p_po_code
			,@p_eta_po_date
			,@p_supplier_code
			,@p_supplier_name
			,@p_unit_from
			,@p_settle_date
			,@p_job_status
			,@p_failed_remarks
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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

