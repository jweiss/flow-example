require_relative 'utils'
require_relative 'activities'

class HelloWorldWorkflow
  extend AWS::Flow::Workflows

  workflow :calculate do
    {
      version: HelloWorldUtils::VERSION,
      task_list: HelloWorldUtils::WF_TASKLIST,
      execution_start_to_close_timeout: 3600,
    }
  end

  activity_client(:client) { { from_class: "HelloWorldActivity" } }

  def calculate(input)
    n = input.to_i
    val = client.double(client.add_3(n))
    # puts "Calculated #{n} as #{val}"
    val
  end
end

if $0 == __FILE__
  HelloWorldUtils.new.workflow_worker(HelloWorldWorkflow).start
  loop do
    # puts "Running once..."
    HelloWorldUtils.new.workflow_worker(HelloWorldWorkflow).run_once
    # puts "Done!"
    gets
  end
end
