CREATE PROCEDURE [dbo].[xsp_ext_client_address_insert]
(
	@p_client_code				nvarchar(50)
	,@p_Addr					nvarchar(4000)	= ''
	,@p_City					nvarchar(250)	= ''
	,@p_Zipcode					nvarchar(50)	= ''
	,@p_MrCustAddrTypeCode		nvarchar(50)	= ''
	,@p_MrBuildingOwnershipCode nvarchar(50)	= ''
	,@p_PhnArea1				nvarchar(4)		= ''
	,@p_Phn1					nvarchar(15)	= ''
	,@p_PhnArea2				nvarchar(4)		= ''
	,@p_Phn2					nvarchar(15)	= ''
	,@p_PhnArea3				nvarchar(4)		= ''
	,@p_Phn3					nvarchar(15)	= ''
	,@p_StayLength				int				= 0
	,@p_AreaCode1				nvarchar(250)	= ''
	,@p_AreaCode2				nvarchar(250)	= ''
	,@p_AreaCode3				nvarchar(5)		= ''
	,@p_AreaCode4				nvarchar(5)		= ''
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
	declare @msg		   nvarchar(max)
			,@year		   nvarchar(2)
			,@month		   nvarchar(2)
			,@code		   nvarchar(50)
			,@is_legal	   nvarchar(1) = N'0'
			,@is_mailing   nvarchar(1) = N'0'
			,@is_residence nvarchar(1) = N'0' ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'OPLCAD'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'CLIENT_ADDRESS'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		if (@p_MrCustAddrTypeCode = 'LEGAL' or @p_MrCustAddrTypeCode = 'COMPANY' or @p_MrCustAddrTypeCode = 'COMPANY_2' or @p_MrCustAddrTypeCode = 'COMPANY_3')
		begin
			set @is_legal = '1'
		end
		if (@p_MrCustAddrTypeCode = 'BIZ' or @p_MrCustAddrTypeCode = 'OTH_BIZ' or @p_MrCustAddrTypeCode = 'RESIDENCE' or @p_MrCustAddrTypeCode = 'RESIDENCE2')
		begin
			set @is_residence = '1'
		end
		if (@p_MrCustAddrTypeCode = 'MAILING')
		begin
			set @is_mailing = '1'
		end

		insert into client_address
		(
			code
			,client_code
			,address
			,province_code
			,province_name
			,city_code
			,city_name
			,zip_code_code
			,zip_code
			,zip_name
			,sub_district
			,village
			,rt
			,rw
			,area_phone_no
			,phone_no
			,is_legal
			,is_collection
			,is_mailing
			,is_residence
			,range_in_km
			,ownership
			,lenght_of_stay
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
			@code
			,@p_client_code
			,@p_Addr
			,''
			,''
			,''
			,@p_City
			,''
			,@p_Zipcode
			,''
			,@p_AreaCode1
			,@p_AreaCode2
			,@p_AreaCode4
			,@p_AreaCode3
			,isnull(@p_PhnArea1, isnull(@p_PhnArea2, @p_PhnArea3))
			,isnull(@p_Phn1, isnull(@p_Phn2, @p_Phn3))
			,@is_legal
			,''
			,@is_mailing
			,@is_residence
			,0
			,case
				 when isnull(@p_MrBuildingOwnershipCode, '') = '' then 'O'
				 else @p_MrBuildingOwnershipCode
			 end
			,@p_StayLength
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
