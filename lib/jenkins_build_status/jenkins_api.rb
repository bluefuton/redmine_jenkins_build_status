module RedmineJenkinsBuildStatus
  class JenkinsApi
    # Returns an array of information about current build status
    def get_build_status_for_project(project_identifier)
      jenkins_config = self.get_config
      jenkins_api_url = jenkins_config['api_url']

      resp = Net::HTTP.get_response(URI.parse(jenkins_api_url))
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
        when 'disabled'
          job_status = 'disabled'
        else
          job_status = 'failed'
        end

        build_status['status'] = job_status  
      end
      
      build_status
    end
    
    protected
    def get_config
      config_path = "#{RAILS_ROOT}/vendor/plugins/redmine_jenkins_build_status/config/jenkins.yml"
      jenkins_config = YAML.load_file(config_path)[RAILS_ENV]
      
      if jenkins_config.nil?
        raise 'Unable to load Jenkins config. Check that config/jenkins.yml exists.'
      end
      
      jenkins_config
    end
  end
end