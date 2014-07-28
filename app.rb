require 'sinatra'
require 'aws-sdk'
require 'json'
require_relative 'flow/utils'

DOMAIN = AWS::SimpleWorkflow.new.domains['flow-test']

def wf
  DOMAIN.workflow_types['HelloWorldWorkflow.calculate', HelloWorldUtils::VERSION]
end

def get_execution(workflow_id)
  open = DOMAIN.workflow_executions.with_workflow_id(workflow_id).to_a
  closed = DOMAIN.workflow_executions.with_status(:closed).with_workflow_id(workflow_id).to_a
  (open + closed).last
end

post '/start-flow' do
  "#{params[:num]} ok"
  ex = wf.start_execution(
    input: params[:num],
    execution_start_to_close_timeout: 300,
    task_list: HelloWorldUtils::WF_TASKLIST
  )
  "#{ex.workflow_id}"
end

get '/result/:wf_id' do
  workflow_id = params[:wf_id]
  ex = get_execution(workflow_id)
  p ex
  return { status: 'Not Found' }.to_json unless ex

  {
    status: ex.status,
    events: ex.events.map(&:to_h),
    result: (YAML.load(ex.events.reverse_order.first.attributes.result) rescue nil)
  }.to_json
end

get '/' do
  File.read("index.html")
end

get '/all' do
  closed = wf.workflow_executions.to_a(:status => :closed)
  open = wf.workflow_executions.to_a(:status => :open)
  str = "hi, there were #{closed.count} executions, and #{open.count} are still running\n\n"
  str << "<h2>Closed</h2>"
  closed.each do |wfe|
    str << "<p>#{wfe.run_id} #{wfe.events.reverse_order.first.attributes.result rescue '-'}</p>"
  end
  str
end
