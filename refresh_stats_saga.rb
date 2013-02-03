class RefreshStatsSaga < Saga

  STATE_QUERYING_RUNNING_GUESTS = 1
  STATE_WAITING_FOR_STATISTICS = 2

  def start()
    @running_guests = {}

    logger.info "Query running guests"
    query(Agent.remote('c001v3-hypervisor'), [:guests])
    change_state(STATE_QUERYING_RUNNING_GUESTS)
    timeout(10)
  end

  def handle_reply(sender, contents, options = {})
    case @state
      when STATE_QUERYING_RUNNING_GUESTS
        if sender
          if contents[0] == [:guests]
            logger.info "Got reply from #{sender.to_s}"
            @running_guests[sender] = contents[1]
          end
        else
          @running_guests.each do |node, guests|
            logger.info "Querying node #{node.to_s}"

            guests.each do |guest_id|
              query(RemoteIdentifier.new(node.to_s), GuestCpuTime.new(:guest_id => guest_id).to_params)
              query(RemoteIdentifier.new(node.to_s), [:guest, guest_id, :vif, :VIF, :rx, :RX, :tx, :TX])
              query(RemoteIdentifier.new(node.to_s), [:guest, guest_id, :block_device, :DEV, :reads, :RD_REQ, :rd_bytes, :RD_BYTES, :writes, :WR_REQ, :wr_bytes, :WR_BYTES])
            end
          end

          change_state(STATE_WAITING_FOR_STATISTICS)
          timeout(60)
        end

      when STATE_WAITING_FOR_STATISTICS
        if sender
          guest_id = contents[1]

          if contents[2] == :cpu_time
            cpu_time = contents[3]
            @ontology.replace [:guest, guest_id, :cpu_time, :CPU_TIME], cpu_time
          elsif contents[2] == :vif
            idx = contents[3]
            rx = contents[5]
            tx = contents[7]
            @ontology.replace [:guest, guest_id, :vif, idx, :rx, :RX, :tx, :TX], {
                :RX => rx,
                :TX => tx
            }
          elsif contents[3] == :block_device
            dev = contents[3]
            rd_req = contents[5]
            rd_bytes = contents[7]
            wr_req = contents[9]
            wr_bytes = contents[11]
            @ontology.replace [:guest, guest_id, :block_device, dev, :reads, :RD_REQ, :rd_bytes, :RD_BYTES, :writes, :WR_REQ, :wr_bytes, :WR_BYTES], {
                :RD_REQ => rd_req,
                :RD_BYTES => rd_bytes,
                :WR_REQ => wr_req,
                :WR_BYTES => wr_bytes
            }
          end
        else
          @ontology.replace [:statistics, :is, :STATE], :fresh
          finish()
        end
    end
  end

  protected

  def logger
    Log4r::Logger['ontology::vm_balancer']
  end

end
