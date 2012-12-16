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
        exception = JSON.parse(response.body)["requestError"]["serviceException"]
        @error = "#{exception["messageId"]} #{exception["text"]}"
      else
        @error = "#{response.code} #{response.message}"
      end
    end

  end
end
