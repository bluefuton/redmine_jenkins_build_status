module RedmineJenkinsBuildStatus
  module Hooks    
    class ViewProjectsShowRightHook < Redmine::Hook::ViewListener
       def view_projects_show_right(context={ })
         jenkins_api_url = 'http://example.com/api/json'
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