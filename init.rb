require 'redmine'
require 'json'
require 'jenkins_build_status/jenkins_api.rb'
require 'jenkins_build_status/hooks/view_projects_show_left_hook'

Redmine::Plugin.register :redmine_jenkins_build_status do
  name 'Jenkins Build Status'
  author 'Chris Rosser'
  description 'Show Jenkins build status for a project'
  version '0.1'
end
