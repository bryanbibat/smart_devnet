require 'smart_devnet/sms_message'

module SmartDevnet

  class << self

    attr_accessor :path_to_cert, :access_code
    attr_writer :sp_id, :sp_password, :nonce, :created_at, :sp_service_id

    def configure
      yield self
      self
    end

    def headers
      { 'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'Authorization' => 'WSSE realm="SDP",profile="UsernameToken"',
        'X-WSSE' => %{ UsernameToken Username="#{@sp_id}",PasswordDigest="#{@sp_password}",Nonce="#{@nonce}", Created="#{@created_at}"},
        'X-RequestHeader' => %{request TransId="", ServiceId="#{@sp_service_id}"}}
    end

    def send_sms_url
      "https://npwifi.smart.com.ph/1/smsmessaging/outbound/#{@access_code}/requests"
    end

    def send_sms(addresses, message)
      SmartDevnet::SmsMessage.new(addresses, message)
    end

    def sms_delivery_status_url(request_id)
      "#{send_sms_url}/#{request_id}/deliveryInfos"
    end


  end
end
