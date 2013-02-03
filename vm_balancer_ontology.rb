require 'active_support'
require_relative 'refresh_stats_saga'

class Statistics < KnowledgeClass
  klass :statistics
  property :is
end

class GuestCpuTime < KnowledgeClass
  klass :guest
  id :guest_id
  property :cpu_time
end

#
# VM balancer ontology.
#
class VmBalancerOntology < Ontology
  ontology 'vm_balancer'

  rule 'no_statistics', [ Statistics.new(:is => :unknown) ] do |ontology, params|
    ontology.logger.info "Need to gather VM statistics"
    ontology.refresh_statistics
  end

  rule 'statistics_becomes_obsolete', [ Statistics.new(:is => :obsolete) ] do |ontology, params|
    ontology.logger.debug "Statistics becomes obsolete. Reloading"
    ontology.refresh_statistics
  end

  rule 'got_fresh_statistics', [ Statistics.new(:is => :fresh) ] do |ontology, params|
    ontology.logger.info "Statistics is fresh. Working"
    ontology.process_statistics
  end

  rule 'obsolete_statistics', [ Statistics.new(:is => :fresh) ], :for => 120.seconds do |ontology, params|
    ontology.replace Statistics.to_template, :IS => :obsolete
  end

  def restore_state
    assert [:statistics, :is, :unknown]
  end

  def refresh_statistics
    replace [:statistics, :is, :STATE], :refreshing
    create_saga(RefreshStatsSaga).start()
  end

  def process_statistics
    matcher = PatternMatcher.new(@facts.enumerate)
    matches = matcher.find_matches_for_condition([:guest, :GUEST_ID, :cpu_time, :CPU_TIME]).map {|data| data.data}
    matches.each do |fact|
      guest_id = fact[1]
      cpu_time = fact[3]

      vif_stats = matcher.find_matches_for_condition([:guest, guest_id, :vif, :VIF, :rx, :RX, :tx, :TX]).map {|data| data.data}
      vif_stats.each do |vif|
        vif_num = vif[3]
        rx_bytes = vif[5]
        tx_bytes = vif[7]
      end

      block_stats = matcher.find_matches_for_condition([:guest, guest_id, :block_device, :DEV, :reads, :RD_REQ, :rd_bytes, :RD_BYTES, :writes, :WR_REQ, :wr_bytes, :WR_BYTES]).map {|data| data.data}
      block_stats.each do |block|
        block_device = block[3]
        num_reads = block[5]
        bytes_read = block[7]
        num_writes = block[9]
        bytes_written = block[11]
      end
    end
  end

  def logger
    Log4r::Logger['ontology::vm_balancer']
  end

end
