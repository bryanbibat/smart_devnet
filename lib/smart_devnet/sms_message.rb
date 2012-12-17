require 'httparty'
require 'json'

module SmartDevnet
  class SmsMessage

    attr_accessor :addresses, :message, :request_id
    attr_reader :status, :error

    def initialize(addresses, message)
      if addresses.is_a? Array
        @addresses = addresses
      else
        @addresses = [addresses]
      end
      @message = message

      send_sms
    end

    def error?
      !error.nil?
    end

    def check_status
      @status = check_delivery_status
    end

    private

    def send_sms_body
      { "outboundSMSMessageRequest" => { 
        "address" => addresses.map { |number| "tel:#{number}" }, 
        "senderAddress" => "#{SmartDevnet.access_code}", 
        "outboundSMSTextMessage" => {"message" => "#{message}" }}}.to_json
    end

    def send_sms
      begin
        response = HTTParty.post(
          SmartDevnet.send_sms_url, 
          headers: SmartDevnet.headers, 
          body: send_sms_body,
          ssl_ca_file: SmartDevnet.path_to_cert)

        if response.code == 201
          @request_id = JSON.parse(response.body)["resourceReference"]["resourceURL"].split("/").last
        else
          process_error(response)
        end
      rescue Exception => e
        @error = e.message
      end
      self
    end

    def check_delivery_status
      begin
        response = HTTParty.post(
          SmartDevnet.sms_delivery_status_url(@request_id), 
          headers: SmartDevnet.headers, 
          ssl_ca_file: SmartDevnet.path_to_cert)

        if response.code == 200
          delivery_infos = JSON.parse(response.body)["deliveryInfoList"]["deliveryInfo"]
          return delivery_infos.reduce({}) do |table, info|
            number = info["address"].split(":")[-1]
            table[number] = info["deliveryStatus"]
            table
          end
        else
          process_error(response)
        end
      rescue Exception => e
        @error = e.message
      end
      nil
    end

    def process_error(response)
      if response.body.include? "requestError"
        error_type = response.body.include?("serviceException") ?
          "serviceException" : "policyException"
        exception = JSON.parse(response.body)["requestError"][error_type]
        @error = "#{exception["messageId"]} #{interpolate(exception["text"], exception["variables"])}"
      else
        @error = "#{response.code} #{response.message}"
      end
    end

    def interpolate(text, variables)
      variables = [variables] unless variables.is_a? Array
      str = ""
      while text =~ /%(\d+)/
        str += "#{$`}#{variables[$1.to_i - 1]}"
        text = $'
      end
      str += text
    end

  end
end
