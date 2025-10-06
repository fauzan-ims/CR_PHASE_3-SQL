CREATE PROCEDURE dbo.xsp_replacement_detail_insert
(
	@p_id					   bigint = 0 output
	,@p_replacement_code	   nvarchar(50)
	,@p_replacement_request_id bigint
	,@p_type				   nvarchar(10)
	,@p_bpkb_no				   nvarchar(50)
	,@p_bpkb_date			   datetime
	,@p_bpkb_name			   nvarchar(250)
	,@p_bpkb_address		   nvarchar(4000)
	,@p_stnk_name			   nvarchar(250)
	,@p_stnk_exp_date		   datetime
	,@p_stnk_tax_date		   datetime
	,@p_cover_note_no		   nvarchar(50)
	,@p_cover_note_date		   datetime
	,@p_cover_note_exp_date	   datetime
	--
	,@p_cre_date			   datetime
	,@p_cre_by				   nvarchar(15)
	,@p_cre_ip_address		   nvarchar(15)
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into replacement_detail
		(
			replacement_code
			,replacement_request_id
			,type
			,bpkb_no
			,bpkb_date
			,bpkb_name
			,bpkb_address
			,stnk_name
			,stnk_exp_date
			,stnk_tax_date
			,cover_note_no
			,cover_note_date
			,cover_note_exp_date
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_replacement_code
			,@p_replacement_request_id
			,@p_type
			,@p_bpkb_no
			,@p_bpkb_date
			,@p_bpkb_name
			,@p_bpkb_address
			,@p_stnk_name
			,@p_stnk_exp_date
			,@p_stnk_tax_date
			,@p_cover_note_no
			,@p_cover_note_date
			,@p_cover_note_exp_date
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
