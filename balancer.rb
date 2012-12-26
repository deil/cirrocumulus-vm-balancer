require 'bundler/setup'
require 'cirrocumulus'
require_relative 'vm_balancer_ontology'

agent = Cirrocumulus::Environment.new(`hostname`.chomp)
agent.load_ontology(VmBalancerOntology.new(Agent.network('balancer')))
agent.run

gets
agent.join
