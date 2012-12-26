require 'bundler/setup'
require 'cirrocumulus'
require_relative 'vm_balancer_ontology'

JabberChannel::server('89.223.109.2')
JabberChannel::conference('cirrocumulus')
JabberChannel::jid_suffix('172.16.11.4')

agent = Cirrocumulus::Environment.new(`hostname`.chomp)
agent.load_ontology(VmBalancerOntology.new(Agent.network('balancer')))
agent.run

gets
agent.join
