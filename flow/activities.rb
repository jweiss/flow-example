require_relative 'utils'

# Defines a set of activities for the HelloWorld sample.
class HelloWorldActivity
  extend AWS::Flow::Activities

  # define an activity with the #activity method.
  activity :double, :add_3 do
    {
      version: HelloWorldUtils::VERSION,
      default_task_list: HelloWorldUtils::ACTIVITY_TASKLIST,
      # timeout values are in seconds.
      default_task_schedule_to_start_timeout: 300,
      default_task_start_to_close_timeout: 300
    }
  end

  # This activity will say hello when invoked by the workflow
  def double(n)
    n.to_i * 2
  end

  def add_3 (n)
    n.to_i + 3
  end
end

# Start an ActivityWorker to work on the HelloWorldActivity tasks
HelloWorldUtils.new.activity_worker(HelloWorldActivity).start if $0 == __FILE__