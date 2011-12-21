require 'redmine'
require 'jenkins_build_status_hooks'

Redmine::Plugin.register :redmine_jenkins_build_status do
  name 'Jenkins Build Status'
  author 'Chris Rosser'
  description 'Show Jenkins build status for a project'
  version '0.1'
end
