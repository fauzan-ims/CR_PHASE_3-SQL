CREATE PROCEDURE dbo.xsp_good_receipt_note_detail_checklist_insert
(
	@p_id											bigint = 0 output
	,@p_good_receipt_note_detail_id					int
	,@p_good_receipt_note_detail_object_info_id		int
	,@p_checklist_code								nvarchar(250)
	,@p_checklist_name								nvarchar(250)
	,@p_checklist_status							nvarchar(10)
	,@p_checklist_remark							nvarchar(4000)
	--
	,@p_cre_date									datetime
	,@p_cre_by										nvarchar(15)
	,@p_cre_ip_address								nvarchar(15)
	,@p_mod_date									datetime
	,@p_mod_by										nvarchar(15)
	,@p_mod_ip_address								nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into good_receipt_note_detail_checklist
		(
			good_receipt_note_detail_id
			,good_receipt_note_detail_object_info_id
			,checklist_code
			,checklist_name
			,checklist_status
			,checklist_remark
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
			@p_good_receipt_note_detail_id
			,@p_good_receipt_note_detail_object_info_id
			,@p_checklist_code
			,@p_checklist_name
			,@p_checklist_status
			,@p_checklist_remark
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
