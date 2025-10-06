--created by, Rian at 17/05/2023

CREATE PROCEDURE [dbo].[xsp_application_asset_detail_insert]
(
	@p_id					   bigint output
	,@p_code				   nvarchar(50)
	,@p_asset_no			   nvarchar(50)
	,@p_type				   nvarchar(15)	  = null
	,@p_description			   nvarchar(250)  = null
	,@p_amount				   decimal(18, 2) = 0
	,@p_is_subject_to_purchase nvarchar(1)	  = 'F'
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
		if @p_is_subject_to_purchase = 'T' or @p_is_subject_to_purchase = 'Y'
			set @p_is_subject_to_purchase = '1' ;
		else
			set @p_is_subject_to_purchase = '0' ;

		insert into dbo.APPLICATION_ASSET_DETAIL
		(
			code
			,asset_no
			,type
			,description
			,amount
			,is_subject_to_purchase
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
			@p_code
			,@p_asset_no
			,@p_type
			,@p_description
			,@p_amount
			,@p_is_subject_to_purchase
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
