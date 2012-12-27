require 'active_support'

class Statistics < KnowledgeClass
  klass :statistics
  property :is
end

#
# VM balancer ontology.
#
class VmBalancerOntology < Ontology
  ontology 'vm_balancer'

  rule 'test', [ [:fact1, :FOO], [:fact2, :FOO], [:fact3, :BAR] ] do |ontology, params|
    p params
  end

  rule 'no_statistics', [ Statistics.new(:is => :unknown) ] do |ontology, params|
    ontology.logger.info "Need to gather VM statistics"
    ontology.refresh_statistics
  end

  rule 'statistics_becomes_obsolete', [ Statistics.new(:is => :obsolete) ] do |ontology, params|
    ontology.logger.debug "Statistics becomes obsolete. Reloading"
    ontology.refresh_statistics
  end

  rule 'obsolete_statistics', [ Statistics.new(:is => :fresh) ], :for => 1.minute do |ontology, params|
    ontology.replace Statistics.to_template, :IS => :obsolete
  end

  def restore_state
    logger.info "Restoring state"
    assert [:fact1, 1]
    assert [:fact1, 2]
    assert [:fact2, 1]
    assert [:fact3, 3]

    #assert [:statistics, :is, :unknown]
  end

  def refresh_statistics
    replace [:statistics, :is, :STATE], :refreshing
    sleep 1
    replace [:statistics, :is, :STATE], :fresh
  end

  def logger
    Log4r::Logger['ontology::vm_balancer']
  end

end
