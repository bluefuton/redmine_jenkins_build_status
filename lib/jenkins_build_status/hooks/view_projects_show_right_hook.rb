module RedmineJenkinsBuildStatus
  module Hooks    
    class ViewProjectsShowRightHook < Redmine::Hook::ViewListener
       def view_projects_show_right(context={ })
         jenkins_api = JenkinsApi.new
         build_status = jenkins_api.get_build_status_for_project(context[:project].identifier)
         
         unless build_status.nil?
           context[:controller].send(:render_to_string, {
             :partial => 'boxes/build_status',
             :locals => { :project => context[:project], 
                          :build_status => build_status
                        }
           })
         end
       end
    end
  end
end