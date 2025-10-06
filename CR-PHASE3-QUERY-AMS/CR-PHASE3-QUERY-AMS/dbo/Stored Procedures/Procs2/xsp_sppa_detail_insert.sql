CREATE PROCEDURE [dbo].[xsp_sppa_detail_insert]
(
	@p_id						bigint = 0 output
	,@p_sppa_code				nvarchar(50)
	,@p_sppa_request_code		nvarchar(50)
	,@p_fa_code					nvarchar(50)
	,@p_insured_name			nvarchar(250)
	,@p_object_name				nvarchar(4000)
	,@p_currency_code			nvarchar(3)
	,@p_sum_insured_amount		decimal(18, 2)
	,@p_from_year				int
	,@p_to_year					int
	,@p_result_status			nvarchar(20)
	,@p_result_date				datetime
	,@p_result_total_buy_amount decimal(18, 2)
	,@p_result_policy_no		nvarchar(50)
	,@p_result_reason			nvarchar(4000)
	,@p_accessories				nvarchar(4000)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into sppa_detail
		(
			sppa_code
			,sppa_request_code
			,insured_name
			,object_name
			,currency_code
			,sum_insured_amount
			,from_year
			,to_year
			,result_status
			,result_date
			,result_total_buy_amount
			,result_policy_no
			,result_reason
			,fa_code
			,accessories
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_sppa_code
			,@p_sppa_request_code
			,@p_insured_name
			,@p_object_name
			,@p_currency_code
			,@p_sum_insured_amount
			,@p_from_year
			,@p_to_year
			,upper(@p_result_status)
			,@p_result_date
			,@p_result_total_buy_amount
			,upper(@p_result_policy_no)
			,@p_result_reason
			,@p_fa_code
			,@p_accessories
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
