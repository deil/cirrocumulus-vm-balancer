require 'bundler/setup'
require 'cirrocumulus'
require 'log4r'
require_relative 'vm_balancer_ontology'

agent_logger = Log4r::Logger.new('agent')
agent_logger.outputters = Log4r::Outputter.stdout

channels_logger = Log4r::Logger.new('channels')
channels_logger.outputters = Log4r::Outputter.stdout

jabber_logger = Log4r::Logger.new('channels::jabber')

ontology_logger = Log4r::Logger.new('ontology')
ontology_logger.outputters = Log4r::Outputter.stdout

run_queue_logger = Log4r::Logger.new('ontology::run_queue')

my_logger = Log4r::Logger.new('ontology::vm_balancer')

JabberChannel::server '172.16.11.4'
JabberChannel::password 'q1w2e3r4'
JabberChannel::conference 'cirrocumulus'

agent = Cirrocumulus::Environment.new(`hostname`.chomp)
agent.load_ontology(VmBalancerOntology.new(Agent.network('balancer')))
agent.run

gets
agent.join
