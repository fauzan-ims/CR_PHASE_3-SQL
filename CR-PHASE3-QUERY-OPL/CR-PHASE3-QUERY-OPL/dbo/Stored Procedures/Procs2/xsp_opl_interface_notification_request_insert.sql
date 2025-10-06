CREATE PROCEDURE dbo.xsp_opl_interface_notification_request_insert
(
	@p_id						  bigint = 0 output
	,@p_code					  nvarchar(50)
	,@p_request_status			  nvarchar(250)
	,@p_request_date			  datetime
	,@p_request_sent_date		  datetime
	,@p_header_message			  nvarchar(250)
	,@p_body_message_1			  nvarchar(4000)
	,@p_body_message_2			  nvarchar(4000)
	,@p_body_message_3			  nvarchar(4000)
	,@p_reference_amount_1		  decimal(18, 2)
	,@p_reference_amount_2		  decimal(18, 2)
	,@p_reference_no_1			  nvarchar(50)
	,@p_reference_no_2			  nvarchar(50)
	,@p_reference_name_1		  nvarchar(250)
	,@p_reference_name_2		  nvarchar(250)
	,@p_sender_company_name		  nvarchar(250)
	,@p_sender_address			  nvarchar(4000)
	,@p_sender_position			  nvarchar(250)
	,@p_sender_name				  nvarchar(250)
	,@p_sender_department		  nvarchar(250)
	,@p_recipient_name			  nvarchar(250)
	,@p_email					  nvarchar(250)
	,@p_email_cc				  nvarchar(250)
	,@p_email_bcc				  nvarchar(250)
	,@p_area_phone_no			  nvarchar(4)
	,@p_phone_no				  nvarchar(15)
	,@p_third_party_email		  nvarchar(250)
	,@p_third_party_email_cc	  nvarchar(250)
	,@p_third_party_email_bcc	  nvarchar(250)
	,@p_third_party_area_phone_no nvarchar(4)
	,@p_third_party_phone_no	  nvarchar(15)
	,@p_staff_email				  nvarchar(250)
	,@p_staff_email_cc			  nvarchar(250)
	,@p_staff_email_bcc			  nvarchar(250)
	,@p_staff_area_phone_no		  nvarchar(4)
	,@p_staff_phone_no			  nvarchar(15)
	,@p_media_code				  nvarchar(50)
	,@p_transaction_type_code	  nvarchar(50)
	,@p_module_code				  nvarchar(50)
	--
	,@p_cre_date				  datetime
	,@p_cre_by					  nvarchar(15)
	,@p_cre_ip_address			  nvarchar(15)
	,@p_mod_date				  datetime
	,@p_mod_by					  nvarchar(15)
	,@p_mod_ip_address			  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into opl_interface_notification_request
		(
			code
			,request_status
			,request_date
			,request_sent_date
			,header_message
			,body_message_1
			,body_message_2
			,body_message_3
			,reference_amount_1
			,reference_amount_2
			,reference_no_1
			,reference_no_2
			,reference_name_1
			,reference_name_2
			,sender_company_name
			,sender_address
			,sender_position
			,sender_name
			,sender_department
			,recipient_name
			,email
			,email_cc
			,email_bcc
			,area_phone_no
			,phone_no
			,third_party_email
			,third_party_email_cc
			,third_party_email_bcc
			,third_party_area_phone_no
			,third_party_phone_no
			,staff_email
			,staff_email_cc
			,staff_email_bcc
			,staff_area_phone_no
			,staff_phone_no
			,media_code
			,transaction_type_code
			,module_code
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
			,@p_request_status
			,@p_request_date
			,@p_request_sent_date
			,@p_header_message
			,@p_body_message_1
			,@p_body_message_2
			,@p_body_message_3
			,@p_reference_amount_1
			,@p_reference_amount_2
			,@p_reference_no_1
			,@p_reference_no_2
			,@p_reference_name_1
			,@p_reference_name_2
			,@p_sender_company_name
			,@p_sender_address
			,@p_sender_position
			,@p_sender_name
			,@p_sender_department
			,@p_recipient_name
			,@p_email
			,@p_email_cc
			,@p_email_bcc
			,@p_area_phone_no
			,@p_phone_no
			,@p_third_party_email
			,@p_third_party_email_cc
			,@p_third_party_email_bcc
			,@p_third_party_area_phone_no
			,@p_third_party_phone_no
			,@p_staff_email
			,@p_staff_email_cc
			,@p_staff_email_bcc
			,@p_staff_area_phone_no
			,@p_staff_phone_no
			,@p_media_code
			,@p_transaction_type_code
			,@p_module_code
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

