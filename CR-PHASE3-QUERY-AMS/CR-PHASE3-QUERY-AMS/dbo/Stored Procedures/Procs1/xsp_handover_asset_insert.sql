CREATE PROCEDURE dbo.xsp_handover_asset_insert
(
	@p_code					nvarchar(50)
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_status				nvarchar(10)
	,@p_transaction_date	datetime
	,@p_handover_date		datetime
	,@p_type				nvarchar(50)
	,@p_remark				nvarchar(4000)
	,@p_fa_code				nvarchar(50)
	,@p_handover_from		nvarchar(250)
	,@p_handover_to			nvarchar(250)
	,@p_unit_condition		nvarchar(4000)
	,@p_reff_code			nvarchar(50)
	,@p_reff_name			nvarchar(250)
	,@p_handover_address	nvarchar(250)
	,@p_handover_phone_area nvarchar(250)
	,@p_handover_phone_no	nvarchar(250)
	,@p_process_status		nvarchar(50)
	,@p_plan_date			datetime
    ,@p_km					int
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
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.handover_asset
		(
			code
			,branch_code
			,branch_name
			,status
			,transaction_date
			,handover_date
			,type
			,remark
			,fa_code
			,handover_from
			,handover_to
			,handover_address
			,handover_phone_area
			,handover_phone_no
			,unit_condition
			,reff_code
			,reff_name
			,process_status
			,plan_date
			,km
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@p_branch_code
			,@p_branch_name
			,@p_status
			,@p_transaction_date
			,@p_handover_date
			,@p_type
			,@p_remark
			,@p_fa_code
			,@p_handover_from
			,@p_handover_to
			,@p_handover_address
			,@p_handover_phone_area
			,@p_handover_phone_no
			,@p_unit_condition
			,@p_reff_code
			,@p_reff_name
			,@p_process_status
			,@p_plan_date
			,@p_km
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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
