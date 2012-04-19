module RedmineJenkinsBuildStatus
  module Hooks    
    class ViewProjectsShowLeftHook < Redmine::Hook::ViewListener
       def view_projects_show_left(context={ })
         jenkins_api = JenkinsApi.new
         build_status = jenkins_api.get_build_status_for_project(context[:project].identifier)

         unless build_status.nil?
           context[:controller].send(:render_to_string, {
             :partial => 'boxes/build_status',
             :locals => { :project => context[:project], 
                          :build_status => build_status,
                          :change_default_hook_position => jenkins_api.change_default_hook_position?
                        }
           })
         end
       end
    end
  end
end