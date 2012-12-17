require 'json'

module SmartDevnet
  class Utils
    class << self

    def process_error(response)
      if response.body.include? "requestError"
        error_type = response.body.include?("serviceException") ?
          "serviceException" : "policyException"
        exception = JSON.parse(response.body)["requestError"][error_type]
        return "#{exception["messageId"]} #{interpolate(exception["text"], exception["variables"])}"
      else
        return "#{response.code} #{response.message}"
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
end
