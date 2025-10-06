CREATE PROCEDURE dbo.xsp_replacement_request_insert
(
	@p_id						 bigint		   output
	,@p_branch_code				 nvarchar(50)
	,@p_branch_name				 nvarchar(250)
	,@p_cover_note_no			 nvarchar(50)
	,@p_cover_note_date			 datetime
	,@p_cover_note_exp_date		 datetime
	,@p_vendor_code				 nvarchar(50)
	,@p_vendor_name				 nvarchar(250)
	,@p_vendor_address			 nvarchar(4000)
	,@p_vendor_pic_name			 nvarchar(250)
	,@p_vendor_pic_area_phone_no nvarchar(4)
	,@p_vendor_pic_phone_no		 nvarchar(15)
	,@p_document_name			 nvarchar(50)
	,@p_count_asset				 int		   = 0
	,@p_received_asset			 int		   = 0
	,@p_extend_count			 int		   = 0
	,@p_file_name				 nvarchar(250) = null
	,@p_paths					 nvarchar(250) = null
	,@p_status					 nvarchar(10)
	,@p_remarks					 nvarchar(500) = null
	,@p_replacement_code		 nvarchar(50)  = null
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.replacement_request
		(
			branch_code
			,branch_name
			,cover_note_no
			,cover_note_date
			,cover_note_exp_date
			,vendor_code
			,vendor_name
			,vendor_address
			,vendor_pic_name
			,vendor_pic_area_phone_no
			,vendor_pic_phone_no
			,document_name
			,count_asset
			,received_asset
			,extend_count
			,paths
			,file_name
			,status
			,remarks
			,replacement_code
			--
			,cre_by
			,cre_date
			,cre_ip_address
			,mod_by
			,mod_date
			,mod_ip_address
		)
		values
		(	@p_branch_code
			,@p_branch_name
			,@p_cover_note_no
			,@p_cover_note_date
			,@p_cover_note_exp_date
			,@p_vendor_code
			,@p_vendor_name
			,@p_vendor_address
			,@p_vendor_pic_name
			,@p_vendor_pic_area_phone_no
			,@p_vendor_pic_phone_no
			,@p_document_name
			,@p_count_asset
			,@p_received_asset
			,@p_extend_count
			,@p_file_name
			,@p_paths
			,@p_status
			,@p_remarks
			,@p_replacement_code
			--
			,@p_cre_by
			,@p_cre_date
			,@p_cre_ip_address
			,@p_mod_by
			,@p_mod_date
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
