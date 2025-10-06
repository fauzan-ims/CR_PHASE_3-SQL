--Created by, Rian at 21/02/2023 

CREATE PROCEDURE [dbo].[xsp_rpt_document_replacement]
(
	@p_user_id		   nvarchar(50)
	,@p_replacement_no nvarchar(50)
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
	declare @msg			 nvarchar(max)
			,@report_company nvarchar(50)
			,@report_title	 nvarchar(50)
			,@report_image	 nvarchar(50) ;

	begin try
		--Delete terlebih dahulu data di tabel report
		delete dbo.rpt_document_replacement
		where	user_id = @p_user_id ;

		--set report company
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		--set report title
		set @report_title = 'DOCUMENT REPLACEMENT' ;

		--set report image
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		--insert data ke tabel report
		insert into dbo.rpt_document_replacement
		(
			user_id
			,report_company
			,report_title
			,report_image
			,replacement_no
			,replacement_date
			,asset_no
			,asset_name
			,document_name
			,type
			,cover_note_no
			,cover_note_date
			,cover_note_exp_date
			,stnk_name
			,stnk_tax_date
			,stnk_exp_date
			,bpkb_no
			,bpkb_name
			,bpkb_date
			,bpkb_address
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	distinct
				@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,@p_replacement_no
				,re.replacement_date
				,isnull(red.asset_no, red.replacement_code)
				--red.plafond_collateral_no
				,case
					when isnull(dm.asset_name,'')='' then '-'
					else dm.asset_name
				end
				,rrq.document_name
				,red.type
				,re.cover_note_no
				,re.cover_note_date
				,re.cover_note_exp_date
				,red.stnk_name
				,red.stnk_tax_date
				,red.stnk_exp_date
				,red.bpkb_no
				,red.bpkb_name
				,red.bpkb_date
				,red.bpkb_address
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.replacement re
				left join dbo.replacement_detail red on (red.replacement_code = re.code)
				left join dbo.replacement_request rrq on (rrq.id			   = red.replacement_request_detail_id) 
				left join dbo.document_main dm on (dm.asset_no = red.asset_no)
		where	re.code = @p_replacement_no ;
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
