module RedmineJenkinsBuildStatus
  module Hooks    
    class ViewProjectsShowRightHook < Redmine::Hook::ViewListener
       def view_projects_show_right(context={ })
         
         config_path = "#{RAILS_ROOT}/vendor/plugins/redmine_jenkins_build_status/config/jenkins.yml"
         jenkins_config = YAML.load_file(config_path)[RAILS_ENV]
         
         if jenkins_config.nil?
           raise 'Unable to load Jenkins config. Check that config/jenkins.yml exists.'
         end 
         
         jenkins_api_url = jenkins_config['api_url']
         resp = Net::HTTP.get_response(URI.parse(jenkins_api_url))
         data = resp.body
         result = JSON.parse(data)
         jobs = result['jobs']
     
         # Is there a Jenkins job for this project?
         project_job = jobs.detect { |job| job['name'] == context[:project].identifier }
     
         unless project_job.nil?
           # What's the job status?
           case project_job['color']
           when 'blue'
             job_status = 'passed'
           when 'disabled'
             job_status = 'disabled'
           else
             job_status = 'failed'
           end
       
           context[:controller].send(:render_to_string, {
             :partial => 'boxes/build_status',
             :locals => { :project => context[:project], 
                          :job => project_job,
                          :job_status => job_status
                        }
           })
         end
       end
    end
  end
end