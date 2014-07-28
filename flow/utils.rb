require 'aws/decider'

class HelloWorldUtils

  VERSION = "6.0"

  WF_TASKLIST = "workflow_tasklist2"
  ACTIVITY_TASKLIST = "activity_tasklist2"

  def initialize
    swf = AWS::SimpleWorkflow.new
    @domain = swf.domains["flow-test"]
  end

  def activity_worker(klass)
    AWS::Flow::ActivityWorker.new(@domain.client, @domain, ACTIVITY_TASKLIST, klass)
    # Note: on Windows, add { { use_forking: false } } to the preceding line.
  end

  def workflow_worker(klass)
    AWS::Flow::WorkflowWorker.new(@domain.client, @domain, WF_TASKLIST, klass)
  end

  def workflow_client(klass)
    AWS::Flow::workflow_client(@domain.client, @domain) { { from_class: klass.name } }
  end
end
