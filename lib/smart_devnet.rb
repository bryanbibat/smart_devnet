require 'smart_devnet/utils'
require 'smart_devnet/sms_message'
require 'smart_devnet/subscription'

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

    def send_sms(addresses, message, notify_url = nil)
      SmartDevnet::SmsMessage.new(addresses, message, notify_url)
    end

    def sms_delivery_status_url(request_id)
      "https://npwifi.smart.com.ph/1/smsmessaging/outbound/requests/#{request_id}/deliveryInfos"
    end

    def subscribe_url
      "https://npwifi.smart.com.ph/1/smsmessaging/outbound/#{@access_code}/subscriptions"
    end

    def subscribe(filter_criteria, notify_url, notification_format = "XML")
      SmartDevnet::Subscription.new(filter_criteria, notify_url, notification_format)
    end

    def unsubscribe_url(subscription_id)
      "#{subscribe_url}/#{subscription_id}"
    end

    def unsubscribe(subscription_id)
      SmartDevnet::Subscription.new(nil, nil, nil, subscription_id).unsubscribe
    end
  end
end
