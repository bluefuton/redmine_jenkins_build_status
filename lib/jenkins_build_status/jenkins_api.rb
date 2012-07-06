module RedmineJenkinsBuildStatus
  class JenkinsApi

    def initialize
      config_path = "#{RAILS_ROOT}/vendor/plugins/redmine_jenkins_build_status/config/jenkins.yml"
      @jenkins_config ||= YAML.load_file(config_path)

      if @jenkins_config.nil?
        raise 'Unable to load Jenkins config. Check that config/jenkins.yml exists.'
      end
    end

    # Returns an array of information about current build status
    def get_build_status_for_project(project_identifier)
      jenkins_config = self.get_config
      jenkins_api_url = jenkins_config['api_url']
      jenkins_api_username = jenkins_config['username']
      jenkins_api_password = jenkins_config['password']

      uri = URI.parse(jenkins_api_url)
      http = Net::HTTP.new(uri.host, uri.port)
      if jenkins_api_url =~ /^https/
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      request = Net::HTTP::Get.new(uri.request_uri)

      if(jenkins_api_username && jenkins_api_password)
        request.basic_auth(jenkins_api_username, jenkins_api_password)
      end
      
      resp = http.request(request)
      data = resp.body
      result = JSON.parse(data)
      jobs = result['jobs']
  
      # Is there a Jenkins job for this project?
      build_status = jobs.detect { |job| job['name'] == project_identifier }
      
      # Jenkins doesn't provide a 'status' key, so we have to infer this from the color
      unless build_status.nil?
        # What's the job status?
        case build_status['color']
        when 'blue'
          job_status = 'passed'
        when 'blue_anime'
          job_status = 'building'
        when 'disabled'
          job_status = 'disabled'
        else
          job_status = 'failed'
        end

        build_status['status'] = job_status  
      end
      
      build_status
    end

    def config_box_position
      self.get_global_config["box_position"]
    end

    protected
    def get_config
      @jenkins_config[RAILS_ENV]
    end

    def get_global_config
      @jenkins_config["config"] || {}
    end
  end
end
