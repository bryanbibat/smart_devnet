require 'httparty'
require 'json'

module SmartDevnet
  class Subscription

    attr_accessor :filter_criteria, :notify_url, :notification_format, :subscription_id
    attr_reader :error

    def initialize(filter_criteria, notify_url, notification_format = "XML", subscription_id = nil)
      @filter_criteria = filter_criteria
      @notify_url = notify_url
      @notification_format = notification_format
      @subscription_id = subscription_id

      subscribe if subscription_id.nil?
    end

    def unsubscribe
      begin
        response = HTTParty.delete(
          SmartDevnet.unsubscribe_url(subscription_id), 
          headers: SmartDevnet.headers, 
          ssl_ca_file: SmartDevnet.path_to_cert)

        unless response.code == 200
          @error = SmartDevnet::Utils.process_error(response)
        end
      rescue Exception => e
        @error = e.message
      end
      self
    end

    def error?
      !error.nil?
    end

    private

    def subscribe_body
      { "deliveryReceiptSubscription" => { 
        "callbackReference" => { "notifyURL" => notify_url,
           "notificationFormat" => notification_format }, 
        "filterCriteria" => filter_criteria }}.to_json
    end

    def subscribe
      begin
        response = HTTParty.post(
          SmartDevnet.subscribe_url, 
          headers: SmartDevnet.headers, 
          body: subscribe_body,
          ssl_ca_file: SmartDevnet.path_to_cert)

        if response.code == 201
          @subscription_id = JSON.parse(response.body)["deliveryReceiptSubscription"]["resourceURL"].split("/").last
        else
          @error = SmartDevnet::Utils.process_error(response)
        end
      rescue Exception => e
        @error = e.message
      end
      self
    end

  end
end
